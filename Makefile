all: build

build:
	@docker build --tag=quay.io/sameersbn/nginx .

release: build
	@docker build --tag=quay.io/sameersbn/nginx:$(shell cat VERSION) .
