#!/usr/bin/env python3
"""
Enhanced Delphi to Laravel Migration CLI
Version: 2.2

Features:
- Full pattern detection (Choice:Char, permissions, logging, validations)
- Generate all Laravel components (Controller, Service, Requests, Policy, Views)
- Proper Laravel directory structure
- Better error handling with detailed messages
- Progress indicators
- Batch processing
- Interactive mode
- Configuration file support
- Colored output
- Dry-run mode
"""

import sys
import os
import json
import argparse
import traceback
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass, field
from enum import Enum
import glob


# ============================================================================
# COLORS AND FORMATTING
# ============================================================================

class Colors:
    """ANSI color codes for terminal output"""
    RESET = '\033[0m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    
    # Colors
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    
    # Background
    BG_RED = '\033[41m'
    BG_GREEN = '\033[42m'
    BG_YELLOW = '\033[43m'
    
    @classmethod
    def disable(cls):
        """Disable colors (for non-TTY output)"""
        cls.RESET = cls.BOLD = cls.DIM = ''
        cls.RED = cls.GREEN = cls.YELLOW = cls.BLUE = ''
        cls.MAGENTA = cls.CYAN = cls.WHITE = ''
        cls.BG_RED = cls.BG_GREEN = cls.BG_YELLOW = ''


# Check if output is TTY
if not sys.stdout.isatty():
    Colors.disable()


def print_header(text: str):
    """Print a header"""
    print(f"\n{Colors.BOLD}{Colors.CYAN}{'='*70}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}{text.center(70)}{Colors.RESET}")
    print(f"{Colors.BOLD}{Colors.CYAN}{'='*70}{Colors.RESET}")


def print_success(text: str):
    """Print success message"""
    print(f"{Colors.GREEN}✅ {text}{Colors.RESET}")


def print_error(text: str):
    """Print error message"""
    print(f"{Colors.RED}❌ {text}{Colors.RESET}")


def print_warning(text: str):
    """Print warning message"""
    print(f"{Colors.YELLOW}⚠️  {text}{Colors.RESET}")


def print_info(text: str):
    """Print info message"""
    print(f"{Colors.BLUE}ℹ️  {text}{Colors.RESET}")


def print_step(text: str):
    """Print step message"""
    print(f"{Colors.MAGENTA}🔧 {text}{Colors.RESET}")


def print_file(text: str, status: str = 'created'):
    """Print file status"""
    if status == 'created':
        print(f"   {Colors.GREEN}✅ {text}{Colors.RESET}")
    elif status == 'skipped':
        print(f"   {Colors.YELLOW}⏭️  {text}{Colors.RESET}")
    elif status == 'error':
        print(f"   {Colors.RED}❌ {text}{Colors.RESET}")


# ============================================================================
# ERROR HANDLING
# ============================================================================

class MigrationError(Exception):
    """Base exception for migration errors"""
    def __init__(self, message: str, details: str = None, suggestions: List[str] = None):
        self.message = message
        self.details = details
        self.suggestions = suggestions or []
        super().__init__(message)
    
    def print_error(self):
        """Print formatted error"""
        print_error(self.message)
        if self.details:
            print(f"{Colors.DIM}   {self.details}{Colors.RESET}")
        if self.suggestions:
            print(f"\n{Colors.YELLOW}   Suggestions:{Colors.RESET}")
            for s in self.suggestions:
                print(f"   • {s}")


class FileNotFoundError(MigrationError):
    """File not found error"""
    def __init__(self, filepath: str):
        super().__init__(
            f"File not found: {filepath}",
            details=f"The file '{filepath}' does not exist or is not accessible.",
            suggestions=[
                "Check if the file path is correct",
                "Ensure the file exists in the specified location",
                f"Current directory: {os.getcwd()}"
            ]
        )


class ParseError(MigrationError):
    """Error parsing a file"""
    def __init__(self, filepath: str, error: str, line: int = None):
        details = f"Error parsing '{filepath}'"
        if line:
            details += f" at line {line}"
        details += f": {error}"
        
        super().__init__(
            f"Parse error in {Path(filepath).name}",
            details=details,
            suggestions=[
                "Check if the file is a valid Delphi source file",
                "Ensure the file encoding is correct (Latin-1 or UTF-8)",
                "Try analyzing the file first: python delphi-migrate.py analyze <file>"
            ]
        )


