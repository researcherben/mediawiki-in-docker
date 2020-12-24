
.PHONY: help
help:
	@echo "make help"
	@echo "      this message"
	@echo "==== Targets outside container ===="
	@echo "make build_mediawiki"


# step 1
build_mediawiki:
	docker build -t mediawiki_with_smw .

# step 2
first_compose: build_mediawiki
	mkdir db
	mkdir images
	cat stack.yml | sed 's/.*\.\/LocalSettings.php.*//g'  > stack_new.yml
	docker-compose --file stack_new.yml  up --force-recreate
	rm stack_new.yml

# step 3
update_php: first_compose
	cp LocalSettings.php LocalSettings.php_without_smw
	echo "enableSemantics('localhost');" >> LocalSettings.php
	docker-compose --file stack.yml  up --force-recreate -d
	container_id = `docker ps | grep mediawiki_with_smw | cut -d' ' -f1`
	docker exec -it $(container_id) php /var/www/html/maintenance/update.php

# all subsequent launches
compose:
	docker-compose --file stack.yml  up --force-recreate

# after exporting the container to an image, you'll
# need to revise stack.yml to reflect the new image name
commit_container_to_image:
	container_id = `docker ps | grep mediawiki_with_smw | cut -d' ' -f1`
	docker commit $(container_id) mediawiki_smw


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
