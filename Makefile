#******************************************************************************
# Copyright (C) 2017 by Alex Fosdick - University of Colorado
#
# Redistribution, modification or use of this software in source or binary
# forms is permitted as long as the files maintain this copyright. Users are 
# permitted to modify this and use it to learn about the field of embedded
# software. Alex Fosdick and the University of Colorado are not liable for any
# misuse of this material. 
#
#*****************************************************************************

#------------------------------------------------------------------------------
# <Put a Description Here>
#
# Use: make [TARGET] [PLATFORM-OVERRIDES]
#
# Build Targets:
#      <Put a description of the supported targets here>
#
# Platform Overrides:
#      <Put a description of the supported Overrides here
#
#------------------------------------------------------------------------------





# Platform specific settings
ifeq ($(PLATFORM),MSP432)
	CC = arm-none-eabi-gcc
	LDFLAGS = -T msp432p401r.lds -Wl,-Map=c1m2.map
	CFLAGS = -Wall -Werror -g -O0 -std=c99 \
			 -mcpu=cortex-m4 -mthumb -march=armv7e-m \
			 -mfloat-abi=hard -mfpu=fpv4-sp-d16 \
			 --specs=nosys.specs
	CPPFLAGS = -DMSP432 -Iinclude -Iinclude/msp432 -I/path/to/msp432_sdk/include
	OBJDUMP = arm-none-eabi-objdump
	# Add check to ensure MSP432 build fails on host
	LDFLAGS += --specs=nosys.specs
else
	CC = gcc
	LDFLAGS = -Wl,-Map=c1m2.map
	CFLAGS = -Wall -Werror -g -O0 -std=c99
	CPPFLAGS = -DHOST
	OBJDUMP = objdump
endif

# Object files
OBJS = $(SOURCES:.c=.o)
PREP = $(SOURCES:.c=.i)
ASMS = $(SOURCES:.c=.asm)

# Dependency files
DEPS = $(SOURCES:.c=.d)

# Target executable
TARGET = c1m2.out

# Build all target
.PHONY: all
all: $(TARGET)
	size $(TARGET)

# Preprocessor output rule
%.i: src/%.c
	$(CC) -E $(CPPFLAGS) $(INCLUDES) $< -o $@

# Assembly output rule
%.asm: src/%.c
	$(CC) -S $(CFLAGS) $(CPPFLAGS) $(INCLUDES) $< -o $@
	$(OBJDUMP) -S $@ > $@.dmp

# Object file rule
%.o: %.c
	$(CC) -c $< $(CFLAGS) $(CPPFLAGS) $(INCLUDES) -MMD -MP -MF $(patsubst %.o,%.d,$@) -o $@

# Compile all objects but don't link
.PHONY: compile-all
compile-all: $(OBJS)

# Build target - compile and link
.PHONY: build
build: $(TARGET)
	@echo "Build complete for platform $(PLATFORM)"
ifeq ($(PLATFORM),MSP432)
	@echo "Note: MSP432 build will fail if run on host as required"
endif

# Link object files
$(TARGET): $(OBJS)
	$(CC) $(OBJS) $(CFLAGS) $(LDFLAGS) -o $@

# Clean target
.PHONY: clean
clean:
	rm -f $(TARGET) $(OBJS) $(PREP) $(ASMS) $(ASMS:=.dmp) \
		  $(OBJS:.o=.d) *.map *.out *.o *.asm *.i

# Include dependency files
-include $(DEPS)
