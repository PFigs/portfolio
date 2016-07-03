CC = gcc
CFLAGS = -Wall -pedantic -g -ansi
DIRS = source source/cliente source/servidor headers
STORE = bin

# Main Target
TARGET = conf

# Makes a list of the source (.c) files.
SOURCE := $(wildcard source/*.c)
# List of header files.
HEADERS := $(wildcard headers/*.h)
# Makes a list of the object files that will have to be created.
OBJECTS := $(addprefix $(STORE)/, $(notdir $(SOURCE:.c=.o)))

# Specify phony rules. These are rules that are not real files.
.PHONY: clean backup dirs


$(TARGET): $(OBJECTS) $(HEADERS)
	@echo -n Linking $(TARGET)...
	@$(CC) $(CFLAGS) -o $(STORE)/$(TARGET) $(OBJECTS) -lm
	@echo " Done"

$(OBJECTS): $(SOURCE) $(HEADERS)
	@echo -n Creating object file for $*...
	@$(CC) $(CFLAGS) -c source/$(notdir $*).c -o $@
	@echo " Done"

# Empty rule to prevent problems when a header is deleted.
%.h: ;
	

# Cleans up the objects, executables and temporary files.
clean:
	@echo -n Making clean...
	@-rm -f $(foreach DIR,$(DIRS),$(DIR)/*~)
	@-rm -f $(STORE)/*
	@echo " Done"
	

# Backup the source files.
backup:
	@-if [ ! -e .backup ]; then mkdir .backup; fi;
	@zip ".backup/backup_`date +%d-%m-%y_%H.%M` $(VER)".zip $(SOURCE) $(HEADERS) $(EXTRA_FILES)
