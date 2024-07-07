#
# Makefile

PREFIX?= .
BINDIR?= $(PREFIX)/bin
INCDIR?= $(PREFIX)/include
OBJDIR?= $(PREFIX)/obj
SRCDIR?= $(PREFIX)/src

OBJS:= \
	memory.o \
	stack.o  \
	vector.o \
	attrmap.o \
	palettes.o \
	tilemaps.o \
	tileset.o \
	gbg.o \
	cgb.o \
	peripherals/lcd.o \
	peripherals/oam.o \
	game/data/tiles.o \
	game/meta.o \
	game/data.o \
	game/game.o \
	init.o

OBJS:= $(addprefix $(OBJDIR)/,$(OBJS))

ROM:= stratagem_hero.gbc

ROM:= $(BINDIR)/$(ROM)

build: $(ROM)

clean:
	$(RM) $(OBJS) $(ROM)

rebuild: clean build

.PHONY: build clean rebuild

$(ROM): $(OBJS)
	./rgbds/rgblink -o $@ -w -l layout.link -m $(BINDIR)/layout.map $^
	./rgbds/rgbfix -vC $@

$(OBJS): $(OBJDIR)/%.o: $(SRCDIR)/%.z80
	@mkdir -p $(dir $@)
	./rgbds/rgbasm -P includes.z80 -I $(INCDIR) -I $(SRCDIR) -o $@ $<
