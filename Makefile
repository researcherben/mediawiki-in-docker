

#stack = stack_with_localsettings

stack = stack_without_localsettings

#stack = stack


first-compose:
	mkdir db
	mkdir images
	cat stack.yml | sed 's/.*\.\/LocalSettings.php.*//g'  > stack_new.yml
	docker-compose --file stack_new.yml  up --force-recreate

# the following assumes "LocalSettings.php" exists
compose:
	docker-compose --file stack_new.yml  up --force-recreate


clean:
	rm -rf db images

build_mediawiki:
	docker build -t mediawiki_with_smw .


list_running_containers:
	docker ps

list_volumes:
	docker volume ls

kill_container:
	docker kill $(CONTAINER_ID)
