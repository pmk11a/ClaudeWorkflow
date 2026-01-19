#!/usr/bin/env python3
"""
PAS Parser - Extract business logic from Delphi Pascal files
Author: Migration Tool
Purpose: Parse Delphi .pas files to extract procedures, functions, and business logic
"""

import re
from typing import Dict, List, Any
from dataclasses import dataclass, field

@dataclass
class ProcedureFunction:
    """Represents a procedure or function"""
    name: str
    type: str  # 'procedure' or 'function'
    parameters: List[Dict[str, str]] = field(default_factory=list)
    return_type: str = ""
    body: str = ""
    visibility: str = "public"  # public, private, protected
    line_number: int = 0

@dataclass
class EventHandler:
    """Represents an event handler"""
    name: str
    component: str
    event_type: str
    body: str
    line_number: int = 0

@dataclass
class ValidationRule:
    """Represents a validation or business rule"""
    location: str
    rule_type: str
    condition: str
    action: str
    line_number: int = 0

class PASParser:
    """Parser for Delphi PAS (Pascal) files"""
    
    def __init__(self, pas_file_path: str):
        self.pas_file_path = pas_file_path
        self.unit_name = ""
        self.uses_units = []
        self.procedures = []
        self.functions = []
        self.event_handlers = []
        self.validation_rules = []
        self.private_vars = []
        self.public_vars = []
        
    def parse(self) -> Dict[str, Any]:
        """Parse the PAS file and extract all information"""
        with open(self.pas_file_path, 'r', encoding='latin-1') as f:
            content = f.read()
        
        # Extract unit name
        self._extract_unit_name(content)
        
        # Extract uses clause
        self._extract_uses(content)
        
        # Extract procedures and functions
        self._extract_procedures_functions(content)
        
        # Extract event handlers
        self._extract_event_handlers(content)
        
        # Extract validation rules
        self._extract_validation_rules(content)
        
        # Extract variables
        self._extract_variables(content)
        
        return {
            'unit_name': self.unit_name,
            'uses': self.uses_units,
            'procedures': self.procedures,
            'functions': self.functions,
            'event_handlers': self.event_handlers,
            'validation_rules': self.validation_rules,
            'private_vars': self.private_vars,
            'public_vars': self.public_vars
        }
    
    def _extract_unit_name(self, content: str):
        """Extract unit name"""
        match = re.search(r'unit\s+(\w+)\s*;', content, re.IGNORECASE)
        if match:
            self.unit_name = match.group(1)
    
    def _extract_uses(self, content: str):
        """Extract uses clause"""
        # Find uses clause in implementation section
        uses_pattern = r'uses\s+([\w\s,]+);'
        matches = re.finditer(uses_pattern, content, re.IGNORECASE)
        
        for match in matches:
            units = match.group(1).split(',')
            self.uses_units.extend([u.strip() for u in units])
    
    def _extract_procedures_functions(self, content: str):
        """Extract all procedures and functions"""
        # Pattern for procedure/function declarations
        proc_func_pattern = r'(procedure|function)\s+(\w+)\.(\w+)\s*(\([^)]*\))?\s*:\s*(\w+)?\s*;'
        
        matches = re.finditer(proc_func_pattern, content, re.IGNORECASE)
        
        for match in matches:
            pf_type = match.group(1).lower()
            class_name = match.group(2)
            method_name = match.group(3)
            params_str = match.group(4) if match.group(4) else ""
            return_type = match.group(5) if match.group(5) else ""
            
            # Extract method body
            start_pos = match.end()
            body = self._extract_method_body(content, start_pos)
            
            # Parse parameters
            parameters = self._parse_parameters(params_str)
            
            pf_obj = ProcedureFunction(
                name=f"{class_name}.{method_name}",
                type=pf_type,
                parameters=parameters,
                return_type=return_type,
                body=body,
                line_number=content[:match.start()].count('\n') + 1
            )
            
            if pf_type == 'procedure':
                self.procedures.append(pf_obj)
            else:
                self.functions.append(pf_obj)
    
    def _extract_method_body(self, content: str, start_pos: int) -> str:
        """Extract the body of a method"""
        # Find the end of the method (next 'end;' at the same level)
        depth = 0
        body_end = start_pos
        
        i = start_pos
        while i < len(content):
            if content[i:i+5].lower() == 'begin':
                depth += 1
                i += 5
            elif content[i:i+3].lower() == 'end':
                if depth == 1 and i + 3 < len(content) and content[i+3] == ';':
                    body_end = i + 4
                    break
                depth -= 1
                i += 3
            else:
                i += 1
        
        return content[start_pos:body_end].strip()
    
    def _parse_parameters(self, params_str: str) -> List[Dict[str, str]]:
        """Parse parameter string"""
        parameters = []
        
        if not params_str or params_str == "()":
            return parameters
        
        # Remove parentheses
        params_str = params_str.strip('()')
        
        # Split by semicolon
        param_groups = params_str.split(';')
        
        for group in param_groups:
            group = group.strip()
            if not group:
                continue
            
            # Check for var/const
            modifier = ""
            if group.lower().startswith('var '):
                modifier = 'var'
                group = group[4:].strip()
            elif group.lower().startswith('const '):
                modifier = 'const'
                group = group[6:].strip()
            
            # Split by colon to get names and type
            parts = group.split(':')
            if len(parts) == 2:
                names = [n.strip() for n in parts[0].split(',')]
                param_type = parts[1].strip()
                
                for name in names:
                    parameters.append({
                        'name': name,
                        'type': param_type,
                        'modifier': modifier
                    })
        
        return parameters
    
    def _extract_event_handlers(self, content: str):
        """Extract event handler methods"""
        # Common event patterns
        event_patterns = [
            r'procedure\s+\w+\.(ToolButton\w+Click)',
            r'procedure\s+\w+\.(FormShow|FormCreate|FormClose|FormDestroy)',
            r'procedure\s+\w+\.(\w+Click|\w+Change|\w+KeyDown)',
        ]
        
        for pattern in event_patterns:
            matches = re.finditer(pattern, content, re.IGNORECASE)
            
            for match in matches:
                event_name = match.group(1)
                
                # Extract body
                start_pos = match.end()
                body = self._extract_method_body(content, start_pos)
                
                # Determine component and event type
                if 'Click' in event_name:
                    event_type = 'Click'
                    component = event_name.replace('Click', '')
                elif 'Show' in event_name:
                    event_type = 'Show'
                    component = event_name.replace('Show', '')
                elif 'Create' in event_name:
                    event_type = 'Create'
                    component = event_name.replace('Create', '')
                else:
                    event_type = 'Unknown'
                    component = event_name
                
                handler = EventHandler(
                    name=event_name,
                    component=component,
                    event_type=event_type,
                    body=body,
                    line_number=content[:match.start()].count('\n') + 1
                )
                
                self.event_handlers.append(handler)
    
    def _extract_validation_rules(self, content: str):
        """Extract validation and business rules"""
        # Look for common validation patterns
        
        # Pattern 1: If checks with messages
        if_msg_pattern = r'if\s+([^;]+)\s+then\s+begin\s+(ShowMessage|MessageBox|Application\.MessageBox)\s*\('
        matches = re.finditer(if_msg_pattern, content, re.IGNORECASE | re.DOTALL)
        
        for match in matches:
            condition = match.group(1).strip()
            action = match.group(2)
            
            rule = ValidationRule(
                location=self._find_containing_method(content, match.start()),
                rule_type='validation',
                condition=condition,
                action=action,
                line_number=content[:match.start()].count('\n') + 1
            )
            
            self.validation_rules.append(rule)
        
        # Pattern 2: IsEmpty checks
        isempty_pattern = r'if\s+(\w+)\.IsEmpty\s*=\s*true'
        matches = re.finditer(isempty_pattern, content, re.IGNORECASE)
        
        for match in matches:
            field = match.group(1)
            
            rule = ValidationRule(
                location=self._find_containing_method(content, match.start()),
                rule_type='empty_check',
                condition=f"{field}.IsEmpty = true",
                action="data validation",
                line_number=content[:match.start()].count('\n') + 1
            )
            
            self.validation_rules.append(rule)
        
        # Pattern 3: Required field checks
        required_pattern = r'if\s+([^;]+)\.Text\s*=\s*[\'"][\'"]\s+then'
        matches = re.finditer(required_pattern, content, re.IGNORECASE)
        
        for match in matches:
            field = match.group(1).strip()
            
            rule = ValidationRule(
                location=self._find_containing_method(content, match.start()),
                rule_type='required',
                condition=f"{field} is empty",
                action="validation",
                line_number=content[:match.start()].count('\n') + 1
            )
            
            self.validation_rules.append(rule)
    
    def _find_containing_method(self, content: str, position: int) -> str:
        """Find which method contains a given position"""
        # Search backwards for procedure/function declaration
        before_content = content[:position]
        
        match = re.search(r'(procedure|function)\s+\w+\.(\w+)', before_content[::-1], re.IGNORECASE)
        if match:
            return match.group(2)[::-1]
        
        return "Unknown"
    
    def _extract_variables(self, content: str):
        """Extract variable declarations"""
        # Find private section
        private_match = re.search(r'private\s+{[^}]*}(.*?)public', content, re.IGNORECASE | re.DOTALL)
        if private_match:
            var_section = private_match.group(1)
            self.private_vars = self._parse_var_section(var_section)
        
        # Find public section
        public_match = re.search(r'public\s+{[^}]*}(.*?)end;', content, re.IGNORECASE | re.DOTALL)
        if public_match:
            var_section = public_match.group(1)
            self.public_vars = self._parse_var_section(var_section)
    
    def _parse_var_section(self, var_section: str) -> List[Dict[str, str]]:
        """Parse variable declarations"""
        variables = []
        
        # Simple variable pattern
        var_pattern = r'(\w+)\s*:\s*(\w+)\s*;'
        matches = re.finditer(var_pattern, var_section)
        
        for match in matches:
            variables.append({
                'name': match.group(1),
                'type': match.group(2)
            })
        
        return variables
    
    def get_crud_methods(self) -> Dict[str, ProcedureFunction]:
        """Get CRUD-related methods"""
        crud_methods = {
            'create': None,
            'read': None,
            'update': None,
            'delete': None,
            'save': None
        }
        
        for proc in self.procedures:
            name_lower = proc.name.lower()
            
            if 'tambah' in name_lower or 'insert' in name_lower:
                crud_methods['create'] = proc
            elif 'ambil' in name_lower or 'select' in name_lower or 'tampil' in name_lower:
                crud_methods['read'] = proc
            elif 'koreksi' in name_lower or 'update' in name_lower or 'ubah' in name_lower:
                crud_methods['update'] = proc
            elif 'hapus' in name_lower or 'delete' in name_lower:
                crud_methods['delete'] = proc
            elif 'simpan' in name_lower or 'save' in name_lower:
                crud_methods['save'] = proc
        
        return crud_methods

if __name__ == "__main__":
    # Test the parser
    import sys
    if len(sys.argv) > 1:
        parser = PASParser(sys.argv[1])
        result = parser.parse()
        
        print(f"Unit: {result['unit_name']}")
        print(f"\nProcedures: {len(result['procedures'])}")
        print(f"Functions: {len(result['functions'])}")
        print(f"Event Handlers: {len(result['event_handlers'])}")
        print(f"Validation Rules: {len(result['validation_rules'])}")
        
        print("\n--- Event Handlers ---")
        for handler in result['event_handlers'][:5]:
            print(f"  {handler.name} ({handler.event_type})")
        
        print("\n--- Validation Rules ---")
        for rule in result['validation_rules'][:5]:
            print(f"  Line {rule.line_number}: {rule.rule_type} - {rule.condition}")
