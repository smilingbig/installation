check:
	shellcheck *.sh

install: install.sh
	bash install.sh

update: update.sh
	bash update.sh
