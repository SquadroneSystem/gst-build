.PHONY: all
all: clean build

.PHONY: clean
clean:
	-rm build

.PHONY: build
build: gstreamer.install

.PHONY: gstreamer.install
gstreamer.install:
	$(shell ./gstreamer-compile.install)
