TARGET:=main
# TODO change to your ARM gcc toolchain path
TOOLCHAIN_PREFIX:=arm-none-eabi

# Optimization level, can be [0, 1, 2, 3, s].
OPTLVL:=0
DBG:=-g

STARTUP:=source
LINKER_SCRIPT:=Utilities/stm32_flash.ld

INCLUDE+=-ILibraries/CMSIS/Device/ST/STM32F4xx/Include
INCLUDE+=-ILibraries/CMSIS/Include
INCLUDE+=-ILibraries/STM32F4xx_StdPeriph_Driver/inc
INCLUDE+=-ILibraries/STM32F4x7_ETH_Driver/inc
INCLUDE+=-Ibsp
INCLUDE+=-Iinclude

BUILD_DIR = build
BIN_DIR = binary

# vpath is used so object files are written to the current directory instead
# of the same directory as their source files
vpath %.c Libraries/STM32F4xx_StdPeriph_Driver/src \
          Libraries/syscall \
          Libraries/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc_ride7 \
          Libraries/STM32F4x7_ETH_Driver/src \
          source bsp

vpath %.s $(STARTUP)
ASRC=startup_stm32f4xx.s

# Project Source Files
SRC+=stm32f4xx_it.c
SRC+=system_stm32f4xx.c
SRC+=main.c

SRC+=ethernet_bsp.c
SRC+=serial.c
SRC+=led.c


# Standard Peripheral Source Files
SRC+=misc.c
#SRC+=stm32f4xx_dcmi.c
#SRC+=stm32f4xx_hash.c
#SRC+=stm32f4xx_rtc.c
#SRC+=stm32f4xx_adc.c
#SRC+=stm32f4xx_dma.c
#SRC+=stm32f4xx_hash_md5.c
#SRC+=stm32f4xx_sai.c
#SRC+=stm32f4xx_can.c
#SRC+=stm32f4xx_dma2d.c
#SRC+=stm32f4xx_hash_sha1.c
#SRC+=stm32f4xx_sdio.c
#SRC+=stm32f4xx_cec.c
#SRC+=stm32f4xx_dsi.c
#SRC+=stm32f4xx_i2c.c
#SRC+=stm32f4xx_spdifrx.c
#SRC+=stm32f4xx_crc.c
SRC+=stm32f4xx_exti.c
#SRC+=stm32f4xx_iwdg.c
#SRC+=stm32f4xx_spi.c
#SRC+=stm32f4xx_cryp.c
#SRC+=stm32f4xx_flash.c
#SRC+=stm32f4xx_lptim.c
SRC+=stm32f4xx_syscfg.c
#SRC+=stm32f4xx_cryp_aes.c
#SRC+=stm32f4xx_flash_ramfunc.c
#SRC+=stm32f4xx_ltdc.c
#SRC+=stm32f4xx_tim.c
#SRC+=stm32f4xx_cryp_des.c
#SRC+=stm32f4xx_fmc.c
#SRC+=stm32f4xx_pwr.c
SRC+=stm32f4xx_usart.c
#SRC+=stm32f4xx_cryp_tdes.c
#SRC+=stm32f4xx_fmpi2c.c
#SRC+=stm32f4xx_qspi.c
#SRC+=stm32f4xx_wwdg.c
#SRC+=stm32f4xx_dac.c
#SRC+=stm32f4xx_fsmc.c
SRC+=stm32f4xx_rcc.c
#SRC+=stm32f4xx_dbgmcu.c
SRC+=stm32f4xx_gpio.c
#SRC+=stm32f4xx_rng.c
SRC+=stm32f4x7_eth.c

CDEFS=-DUSE_STDPERIPH_DRIVER
CDEFS+=-DSTM32F40_41xxx
CDEFS+=-DHSE_VALUE=25000000
CDEFS+=-D__FPU_PRESENT=1
CDEFS+=-D__FPU_USED=1
CDEFS+=-DARM_MATH_CM4

