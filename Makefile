# include .env
NOW := $(shell date +"%Y%m%d")


PHOBY: today
today:
	@echo "Today is ${NOW}"
	@touch docs/${NOW}.md

PHOBY: up
up:
	@docker compose up -d

PHOBY: down
down:
	@docker compose down

PHOBY: reset
reset:
	@make down
	@-docker image rm go-software-router-server
	@docker compose build --no-cache
	@docker compose up -d

PHOBY: bash
bash:
	docker compose exec -it --user root server bash 
