DATA_DIR = /home/yuotsubo/data

all: setup build up

setup:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

build:
	docker compose -f srcs/docker-compose.yml build

up:
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean: down
	docker compose -f srcs/docker-compose.yml down -v
	@sudo rm -rf $(DATA_DIR)

fclean: clean
	docker system prune -af

re: fclean all

logs:
	docker compose -f srcs/docker-compose.yml logs -f

.PHONY: all setup build up down clean fclean re logs
