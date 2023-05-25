# include .env
NOW := $(shell date +"%Y%m%d")


PHOBY: today
today:
	@echo "Today is ${NOW}"
	@touch docs/${NOW}.md

PHOBY: up
up:
	@docker compose up -d

PHOBY: reset
reset:
	@docker compose down
	@docker compose build --no-cache
	@docker compose up -d
	@docker compose exec -it --user root server ./init.bash

PHOBY: bash
bash:
	docker compose exec -it --user root server bash 