class GenerationError(MigrationError):
    """Error generating output"""
    def __init__(self, component: str, error: str):
        super().__init__(
            f"Failed to generate {component}",
            details=str(error),
            suggestions=[
                "Check if the output directory is writable",
                "Ensure disk has enough space",
                "Try with --verbose flag for more details"
            ]
        )


class ConfigError(MigrationError):
    """Configuration error"""
    pass


# ============================================================================
# CONFIGURATION
# ============================================================================

@dataclass
class MigrationConfig:
    """Migration configuration"""
    # Paths
    output_dir: str = "./output"
    
    # Generation options
    with_audit_log: bool = True
    with_views: bool = True
    with_tests: bool = False
    with_api_resources: bool = False
    
    # Style options
    use_tailwind: bool = True
    use_alpine: bool = True
    
    # Behavior options
    overwrite: bool = False
    dry_run: bool = False
    verbose: bool = False
    
    @classmethod
    def from_file(cls, filepath: str) -> 'MigrationConfig':
        """Load config from JSON file"""
        try:
            with open(filepath) as f:
                data = json.load(f)
            return cls(**data)
        except Exception as e:
            raise ConfigError(f"Failed to load config: {e}")
    
    def to_file(self, filepath: str):
        """Save config to JSON file"""
        with open(filepath, 'w') as f:
            json.dump(self.__dict__, f, indent=2)


# ============================================================================
# PROGRESS TRACKING
# ============================================================================

class ProgressTracker:
    """Track and display progress"""
    
    def __init__(self, total: int, description: str = "Processing"):
        self.total = total
        self.current = 0
        self.description = description
        self.errors: List[str] = []
        self.warnings: List[str] = []
    
    def update(self, message: str = None):
        """Update progress"""
        self.current += 1
        self._display(message)
    
    def _display(self, message: str = None):
        """Display progress bar"""
        percent = (self.current / self.total) * 100 if self.total > 0 else 100
        bar_width = 40
        filled = int(bar_width * self.current / self.total) if self.total > 0 else bar_width
        bar = '█' * filled + '░' * (bar_width - filled)
        
        status = f"{self.current}/{self.total}"
        line = f"\r{Colors.CYAN}{self.description}:{Colors.RESET} [{bar}] {percent:5.1f}% {status}"
        
        if message:
            line += f" - {message}"
        
        print(line, end='', flush=True)
        
        if self.current >= self.total:
            print()  # New line at end
    
    def add_error(self, error: str):
        """Add error message"""
        self.errors.append(error)
    
    def add_warning(self, warning: str):
        """Add warning message"""
        self.warnings.append(warning)
    
    def summary(self):
        """Print summary"""
        print(f"\n{Colors.BOLD}Summary:{Colors.RESET}")
        print(f"   Processed: {self.current}/{self.total}")
        print(f"   Errors: {len(self.errors)}")
        print(f"   Warnings: {len(self.warnings)}")
        
        if self.errors:
            print(f"\n{Colors.RED}Errors:{Colors.RESET}")
            for e in self.errors[:5]:
                print(f"   • {e}")
            if len(self.errors) > 5:
                print(f"   ... and {len(self.errors) - 5} more")


# ============================================================================
# MAIN CLI CLASS
# ============================================================================

# Add current directory to path
SCRIPT_DIR = Path(__file__).parent.absolute()
sys.path.insert(0, str(SCRIPT_DIR / 'parsers'))
sys.path.insert(0, str(SCRIPT_DIR / 'generators'))

# Import parsers (with error handling)
try:
    from pas_parser_enhanced import EnhancedPASParser, print_analysis
    from dfm_parser_enhanced import EnhancedDFMParser, print_analysis as print_dfm_analysis
except ImportError as e:
    print_error(f"Failed to import parsers: {e}")
    print_info("Make sure all parser files are in the 'parsers' directory")
    sys.exit(1)

# Import generators (with error handling)
try:
    from request_generator import LaravelRequestGenerator, create_from_parser_result as create_request_generator
    from service_generator import LaravelServiceGenerator, create_from_parser_result as create_service_generator
    from controller_generator_enhanced import EnhancedControllerGenerator, create_from_parser_result as create_controller_generator
    from policy_generator import LaravelPolicyGenerator, create_from_parser_result as create_policy_generator
    from audit_log_generator import generate_audit_log_class, generate_migration
    from view_generator_enhanced import EnhancedViewGenerator
except ImportError as e:
    print_error(f"Failed to import generators: {e}")
    print_info("Make sure all generator files are in the 'generators' directory")
    sys.exit(1)


