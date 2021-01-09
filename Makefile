
.PHONY: help
help:
	@echo "make help"
	@echo "      this message"
	@echo "==== Targets outside container ===="
	@echo "first run"
	@echo "    make first_compose"
	@echo "use a browser to visit localhost:8080 and configure LocalSettings.php"
	@echo "then run"
	@echo "    make update_php"


# step 1: create a MW image that includes SMW extension and dependencies
# by running composer within the Dockerfile build process
build_mediawiki:
	docker build -t mediawiki_with_smw .

# step 2: initialization of MW to create LocalSettings.php
# for database config, see
# https://github.com/researcherben/mediawiki-in-docker/blob/main/screenshots_of_wiki/installation_20_dbconnect.png
first_compose: build_mediawiki
	rm -rf db images stack_new.yml
	mkdir db
	mkdir images
	cat stack.yml | sed 's/.*\.\/LocalSettings.php.*//g'  > stack_new.yml
	docker-compose --file stack_new.yml  up --force-recreate -d
	/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome http://localhost:8080

# step 3: start the docker-compose but don't visit the wiki yet
# need to add "enableSemantics" and then run php update
# caveat: is evaluated as Make reads the Makefile, not as the target is executed
update_php: #first_compose
	rm stack_new.yml
	echo "enableSemantics('localhost');" >> LocalSettings.php
	docker-compose --file stack.yml  up --force-recreate -d
	$(eval container_id := $(shell docker ps | grep mediawiki_with_smw | cut -d' ' -f1))
	#container_id=`docker ps | grep mediawiki_with_smw | cut -d' ' -f1`
	# docker exec -it ${container_id} php /var/www/html/maintenance/update.php
	docker exec -it $(container_id) php /var/www/html/maintenance/update.php

# at this point you have a fully install SMW extension! Hooray.
# changes to content are saved in the /db folder

# all subsequent launches
compose:
	docker-compose --file stack.yml  up --force-recreate

enter_running_image:
	$(eval container_id := $(shell docker ps | grep mediawiki_with_smw | cut -d' ' -f1))
	docker exec -it $(container_id) /bin/bash

# OPTIONAL; not required
# after exporting the container to an image, you'll
# need to revise stack.yml to reflect the new image name
commit_container_to_image:
	$(eval container_id := $(shell docker ps | grep mediawiki | cut -d' ' -f1))
	#container_id = `docker ps | grep mediawiki_with_smw | cut -d' ' -f1`
	docker commit $(container_id) mediawiki_and_smw_installed


clean:
	rm -rf db images

run_mw_without_db:
	docker run -it --rm mediawiki_with_smw:latest /bin/bash

list_running_containers:
	docker ps

list_volumes:
	docker volume ls

# the following assumes you've passed CONTAINER_ID as an argument to make
kill_container:
	$(eval container_id := $(shell docker ps | grep mediawiki_with_smw | cut -d' ' -f1))
	docker kill $(container_id)
	$(eval container_id := $(shell docker ps | grep mariadb | cut -d' ' -f1))
	docker kill $(container_id)
