#!/usr/bin/env python3
"""
Enhanced DFM Parser - Extract components, fields, and structure from Delphi Form files
Version: 2.0

Features:
- Detects all common component types (TEdit, TComboBox, TDateTimePicker, etc.)
- Extracts validation properties (MaxLength, MaxValue, MinValue)
- Extracts event handlers (OnClick, OnChange, OnExit, etc.)
- Detects field dependencies and conditional visibility
- Extracts data binding information
- Groups components by panels/containers
"""

import re
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass, field
from enum import Enum


class ComponentCategory(Enum):
    """Component categories for grouping"""
    INPUT = "input"
    DISPLAY = "display"
    CONTAINER = "container"
    DATA = "data"
    ACTION = "action"
    NAVIGATION = "navigation"
    UNKNOWN = "unknown"


@dataclass
class DFMProperty:
    """Represents a component property"""
    name: str
    value: Any
    property_type: str = "string"  # string, integer, boolean, enum, object


@dataclass
class DFMEvent:
    """Represents an event handler"""
    event_name: str  # OnClick, OnChange, etc.
    handler_name: str  # The procedure name
    component_name: str


@dataclass
class DFMComponent:
    """Enhanced component representation"""
    name: str
    component_type: str
    category: ComponentCategory = ComponentCategory.UNKNOWN
    properties: Dict[str, Any] = field(default_factory=dict)
    events: List[DFMEvent] = field(default_factory=list)
    children: List['DFMComponent'] = field(default_factory=list)
    parent: Optional[str] = None
    
    # For input components
    field_name: str = ""
    caption: str = ""
    data_type: str = ""
    max_length: int = 0
    required: bool = False
    read_only: bool = False
    visible: bool = True
    enabled: bool = True
    
    # For data-bound components
    data_source: str = ""
    data_field: str = ""
    
    # Position
    left: int = 0
    top: int = 0
    width: int = 0
    height: int = 0
    tab_order: int = 0


@dataclass
class DFMField:
    """Represents a database/form field"""
    name: str
    field_name: str
    caption: str = ""
    data_type: str = "string"
    size: int = 0
    width: int = 0
    visible: bool = True
    required: bool = False
    read_only: bool = False
    
    # Validation
    max_length: int = 0
    max_value: Optional[float] = None
    min_value: Optional[float] = None
    
    # Input type for Laravel
    input_type: str = "text"  # text, number, date, checkbox, select, textarea
    
    # Data binding
    lookup_table: str = ""
    lookup_field: str = ""
    
    # Component info
    component_name: str = ""
    component_type: str = ""


@dataclass  
class FormLayout:
    """Represents form layout structure"""
    panels: List[Dict[str, Any]] = field(default_factory=list)
    field_groups: Dict[str, List[str]] = field(default_factory=dict)
    tab_pages: List[Dict[str, Any]] = field(default_factory=list)


