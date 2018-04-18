#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0xb587fcbd, __VMLINUX_SYMBOL_STR(module_layout) },
	{ 0xfe7396c4, __VMLINUX_SYMBOL_STR(generic_file_llseek) },
	{ 0xb887aa44, __VMLINUX_SYMBOL_STR(kthread_stop) },
	{ 0x6748018e, __VMLINUX_SYMBOL_STR(kmem_cache_alloc_trace) },
	{ 0x3fda5754, __VMLINUX_SYMBOL_STR(kmalloc_caches) },
	{ 0xe6e4df53, __VMLINUX_SYMBOL_STR(proc_create_data) },
	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
	{ 0x779a18af, __VMLINUX_SYMBOL_STR(kstrtoll) },
	{ 0xbb4f4766, __VMLINUX_SYMBOL_STR(simple_write_to_buffer) },
	{ 0xdb7305a1, __VMLINUX_SYMBOL_STR(__stack_chk_fail) },
	{ 0x619cb7dd, __VMLINUX_SYMBOL_STR(simple_read_from_buffer) },
	{ 0x4ca9669f, __VMLINUX_SYMBOL_STR(scnprintf) },
	{ 0xaba3fecd, __VMLINUX_SYMBOL_STR(bestjae_atomic) },
	{ 0xbdfb6dbb, __VMLINUX_SYMBOL_STR(__fentry__) },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";


MODULE_INFO(srcversion, "20BD7F28CEFB3CC61C319BA");
