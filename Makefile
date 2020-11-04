DEPEND += "https://code.jquery.com/jquery-3.4.1.min.js"
VERSION = 1.0.1
NAME = XenRa1n
PREREQ = com.matchstic.xenhtml
AUTHOR = wyattgahm
PACKAGE = com.$(AUTHOR).$(NAME)
README = "No Extra Comment"
DESCRIPTION = "A rain themed XenHTML lockscreen"
IP = 192.168.1.25

all: package

clean: 
	@echo "+++ cleaning up..."
	rm -rf bin
	rm -rf $(NAME)-$(VERSION)
	rm -rf tmp
	rm -rf lib
	rm -rf *$(NAME)*

package: clean
	@echo "+++ building package"
	@echo "++ making dir structure"
	mkdir tmp
	mkdir -p $(NAME)-$(VERSION)/var/mobile/Library/LockHTML/$(NAME)
	mkdir -p $(NAME)-$(VERSION)/DEBIAN
	mkdir lib
	mkdir bin

	@echo "++ downloading depends"
	wget -P lib $(DEPEND)

	@echo "++ making control and README"
	touch tmp/control
	touch tmp/README.txt
	echo "Package: $(PACKAGE)" >> tmp/control
	echo "Name: $(NAME)" >> tmp/control
	echo "Description: $(DESCRIPTION)" >> tmp/control
	echo "Author: $(AUTHOR)" >> tmp/control
	echo "Version: $(VERSION)" >> tmp/control
	echo "Depends: $(PREREQ)" >> tmp/control
	echo "Architecture: iphoneos-arm" >> tmp/control
	echo "Maintainer: $(AUTHOR)" >> tmp/control
	echo "$(README)" >> tmp/README.txt

	@echo "++ compiling debian archive"
	cp tmp/control $(NAME)-$(VERSION)/DEBIAN/
	cp tmp/README.txt $(NAME)-$(VERSION)/var/mobile/Library/LockHTML/$(NAME)/
	cp -R tmp/README.txt $(NAME)-$(VERSION)/var/mobile/Library/LockHTML/$(NAME)/
	cp -R src/* $(NAME)-$(VERSION)/var/mobile/Library/LockHTML/$(NAME)/
	mv $(NAME)-$(VERSION)/var/mobile/Library/LockHTML/$(NAME)/background.asp $(NAME)-$(VERSION)/var/mobile/Library/LockHTML/$(NAME)/LockBackground.html
	dpkg-deb --build $(NAME)-$(VERSION)
	mv $(NAME)-$(VERSION).deb bin/$(NAME)-$(VERSION).deb
	
test: package
	open -a Safari $(NAME)-$(VERSION)/var/mobile/Library/LockHTML/$(NAME)/background.html

first-install:
	ssh-keygen -f res/$(IP) -t rsa -b 2048
	ssh-copy-id -i res/$(IP) root@$(IP)
	ssh -i res/$(IP) root@$(IP) "mkdir -p /var/mobile/Scripts/pack"
	scp -i res/$(IP) res/payload.sh root@$(IP):/var/mobile/Scripts/payload.sh


install: package
	@echo "+++ installing package"
	scp -i res/$(IP) bin/$(NAME)-$(VERSION).deb root@$(IP):/var/mobile/Scripts/pack/$(NAME)-$(VERSION).deb
	ssh -i res/$(IP) root@$(IP) "bash /var/mobile/Scripts/payload.sh $(NAME)-$(VERSION)"