class EnhancedDFMParser:
    """Enhanced Parser for Delphi DFM files"""
    
    # Component type to category mapping
    COMPONENT_CATEGORIES = {
        # Input components
        'Edit': ComponentCategory.INPUT,
        'LabeledEdit': ComponentCategory.INPUT,
        'MaskEdit': ComponentCategory.INPUT,
        'Memo': ComponentCategory.INPUT,
        'RichEdit': ComponentCategory.INPUT,
        'ComboBox': ComponentCategory.INPUT,
        'DBComboBox': ComponentCategory.INPUT,
        'DBLookupComboBox': ComponentCategory.INPUT,
        'CheckBox': ComponentCategory.INPUT,
        'DBCheckBox': ComponentCategory.INPUT,
        'RadioButton': ComponentCategory.INPUT,
        'RadioGroup': ComponentCategory.INPUT,
        'DateTimePicker': ComponentCategory.INPUT,
        'MonthCalendar': ComponentCategory.INPUT,
        'SpinEdit': ComponentCategory.INPUT,
        'CurrencyEdit': ComponentCategory.INPUT,
        'DBEdit': ComponentCategory.INPUT,
        'DBMemo': ComponentCategory.INPUT,
        'DBImage': ComponentCategory.INPUT,
        'DBRichEdit': ComponentCategory.INPUT,
        'DBDateTimePicker': ComponentCategory.INPUT,
        
        # Display components
        'Label': ComponentCategory.DISPLAY,
        'DBText': ComponentCategory.DISPLAY,
        'StaticText': ComponentCategory.DISPLAY,
        'Image': ComponentCategory.DISPLAY,
        'Shape': ComponentCategory.DISPLAY,
        'Bevel': ComponentCategory.DISPLAY,
        
        # Grid/Table components
        'DBGrid': ComponentCategory.DISPLAY,
        'StringGrid': ComponentCategory.DISPLAY,
        'DrawGrid': ComponentCategory.DISPLAY,
        'dxDBGrid': ComponentCategory.DISPLAY,
        'cxGrid': ComponentCategory.DISPLAY,
        
        # Container components
        'Panel': ComponentCategory.CONTAINER,
        'GroupBox': ComponentCategory.CONTAINER,
        'ScrollBox': ComponentCategory.CONTAINER,
        'PageControl': ComponentCategory.CONTAINER,
        'TabSheet': ComponentCategory.CONTAINER,
        'Splitter': ComponentCategory.CONTAINER,
        'Frame': ComponentCategory.CONTAINER,
        
        # Data components
        'DataSource': ComponentCategory.DATA,
        'ADOConnection': ComponentCategory.DATA,
        'ADOQuery': ComponentCategory.DATA,
        'ADOTable': ComponentCategory.DATA,
        'ADOStoredProc': ComponentCategory.DATA,
        'ADODataSet': ComponentCategory.DATA,
        'ClientDataSet': ComponentCategory.DATA,
        
        # Action components
        'Button': ComponentCategory.ACTION,
        'BitBtn': ComponentCategory.ACTION,
        'SpeedButton': ComponentCategory.ACTION,
        'ToolButton': ComponentCategory.ACTION,
        'ToolBar': ComponentCategory.ACTION,
        'MainMenu': ComponentCategory.ACTION,
        'PopupMenu': ComponentCategory.ACTION,
        'ActionList': ComponentCategory.ACTION,
    }
    
    # Laravel input type mapping
    LARAVEL_INPUT_TYPES = {
        'Edit': 'text',
        'LabeledEdit': 'text',
        'MaskEdit': 'text',
        'Memo': 'textarea',
        'RichEdit': 'textarea',
        'ComboBox': 'select',
        'DBComboBox': 'select',
        'DBLookupComboBox': 'select',
        'CheckBox': 'checkbox',
        'DBCheckBox': 'checkbox',
        'RadioButton': 'radio',
        'RadioGroup': 'radio',
        'DateTimePicker': 'date',
        'MonthCalendar': 'date',
        'SpinEdit': 'number',
        'CurrencyEdit': 'number',
        'DBEdit': 'text',
        'DBMemo': 'textarea',
    }
    
    def __init__(self, dfm_file_path: str):
        self.dfm_file_path = dfm_file_path
        self.content = ""
        
        # Parsed data
        self.form_name = ""
        self.form_type = ""
        self.form_caption = ""
        self.form_properties: Dict[str, Any] = {}
        
        self.components: List[DFMComponent] = []
        self.fields: List[DFMField] = []
        self.events: List[DFMEvent] = []
        self.stored_procs: List[Dict[str, Any]] = []
        self.data_sources: List[Dict[str, Any]] = []
        self.layout: FormLayout = FormLayout()
        
        # Component lookup
        self._component_map: Dict[str, DFMComponent] = {}
        
    def parse(self) -> Dict[str, Any]:
        """Parse the DFM file and extract all information"""
        try:
            with open(self.dfm_file_path, 'r', encoding='latin-1') as f:
                self.content = f.read()
        except Exception:
            with open(self.dfm_file_path, 'r', encoding='utf-8', errors='ignore') as f:
                self.content = f.read()
        
        # Parse in order
        self._extract_form_info()
        self._extract_all_components()
        self._extract_fields_from_components()
        self._extract_data_components()
        self._extract_all_events()
        self._build_component_hierarchy()
        self._analyze_layout()
        
        return self._build_result()
    
    def _extract_form_info(self):
        """Extract main form properties"""
        # Form declaration
        form_match = re.search(r'object\s+(\w+):\s+T(\w+)', self.content)
        if form_match:
            self.form_name = form_match.group(1)
            self.form_type = form_match.group(2)
        
        # Caption
        caption_match = re.search(r"Caption\s*=\s*'([^']*)'", self.content)
        if caption_match:
            self.form_caption = caption_match.group(1)
        
        # Form dimensions
        for prop in ['Width', 'Height', 'Left', 'Top']:
            match = re.search(rf'{prop}\s*=\s*(\d+)', self.content[:1000])
            if match:
                self.form_properties[prop.lower()] = int(match.group(1))
    
    def _extract_all_components(self):
        """Extract all components with their properties"""
        # Pattern for component start
        component_pattern = r'object\s+(\w+):\s+T(\w+)'
        
        for match in re.finditer(component_pattern, self.content):
            comp_name = match.group(1)
            comp_type = match.group(2)
            
            # Skip the main form
            if comp_name == self.form_name:
                continue
            
            # Get component category
            category = self.COMPONENT_CATEGORIES.get(comp_type, ComponentCategory.UNKNOWN)
            
            # Extract component section
            start_pos = match.start()
            section = self._extract_component_section(start_pos)
            
            # Create component
            component = DFMComponent(
                name=comp_name,
                component_type=comp_type,
                category=category
            )
            
            # Extract properties
            self._extract_component_properties(component, section)
            
            # Extract events
            self._extract_component_events(component, section)
            
            self.components.append(component)
            self._component_map[comp_name] = component
    
    def _extract_component_section(self, start_pos: int) -> str:
        """Extract the section for a component (between object and matching end)"""
        depth = 0
        i = start_pos
        
        # Find 'object' keyword
        while i < len(self.content) and self.content[i:i+6].lower() != 'object':
            i += 1
        
        section_start = i
        
        # Count object/end pairs
        while i < len(self.content):
            if self.content[i:i+6].lower() == 'object':
                depth += 1
                i += 6
            elif self.content[i:i+3].lower() == 'end':
                depth -= 1
                if depth == 0:
                    return self.content[section_start:i+3]
                i += 3
            else:
                i += 1
        
        # Return up to 2000 chars if no matching end found
        return self.content[section_start:min(section_start + 2000, len(self.content))]
    
    def _extract_component_properties(self, component: DFMComponent, section: str):
        """Extract properties from component section"""
        # Common properties
        property_patterns = {
            'Caption': (r"Caption\s*=\s*'([^']*)'", str),
            'Text': (r"Text\s*=\s*'([^']*)'", str),
            'FieldName': (r"FieldName\s*=\s*'([^']*)'", str),
            'DataField': (r"DataField\s*=\s*'([^']*)'", str),
            'DataSource': (r"DataSource\s*=\s*(\w+)", str),
            'Left': (r'Left\s*=\s*(\d+)', int),
            'Top': (r'Top\s*=\s*(\d+)', int),
            'Width': (r'Width\s*=\s*(\d+)', int),
            'Height': (r'Height\s*=\s*(\d+)', int),
            'TabOrder': (r'TabOrder\s*=\s*(\d+)', int),
            'MaxLength': (r'MaxLength\s*=\s*(\d+)', int),
            'MaxValue': (r'MaxValue\s*=\s*([\d.]+)', float),
            'MinValue': (r'MinValue\s*=\s*([\d.]+)', float),
            'Visible': (r'Visible\s*=\s*(\w+)', lambda x: x.lower() == 'true'),
            'Enabled': (r'Enabled\s*=\s*(\w+)', lambda x: x.lower() == 'true'),
            'ReadOnly': (r'ReadOnly\s*=\s*(\w+)', lambda x: x.lower() == 'true'),
            'Required': (r'Required\s*=\s*(\w+)', lambda x: x.lower() == 'true'),
            'ParentFont': (r'ParentFont\s*=\s*(\w+)', lambda x: x.lower() == 'true'),
            'CharCase': (r'CharCase\s*=\s*(\w+)', str),
            'EditMask': (r"EditMask\s*=\s*'([^']*)'", str),
            'PasswordChar': (r"PasswordChar\s*=\s*'([^']*)'", str),
        }
        
        for prop_name, (pattern, converter) in property_patterns.items():
            match = re.search(pattern, section)
            if match:
                try:
                    value = converter(match.group(1))
                    component.properties[prop_name] = value
                    
                    # Set specific attributes
                    if prop_name == 'Caption':
                        component.caption = value
                    elif prop_name == 'FieldName':
                        component.field_name = value
                    elif prop_name == 'DataField':
                        component.data_field = value
                    elif prop_name == 'DataSource':
                        component.data_source = value
                    elif prop_name == 'MaxLength':
                        component.max_length = value
                    elif prop_name == 'Left':
                        component.left = value
                    elif prop_name == 'Top':
                        component.top = value
                    elif prop_name == 'Width':
                        component.width = value
                    elif prop_name == 'Height':
                        component.height = value
                    elif prop_name == 'TabOrder':
                        component.tab_order = value
                    elif prop_name == 'Visible':
                        component.visible = value
                    elif prop_name == 'Enabled':
                        component.enabled = value
                    elif prop_name == 'ReadOnly':
                        component.read_only = value
                    elif prop_name == 'Required':
                        component.required = value
                except Exception:
                    pass
        
        # Extract Items (for ComboBox, ListBox, etc.)
        items_match = re.search(r'Items\.Strings\s*=\s*\((.*?)\)', section, re.DOTALL)
        if items_match:
            items_text = items_match.group(1)
            items = re.findall(r"'([^']*)'", items_text)
            component.properties['Items'] = items
        
        # Extract LookupKeyFields and LookupResultField
        lookup_key_match = re.search(r"LookupKeyFields\s*=\s*'([^']*)'", section)
        if lookup_key_match:
            component.properties['LookupKeyFields'] = lookup_key_match.group(1)
        
        lookup_result_match = re.search(r"LookupResultField\s*=\s*'([^']*)'", section)
        if lookup_result_match:
            component.properties['LookupResultField'] = lookup_result_match.group(1)
    
    def _extract_component_events(self, component: DFMComponent, section: str):
        """Extract event handlers from component section"""
        event_pattern = r'On(\w+)\s*=\s*(\w+)'
        
        for match in re.finditer(event_pattern, section):
            event_name = f"On{match.group(1)}"
            handler_name = match.group(2)
            
            event = DFMEvent(
                event_name=event_name,
                handler_name=handler_name,
                component_name=component.name
            )
            
            component.events.append(event)
            self.events.append(event)
    
    def _extract_fields_from_components(self):
        """Extract field information from input components"""
        for component in self.components:
            if component.category != ComponentCategory.INPUT:
                continue
            
            # Determine field name
            field_name = component.field_name or component.data_field or component.name
            
            # Skip if no meaningful field name
            if not field_name or field_name == component.name and not component.data_source:
                # Try to derive from component name
                # e.g., EdtNama -> Nama, CbxStatus -> Status
                derived = self._derive_field_name(component.name)
                if derived:
                    field_name = derived
                else:
                    continue
            
            # Determine input type
            input_type = self.LARAVEL_INPUT_TYPES.get(component.component_type, 'text')
            
            # Determine data type
            data_type = self._guess_data_type(component)
            
            # Get caption from associated label if not set
            caption = component.caption
            if not caption:
                caption = self._find_associated_label(component)
            
            field = DFMField(
                name=component.name,
                field_name=field_name,
                caption=caption or field_name,
                data_type=data_type,
                width=component.width,
                visible=component.visible,
                required=component.required,
                read_only=component.read_only,
                max_length=component.max_length,
                input_type=input_type,
                component_name=component.name,
                component_type=component.component_type
            )
            
            # Set lookup info
            if 'LookupKeyFields' in component.properties:
                field.lookup_field = component.properties['LookupKeyFields']
            
            # Set max/min values
            if 'MaxValue' in component.properties:
                field.max_value = component.properties['MaxValue']
            if 'MinValue' in component.properties:
                field.min_value = component.properties['MinValue']
            
            self.fields.append(field)
    
    def _derive_field_name(self, component_name: str) -> Optional[str]:
        """Derive field name from component name"""
        # Common prefixes
        prefixes = ['Edt', 'edt', 'Edit', 'edit', 'Cbx', 'cbx', 'Cmb', 'cmb', 
                    'Chk', 'chk', 'Dtp', 'dtp', 'Spn', 'spn', 'Txt', 'txt',
                    'DB', 'db', 'Lbl', 'lbl', 'Mmo', 'mmo', 'Mem', 'mem']
        
        for prefix in prefixes:
            if component_name.startswith(prefix):
                remainder = component_name[len(prefix):]
                if remainder:
                    return remainder
        
        return None
    
    def _guess_data_type(self, component: DFMComponent) -> str:
        """Guess data type from component type and properties"""
        comp_type = component.component_type
        
        if comp_type in ['DateTimePicker', 'MonthCalendar', 'DBDateTimePicker']:
            return 'date'
        elif comp_type in ['SpinEdit', 'CurrencyEdit']:
            return 'numeric'
        elif comp_type in ['CheckBox', 'DBCheckBox']:
            return 'boolean'
        elif comp_type in ['Memo', 'RichEdit', 'DBMemo', 'DBRichEdit']:
            return 'text'
        elif 'MaxValue' in component.properties or 'MinValue' in component.properties:
            return 'numeric'
        else:
            return 'string'
    
    def _find_associated_label(self, component: DFMComponent) -> Optional[str]:
        """Find label associated with an input component"""
        # Look for label with FocusControl = component.name
        for comp in self.components:
            if comp.component_type == 'Label':
                if comp.properties.get('FocusControl') == component.name:
                    return comp.caption
        
        # Look for label with similar name or position
        for comp in self.components:
            if comp.component_type == 'Label':
                # Check if label name suggests association
                # e.g., LblNama for EdtNama
                label_suffix = comp.name.replace('Lbl', '').replace('lbl', '').replace('Label', '')
                comp_suffix = self._derive_field_name(component.name)
                
                if label_suffix and comp_suffix and label_suffix.lower() == comp_suffix.lower():
                    return comp.caption
                
                # Check position (label usually to the left or above)
                if abs(comp.top - component.top) < 25 and comp.left < component.left:
                    if component.left - comp.left < 200:
                        return comp.caption
        
        return None
    
    def _extract_data_components(self):
        """Extract data-related components (DataSources, Stored Procedures, etc.)"""
        for component in self.components:
            if component.category != ComponentCategory.DATA:
                continue
            
            if component.component_type == 'ADOStoredProc':
                self._extract_stored_proc(component)
            elif component.component_type == 'DataSource':
                self.data_sources.append({
                    'name': component.name,
                    'dataset': component.properties.get('DataSet', '')
                })
    
    def _extract_stored_proc(self, component: DFMComponent):
        """Extract stored procedure information"""
        section = self._get_component_section(component.name)
        if not section:
            return
        
        # Get procedure name
        proc_match = re.search(r"ProcedureName\s*=\s*'([^']*)'", section)
        proc_name = proc_match.group(1) if proc_match else ""
        
        # Extract parameters
        params = []
        params_match = re.search(r'Parameters\s*=\s*<(.*?)>', section, re.DOTALL)
        
        if params_match:
            params_text = params_match.group(1)
            item_pattern = r'item\s+(.*?)end'
            
            for item_match in re.finditer(item_pattern, params_text, re.DOTALL):
                param_text = item_match.group(1)
                
                param = {}
                
                name_match = re.search(r"Name\s*=\s*'@?([^']*)'", param_text)
                if name_match:
                    param['name'] = name_match.group(1)
                
                dtype_match = re.search(r'DataType\s*=\s*ft(\w+)', param_text)
                if dtype_match:
                    param['data_type'] = dtype_match.group(1)
                
                size_match = re.search(r'Size\s*=\s*(\d+)', param_text)
                if size_match:
                    param['size'] = int(size_match.group(1))
                
                direction_match = re.search(r'Direction\s*=\s*pd(\w+)', param_text)
                if direction_match:
                    param['direction'] = direction_match.group(1)
                
                if param.get('name'):
                    params.append(param)
        
        self.stored_procs.append({
            'component_name': component.name,
            'procedure_name': proc_name,
            'parameters': params
        })
    
    def _get_component_section(self, component_name: str) -> Optional[str]:
        """Get the section for a specific component"""
        pattern = rf'object\s+{component_name}\s*:\s*T\w+'
        match = re.search(pattern, self.content)
        if match:
            return self._extract_component_section(match.start())
        return None
    
    def _extract_all_events(self):
        """Extract all events for event-to-handler mapping"""
        # Already extracted in _extract_component_events
        pass
    
    def _build_component_hierarchy(self):
        """Build parent-child relationships between components"""
        # This is complex in DFM files - for now, infer from position
        # Containers (Panel, GroupBox, etc.) contain components within their bounds
        
        containers = [c for c in self.components if c.category == ComponentCategory.CONTAINER]
        
        for container in containers:
            for component in self.components:
                if component == container:
                    continue
                
                # Check if component is inside container bounds
                if (component.left >= container.left and 
                    component.top >= container.top and
                    component.left + component.width <= container.left + container.width and
                    component.top + component.height <= container.top + container.height):
                    
                    # Check if not already a closer parent
                    if component.parent is None:
                        component.parent = container.name
                        container.children.append(component)
    
    def _analyze_layout(self):
        """Analyze form layout for structure"""
        # Group fields by panels
        panels = [c for c in self.components if c.component_type in ['Panel', 'GroupBox']]
        
        for panel in panels:
            panel_fields = [f.field_name for f in self.fields 
                          if self._component_map.get(f.component_name, DFMComponent("","")).parent == panel.name]
            
            self.layout.panels.append({
                'name': panel.name,
                'caption': panel.caption,
                'fields': panel_fields
            })
            
            if panel.caption:
                self.layout.field_groups[panel.caption] = panel_fields
        
        # Extract tab pages
        tab_sheets = [c for c in self.components if c.component_type == 'TabSheet']
        
        for tab in tab_sheets:
            tab_fields = [f.field_name for f in self.fields 
                         if self._component_map.get(f.component_name, DFMComponent("","")).parent == tab.name]
            
            self.layout.tab_pages.append({
                'name': tab.name,
                'caption': tab.caption or tab.name,
                'fields': tab_fields
            })
    
    def _build_result(self) -> Dict[str, Any]:
        """Build the result dictionary"""
        return {
            'form_name': self.form_name,
            'form_type': self.form_type,
            'caption': self.form_caption,
            'form_properties': self.form_properties,
            
            # Components
            'components': self.components,
            'component_count': len(self.components),
            'components_by_category': self._group_by_category(),
            
            # Fields
            'fields': self.fields,
            'field_count': len(self.fields),
            
            # Events
            'events': self.events,
            'event_count': len(self.events),
            
            # Data
            'stored_procs': self.stored_procs,
            'data_sources': self.data_sources,
            
            # Layout
            'layout': {
                'panels': self.layout.panels,
                'field_groups': self.layout.field_groups,
                'tab_pages': self.layout.tab_pages,
            },
            
            # Summary
            'summary': {
                'input_components': len([c for c in self.components if c.category == ComponentCategory.INPUT]),
                'display_components': len([c for c in self.components if c.category == ComponentCategory.DISPLAY]),
                'container_components': len([c for c in self.components if c.category == ComponentCategory.CONTAINER]),
                'action_components': len([c for c in self.components if c.category == ComponentCategory.ACTION]),
                'data_components': len([c for c in self.components if c.category == ComponentCategory.DATA]),
                'stored_proc_count': len(self.stored_procs),
                'event_count': len(self.events),
            }
        }
    
    def _group_by_category(self) -> Dict[str, List[str]]:
        """Group components by category"""
        groups = {}
        for component in self.components:
            cat_name = component.category.value
            if cat_name not in groups:
                groups[cat_name] = []
            groups[cat_name].append(component.name)
        return groups
    
    def get_laravel_fields(self) -> List[Dict[str, Any]]:
        """Get fields formatted for Laravel generation"""
        result = []
        
        for field in self.fields:
            laravel_field = {
                'name': self._to_snake_case(field.field_name),
                'original_name': field.field_name,
                'label': field.caption,
                'type': field.data_type,
                'input_type': field.input_type,
                'required': field.required,
                'max_length': field.max_length if field.max_length > 0 else None,
                'min_value': field.min_value,
                'max_value': field.max_value,
                'read_only': field.read_only,
            }
            
            # Build validation rules
            rules = []
            if field.required:
                rules.append('required')
            else:
                rules.append('nullable')
            
            if field.data_type == 'numeric':
                rules.append('numeric')
                if field.min_value is not None:
                    rules.append(f'min:{field.min_value}')
                if field.max_value is not None:
                    rules.append(f'max:{field.max_value}')
            elif field.data_type == 'date':
                rules.append('date')
            elif field.data_type == 'boolean':
                rules.append('boolean')
            else:
                rules.append('string')
                if field.max_length > 0:
                    rules.append(f'max:{field.max_length}')
            
            laravel_field['validation_rules'] = rules
            
            result.append(laravel_field)
        
        return result
    
    def _to_snake_case(self, name: str) -> str:
        """Convert to snake_case"""
        # Insert underscore before uppercase letters
        result = re.sub(r'([A-Z])', r'_\1', name).lower()
        # Remove leading underscore
        return result.lstrip('_')


