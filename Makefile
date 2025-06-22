DESTDIR ?=
PREFIX ?= /usr/local

SQL := sqlite3
DB := device_map.db
JSON := devices.json
TGTCOMP := targetcompiler

ROOT_DIR = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

.SUFFIXES: .sql .db

.sql.db:
	$(SQL) $@ < $<

all: $(TGTCOMP) $(JSON) $(DB)

targetcompiler:
	$(CXX) $(ROOT_DIR)/targetcompiler.cpp -o $(ROOT_DIR)/targetcompiler -std=c++17 -ljsoncpp

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
