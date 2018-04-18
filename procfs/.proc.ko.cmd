cmd_/root/procfs/proc.ko := ld -r -m elf_x86_64 -T ./scripts/module-common.lds --build-id  -o /root/procfs/proc.ko /root/procfs/proc.o /root/procfs/proc.mod.o ;  true
