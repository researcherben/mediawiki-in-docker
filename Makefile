

# step 1
first-compose:
	mkdir db
	mkdir images
	cat stack.yml | sed 's/.*\.\/LocalSettings.php.*//g'  > stack_new.yml
	docker-compose --file stack_new.yml  up --force-recreate
	rm stack_new.yml

# step 2
build_mediawiki:
	docker build -t mediawiki_with_smw .

update_php:
	docker-compose --file stack.yml  up --force-recreate
	container_id = `docker ps | grep mediawiki_with_smw | cut -d' ' -f1`
	docker exec -it $(container_id) php /var/www/html/maintenance/update.php

compose:
	docker-compose --file stack.yml  up --force-recreate

clean:
	rm -rf db images

run_mw_without_db:
	docker run -it --rm mediawiki_with_smw:latest /bin/bash

list_running_containers:
	docker ps

list_volumes:
	docker volume ls

kill_container:
	docker kill $(CONTAINER_ID)
