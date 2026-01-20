#!/usr/bin/env python3
"""
Enhanced PAS Parser - Extract business logic from Delphi Pascal files
Version: 2.0 - With full pattern detection for rigorous migration

Detects:
- Choice:Char parameter (I/U/D modes)
- Permission variables (IsTambah, IsKoreksi, IsHapus, IsCetak, IsExcel)
- LoggingData() calls with parameters
- All 8 validation patterns
- Stored procedure calls and parameters
- Exception handling patterns
"""

import re
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass, field
from enum import Enum

class OperationMode(Enum):
    INSERT = 'I'
    UPDATE = 'U'
    DELETE = 'D'
    UNKNOWN = '?'

@dataclass
class ProcedureFunction:
    """Represents a procedure or function"""
    name: str
    type: str  # 'procedure' or 'function'
    parameters: List[Dict[str, str]] = field(default_factory=list)
    return_type: str = ""
    body: str = ""
    visibility: str = "public"
    line_number: int = 0
    has_choice_param: bool = False
    modes_detected: List[str] = field(default_factory=list)

@dataclass
class EventHandler:
    """Represents an event handler"""
    name: str
    component: str
    event_type: str
    body: str
    line_number: int = 0
    calls_procedure: Optional[str] = None
    mode: Optional[str] = None

@dataclass
class ValidationRule:
    """Represents a validation or business rule"""
    location: str
    rule_type: str
    field_name: str
    condition: str
    error_message: str
    line_number: int = 0
    laravel_rule: str = ""

@dataclass
class PermissionCheck:
    """Represents a permission check variable"""
    name: str
    permission_type: str  # 'create', 'update', 'delete', 'print', 'export'
    line_number: int = 0
    laravel_permission: str = ""

@dataclass
class LoggingCall:
    """Represents a LoggingData() call"""
    location: str
    user_param: str
    action_param: str  # I, U, D
    source_param: str
    nobukti_param: str
    keterangan_param: str
    line_number: int = 0
    full_call: str = ""

@dataclass
class StoredProcCall:
    """Represents a stored procedure call"""
    procedure_name: str
    parameters: List[Dict[str, Any]] = field(default_factory=list)
    mode: Optional[str] = None
    line_number: int = 0

@dataclass
class ExceptionHandler:
    """Represents exception handling"""
    location: str
    exception_type: str
    error_message: str
    line_number: int = 0


