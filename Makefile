all: build

build:
	@docker build --tag=${USER}/nginx .

release: build
	@docker build --tag=${USER}/nginx:$(shell cat VERSION) .