class DelphiMigrationCLI:
    """Enhanced CLI for Delphi to Laravel migration"""
    
    def __init__(self, config: MigrationConfig = None):
        self.config = config or MigrationConfig()
        self.output_dir = Path(self.config.output_dir)
        self._ensure_output_structure()
        
        # Statistics
        self.stats = {
            'files_processed': 0,
            'files_generated': 0,
            'errors': 0,
            'warnings': 0,
        }
    
    def _ensure_output_structure(self):
        """Create Laravel-compatible output directory structure"""
        if self.config.dry_run:
            return
        
        dirs = [
            self.output_dir / "app" / "Http" / "Controllers",
            self.output_dir / "app" / "Http" / "Requests",
            self.output_dir / "app" / "Models",
            self.output_dir / "app" / "Policies",
            self.output_dir / "app" / "Services",
            self.output_dir / "app" / "Support",
            self.output_dir / "database" / "migrations",
            self.output_dir / "resources" / "views",
            self.output_dir / "routes",
            self.output_dir / "tests" / "Feature",
            self.output_dir / "tests" / "Unit",
        ]
        
        for d in dirs:
            d.mkdir(parents=True, exist_ok=True)
    
    def _check_file_exists(self, filepath: str) -> Path:
        """Check if file exists and return Path object"""
        path = Path(filepath)
        if not path.exists():
            raise FileNotFoundError(filepath)
        return path
    
    def _write_file(self, filepath: Path, content: str, description: str = None) -> bool:
        """Write file with error handling"""
        if self.config.dry_run:
            print_file(f"{filepath.name} (dry run)", 'skipped')
            return True
        
        if filepath.exists() and not self.config.overwrite:
            print_file(f"{filepath.name} (already exists)", 'skipped')
            return False
        
        try:
            filepath.parent.mkdir(parents=True, exist_ok=True)
            filepath.write_text(content)
            print_file(filepath.name)
            self.stats['files_generated'] += 1
            return True
        except Exception as e:
            print_file(f"{filepath.name} - {e}", 'error')
            self.stats['errors'] += 1
            return False
    
    def _make_serializable(self, obj) -> Any:
        """Convert dataclasses and complex objects to serializable dicts"""
        if hasattr(obj, '__dataclass_fields__'):
            return {k: self._make_serializable(v) for k, v in obj.__dict__.items()}
        elif isinstance(obj, dict):
            return {k: self._make_serializable(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [self._make_serializable(i) for i in obj]
        elif hasattr(obj, 'value'):  # Enum
            return obj.value
        else:
            return obj
    
    def generate_model_name(self, unit_name: str) -> str:
        """Generate model name from unit name"""
        name = unit_name
        for prefix in ['Frm', 'frm', 'Fr', 'fr', 'Form', 'form', 'Unit', 'unit']:
            if name.startswith(prefix):
                name = name[len(prefix):]
                break
        
        # Convert to PascalCase
        return ''.join(word.capitalize() for word in name.split('_'))
    
    # ========================================================================
    # ANALYZE COMMANDS
    # ========================================================================
    
    def analyze(self, pas_file: str) -> Dict[str, Any]:
        """Analyze a PAS file and show detected patterns"""
        filepath = self._check_file_exists(pas_file)
        
        print_header("ANALYZING PAS FILE")
        print_info(f"File: {filepath}")
        
        try:
            parser = EnhancedPASParser(str(filepath))
            result = parser.parse()
            
            print_analysis(result)
            
            # Save analysis to JSON
            analysis_file = self.output_dir / f"{result['unit_name']}_analysis.json"
            serializable = self._make_serializable(result)
            
            if not self.config.dry_run:
                with open(analysis_file, 'w') as f:
                    json.dump(serializable, f, indent=2)
                print_info(f"Analysis saved: {analysis_file}")
            
            self.stats['files_processed'] += 1
            return result
            
        except Exception as e:
            raise ParseError(pas_file, str(e))
    
    def analyze_dfm(self, dfm_file: str) -> Dict[str, Any]:
        """Analyze a DFM file and show detected components"""
        filepath = self._check_file_exists(dfm_file)
        
        print_header("ANALYZING DFM FILE")
        print_info(f"File: {filepath}")
        
        try:
            parser = EnhancedDFMParser(str(filepath))
            result = parser.parse()
            
            print_dfm_analysis(result)
            
            # Save analysis to JSON
            analysis_file = self.output_dir / f"{result['form_name']}_dfm_analysis.json"
            serializable = self._make_serializable(result)
            
            if not self.config.dry_run:
                with open(analysis_file, 'w') as f:
                    json.dump(serializable, f, indent=2, default=str)
                print_info(f"Analysis saved: {analysis_file}")
            
            self.stats['files_processed'] += 1
            return result
            
        except Exception as e:
            raise ParseError(dfm_file, str(e))
    
    # ========================================================================
    # MIGRATION COMMANDS
    # ========================================================================
    
    def migrate(self, pas_file: str, dfm_file: str = None, model_name: str = None) -> Dict[str, Any]:
        """Full migration: analyze + generate all components"""
        filepath = self._check_file_exists(pas_file)
        dfm_filepath = self._check_file_exists(dfm_file) if dfm_file else None
        
        print_header("DELPHI TO LARAVEL MIGRATION")
        
        if self.config.dry_run:
            print_warning("DRY RUN MODE - No files will be created")
        
        # Parse PAS file
        try:
            parser = EnhancedPASParser(str(filepath))
            result = parser.parse()
        except Exception as e:
            raise ParseError(pas_file, str(e))
        
        print_analysis(result)
        
        # Determine model name
        if not model_name:
            model_name = self.generate_model_name(result['unit_name'])
        
        module_name = model_name.lower()
        
        print(f"\n{Colors.BOLD}📊 Migration Target:{Colors.RESET}")
        print(f"   Unit: {result['unit_name']}")
        print(f"   Model: {model_name}")
        print(f"   Module: {module_name}")
        print(f"   Output: {self.output_dir.absolute()}")
        
        generated_files = []
        
        # 1. Generate Request Classes
        print_step("Generating Request Classes...")
        try:
            request_gen = create_request_generator(result, model_name)
            requests = request_gen.generate_all()
            
            request_dir = self.output_dir / "app" / "Http" / "Requests" / model_name
            
            for filename, content in requests.items():
                filepath = request_dir / filename
                if self._write_file(filepath, content):
                    generated_files.append(str(filepath))
        except Exception as e:
            raise GenerationError("Request classes", str(e))
        
        # 2. Generate Service
        print_step("Generating Service...")
        try:
            service_gen = create_service_generator(result, model_name)
            service_content = service_gen.generate()
            
            service_file = self.output_dir / "app" / "Services" / f"{model_name}Service.php"
            if self._write_file(service_file, service_content):
                generated_files.append(str(service_file))
        except Exception as e:
            raise GenerationError("Service class", str(e))
        
        # 3. Generate Controller
        print_step("Generating Controller...")
        try:
            controller_gen = create_controller_generator(result, model_name)
            controller_content = controller_gen.generate()
            
            controller_file = self.output_dir / "app" / "Http" / "Controllers" / f"{model_name}Controller.php"
            if self._write_file(controller_file, controller_content):
                generated_files.append(str(controller_file))
        except Exception as e:
            raise GenerationError("Controller class", str(e))
        
        # 4. Generate Policy
        print_step("Generating Policy...")
        try:
            policy_gen = create_policy_generator(result, model_name)
            policy_content = policy_gen.generate()
            
            policy_file = self.output_dir / "app" / "Policies" / f"{model_name}Policy.php"
            if self._write_file(policy_file, policy_content):
                generated_files.append(str(policy_file))
        except Exception as e:
            raise GenerationError("Policy class", str(e))
        
        # 5. Generate AuditLog support
        if self.config.with_audit_log:
            print_step("Generating AuditLog Support...")
            try:
                audit_file = self.output_dir / "app" / "Support" / "AuditLog.php"
                if self._write_file(audit_file, generate_audit_log_class()):
                    generated_files.append(str(audit_file))
                
                migration_name = f"{datetime.now().strftime('%Y_%m_%d_%H%M%S')}_create_log_activity_table.php"
                migration_file = self.output_dir / "database" / "migrations" / migration_name
                
                # Check if migration already exists
                existing_migrations = list((self.output_dir / "database" / "migrations").glob("*log_activity*.php"))
                if not existing_migrations:
                    if self._write_file(migration_file, generate_migration()):
                        generated_files.append(str(migration_file))
                else:
                    print_file("log_activity migration (already exists)", 'skipped')
            except Exception as e:
                raise GenerationError("AuditLog support", str(e))
        
        # 6. Generate Routes
        print_step("Generating Routes...")
        try:
            routes_content = self._generate_routes(model_name, module_name)
            routes_file = self.output_dir / "routes" / f"{module_name}_routes.php"
            if self._write_file(routes_file, routes_content):
                generated_files.append(str(routes_file))
        except Exception as e:
            raise GenerationError("Routes", str(e))
        
        # 7. Generate Views
        if self.config.with_views:
            print_step("Generating Views...")
            try:
                view_gen = EnhancedViewGenerator(model_name, module_name)
                
                # Add fields from DFM if provided
                if dfm_filepath:
                    dfm_parser = EnhancedDFMParser(str(dfm_filepath))
                    dfm_result = dfm_parser.parse()
                    
                    for field in dfm_result.get('fields', []):
                        field_name = field.field_name if hasattr(field, 'field_name') else field.get('field_name', '')
                        if field_name:
                            view_gen.add_field(
                                name=field_name.lower(),
                                label=field.caption if hasattr(field, 'caption') else field.get('caption', field_name),
                                input_type=field.input_type if hasattr(field, 'input_type') else field.get('input_type', 'text'),
                                required=field.required if hasattr(field, 'required') else field.get('required', False),
                                max_length=field.max_length if hasattr(field, 'max_length') else field.get('max_length', 0),
                            )
                else:
                    # Add fields from validation rules
                    for rule in result.get('validation_rules', []):
                        if hasattr(rule, 'field_name') and rule.field_name and rule.field_name.lower() != 'unknown':
                            view_gen.add_field(
                                name=rule.field_name.lower(),
                                label=rule.field_name.replace('_', ' ').title(),
                                input_type='text',
                                required=(rule.rule_type == 'required' if hasattr(rule, 'rule_type') else False)
                            )
                
                views = view_gen.generate_all()
                view_dir = self.output_dir / "resources" / "views" / module_name
                
                for filename, content in views.items():
                    filepath = view_dir / filename
                    if self._write_file(filepath, content):
                        generated_files.append(str(filepath))
            except Exception as e:
                raise GenerationError("Views", str(e))
        
        # Save migration report
        report = {
            'source_file': str(pas_file),
            'dfm_file': str(dfm_file) if dfm_file else None,
            'model_name': model_name,
            'module_name': module_name,
            'generated_at': datetime.now().isoformat(),
            'dry_run': self.config.dry_run,
            'files_generated': generated_files,
            'patterns_detected': {
                'permissions': result['summary']['permissions_found'],
                'choice_procedures': result['summary']['choice_procedures_count'],
                'validation_rules': result['summary']['validation_rules_count'],
                'logging_calls': result['summary']['logging_calls_count'],
                'has_insert_mode': result['summary']['has_insert_mode'],
                'has_update_mode': result['summary']['has_update_mode'],
                'has_delete_mode': result['summary']['has_delete_mode'],
            },
            'stats': self.stats
        }
        
        if not self.config.dry_run:
            report_file = self.output_dir / f"{model_name}_migration_report.json"
            with open(report_file, 'w') as f:
                json.dump(report, f, indent=2)
        
        # Print summary
        print_header("MIGRATION COMPLETE")
        print(f"\n{Colors.BOLD}📁 Output directory:{Colors.RESET} {self.output_dir.absolute()}")
        print(f"{Colors.BOLD}📊 Files generated:{Colors.RESET} {len(generated_files)}")
        
        if self.stats['errors'] > 0:
            print(f"{Colors.RED}❌ Errors: {self.stats['errors']}{Colors.RESET}")
        
        print(f"\n{Colors.BOLD}📋 Generated Files:{Colors.RESET}")
        for f in generated_files:
            print(f"   • {Path(f).relative_to(self.output_dir)}")
        
        print(f"\n{Colors.GREEN}⏱️  Estimated time saved: ~8-12 hours of manual coding{Colors.RESET}")
        
        self.stats['files_processed'] += 1
        return report
    
    # ========================================================================
    # BATCH PROCESSING
    # ========================================================================
    
    def batch_migrate(self, source_dir: str, pattern: str = "*.pas") -> Dict[str, Any]:
        """Migrate multiple files"""
        source_path = Path(source_dir)
        if not source_path.exists():
            raise FileNotFoundError(source_dir)
        
        # Find all matching files
        pas_files = list(source_path.glob(pattern))
        
        if not pas_files:
            print_warning(f"No files matching '{pattern}' found in {source_dir}")
            return {'processed': 0, 'success': 0, 'failed': 0}
        
        print_header(f"BATCH MIGRATION: {len(pas_files)} files")
        
        progress = ProgressTracker(len(pas_files), "Migrating")
        
        results = {
            'processed': 0,
            'success': 0,
            'failed': 0,
            'files': []
        }
        
        for pas_file in pas_files:
            try:
                # Find matching DFM file
                dfm_file = pas_file.with_suffix('.dfm')
                dfm_path = str(dfm_file) if dfm_file.exists() else None
                
                self.migrate(str(pas_file), dfm_path)
                results['success'] += 1
                results['files'].append({'file': str(pas_file), 'status': 'success'})
                
            except MigrationError as e:
                results['failed'] += 1
                results['files'].append({'file': str(pas_file), 'status': 'failed', 'error': e.message})
                progress.add_error(f"{pas_file.name}: {e.message}")
                
            except Exception as e:
                results['failed'] += 1
                results['files'].append({'file': str(pas_file), 'status': 'failed', 'error': str(e)})
                progress.add_error(f"{pas_file.name}: {e}")
            
            results['processed'] += 1
            progress.update(pas_file.name)
        
        progress.summary()
        return results
    
    # ========================================================================
    # VERIFICATION
    # ========================================================================
    
    def verify(self) -> Dict[str, Any]:
        """Verify generated files"""
        print_header("VERIFYING OUTPUT")
        print_info(f"Directory: {self.output_dir}")
        
        expected = {
            'Controllers': self.output_dir / 'app' / 'Http' / 'Controllers',
            'Requests': self.output_dir / 'app' / 'Http' / 'Requests',
            'Services': self.output_dir / 'app' / 'Services',
            'Policies': self.output_dir / 'app' / 'Policies',
            'Support': self.output_dir / 'app' / 'Support',
            'Views': self.output_dir / 'resources' / 'views',
            'Routes': self.output_dir / 'routes',
            'Migrations': self.output_dir / 'database' / 'migrations',
        }
        
        results = {}
        total_files = 0
        
        for name, path in expected.items():
            if path.exists():
                files = list(path.rglob('*.php')) + list(path.rglob('*.blade.php'))
                results[name] = {
                    'exists': True,
                    'files': [str(f.relative_to(self.output_dir)) for f in files],
                    'count': len(files)
                }
                total_files += len(files)
                print_success(f"{name}: {len(files)} files")
            else:
                results[name] = {'exists': False, 'files': [], 'count': 0}
                print_warning(f"{name}: not found")
        
        print(f"\n{Colors.BOLD}Total files: {total_files}{Colors.RESET}")
        
        return results
    
    # ========================================================================
    # HELPER METHODS
    # ========================================================================
    
    def _generate_routes(self, model_name: str, module_name: str) -> str:
        """Generate routes file"""
        return f'''<?php

use App\\Http\\Controllers\\{model_name}Controller;
use Illuminate\\Support\\Facades\\Route;

/*
|--------------------------------------------------------------------------
| {model_name} Routes
|--------------------------------------------------------------------------
|
| Routes for {model_name} module
| Include this file in routes/web.php:
|   require __DIR__.'/{module_name}_routes.php';
|
*/

Route::middleware(['auth'])->group(function () {{
    // Resource routes (index, create, store, show, edit, update, destroy)
    Route::resource('{module_name}', {model_name}Controller::class);

    // Additional routes
    Route::prefix('{module_name}')->name('{module_name}.')->group(function () {{
        // Export to Excel
        Route::get('export', [{model_name}Controller::class, 'export'])->name('export');

        // Print
        Route::get('{{id}}/print', [{model_name}Controller::class, 'print'])->name('print');

        // Restore soft-deleted
        Route::post('{{id}}/restore', [{model_name}Controller::class, 'restore'])->name('restore');
    }});
}});
'''
    
    def init_config(self, output_file: str = "delphi-migrate.json"):
        """Initialize configuration file"""
        config = MigrationConfig()
        config.to_file(output_file)
        print_success(f"Configuration file created: {output_file}")
        print_info("Edit this file to customize migration settings")


# ============================================================================
# INTERACTIVE MODE
# ============================================================================

def interactive_mode():
    """Interactive CLI mode"""
    print_header("DELPHI TO LARAVEL MIGRATION - INTERACTIVE MODE")
    
    print(f"\n{Colors.CYAN}Welcome! This wizard will guide you through the migration process.{Colors.RESET}\n")
    
    # Get PAS file
    pas_file = input(f"{Colors.BOLD}Enter PAS file path:{Colors.RESET} ").strip()
    if not pas_file:
        print_error("PAS file is required")
        return
    
    if not Path(pas_file).exists():
        print_error(f"File not found: {pas_file}")
        return
    
    # Check for DFM file
    dfm_file = Path(pas_file).with_suffix('.dfm')
    use_dfm = None
    if dfm_file.exists():
        use_dfm = input(f"{Colors.BOLD}Found {dfm_file.name}. Use it? [Y/n]:{Colors.RESET} ").strip().lower()
        use_dfm = str(dfm_file) if use_dfm != 'n' else None
    
    # Get model name
    suggested = ''.join(word.capitalize() for word in Path(pas_file).stem.replace('Frm', '').replace('frm', '').split('_'))
    model_name = input(f"{Colors.BOLD}Model name [{suggested}]:{Colors.RESET} ").strip()
    model_name = model_name or suggested
    
    # Get output directory
    output_dir = input(f"{Colors.BOLD}Output directory [./output]:{Colors.RESET} ").strip()
    output_dir = output_dir or "./output"
    
    # Options
    print(f"\n{Colors.BOLD}Options:{Colors.RESET}")
    with_views = input("  Generate views? [Y/n]: ").strip().lower() != 'n'
    with_audit_log = input("  Generate AuditLog? [Y/n]: ").strip().lower() != 'n'
    
    # Confirm
    print(f"\n{Colors.BOLD}Summary:{Colors.RESET}")
    print(f"  PAS file: {pas_file}")
    print(f"  DFM file: {use_dfm or 'None'}")
    print(f"  Model: {model_name}")
    print(f"  Output: {output_dir}")
    print(f"  Views: {'Yes' if with_views else 'No'}")
    print(f"  AuditLog: {'Yes' if with_audit_log else 'No'}")
    
    confirm = input(f"\n{Colors.BOLD}Proceed? [Y/n]:{Colors.RESET} ").strip().lower()
    if confirm == 'n':
        print_info("Migration cancelled")
        return
    
    # Run migration
    config = MigrationConfig(
        output_dir=output_dir,
        with_views=with_views,
        with_audit_log=with_audit_log
    )
    
    cli = DelphiMigrationCLI(config)
    
    try:
        cli.migrate(pas_file, use_dfm, model_name)
    except MigrationError as e:
        e.print_error()
    except Exception as e:
        print_error(f"Unexpected error: {e}")
        if config.verbose:
            traceback.print_exc()


# ============================================================================
# MAIN
# ============================================================================

def main():
    """Main CLI entry point"""
    parser = argparse.ArgumentParser(
        description='Enhanced Delphi to Laravel Migration CLI v2.2',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
{Colors.BOLD}Examples:{Colors.RESET}
  {Colors.CYAN}# Analyze PAS file{Colors.RESET}
  %(prog)s analyze FrmAktiva.pas
  
  {Colors.CYAN}# Analyze DFM file{Colors.RESET}
  %(prog)s analyze-dfm FrmAktiva.dfm
  
  {Colors.CYAN}# Full migration{Colors.RESET}
  %(prog)s migrate FrmAktiva.pas
  %(prog)s migrate FrmAktiva.pas --dfm FrmAktiva.dfm --model Aktiva
  
  {Colors.CYAN}# Batch migration{Colors.RESET}
  %(prog)s batch ./delphi-src --pattern "Frm*.pas"
  
  {Colors.CYAN}# Interactive mode{Colors.RESET}
  %(prog)s interactive
  
  {Colors.CYAN}# Verify output{Colors.RESET}
  %(prog)s verify

{Colors.BOLD}Configuration:{Colors.RESET}
  %(prog)s init-config           # Create config file
  %(prog)s migrate --config delphi-migrate.json
        """
    )
    
    # Global options
    parser.add_argument('--output', '-o', default='./output', help='Output directory')
    parser.add_argument('--config', '-c', help='Configuration file')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    parser.add_argument('--dry-run', action='store_true', help='Dry run (no files created)')
    parser.add_argument('--overwrite', action='store_true', help='Overwrite existing files')
    parser.add_argument('--no-color', action='store_true', help='Disable colored output')
    
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    
    # Analyze PAS command
    analyze_parser = subparsers.add_parser('analyze', help='Analyze PAS file')
    analyze_parser.add_argument('file', help='PAS file to analyze')
    
    # Analyze DFM command
    analyze_dfm_parser = subparsers.add_parser('analyze-dfm', help='Analyze DFM file')
    analyze_dfm_parser.add_argument('file', help='DFM file to analyze')
    
    # Migrate command
    migrate_parser = subparsers.add_parser('migrate', help='Full migration')
    migrate_parser.add_argument('file', help='PAS file to migrate')
    migrate_parser.add_argument('--dfm', help='DFM file (optional)')
    migrate_parser.add_argument('--model', help='Model name (auto-detected if not provided)')
    migrate_parser.add_argument('--no-views', action='store_true', help='Skip view generation')
    migrate_parser.add_argument('--no-audit-log', action='store_true', help='Skip AuditLog generation')
    
    # Batch command
    batch_parser = subparsers.add_parser('batch', help='Batch migration')
    batch_parser.add_argument('directory', help='Source directory')
    batch_parser.add_argument('--pattern', default='*.pas', help='File pattern (default: *.pas)')
    
    # Verify command
    verify_parser = subparsers.add_parser('verify', help='Verify generated files')
    
    # Interactive command
    interactive_parser = subparsers.add_parser('interactive', help='Interactive mode')
    
    # Init config command
    init_parser = subparsers.add_parser('init-config', help='Initialize config file')
    init_parser.add_argument('--file', default='delphi-migrate.json', help='Config file name')
    
    # Generate specific components
    gen_req_parser = subparsers.add_parser('generate-requests', help='Generate only Request classes')
    gen_req_parser.add_argument('file', help='PAS file')
    gen_req_parser.add_argument('--model', required=True, help='Model name')
    
    gen_svc_parser = subparsers.add_parser('generate-service', help='Generate only Service class')
    gen_svc_parser.add_argument('file', help='PAS file')
    gen_svc_parser.add_argument('--model', required=True, help='Model name')
    
    args = parser.parse_args()
    
    # Handle no-color
    if args.no_color:
        Colors.disable()
    
    # Handle no command
    if not args.command:
        parser.print_help()
        sys.exit(0)
    
    # Handle interactive mode
    if args.command == 'interactive':
        interactive_mode()
        return
    
    # Load or create config
    if args.config and Path(args.config).exists():
        config = MigrationConfig.from_file(args.config)
    else:
        config = MigrationConfig()
    
    # Override config with CLI args
    config.output_dir = args.output
    config.verbose = args.verbose
    config.dry_run = args.dry_run
    config.overwrite = args.overwrite
    
    if hasattr(args, 'no_views'):
        config.with_views = not args.no_views
    if hasattr(args, 'no_audit_log'):
        config.with_audit_log = not args.no_audit_log
    
    # Create CLI instance
    cli = DelphiMigrationCLI(config)
    
    try:
        # Execute command
        if args.command == 'analyze':
            cli.analyze(args.file)
        
        elif args.command == 'analyze-dfm':
            cli.analyze_dfm(args.file)
        
        elif args.command == 'migrate':
            cli.migrate(
                args.file,
                dfm_file=args.dfm,
                model_name=args.model
            )
        
        elif args.command == 'batch':
            cli.batch_migrate(args.directory, args.pattern)
        
        elif args.command == 'verify':
            cli.verify()
        
        elif args.command == 'init-config':
            cli.init_config(args.file)
        
        elif args.command == 'generate-requests':
            filepath = cli._check_file_exists(args.file)
            parser_obj = EnhancedPASParser(str(filepath))
            result = parser_obj.parse()
            
            request_gen = create_request_generator(result, args.model)
            requests = request_gen.generate_all()
            
            request_dir = cli.output_dir / "app" / "Http" / "Requests" / args.model
            
            print_step(f"Generating Request classes for {args.model}...")
            for filename, content in requests.items():
                filepath = request_dir / filename
                cli._write_file(filepath, content)
        
        elif args.command == 'generate-service':
            filepath = cli._check_file_exists(args.file)
            parser_obj = EnhancedPASParser(str(filepath))
            result = parser_obj.parse()
            
            service_gen = create_service_generator(result, args.model)
            content = service_gen.generate()
            
            service_file = cli.output_dir / "app" / "Services" / f"{args.model}Service.php"
            
            print_step(f"Generating Service class for {args.model}...")
            cli._write_file(service_file, content)
    
    except MigrationError as e:
        e.print_error()
        sys.exit(1)
    
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Migration cancelled by user{Colors.RESET}")
        sys.exit(130)
    
    except Exception as e:
        print_error(f"Unexpected error: {e}")
        if config.verbose:
            traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
