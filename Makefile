.PHONY: doctor herdr-plugins xcode-check xcode-install xcode-update test lint

# Python 3.11+ enables external-manifest checks; older Python 3 reports a skip.
doctor:
	python3 -B scripts/doctor.py

herdr-plugins:
	./install-herdr-plugins

xcode-check:
	./update-xcode-tools --check

# First-time Apple GUI installer, not a full Xcode installation.
xcode-install:
	./update-xcode-tools --bootstrap

# Supply the exact label printed by xcode-check; pass via environment, not shell interpolation.
xcode-update: export XCODE_TOOLS_LABEL = $(value LABEL)
xcode-update:
	@test -n "$$XCODE_TOOLS_LABEL" || { echo 'Usage: make xcode-update LABEL="Command Line Tools for Xcode-..."' >&2; exit 2; }
	./update-xcode-tools --install "$$XCODE_TOOLS_LABEL"

lint:
	bash -n setup install-packages install-extras install-herdr-plugins update-xcode-tools
	shellcheck setup install-packages install-extras install-herdr-plugins update-xcode-tools

test:
	python3 -B -m unittest discover -s tests -p 'test_*.py'
