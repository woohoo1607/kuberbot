APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=europe-west3-docker.pkg.dev/devops-419309/kuberbot
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

TARGETOS=linux # linux darwin windows
TARGETARCH=arm64 # arm64 amd64

define build_builder
	CGO_ENABLED=0 GOOS=$1 GOARCH=$2 go build -v -o kuberbot -ldflags "-X="github.com/woohoo1607/kuberbot/cmd.appVersion=${VERSION}
endef

define image_builder
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-$2 --build-arg TARGETOS=$1 --build-arg TARGETARCH=$2
endef

define cleaner
	rm -rf kuberbot && docker rmi ${REGISTRY}/${APP}:${VERSION}-$1
endef

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	$(call build_builder,${TARGETOS},${TARGETARCH})

linux: format get
	$(call build_builder,linux,amd64)

macos: format get
	$(call build_builder,darwin,arm64)

windows: format get
	$(call build_builder,windows,amd64)

arm: format get
	$(call build_builder,linux,arm64)

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} --build-arg TARGETOS=linux

image_linux:
	$(call image_builder,linux,amd64)

image_macos:
	$(call image_builder,darwin,arm64)

image_windows:
	$(call image_builder,windows,amd64)

image_arm:
	$(call image_builder,linux,arm64)

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	$(call cleaner,$(TARGETARCH))

clean_linux:
	$(call cleaner,amd64)

clean_macos:
	$(call cleaner,amd64)

clean_windows:
	$(call cleaner,amd64)

clean_arm:
	$(call cleaner,arm64)