PREFIX := riscv64-unknown-elf-
CC := $(PREFIX)g++
OBJDUMP := $(PREFIX)objdump
CFLAGS := -march=rv32im -mabi=ilp32 -std=c99 -g3
QEMU := qemu-riscv32-static
QEMU_FLAGS := 
INC := ./inc
EXE := prac

.PHONY: clean
.PHONY: help
.PHONY: port
.PHONY: kill

# Run the prac, kill to ensure only one instance of qemu running
run: prac kill
	@$(QEMU) $(QEMU_FLAGS) $(EXE)

# Debug the prac
debug: prac port kill
	@echo "target remote localhost:`sed -n '1 p' port.env`" > ./qemu_riscv32.gdbinit
	@echo "Debug session started"
	@echo "Waiting for gdb connection on port `sed -n '1 p' port.env`"
	@$(QEMU) $(QEMU_FLAGS) -g `sed -n '1 p' port.env` $(EXE)

# Kill qemu, ignore if none is presented
kill:
	@killall -s KILL qemu-riscv32-static -u ${USER} -q || :

# Obtain an unused port
port:
	@ruby -e 'require "socket"; puts Addrinfo.tcp("", 0).bind {|s| s.local_address.ip_port }' > ./port.env

%.o: %.c
	@$(CC) -o $@ -c $^ -I$(INC) $(CFLAGS)

# Remove '#' for prac other than prac 0
prac: prac*.S autograder.o
	@$(CC) -o $(EXE) $^ -I$(INC) $(CFLAGS)

prac.dump: $(EXE)
	@$(OBJDUMP) -D $^ > $@

clean:
	@rm -f $(EXE) port.env qemu_riscv32.gdbinit

help:
	@echo "-----------------------------------------------------"
	@echo "| Help section for ECE 362 Lab Practical            |"
	@echo "-----------------------------------------------------"
	@echo "| make: compile and run the practical code on qemu  |"
	@echo "|                                                   |"
	@echo "| make run: same as 'make'                          |"
	@echo "|                                                   |"
	@echo "| make debug: compile and launch executable waiting |"
	@echo "|             for VSCode connection                 |"
	@echo "|                                                   |"
	@echo "| make kill: kill all qemu instance belong to       |"
	@echo "|            the user. Automatically executed with  |"
	@echo "|            'make run' and 'make debug'            |"
	@echo "|                                                   |"
	@echo "| make port: get an unused port for gdb connection  |"
	@echo "|            used internally for 'debug'            |"
	@echo "|                                                   |"
	@echo "| make prac: compile prac with autograder           |"
	@echo "|                                                   |"
	@echo "| make clean: clean up object file and executable   |"
	@echo "|                                                   |"
	@echo "| make help: print this message                     |"
	@echo "|                                                   |"
	@echo "-----------------------------------------------------"
