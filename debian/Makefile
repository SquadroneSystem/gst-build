# This Makefile is responsible for cleaning and launching debian package build
# For Cross-build target (armhf for example), see doc/build_crossbuild_environment.md

# These variables are set by jenkins as env variables, we provide default values here
BUILD_NUMBER ?= 0

# The following variables are automatically read from standard files, thus
# keeping this Makefile generic and compatible with many projects.
# This automatic extraction imposes some restrictions on how we write data
# to those files.
#
# Please, try to:
# - Document the imposed restrictions
# - Limit this variable-extraction to mandatory, standard files

# TODO document the NAME_PKG regex
NAME_PKG=$(shell head -n1 changelog | sed '/^\([^ ]*\).*/!d;s//\1/')

# TODO document the VERSION regex
VERSION=$(shell head -n1 changelog | sed '/.*(\([.+~A-Za-z0-9]*\).*).*/!d;s//\1/')

# Extract the module name from setup.py:
# - Extract line where name is the first nonwhitespace (space or tab) character
# - Followed by optional whitespace (space or tab) characters and a "=" sign
# - We extract all the following characters, until...
# - A comma is found, followed by optional whitespace (space or tab) characters
# - Final sed removes unwanted characters:
#       (space, tab, comma, single quotation mark, double quotation mark)
PYBUILD_NAME=$(shell sed '/^[ \t]*name[ \t]*=\(.*\),[ \t]*/!d;s//\1/' ../setup.py | sed "s/[ \t,'\"]//g")

SOURCE_DIR=$(shell dirname $(shell pwd))
GIT_COMMIT=$(shell git rev-parse --short HEAD)
VERSION_BUILD=jenkins$(BUILD_NUMBER)+git$(GIT_COMMIT)
DISTRIB_BUILD=$(shell lsb_release -cs)
NAME_PKG_WITH_VERSION=$(NAME_PKG)-$(VERSION)
NAME_PKG_WITH_VERSION_FULL=$(NAME_PKG)-$(VERSION)-$(VERSION_BUILD)

.PHONY: all
all: clean deb

.PHONY: deb
deb: clean deb_first_stage deb_second_stage

.PHONY: dput
dput: deb
	find . -name '*.changes' -exec dput --config /etc/sqdr/dput.cf --force --unchecked sqdr-default {} \;

.PHONY: dput-jenkins2
dput-jenkins2: deb
	find . -name '*.changes' -exec dput --config /etc/sqdr/dput.cf --force --unchecked sqdr-jenkins2 {} \;

.PHONY: deb_armhf
deb_armhf: clean_package_version_dir $(NAME_PKG_WITH_VERSION).orig.tar.gz
	cd ./$(NAME_PKG_WITH_VERSION) && sbuild -d bionic-armhf --host=armhf --build=armhf

.PHONY: zip
zip: clean_package_version_dir $(NAME_PKG_WITH_VERSION_FULL).zip

.PHONY: deb_first_stage
deb_first_stage: $(NAME_PKG_WITH_VERSION) $(NAME_PKG_WITH_VERSION).orig.tar.gz

.PHONY: deb_second_stage
deb_second_stage:
	find ./$(NAME_PKG_WITH_VERSION) -name 'changelog' -exec sed -i "1 s/^\(\S* ([^)]*)\) \S*;/\\1 ${DISTRIB_BUILD};/g" {} \;
	# NOTE: PYBUILD_NAME is only needed for python packages but does not conflict with anything else
	export PYBUILD_NAME=${PYBUILD_NAME} && \
	cd ./$(NAME_PKG_WITH_VERSION) && \
	debuild --preserve-envvar PYBUILD_NAME --preserve-envvar CCACHE_* -us -uc -b --changes-option=-DDistribution=${DISTRIB_BUILD}

.PHONY: clean_package_version_dir
clean_package_version_dir:
	-find . -depth -name "$(NAME_PKG)-*" -type d -exec rm -rf {} \;

.PHONY: clean
clean: clean_package_version_dir
	-rm -rf *.deb *.ddeb *.tar.xz *.tar.gz *.buildinfo *.build *.changes *.dsc *.zip *.upload

$(NAME_PKG_WITH_VERSION):
	@echo "\n=> Copying source directory (${SOURCE_DIR}) to /tmp to build tarball"
	cp -r $(SOURCE_DIR) /tmp/$(NAME_PKG_WITH_VERSION)
	@echo "\n=> Deleting git repositories and files from source directory to be tarballed (while in /tmp to avoid accidents)"
	-find /tmp/$(NAME_PKG_WITH_VERSION) -depth -name '.git*' -exec rm -rf {} \;
	@echo "\n=> Moving directory to be tarballed to current directory"
	mv /tmp/$(NAME_PKG_WITH_VERSION) .
	@echo "\n=> Clean the directory to be tarballed"
	-cd $(NAME_PKG_WITH_VERSION) && make clean
	find $(NAME_PKG_WITH_VERSION) -name 'changelog' -exec sed -i "1 s/(\([-.+:~A-Za-z0-9]*\\)-[.+~A-Za-z0-9]*)/(\\1-${VERSION_BUILD})/g" {} \;

$(NAME_PKG_WITH_VERSION_FULL).zip: $(NAME_PKG_WITH_VERSION)
	cp changelog $(NAME_PKG_WITH_VERSION)/
	rm -r $(NAME_PKG_WITH_VERSION)/debian
	zip -r $(NAME_PKG_WITH_VERSION_FULL).zip $(NAME_PKG_WITH_VERSION)

$(NAME_PKG_WITH_VERSION).orig.tar.gz: $(NAME_PKG_WITH_VERSION)
	@echo "\n=> Build/create the tarball"
	tar -zcvf $(NAME_PKG)_$(VERSION).orig.tar.gz $(NAME_PKG_WITH_VERSION)
