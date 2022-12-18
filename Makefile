check:
	shellcheck *.sh

install: install.sh
	bash install.sh

update: update.sh
	bash update.sh

remove: remove.sh
	bash remove.sh

docker_setup:
	docker build --progress=plain --no-cache -t installtest .
	docker run -d -p 2022:22 installtest 
	docker ps -a

docker_connect: 
	ssh test@localhost -p 2022

docker_remove: dockerfile
	echo 'Not working from within Makefile currently, but if you run this command
	itll work.'
	docker rm -f $(docker ps -a | grep installtest | awk "{print $1}")
