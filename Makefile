ifeq (image,$(firstword $(MAKECMDGOALS)))
	ARGS1 := $(word 2,$(MAKECMDGOALS)) 
	ARGS2 := $(word 3,$(MAKECMDGOALS))
else
	ARGS1 := $(word 1,$(MAKECMDGOALS)) 
	ARGS2 := $(word 2,$(MAKECMDGOALS))
endif

APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=sergeypashkov
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

TARGETOS ?= $(if $(filter apple,$(ARGS1)),darwin,$(if $(filter windows,$(ARGS1)),windows,linux))
TARGETARCH ?= $(if $(filter arm arm64,$(ARGS2)),arm64,$(if $(filter amd amd64,$(ARGS2)),amd64,amd64))

linux: build
windows: build
macos: build

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build:
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -ldflags "-X="github.com/sergeypashkov/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} --build-arg TARGETOS=${TARGETOS} --build-arg TARGETARCH=${TARGETARCH}
	@echo ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} > last_image_tag

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	docker rmi $(shell cat last_image_tag)
	rm -rf kbot
	rm -rf kbot.exe

%::
	@true
    