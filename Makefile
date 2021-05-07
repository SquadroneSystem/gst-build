.PHONY: all
all: clean build

.PHONY: clean
clean:
	-rm build

.PHONY: build
build: gstreamer.install

.PHONY: gstreamer.install
gstreamer.install:
	./gstreamer-compile.install

# .PHONY: install
# install:
# 	DESTDIR=/usr ninja -j4 -C build install
