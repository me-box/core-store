PACKAGE  = databox
.PHONY: all
all: build

.PHONY: build
build:
	docker build -t dev/core-store .

.PHONY: test
test:
	#does it build is the best we can do here fror now
	docker build -t dev/core-store . --no-cache