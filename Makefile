IMAGE_NAME=core-store
DEFAULT_REG=databoxsystems
VERSION=latest

.PHONY: all
all: build-amd64 build-arm64v8 publish-images

define gitPullorClone
	git -C ./build/$(2) pull || git clone -b $(3) $(1) ./build/$(2)
endef

.PHONY: build-zest-amd64
build-zest-amd64:
	$(call gitPullorClone, https://github.com/me-box/zestdb.git,zestdb,master)
	cd ./build/zestdb && docker build -t $(DEFAULT_REG)/zestdb-amd64:$(VERSION) -f Dockerfile .


.PHONY: build-zest-arm64v8
build-zest-arm64v8:
	$(call gitPullorClone, https://github.com/me-box/zestdb.git,zestdb,master)
	cd ./build/zestdb && docker build -t $(DEFAULT_REG)/zestdb-arm64v8:$(VERSION) -f Dockerfile-aarch64 .


.PHONY: build-amd64
build-amd64:
	$(MAKE) build-zest-amd64
	docker build -t $(DEFAULT_REG)/$(IMAGE_NAME)-amd64:$(VERSION) --build-arg ZEST_FROM=$(DEFAULT_REG)/zestdb-amd64:$(VERSION) . $(OPTS)

.PHONY: build-arm64v8
build-arm64v8:
	$(MAKE) build-zest-arm64v8
	docker build -t $(DEFAULT_REG)/$(IMAGE_NAME)-arm64v8:$(VERSION) --build-arg ZEST_FROM=$(DEFAULT_REG)/zestdb-arm64v8:$(VERSION) . $(OPTS)

.PHONY: publish-images
publish-images:
	docker push $(DEFAULT_REG)/zestdb-amd64:$(VERSION)
	docker push $(DEFAULT_REG)/$(IMAGE_NAME)-amd64:$(VERSION)
	docker push $(DEFAULT_REG)/$(IMAGE_NAME)-arm64v8:$(VERSION)
	docker push $(DEFAULT_REG)/zestdb-arm64v8:$(VERSION)

.PHONY: test
test:
#NOT IMPLIMENTED
