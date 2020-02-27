COREDIR=/home/tomhaus/NetBeansProjects/KETCube-fw-ZCU/
TARGET=KETCube

DEBUG = -g3
OPTIMIZE = -Os

STLINK = /usr/local/bin/st-flash

INC_DIRS  = $(COREDIR)Drivers/STM32L0xx_HAL_Driver/Inc
INC_DIRS += .
INC_DIRS += $(COREDIR)Drivers/BSP/CMWX1ZZABZ-0xx/
INC_DIRS += $(COREDIR)Drivers/BSP/Components/sx1276
INC_DIRS += $(COREDIR)Drivers/CMSIS/Device/ST/STM32L0xx/Include
INC_DIRS += $(COREDIR)Drivers/CMSIS/Documentation/Core/html
INC_DIRS += $(COREDIR)Drivers/CMSIS/Documentation/DSP/html
INC_DIRS += $(COREDIR)Drivers/CMSIS/Include
INC_DIRS += $(COREDIR)Drivers/CMSIS/RTOS/Template
INC_DIRS += $(COREDIR)Drivers/KETCube/core
INC_DIRS += $(COREDIR)Drivers/KETCube/modules
INC_DIRS += $(COREDIR)Drivers/STM32L0xx_HAL_Driver/Inc
INC_DIRS += $(COREDIR)Drivers/STM32L0xx_HAL_Driver/Inc/Legacy
INC_DIRS += $(COREDIR)KETCube/core
INC_DIRS += $(COREDIR)KETCube/modules/actuation
INC_DIRS += $(COREDIR)KETCube/modules/communication
INC_DIRS += $(COREDIR)KETCube/modules/sensing
INC_DIRS += $(COREDIR)Middlewares/Third_Party/Lora/Conf
INC_DIRS += $(COREDIR)Middlewares/Third_Party/Lora/Conf/Inc
INC_DIRS += $(COREDIR)Middlewares/Third_Party/Lora/Core
INC_DIRS += $(COREDIR)Middlewares/Third_Party/Lora/Crypto
INC_DIRS += $(COREDIR)Middlewares/Third_Party/Lora/Mac
INC_DIRS += $(COREDIR)Middlewares/Third_Party/Lora/Mac/region
INC_DIRS += $(COREDIR)Middlewares/Third_Party/Lora/Phy
INC_DIRS += $(COREDIR)Middlewares/Third_Party/Lora/Utilities
INC_DIRS += $(COREDIR)Middlewares/Third_Party/Semtech/Utilities/
INC_DIRS += $(COREDIR)Projects/inc
INC_DIRS += $(COREDIR)Projects/inc/actuation
INC_DIRS += $(COREDIR)Projects/inc/communication
INC_DIRS += $(COREDIR)Projects/inc/sensing
INC_DIRS += $(COREDIR)Projects/inc/drivers
INC_DIRS += $(COREDIR)Projects/Makefile/inc

INCLUDE = $(addprefix -I, $(INC_DIRS))

##########################################################

CFLAGS   = -Wall  -Wno-missing-braces -g -mthumb -mcpu=cortex-m0plus -fdiagnostics-color=auto $(OPTIMIZE)
CFLAGS  += -march=armv6-m -mlittle-endian -Wl,--gc-sections -TSTM32L072CZYx_FLASH.ld $(DEBUG)
CFLAGS  += -DSTM32L082xx -DUSE_B_L082Z_KETCube -DUSE_HAL_DRIVER -DREGION_EU868

LDFLAGS  = -mcpu=cortex-m0 -march=armv6-m -TSTM32L072CZYx_FLASH.ld -Wl,-Map=$(TARGET).map
LDFLAGS += -mthumb -mfloat-abi=soft -specs=nano.specs -specs=nosys.specs
LDFLAGS += -lc -lrdimon -u _printf_float

.PHONY: clean

make:
	@echo Compiling
	@arm-none-eabi-gcc -c $(CFLAGS) $(INCLUDE) example.c -o example.o
	@echo "Linking (creating .elf)"
	@arm-none-eabi-gcc example.o KETCube.a $(LDFLAGS) -o example.elf
	@echo "Creating .hex file"
	@arm-none-eabi-objcopy -O ihex example.elf example.hex
	@echo "Creating .bin file"
	@arm-none-eabi-objcopy -O binary -S example.elf example.bin
	@$(MAKE) sigdone

clean:
	@echo Cleaning....
	@rm -f example.o example.elf KETCube.map example.hex example.bin
	$(MAKE) sigdone

erase:
	$(STLINK) erase
	@$(MAKE) sigdone

stflash:
	@echo "Uploading code..."
	$(STLINK) write example.bin 0x8000000
	$(STLINK) reset
	@$(MAKE) sigdone

sigdone:
	@echo "ALL DONE"
