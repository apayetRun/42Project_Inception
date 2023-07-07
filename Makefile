VOLUME_FOLDER_HTML = $(HOME)/data/html
VOLUME_FOLDER_MYSQL = $(HOME)/data/mysql
DOCKER_CONFIG=$(HOME)/.docker

#if exist return 0
ENV_FILE_EXIST=$(shell ls ./srcs/.env 2>&1 | grep -i "no such file" | wc -w)

DOCKER_LIST_RUNNING=$(shell docker ps -qa | wc -w)
DOCKER_IMAGES=$(shell docker images -qa | wc -w)
DOCKER_NETWORK=$(shell docker network ls -q | wc -w)
DOCKER_VOLUME=$(shell docker volume ls -q | wc -w)

DOCKER_OUT_LIST_RUN=$(shell docker ps -qa)
DOCKER_OUT_IMAGES=$(shell docker images -qa )
DOCKER_OUT_NETWORK=$(shell docker network ls -q)
DOCKER_OUT_VOLUME=$(shell docker volume ls -q)

SERVER_NAME_REGISTRATION= /etc/hosts.OLD
SERVER_NAME_REGISTRED=$(shell ls $(SERVER_NAME_REGISTRATION) 2>&1 | grep -i "no such file" | wc -w)

all :  check_env_file
	make register_server_name -C .
	make build -C .
	make create_folder -C .
	make start -C .

check_env_file: 
ifeq ($(ENV_FILE_EXIST), 0)
	@echo "\033[0;32menv file exist\033[0m"
else
	@echo "env file not found"
	@echo "The subject require to use a .env file you need to create it"
	@echo "This is an example, dont use this credential value for production, cause really unsecure"
	@echo "The subject require admin user and regular user set value for the evaluation"
	@echo "\
\033[0;31mMYSQL_ROOT_PASSWORD=root_password\n\
MYSQL_USER=user_inception\n\
MYSQL_PASSWORD=password\n\
MYSQL_DATABASE=wp_inception\n\
\
WP_ADMIN_USER=master_account\n\
WP_ADMIN_PASSWORD=master_password\n\
WP_ADMIN_EMAIL=master_email@example.com\n\
WP_REGULAR_USER=regular_user\n\
WP_REGULAR_PASSWORD=regular_password\n\
WP_REGULAR_EMAIL=regular_email@example.com\033[0m"
	@make -s err -C .
endif

err:
	$(error please create the .env fil with the correct value)

remove_volume_file:
	sudo rm -rf $(VOLUME_FOLDER_MYSQL) $(VOLUME_FOLDER_HTML)

print_folder_config:
	@echo $(VOLUME_FOLDER_HTML)
	@echo $(VOLUME_FOLDER_MYSQL)

## VM PART START
prepare_vm_after_fresh_install:
	make -C . update_upgrade_vm
	make -C . install_docker
	make -C . register_server_name

update_upgrade_vm:
	sudo apt update && sudo apt safe-upgrade -y

install_docker:
	sudo apt install docker.io

register_server_name:
ifeq ($(SERVER_NAME_REGISTRED), 0)
	@echo "Server Name already registred to /etc/hosts"
else
	sudo sh -c 'cp /etc/hosts /etc/hosts.OLD'
	sudo sh -c 'echo "127.0.0.1	apayet.42.fr" >> /etc/hosts'
	@echo "Creating a backup of /etc/hosts to /etc/hosts.OLD with host provided"
endif
	

unregister_server_name:
	@sudo sh -c 'cp /etc/hosts.OLD /etc/hosts 2>/dev/null; echo "Rollback hosts file"'
	@sudo sh -c 'rm -rf /etc/hosts.OLD'

install_docker_compose_plugin:
	echo "mkdir -p $(DOCKER_CONFIG)/cli-plugins" > ./vm_installer_plugin.sh
	echo "curl -SL https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-linux-x86_64 -o $(DOCKER_CONFIG)/cli-plugins/docker-compose" >> ./vm_installer_plugin.sh
	echo "chmod +x $(DOCKER_CONFIG)/cli-plugins/docker-compose" >> ./vm_installer_plugin.sh
	chmod +x ./vm_installer_plugin.sh
	sh ./vm_installer_plugin.sh
	rm -f ./vm_installer_plugin.sh
	docker compose version

create_folder:
	mkdir -p $(VOLUME_FOLDER_HTML)
	mkdir -p $(VOLUME_FOLDER_MYSQL)

## VM PART END

start:
	docker compose -f ./srcs/docker-compose.yml up

stop:
	docker compose -f ./srcs/docker-compose.yml down

build:
	docker compose -f ./srcs/docker-compose.yml build

status:
	docker system df

clean:
	docker system prune -af

stop_docker_container:
ifeq ($(DOCKER_LIST_RUNNING), 0)
	@echo "all container is stopped"
else
	docker stop $(DOCKER_OUT_LIST_RUN)
	docker rm $(DOCKER_OUT_LIST_RUN);
endif

fclean:
	@echo "You must use sudo for full clean content data, so please auth if prompted else just use clean"
	sudo rm -rf $(VOLUME_FOLDER_HTML) $(VOLUME_FOLDER_MYSQL)
	make unregister_server_name -C .
	make stop_docker_container -C .
ifeq ($(DOCKER_IMAGES), 0)
	@echo "Images already suppressed"
else
	docker rmi -f $(DOCKER_OUT_IMAGES);
endif
ifeq ($(DOCKER_VOLUME), 0)
	@echo "Volumes already suppressed"
else
	@echo "SUPPRESS volume of docker "
	docker volume rm $(DOCKER_OUT_VOLUME);
endif
	make remove_network -C .

remove_network:
	docker network rm $(DOCKER_OUT_NETWORK) 2>/dev/null | return 0;

re : 
	make stop -C .
	make fclean -C .
	make all -C .
