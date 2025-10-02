.PHONY: gen clean help

# Generate code with build_runner
gen:
	@echo "Running build_runner code generation..."
	@dart run build_runner build --delete-conflicting-outputs

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	@dart run build_runner clean

# Watch for changes and regenerate
watch:
	@echo "Watching for changes..."
	@dart run build_runner watch --delete-conflicting-outputs

# Show help
help:
	@echo "Available commands:"
	@echo "  make gen    - Generate code with build_runner"
	@echo "  make clean  - Clean generated files"
	@echo "  make watch  - Watch for changes and regenerate"
