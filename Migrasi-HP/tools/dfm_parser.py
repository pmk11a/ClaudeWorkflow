#!/usr/bin/env python3
"""
DFM Parser - Extract components, fields, and structure from Delphi Form files
Author: Migration Tool
Purpose: Parse Delphi .dfm files to extract UI components and database fields
"""

import re
from typing import Dict, List, Any
from dataclasses import dataclass, field

@dataclass
class DFMComponent:
    """Represents a Delphi component"""
    name: str
    type: str
    properties: Dict[str, Any] = field(default_factory=dict)
    children: List['DFMComponent'] = field(default_factory=list)
    events: Dict[str, str] = field(default_factory=dict)

@dataclass
class DFMField:
    """Represents a database field"""
    name: str
    field_name: str
    caption: str = ""
    data_type: str = ""
    size: int = 0
    width: int = 0
    visible: bool = True
    required: bool = False

class DFMParser:
    """Parser for Delphi DFM files"""
    
    def __init__(self, dfm_file_path: str):
        self.dfm_file_path = dfm_file_path
        self.components = []
        self.fields = []
        self.form_properties = {}
        self.data_source = None
        self.stored_proc = None
        
    def parse(self) -> Dict[str, Any]:
        """Parse the DFM file and extract all information"""
        with open(self.dfm_file_path, 'r', encoding='latin-1') as f:
            content = f.read()
        
        # Extract form properties
        self._extract_form_properties(content)
        
        # Extract components
        self._extract_components(content)
        
        # Extract grid columns (database fields)
        self._extract_grid_columns(content)
        
        # Extract stored procedure info
        self._extract_stored_proc(content)
        
        # Extract toolbar buttons
        self._extract_toolbar_buttons(content)
        
        return {
            'form_name': self.form_properties.get('name', ''),
            'caption': self.form_properties.get('caption', ''),
            'components': self.components,
            'fields': self.fields,
            'data_source': self.data_source,
            'stored_proc': self.stored_proc,
            'form_properties': self.form_properties
        }
    
    def _extract_form_properties(self, content: str):
        """Extract main form properties"""
        # Extract form name
        form_match = re.search(r'object\s+(\w+):\s+T(\w+)', content)
        if form_match:
            self.form_properties['name'] = form_match.group(1)
            self.form_properties['type'] = form_match.group(2)
        
        # Extract caption
        caption_match = re.search(r"Caption\s*=\s*'([^']*)'", content)
        if caption_match:
            self.form_properties['caption'] = caption_match.group(1)
    
    def _extract_components(self, content: str):
        """Extract all components from DFM"""
        # Find all component definitions
        component_pattern = r'object\s+(\w+):\s+T([\w]+)'
        matches = re.finditer(component_pattern, content)
        
        for match in matches:
            comp_name = match.group(1)
            comp_type = match.group(2)
            
            component = DFMComponent(
                name=comp_name,
                type=comp_type
            )
            
            self.components.append(component)
    
    def _extract_grid_columns(self, content: str):
        """Extract database grid columns"""
        # Pattern for grid column definitions
        column_pattern = r'object\s+(dxDBGrid\w+):\s+TdxDBGrid(\w+)Column'
        
        columns = re.finditer(column_pattern, content)
        
        for col_match in columns:
            col_name = col_match.group(1)
            
            # Extract field properties
            field_obj = DFMField(name=col_name, field_name="")
            
            # Find the section for this column
            start_pos = col_match.start()
            end_match = re.search(r'\n\s*end\b', content[start_pos:])
            if end_match:
                section = content[start_pos:start_pos + end_match.start()]
                
                # Extract caption
                caption_match = re.search(r"Caption\s*=\s*'([^']*)'", section)
                if caption_match:
                    field_obj.caption = caption_match.group(1)
                
                # Extract FieldName
                fieldname_match = re.search(r"FieldName\s*=\s*'([^']*)'", section)
                if fieldname_match:
                    field_obj.field_name = fieldname_match.group(1)
                
                # Extract Width
                width_match = re.search(r'Width\s*=\s*(\d+)', section)
                if width_match:
                    field_obj.width = int(width_match.group(1))
                
                # Extract Visible
                visible_match = re.search(r'Visible\s*=\s*(\w+)', section)
                if visible_match:
                    field_obj.visible = visible_match.group(1).lower() == 'true'
                
                if field_obj.field_name:
                    self.fields.append(field_obj)
    
    def _extract_stored_proc(self, content: str):
        """Extract stored procedure information"""
        # Find ADOStoredProc component
        sp_pattern = r'object\s+(\w+):\s+TADOStoredProc'
        sp_match = re.search(sp_pattern, content)
        
        if sp_match:
            sp_name = sp_match.group(1)
            
            # Extract procedure name
            proc_pattern = r"ProcedureName\s*=\s*'([^']*)';"
            proc_match = re.search(proc_pattern, content)
            
            if proc_match:
                proc_name = proc_match.group(1).split(';')[0]
                
                self.stored_proc = {
                    'component_name': sp_name,
                    'procedure_name': proc_name,
                    'parameters': self._extract_sp_parameters(content, sp_match.start())
                }
    
    def _extract_sp_parameters(self, content: str, start_pos: int) -> List[Dict]:
        """Extract stored procedure parameters"""
        params = []
        
        # Find Parameters section
        params_section_match = re.search(r'Parameters\s*=\s*<(.*?)>', content[start_pos:], re.DOTALL)
        
        if params_section_match:
            params_text = params_section_match.group(1)
            
            # Extract individual parameters
            item_pattern = r"item\s+(.*?)end"
            items = re.finditer(item_pattern, params_text, re.DOTALL)
            
            for item in items:
                param_text = item.group(1)
                
                param = {}
                
                # Extract Name
                name_match = re.search(r"Name\s*=\s*'@?([^']*)'", param_text)
                if name_match:
                    param['name'] = name_match.group(1)
                
                # Extract DataType
                dtype_match = re.search(r'DataType\s*=\s*ft(\w+)', param_text)
                if dtype_match:
                    param['data_type'] = dtype_match.group(1)
                
                # Extract Size
                size_match = re.search(r'Size\s*=\s*(\d+)', param_text)
                if size_match:
                    param['size'] = int(size_match.group(1))
                
                if param.get('name'):
                    params.append(param)
        
        return params
    
    def _extract_toolbar_buttons(self, content: str):
        """Extract toolbar buttons and their actions"""
        button_pattern = r'object\s+(ToolButton\d+):\s+TToolButton'
        buttons = re.finditer(button_pattern, content)
        
        toolbar_actions = []
        
        for btn_match in buttons:
            btn_name = btn_match.group(1)
            
            # Find button section
            start_pos = btn_match.start()
            end_match = re.search(r'\n\s*end\b', content[start_pos:])
            
            if end_match:
                section = content[start_pos:start_pos + end_match.start()]
                
                # Extract caption and click event
                caption_match = re.search(r"Caption\s*=\s*'([^']*)'", section)
                onclick_match = re.search(r"OnClick\s*=\s*(\w+)", section)
                
                if caption_match or onclick_match:
                    toolbar_actions.append({
                        'name': btn_name,
                        'caption': caption_match.group(1) if caption_match else '',
                        'onclick': onclick_match.group(1) if onclick_match else ''
                    })
        
        self.form_properties['toolbar_actions'] = toolbar_actions
    
    def get_database_fields(self) -> List[DFMField]:
        """Get list of database fields"""
        return self.fields
    
    def get_visible_fields(self) -> List[DFMField]:
        """Get only visible fields"""
        return [f for f in self.fields if f.visible]
    
    def generate_field_list(self) -> List[str]:
        """Generate list of field names for database queries"""
        return [f.field_name for f in self.fields if f.field_name]

if __name__ == "__main__":
    # Test the parser
    import sys
    if len(sys.argv) > 1:
        parser = DFMParser(sys.argv[1])
        result = parser.parse()
        
        print(f"Form: {result['form_name']}")
        print(f"Caption: {result['caption']}")
        print(f"\nFields found: {len(result['fields'])}")
        
        for field in result['fields'][:10]:  # Show first 10
            print(f"  - {field.field_name} ({field.caption})")
        
        if result['stored_proc']:
            print(f"\nStored Procedure: {result['stored_proc']['procedure_name']}")
            print(f"Parameters: {len(result['stored_proc']['parameters'])}")
