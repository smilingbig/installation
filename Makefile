check:
	shellcheck *.sh

install: install.sh
	bash install.sh

update: update.sh
	bash update.sh

remove: remove.sh
	bash remove.sh

docker_setup:
	docker build -t installtest .
	docker run -d -p 2022:22 installtest 
	docker ps

docker_connect: 
	kitty +kitten ssh test@localhost -p 2022
