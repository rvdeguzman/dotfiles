.PHONY: doctor status diff apply sync externals nvm-install herdr-plugins rex-keys xcode-check xcode-install xcode-update test lint

doctor:
	python3 -B scripts/doctor.py

# Copy-mode sync between home/ and $HOME. Limit to paths with PATHS=".config/rex ...".
status diff apply sync:
	./dot $@ $(PATHS)

externals:
	./install-externals

nvm-install:
	./install-nvm

herdr-plugins:
	./install-herdr-plugins

rex-keys:
	./configure-rex

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
	bash -n dot install-externals install-packages install-extras install-nvm install-herdr-plugins configure-rex update-xcode-tools
	shellcheck dot install-externals install-packages install-extras install-nvm install-herdr-plugins configure-rex update-xcode-tools
	zsh -n home/.config/zsh/zshrc.example
	zsh -n home/.config/zsh/secrets.zsh.example

test:
	python3 -B -m unittest discover -s tests -p 'test_*.py'
