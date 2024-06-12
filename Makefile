SHELL := bash

.PHONY: install
install:
	@echo -n "Are you sure? [y/N] " && read ans && if [ $${ans:-'N'} != 'y' ]; then echo "exiting"; fi
	@echo
	@echo "checking system dependencies"
	@bash bin/check_deps.bash
	@echo
	@echo "installing perl dependencies"
	@cpanm -n App::Toot indirect multidimensional bareword::filehandles strictures XML::Feed DBD::SQLite
	@echo
	@echo "creating sqlite3 database"
	@bash bin/create_database.sh
	@echo
	@echo "installation is complete"
	@echo "create the cronjob and add the mastodon credentials to automate posting"
