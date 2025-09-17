AS = nasm
LD = ld
ASFLAGS = -f elf64
LDFLAGS = -no-pie

SRC_DIR = src
BIN = assfetch.out

SRCS = $(wildcard $(SRC_DIR)/*.asm)
OBJS = $(patsubst $(SRC_DIR)/%.asm, %.o, $(SRCS))

TOOLS_DIR = ./tools
PCI_IDS = ./pciids/pci.ids
PCI_BIN = ./resources/pciids.out
PCI_ARGS = --cut-brackets

PREFIX = /usr/local

all: $(TOOLS_DIR)/generate_ids.c.out $(BIN)

$(BIN): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

$(TOOLS_DIR)/generate_ids.c.out:
	$(MAKE) -C $(TOOLS_DIR)
	$(TOOLS_DIR)/generate_ids.c.out $(PCI_IDS) $(PCI_BIN) $(PCI_ARGS)

%.o: $(SRC_DIR)/%.asm
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -f $(OBJS) $(BIN)
	$(MAKE) -C $(TOOLS_DIR) clean

install: $(BIN)
	cp $(BIN) $(PREFIX)/bin/$(BIN:.out=)
	chmod +x $(PREFIX)/bin/$(BIN:.out=)

