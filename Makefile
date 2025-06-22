DESTDIR ?=
PREFIX ?= /usr/local

SQL := sqlite3
DB := device_map.db
JSON := devices.json
TGTCOMP := targetcompiler
DARWIN_CFLAGS := -isystem /opt/homebrew/include -L/opt/homebrew/lib
UNAME := $(shell uname)

CFLAGS += -std=c++17 -ljsoncpp

ifeq ($(UNAME),Darwin)
CFLAGS += $(DARWIN_CFLAGS)
endif

ROOT_DIR = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

.SUFFIXES: .sql .db

.sql.db:
	$(SQL) $@ < $<

all: $(TGTCOMP) $(JSON) $(DB)

targetcompiler:
	$(CXX) $(ROOT_DIR)/targetcompiler.cpp -o $(ROOT_DIR)/targetcompiler $(CFLAGS)

devices.json:
	$(ROOT_DIR)/targetcompiler -v --targets $(ROOT_DIR)/Targets --output devices.json

install: all
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 0755 embedded_device_map.py \
		$(DESTDIR)$(PREFIX)/bin/embedded_device_map
	install -d $(DESTDIR)$(PREFIX)/standalone/firmware
	install -m 0644 device_map.db \
		$(DESTDIR)$(PREFIX)/standalone/firmware/device_map.db

.PHONY: clean
clean:
	-rm -f $(DB)
	-rm -f $(JSON)
	-rm -f $(TGTCOMP)
