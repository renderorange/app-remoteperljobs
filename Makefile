SHELL := bash
PERL_DEPS := $(shell cat cpanfile|cut -d"'" -f2)

.PHONY: install
install:
	@echo -n "Are you sure? [y/N] " && read ans && if [ $${ans:-'N'} != 'y' ]; then echo "exiting"; fi
	@echo
	@echo "checking system dependencies"
	@bash bin/check_deps.bash
	@echo
	@echo "installing perl dependencies"
	@cpanm -nq $(PERL_DEPS)
	@echo
	@echo "creating sqlite3 database"
	@bash bin/create_database.sh
	@echo
	@echo "installation is complete"
	@echo "create the cronjob and add the mastodon credentials to automate posting"

.PHONY: upgrade
upgrade:
	@echo -n "Are you sure? [y/N] " && read ans && if [ $${ans:-'N'} != 'y' ]; then echo "exiting"; fi
	@echo "updating repo"
	@git fetch && git pull
	@echo "installing perl dependencies"
	@cpanm -nq $(PERL_DEPS)
	@echo "applying database patches"
	@bash bin/apply_database_patches.bash