MCUFLAGS=-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -fsingle-precision-constant -finline-functions -Wdouble-promotion -std=c99
COMMONFLAGS=-O$(OPTLVL) $(DBG) -Wall -ffunction-sections -fdata-sections
CFLAGS=$(COMMONFLAGS) $(MCUFLAGS) $(INCLUDE) $(CDEFS)
LDFLAGS=$(MCUFLAGS) -u _scanf_float -u _printf_float -fno-exceptions  \
        -Wl,--gc-sections,-T$(LINKER_SCRIPT),-Map,$(BIN_DIR)/$(TARGET).map

CC=$(TOOLCHAIN_PREFIX)-gcc
LD=$(TOOLCHAIN_PREFIX)-gcc
OBJCOPY=$(TOOLCHAIN_PREFIX)-objcopy
AS=$(TOOLCHAIN_PREFIX)-as
AR=$(TOOLCHAIN_PREFIX)-ar
GDB=$(TOOLCHAIN_PREFIX)-gdb
READELF=$(TOOLCHAIN_PREFIX)-readelf
SIZE=$(TOOLCHAIN_PREFIX)-size
OBJDUMP=$(TOOLCHAIN_PREFIX)-objdump
NM=$(TOOLCHAIN_PREFIX)-nm

OBJ = $(SRC:%.c=$(BUILD_DIR)/%.o)
DEP = $(SRC:%.c=$(BUILD_DIR)/%.d)

all: $(OBJ)
	@echo [AS] $(ASRC)
	@$(AS) -o $(ASRC:%.s=$(BUILD_DIR)/%.o) $(STARTUP)/$(ASRC)
	@echo [LD] $(TARGET).elf
	@$(CC) -o $(BIN_DIR)/$(TARGET).elf $(LDFLAGS) $(OBJ) $(ASRC:%.s=$(BUILD_DIR)/%.o)
	@echo [HEX] $(TARGET).hex
	@$(OBJCOPY) -O ihex $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).hex
	@echo [BIN] $(TARGET).bin
	@$(OBJCOPY) -O binary $(BIN_DIR)/$(TARGET).elf $(BIN_DIR)/$(TARGET).bin
	@echo [INFO.ELF] $(TARGET).info.elf
	@$(READELF) -a  $(BIN_DIR)/$(TARGET).elf >  $(BIN_DIR)/$(TARGET).info_elf
	@echo [INFO.SIZE] $(TARGET).info_size
	@$(SIZE) -d -B -t  $(BIN_DIR)/$(TARGET).elf >  $(BIN_DIR)/$(TARGET).info_size
	@echo [INFO.code] $(TARGET).info.code
	@$(OBJDUMP) -S  $(BIN_DIR)/$(TARGET).elf >  $(BIN_DIR)/$(TARGET).info_code
	@echo [INFO_SYBOL] $(TARGET).info_symbol
	@$(NM) -t d -S --size-sort -s  $(BIN_DIR)/$(TARGET).elf >  $(BIN_DIR)/$(TARGET).info_symbol

-include $(DEP)

$(BUILD_DIR)/%.o: %.c
	@echo [CC] $(notdir $<)
	@$(CC) $(CFLAGS) $< -c -o $@

$(BUILD_DIR)/%.d: %.c
	@echo DEPEND $(notdir $<)
	@set -e; rm -f $@; \
	$(CC) -MM $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\.o\)[ :]*,$(BUILD_DIR)/\1 $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

.PHONY: clean flash show

clean:
	@echo [RM] OBJ DEP
	@rm -f $(OBJ)
	@rm -f $(ASRC:%.s=$(BUILD_DIR)/%.o)
	@rm -f $(DEP)
	@echo [RM] BIN
	@rm -f $(BIN_DIR)/*

flash:
	@echo Load HEX
	@st-link_cli  -p $(BIN_DIR)/$(TARGET).hex
	@echo Run Application
	@st-link_cli -Rst

show:
	@echo show SRC
	@echo $(SRC)
	@echo show DEP
	@echo $(DEP)
	@echo show OBJ
	@echo $(OBJ)

