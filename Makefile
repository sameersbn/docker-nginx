all: build

build:
	@docker build --tag=sameersbn/nginx .

release: build
	@docker build --tag=sameersbn/nginx:$(shell cat VERSION) .
