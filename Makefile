check:
	shellcheck *.sh

install: install.sh
	bash install.sh

update: update.sh
	bash update.sh

docker_setup:
	docker build --progress=plain --no-cache -t installtest .
	docker run -d -p 2022:22 installtest 
	docker ps

docker_connect: 
	ssh test@localhost -p 2022
