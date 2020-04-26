PY := python3

PY_FILES := common.py

.PHONY: help dev tc lint fmt clean

help:
	@echo "Targets:"
	@echo "help    show this help message"
	@echo "dev     install dev dependencies"
	@echo "tc      run typechecker"
	@echo "lint    run linter"
	@echo "fmt     format code"
	@echo "clean   remove temp files"

dev:
	$(PY) -m pip install -r requirements-dev.txt

tc:
	$(PY) -m mypy $(PY_FILES)

lint:
	$(PY) -m pylint $(PY_FILES)

fmt:
	$(PY) -m black .

clean:
	rm -rf __pycache__ .mypy_cache *.pyc