class EnhancedPASParser:
    """Enhanced Parser for Delphi PAS files with full pattern detection"""
    
    # Permission mapping to Laravel
    PERMISSION_MAP = {
        'IsTambah': ('create', 'create-{module}'),
        'IsKoreksi': ('update', 'update-{module}'),
        'IsHapus': ('delete', 'delete-{module}'),
        'IsCetak': ('print', 'print-{module}'),
        'IsExcel': ('export', 'export-{module}'),
        'IsExport': ('export', 'export-{module}'),
    }
    
    def __init__(self, pas_file_path: str):
        self.pas_file_path = pas_file_path
        self.content = ""
        self.lines = []
        
        # Basic info
        self.unit_name = ""
        self.uses_units = []
        self.form_class = ""
        
        # Extracted data
        self.procedures: List[ProcedureFunction] = []
        self.functions: List[ProcedureFunction] = []
        self.event_handlers: List[EventHandler] = []
        self.validation_rules: List[ValidationRule] = []
        self.permission_checks: List[PermissionCheck] = []
        self.logging_calls: List[LoggingCall] = []
        self.stored_proc_calls: List[StoredProcCall] = []
        self.exception_handlers: List[ExceptionHandler] = []
        
        # Mode-based operations
        self.choice_procedures: List[ProcedureFunction] = []
        self.mode_operations: Dict[str, List[str]] = {
            'I': [],  # INSERT operations
            'U': [],  # UPDATE operations
            'D': [],  # DELETE operations
        }
        
    def parse(self) -> Dict[str, Any]:
        """Parse the PAS file and extract all information"""
        try:
            with open(self.pas_file_path, 'r', encoding='latin-1') as f:
                self.content = f.read()
                self.lines = self.content.split('\n')
        except Exception as e:
            # Try UTF-8 if latin-1 fails
            with open(self.pas_file_path, 'r', encoding='utf-8', errors='ignore') as f:
                self.content = f.read()
                self.lines = self.content.split('\n')
        
        # Extract all information
        self._extract_unit_info()
        self._extract_permission_variables()
        self._extract_procedures_functions()
        self._extract_choice_procedures()
        self._extract_event_handlers()
        self._extract_validation_rules()
        self._extract_logging_calls()
        self._extract_stored_proc_calls()
        self._extract_exception_handlers()
        self._analyze_mode_operations()
        
        return self._build_result()
    
    def _extract_unit_info(self):
        """Extract unit name and uses clause"""
        # Unit name
        match = re.search(r'unit\s+(\w+)\s*;', self.content, re.IGNORECASE)
        if match:
            self.unit_name = match.group(1)
        
        # Form class
        match = re.search(r'type\s+T(\w+)\s*=\s*class\s*\(T(Form|Frame)', self.content, re.IGNORECASE)
        if match:
            self.form_class = match.group(1)
        
        # Uses clause
        uses_pattern = r'uses\s+([\w\s,\n]+?);'
        matches = re.finditer(uses_pattern, self.content, re.IGNORECASE | re.DOTALL)
        for match in matches:
            units = re.split(r'[,\n]', match.group(1))
            self.uses_units.extend([u.strip() for u in units if u.strip()])
    
    def _extract_permission_variables(self):
        """Extract IsTambah, IsKoreksi, IsHapus, etc."""
        # Pattern: IsTambah, IsKoreksi, IsHapus: Boolean;
        # Or: IsTambah: Boolean;
        
        permission_names = '|'.join(self.PERMISSION_MAP.keys())
        pattern = rf'\b({permission_names})\s*[:,]\s*Boolean'
        
        for match in re.finditer(pattern, self.content, re.IGNORECASE):
            perm_name = match.group(1)
            perm_type, laravel_perm = self.PERMISSION_MAP.get(perm_name, ('unknown', 'unknown'))
            
            line_num = self.content[:match.start()].count('\n') + 1
            
            self.permission_checks.append(PermissionCheck(
                name=perm_name,
                permission_type=perm_type,
                line_number=line_num,
                laravel_permission=laravel_perm.format(module=self.unit_name.lower())
            ))
    
    def _extract_procedures_functions(self):
        """Extract all procedures and functions with their bodies"""
        # Pattern for implementation section
        impl_match = re.search(r'implementation', self.content, re.IGNORECASE)
        if not impl_match:
            return
        
        impl_content = self.content[impl_match.end():]
        
        # Pattern for procedure/function
        pattern = r'(procedure|function)\s+(?:T(\w+)\.)?(\w+)\s*(\([^)]*\))?\s*(?::\s*(\w+))?\s*;'
        
        for match in re.finditer(pattern, impl_content, re.IGNORECASE):
            pf_type = match.group(1).lower()
            class_name = match.group(2) or ""
            method_name = match.group(3)
            params_str = match.group(4) or ""
            return_type = match.group(5) or ""
            
            # Check for Choice parameter
            has_choice = bool(re.search(r'Choice\s*:\s*Char', params_str, re.IGNORECASE))
            
            # Extract body
            body_start = match.end()
            body = self._extract_method_body(impl_content, body_start)
            
            # Detect modes in body
            modes = []
            if has_choice:
                for mode in ['I', 'U', 'D']:
                    if re.search(rf"Choice\s*=\s*['\"]?{mode}['\"]?", body, re.IGNORECASE):
                        modes.append(mode)
            
            # Parse parameters
            parameters = self._parse_parameters(params_str)
            
            line_num = self.content[:impl_match.end() + match.start()].count('\n') + 1
            
            pf = ProcedureFunction(
                name=f"{class_name}.{method_name}" if class_name else method_name,
                type=pf_type,
                parameters=parameters,
                return_type=return_type,
                body=body,
                line_number=line_num,
                has_choice_param=has_choice,
                modes_detected=modes
            )
            
            if pf_type == 'procedure':
                self.procedures.append(pf)
            else:
                self.functions.append(pf)
            
            if has_choice:
                self.choice_procedures.append(pf)
    
    def _extract_choice_procedures(self):
        """Specifically extract procedures with Choice:Char parameter"""
        # Already done in _extract_procedures_functions
        # This method provides additional analysis
        
        for proc in self.choice_procedures:
            for mode in proc.modes_detected:
                self.mode_operations[mode].append(proc.name)
    
    def _extract_event_handlers(self):
        """Extract event handler methods"""
        # Patterns for common events
        event_patterns = [
            (r'procedure\s+T\w+\.(ToolButton\d+Click)', 'ToolButtonClick'),
            (r'procedure\s+T\w+\.(\w+BtnClick)', 'ButtonClick'),
            (r'procedure\s+T\w+\.(Form(?:Show|Create|Close|Destroy|Activate))', 'FormEvent'),
            (r'procedure\s+T\w+\.(\w+Click)', 'Click'),
            (r'procedure\s+T\w+\.(\w+Change)', 'Change'),
            (r'procedure\s+T\w+\.(\w+KeyDown)', 'KeyDown'),
            (r'procedure\s+T\w+\.(\w+KeyPress)', 'KeyPress'),
            (r'procedure\s+T\w+\.(\w+Exit)', 'Exit'),
            (r'procedure\s+T\w+\.(\w+Enter)', 'Enter'),
        ]
        
        for pattern, event_type in event_patterns:
            for match in re.finditer(pattern, self.content, re.IGNORECASE):
                event_name = match.group(1)
                
                # Extract body
                body_start = match.end()
                # Find the body after the semicolon
                body = self._extract_method_body(self.content, body_start)
                
                # Detect if it calls a Choice procedure
                calls_proc = None
                mode = None
                for proc in self.choice_procedures:
                    proc_name = proc.name.split('.')[-1]
                    if proc_name in body:
                        calls_proc = proc_name
                        # Try to detect mode from call
                        mode_match = re.search(rf"{proc_name}\s*\(\s*['\"]([IUD])['\"]", body)
                        if mode_match:
                            mode = mode_match.group(1)
                        break
                
                # Determine component from event name
                component = event_name
                for suffix in ['Click', 'Change', 'KeyDown', 'KeyPress', 'Exit', 'Enter', 'Show', 'Create', 'Close']:
                    if event_name.endswith(suffix):
                        component = event_name[:-len(suffix)]
                        break
                
                line_num = self.content[:match.start()].count('\n') + 1
                
                self.event_handlers.append(EventHandler(
                    name=event_name,
                    component=component,
                    event_type=event_type,
                    body=body,
                    line_number=line_num,
                    calls_procedure=calls_proc,
                    mode=mode
                ))
    
    def _extract_validation_rules(self):
        """Extract all 8 validation patterns"""
        
        # Pattern A: Range validation
        # if EdtQuantity.Value < 0 then
        range_pattern = r"if\s+(\w+)\.(Value|AsFloat|AsInteger)\s*([<>]=?)\s*([\d.]+)\s+then"
        for match in re.finditer(range_pattern, self.content, re.IGNORECASE):
            field = match.group(1)
            operator = match.group(3)
            value = match.group(4)
            
            # Map to Laravel rule
            if '<' in operator:
                laravel_rule = f"max:{value}"
            else:
                laravel_rule = f"min:{value}"
            
            self._add_validation_rule(match, 'range', field, 
                f"{field} {operator} {value}", laravel_rule)
        
        # Pattern B: Unique validation (Locate check)
        # if QuCheck.Locate('Field', Value, []) then
        unique_pattern = r"if\s+(\w+)\.Locate\s*\(\s*['\"](\w+)['\"]\s*,\s*(\w+)"
        for match in re.finditer(unique_pattern, self.content, re.IGNORECASE):
            field = match.group(2)
            self._add_validation_rule(match, 'unique', field,
                f"Locate check on {field}", f"unique:table,{field.lower()}")
        
        # Pattern C: Empty/Required check
        # if Field.Text = '' then OR if Field.IsEmpty then
        empty_patterns = [
            (r"if\s+(\w+)\.Text\s*=\s*['\"]['\"]", 'text_empty'),
            (r"if\s+(\w+)\.IsEmpty\s*(?:=\s*true)?", 'is_empty'),
            (r"if\s+Trim\s*\(\s*(\w+)\.Text\s*\)\s*=\s*['\"]['\"]", 'trim_empty'),
        ]
        for pattern, check_type in empty_patterns:
            for match in re.finditer(pattern, self.content, re.IGNORECASE):
                field = match.group(1)
                self._add_validation_rule(match, 'required', field,
                    f"{field} is empty", "required")
        
        # Pattern D: Format validation (date, etc)
        format_patterns = [
            (r"if\s+not\s+IsValidDate\s*\(\s*(\w+)", 'date'),
            (r"if\s+not\s+TryStrToDate\s*\(\s*(\w+)", 'date'),
            (r"if\s+not\s+TryStrToFloat\s*\(\s*(\w+)", 'numeric'),
            (r"if\s+not\s+TryStrToInt\s*\(\s*(\w+)", 'integer'),
        ]
        for pattern, format_type in format_patterns:
            for match in re.finditer(pattern, self.content, re.IGNORECASE):
                field = match.group(1)
                laravel_rule = {'date': 'date', 'numeric': 'numeric', 'integer': 'integer'}.get(format_type, 'string')
                self._add_validation_rule(match, 'format', field,
                    f"{field} format check ({format_type})", laravel_rule)
        
        # Pattern E: Lookup/Exists validation
        # if not QuTable.Locate('Field', Value, []) then
        lookup_pattern = r"if\s+not\s+(\w+)\.Locate\s*\(\s*['\"](\w+)['\"]\s*,\s*(\w+)"
        for match in re.finditer(lookup_pattern, self.content, re.IGNORECASE):
            table = match.group(1)
            field = match.group(2)
            self._add_validation_rule(match, 'exists', field,
                f"{field} must exist in {table}", f"exists:{table.lower()},{field.lower()}")
        
        # Pattern F: Conditional validation
        # if Condition then if Field... then
        conditional_pattern = r"if\s+(\w+)\s*=\s*(\d+|true|false|['\"][^'\"]+['\"])\s+then\s+(?:begin\s+)?if\s+(\w+)"
        for match in re.finditer(conditional_pattern, self.content, re.IGNORECASE | re.DOTALL):
            condition_field = match.group(1)
            condition_value = match.group(2).strip("'\"")
            target_field = match.group(3)
            self._add_validation_rule(match, 'conditional', target_field,
                f"{target_field} required if {condition_field}={condition_value}",
                f"required_if:{condition_field.lower()},{condition_value}")
        
        # Pattern G: Exception with message
        # raise Exception.Create('message')
        exception_pattern = r"raise\s+Exception\.Create\s*\(\s*['\"]([^'\"]+)['\"]\s*\)"
        for match in re.finditer(exception_pattern, self.content, re.IGNORECASE):
            message = match.group(1)
            # Try to find related field from context
            context_start = max(0, match.start() - 200)
            context = self.content[context_start:match.start()]
            field_match = re.search(r'(\w+)\.(Text|Value|AsFloat)', context)
            field = field_match.group(1) if field_match else "unknown"
            
            self._add_validation_rule(match, 'exception', field,
                message, "custom_validation", message)
        
        # Pattern H: In/Enum validation
        # if not (Status in ['A', 'I']) then
        enum_pattern = r"if\s+not\s*\(\s*(\w+)\s+in\s+\[([^\]]+)\]\s*\)"
        for match in re.finditer(enum_pattern, self.content, re.IGNORECASE):
            field = match.group(1)
            values = match.group(2)
            # Clean up values
            values_list = [v.strip().strip("'\"") for v in values.split(',')]
            self._add_validation_rule(match, 'enum', field,
                f"{field} must be in [{values}]", f"in:{','.join(values_list)}")
    
    def _add_validation_rule(self, match, rule_type: str, field: str, 
                             condition: str, laravel_rule: str, error_msg: str = ""):
        """Helper to add validation rule"""
        line_num = self.content[:match.start()].count('\n') + 1
        location = self._find_containing_method(match.start())
        
        self.validation_rules.append(ValidationRule(
            location=location,
            rule_type=rule_type,
            field_name=field,
            condition=condition,
            error_message=error_msg or f"Validation failed for {field}",
            line_number=line_num,
            laravel_rule=laravel_rule
        ))
    
    def _extract_logging_calls(self):
        """Extract LoggingData() calls"""
        # LoggingData(IDUser, Choice, 'Source', 'NoBukti', 'Keterangan')
        pattern = r"LoggingData\s*\(\s*([^,]+)\s*,\s*([^,]+)\s*,\s*['\"]([^'\"]+)['\"]\s*,\s*([^,]+)\s*,\s*([^)]+)\)"
        
        for match in re.finditer(pattern, self.content, re.IGNORECASE):
            user_param = match.group(1).strip()
            action_param = match.group(2).strip()
            source_param = match.group(3).strip()
            nobukti_param = match.group(4).strip()
            keterangan_param = match.group(5).strip()
            
            line_num = self.content[:match.start()].count('\n') + 1
            location = self._find_containing_method(match.start())
            
            self.logging_calls.append(LoggingCall(
                location=location,
                user_param=user_param,
                action_param=action_param,
                source_param=source_param,
                nobukti_param=nobukti_param,
                keterangan_param=keterangan_param,
                line_number=line_num,
                full_call=match.group(0)
            ))
    
    def _extract_stored_proc_calls(self):
        """Extract stored procedure calls"""
        # Pattern: sp_name.ExecProc or sp_name.Open
        exec_pattern = r"(\w+)\.(ExecProc|Open)\s*;"
        
        for match in re.finditer(exec_pattern, self.content, re.IGNORECASE):
            proc_var = match.group(1)
            
            # Find parameters assignment before this call
            context_start = max(0, match.start() - 2000)
            context = self.content[context_start:match.start()]
            
            # Extract parameters
            params = []
            param_pattern = rf"{proc_var}\.Parameters\[(\d+)\]\.Value\s*:=\s*([^;]+);"
            for param_match in re.finditer(param_pattern, context):
                params.append({
                    'index': int(param_match.group(1)),
                    'value': param_match.group(2).strip()
                })
            
            # Try to detect mode
            mode = None
            mode_match = re.search(r"Parameters\[1\]\.Value\s*:=\s*['\"]?([IUD])['\"]?", context)
            if mode_match:
                mode = mode_match.group(1)
            
            line_num = self.content[:match.start()].count('\n') + 1
            
            self.stored_proc_calls.append(StoredProcCall(
                procedure_name=proc_var,
                parameters=sorted(params, key=lambda x: x['index']),
                mode=mode,
                line_number=line_num
            ))
    
    def _extract_exception_handlers(self):
        """Extract try/except blocks"""
        pattern = r"except\s+(on\s+E\s*:\s*(\w+)\s+do\s+)?begin?\s*(.*?)end\s*;"
        
        for match in re.finditer(pattern, self.content, re.IGNORECASE | re.DOTALL):
            exception_type = match.group(2) or "Exception"
            handler_body = match.group(3)
            
            # Extract error message
            msg_match = re.search(r"ShowMessage\s*\(\s*['\"]([^'\"]+)['\"]", handler_body)
            error_msg = msg_match.group(1) if msg_match else "Error occurred"
            
            line_num = self.content[:match.start()].count('\n') + 1
            location = self._find_containing_method(match.start())
            
            self.exception_handlers.append(ExceptionHandler(
                location=location,
                exception_type=exception_type,
                error_message=error_msg,
                line_number=line_num
            ))
    
    def _analyze_mode_operations(self):
        """Analyze which operations belong to which mode"""
        for proc in self.choice_procedures:
            body = proc.body
            
            # Find mode-specific code blocks
            mode_blocks = {}
            for mode in ['I', 'U', 'D']:
                # Pattern: if Choice='I' then begin ... end
                pattern = rf"if\s*\(?Choice\s*=\s*['\"]?{mode}['\"]?\)?\s*then\s*begin(.*?)end\s*;"
                matches = re.finditer(pattern, body, re.IGNORECASE | re.DOTALL)
                mode_blocks[mode] = [m.group(1) for m in matches]
            
            # Store in mode_operations with more detail
            for mode, blocks in mode_blocks.items():
                if blocks:
                    for block in blocks:
                        # Extract key operations from block
                        if 'LoggingData' in block:
                            self.mode_operations[mode].append(f"{proc.name}:logging")
                        if 'Requery' in block:
                            self.mode_operations[mode].append(f"{proc.name}:refresh")
    
    def _extract_method_body(self, content: str, start_pos: int) -> str:
        """Extract method body between begin and end"""
        # Find 'begin' after start_pos
        begin_match = re.search(r'\bbegin\b', content[start_pos:], re.IGNORECASE)
        if not begin_match:
            return ""
        
        actual_start = start_pos + begin_match.end()
        
        # Count begin/end to find matching end
        depth = 1
        i = actual_start
        while i < len(content) and depth > 0:
            # Check for begin
            if content[i:i+5].lower() == 'begin':
                depth += 1
                i += 5
            # Check for end
            elif content[i:i+3].lower() == 'end':
                depth -= 1
                if depth == 0:
                    return content[actual_start:i].strip()
                i += 3
            else:
                i += 1
        
        return content[actual_start:min(actual_start + 1000, len(content))].strip()
    
    def _parse_parameters(self, params_str: str) -> List[Dict[str, str]]:
        """Parse parameter string"""
        parameters = []
        
        if not params_str or params_str.strip() in ['', '()']:
            return parameters
        
        params_str = params_str.strip('()')
        param_groups = params_str.split(';')
        
        for group in param_groups:
            group = group.strip()
            if not group:
                continue
            
            modifier = ""
            if group.lower().startswith('var '):
                modifier = 'var'
                group = group[4:].strip()
            elif group.lower().startswith('const '):
                modifier = 'const'
                group = group[6:].strip()
            
            if ':' in group:
                parts = group.split(':')
                names = [n.strip() for n in parts[0].split(',')]
                param_type = parts[1].strip() if len(parts) > 1 else 'variant'
                
                for name in names:
                    if name:
                        parameters.append({
                            'name': name,
                            'type': param_type,
                            'modifier': modifier
                        })
        
        return parameters
    
    def _find_containing_method(self, position: int) -> str:
        """Find which method contains a given position"""
        before = self.content[:position]
        
        # Search backwards for procedure/function
        matches = list(re.finditer(r'(procedure|function)\s+(?:T\w+\.)?(\w+)', before, re.IGNORECASE))
        if matches:
            return matches[-1].group(2)
        
        return "Unknown"
    
    def _build_result(self) -> Dict[str, Any]:
        """Build the result dictionary"""
        return {
            'unit_name': self.unit_name,
            'form_class': self.form_class,
            'uses': self.uses_units,
            
            # Methods
            'procedures': self.procedures,
            'functions': self.functions,
            'event_handlers': self.event_handlers,
            
            # Business Logic
            'choice_procedures': self.choice_procedures,
            'mode_operations': self.mode_operations,
            'permission_checks': self.permission_checks,
            'validation_rules': self.validation_rules,
            'logging_calls': self.logging_calls,
            'stored_proc_calls': self.stored_proc_calls,
            'exception_handlers': self.exception_handlers,
            
            # Summary
            'summary': {
                'total_procedures': len(self.procedures),
                'total_functions': len(self.functions),
                'total_event_handlers': len(self.event_handlers),
                'choice_procedures_count': len(self.choice_procedures),
                'permissions_found': [p.name for p in self.permission_checks],
                'validation_rules_count': len(self.validation_rules),
                'logging_calls_count': len(self.logging_calls),
                'has_insert_mode': len(self.mode_operations['I']) > 0,
                'has_update_mode': len(self.mode_operations['U']) > 0,
                'has_delete_mode': len(self.mode_operations['D']) > 0,
            }
        }
    
    def get_crud_methods(self) -> Dict[str, Optional[ProcedureFunction]]:
        """Get CRUD-related methods"""
        crud = {
            'create': None,
            'read': None,
            'update': None,
            'delete': None,
            'save': None
        }
        
        for proc in self.procedures:
            name_lower = proc.name.lower()
            
            if proc.has_choice_param:
                crud['save'] = proc
            elif any(x in name_lower for x in ['tambah', 'insert', 'add', 'create', 'new']):
                crud['create'] = proc
            elif any(x in name_lower for x in ['ambil', 'select', 'tampil', 'load', 'get', 'fetch']):
                crud['read'] = proc
            elif any(x in name_lower for x in ['koreksi', 'update', 'ubah', 'edit', 'modify']):
                crud['update'] = proc
            elif any(x in name_lower for x in ['hapus', 'delete', 'remove']):
                crud['delete'] = proc
        
        return crud
    
    def get_laravel_validation_rules(self) -> Dict[str, List[str]]:
        """Get validation rules formatted for Laravel"""
        rules = {}
        
        for rule in self.validation_rules:
            field = rule.field_name.lower()
            if field not in rules:
                rules[field] = []
            
            if rule.laravel_rule and rule.laravel_rule not in rules[field]:
                rules[field].append(rule.laravel_rule)
        
        return rules