def print_analysis(result: Dict[str, Any]):
    """Pretty print DFM analysis results"""
    print("=" * 70)
    print(f" ENHANCED DFM PARSER ANALYSIS: {result['form_name']}")
    print("=" * 70)
    
    print(f"\n📋 FORM INFO")
    print(f"   Name: {result['form_name']}")
    print(f"   Type: {result['form_type']}")
    print(f"   Caption: {result['caption']}")
    
    summary = result['summary']
    print(f"\n📊 COMPONENT SUMMARY")
    print(f"   Total Components: {result['component_count']}")
    print(f"   • Input: {summary['input_components']}")
    print(f"   • Display: {summary['display_components']}")
    print(f"   • Container: {summary['container_components']}")
    print(f"   • Action: {summary['action_components']}")
    print(f"   • Data: {summary['data_components']}")
    
    print(f"\n📝 FIELDS DETECTED ({result['field_count']})")
    for field in result['fields'][:10]:
        req = "✓" if field.required else " "
        print(f"   [{req}] {field.field_name:20} ({field.input_type:10}) - {field.caption}")
    if result['field_count'] > 10:
        print(f"   ... and {result['field_count'] - 10} more")
    
    print(f"\n⚡ EVENTS DETECTED ({result['event_count']})")
    for event in result['events'][:5]:
        print(f"   • {event.component_name}.{event.event_name} → {event.handler_name}")
    if result['event_count'] > 5:
        print(f"   ... and {result['event_count'] - 5} more")
    
    if result['stored_procs']:
        print(f"\n🗄️  STORED PROCEDURES ({len(result['stored_procs'])})")
        for sp in result['stored_procs']:
            print(f"   • {sp['procedure_name']} ({len(sp['parameters'])} params)")
    
    if result['layout']['panels']:
        print(f"\n📐 LAYOUT")
        for panel in result['layout']['panels'][:3]:
            print(f"   • {panel['caption'] or panel['name']}: {len(panel['fields'])} fields")
    
    print("\n" + "=" * 70)


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        parser = EnhancedDFMParser(sys.argv[1])
        result = parser.parse()
        print_analysis(result)
        
        # Print Laravel fields
        print("\n📦 LARAVEL FIELDS:")
        for field in parser.get_laravel_fields()[:5]:
            rules = '|'.join(field['validation_rules'])
            print(f"   '{field['name']}' => '{rules}',")
    else:
        print("Usage: python dfm_parser_enhanced.py <file.dfm>")
