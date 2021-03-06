DIR := ${CURDIR}
CURRENT_UID := $$(id -u)
CURRENT_GID := $$(id -g)

all: build copy

build:
	docker build --no-cache -t alacritty .

copy:
	docker run --rm -v $(DIR):/out -u $(CURRENT_UID):$(CURRENT_GID) alacritty cp target/release/alacritty /out
	docker run --rm -v $(DIR):/out -u $(CURRENT_UID):$(CURRENT_GID) alacritty cp extra/alacritty.info /out
	docker run --rm -v $(DIR):/out -u $(CURRENT_UID):$(CURRENT_GID) alacritty cp extra/alacritty.man /out

clean:
	docker rmi -f alacritty
	docker rmi -f rust

master:
	sed '/checkout/d' Dockerfile > Dockerfile.master
	docker build -f Dockerfile.master -t alacritty .
	$(MAKE) copy

check:
	-git clone https://github.com/alacritty/alacritty.git /tmp/alacritty
	-git --git-dir=/tmp/alacritty/.git pull
	@echo ""
	@echo ""
	@echo "latest alacritty version"
	@git --git-dir=/tmp/alacritty/.git describe --tags `git --git-dir=/tmp/alacritty/.git rev-list --tags --max-count=1`
	@echo ""
	@echo "current alacritty version"
	@alacritty --version | sed -e "s/^alacritty\s//g"
	@echo ""

install: build copy
	cp -f ./alacritty /usr/local/bin/alacritty
	mkdir -p /usr/local/share/man/man1
	gzip -c alacritty.man | tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
	tic -xe alacritty,alacritty-direct ./alacritty.info