def print_analysis(result: Dict[str, Any]):
    """Pretty print analysis results"""
    print("=" * 70)
    print(f" ENHANCED PAS PARSER ANALYSIS: {result['unit_name']}")
    print("=" * 70)
    
    summary = result['summary']
    
    print(f"\n📋 SUMMARY")
    print(f"   Unit: {result['unit_name']}")
    print(f"   Form Class: {result['form_class']}")
    print(f"   Procedures: {summary['total_procedures']}")
    print(f"   Functions: {summary['total_functions']}")
    print(f"   Event Handlers: {summary['total_event_handlers']}")
    
    print(f"\n🔐 PERMISSIONS DETECTED")
    if summary['permissions_found']:
        for perm in result['permission_checks']:
            print(f"   • {perm.name} → {perm.laravel_permission}")
    else:
        print("   (none found)")
    
    print(f"\n🔄 MODE-BASED OPERATIONS (Choice:Char)")
    print(f"   Choice procedures: {summary['choice_procedures_count']}")
    print(f"   INSERT mode (I): {'✓' if summary['has_insert_mode'] else '✗'}")
    print(f"   UPDATE mode (U): {'✓' if summary['has_update_mode'] else '✗'}")
    print(f"   DELETE mode (D): {'✓' if summary['has_delete_mode'] else '✗'}")
    
    if result['choice_procedures']:
        print(f"\n   Procedures with Choice parameter:")
        for proc in result['choice_procedures']:
            modes = ', '.join(proc.modes_detected) or 'none detected'
            print(f"   • {proc.name} (modes: {modes})")
    
    print(f"\n✅ VALIDATION RULES ({summary['validation_rules_count']} found)")
    if result['validation_rules']:
        by_type = {}
        for rule in result['validation_rules']:
            by_type.setdefault(rule.rule_type, []).append(rule)
        
        for rule_type, rules in by_type.items():
            print(f"   {rule_type}: {len(rules)}")
            for rule in rules[:3]:  # Show first 3
                print(f"      • {rule.field_name}: {rule.laravel_rule}")
    
    print(f"\n📝 LOGGING CALLS ({summary['logging_calls_count']} found)")
    if result['logging_calls']:
        for log in result['logging_calls'][:5]:
            print(f"   • {log.location}: {log.action_param} → {log.source_param}")
    
    print("\n" + "=" * 70)


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        parser = EnhancedPASParser(sys.argv[1])
        result = parser.parse()
        print_analysis(result)
        
        # Also print Laravel validation rules
        print("\n📦 LARAVEL VALIDATION RULES:")
        rules = parser.get_laravel_validation_rules()
        for field, field_rules in rules.items():
            print(f"   '{field}' => '{"|".join(field_rules)}',")
    else:
        print("Usage: python pas_parser_enhanced.py <file.pas>")
