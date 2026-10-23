PREFIX ?= /usr
QMLDIR ?= $(PREFIX)/lib/qt6/qml
DEST = $(DESTDIR)$(QMLDIR)/Twilight/Launcher

install:
	install -d $(DEST)
	cp -r Twilight/Launcher/. $(DEST)

uninstall:
	rm -rf $(DEST)

.PHONY: install uninstall
