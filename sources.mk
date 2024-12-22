# sources.mk

# For MSP432 platform
ifeq ($(PLATFORM),MSP432)
  SOURCES = src/main.c src/memory.c src/interrupts_msp432p401r_gcc.c src/startup_msp432p401r_gcc.c src/system_msp432p401r.c
else
  # For HOST platform
  SOURCES = src/main.c src/memory.c
endif
