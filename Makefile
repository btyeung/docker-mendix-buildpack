VERSION=$(shell cat docker-buildpack.version)
CF_BUILDPACK_VERSION=$(shell cat cf-buildpack.version)
ROOTFS_VERSION=$(shell cat rootfs.version)

#modify this per project name
#TODO: parameterize

PROJECT_NAME=PS_Starter.mpk

unpack-project:
	rm -rf build
	mkdir -p build
	unzip downloads/$(PROJECT_NAME) -d build/

get-sample:
	if [ -d build ]; then rm -rf build; fi
	if [ -d downloads ]; then rm -rf downloads; fi
	mkdir -p downloads build
	wget https://s3-eu-west-1.amazonaws.com/mx-buildpack-ci/BuildpackTestApp-mx-7-16.mda -O downloads/application.mpk
	unzip downloads/application.mpk -d build/

build-image:
	docker build \
	--build-arg BUILD_PATH=build \
	--build-arg CF_BUILDPACK=$(CF_BUILDPACK_VERSION) \
	--build-arg ROOTFS_IMAGE=$(ROOTFS_VERSION) \
	-t mendix/mendix-buildpack:$(VERSION) .

build-image-extract:
	docker build \
	-f Dockerfile-extract \
	--build-arg BUILD_PATH=build \
	--build-arg CF_BUILDPACK=$(CF_BUILDPACK_VERSION) \
	--build-arg ROOTFS_IMAGE=$(ROOTFS_VERSION) \
	-t mx-build:latest .

build-extract: unpack-project build-image-extract
	./extract.sh $(PROJECT_NAME)
	
build-auto-extract: build-image-extract
	./extract.sh $(PROJECT_NAME)

#TODO: add parameter name of mda file
extract-only:
	./extract.sh

test-container:
	tests/test-generic.sh tests/docker-compose-postgres.yml
	tests/test-generic.sh tests/docker-compose-sqlserver.yml
	tests/test-generic.sh tests/docker-compose-azuresql.yml

run-container:
	BUILDPACK_VERSION=$(VERSION) docker-compose -f tests/docker-compose-mysql.yml up
