# include .env
NOW := $(shell date +"%Y%m%d")


PHOBY: today
today:
	@echo "Today is ${NOW}"
	@touch docs/${NOW}.md

PHOBY: run
run:
	@go build -o curo
	@./curo
