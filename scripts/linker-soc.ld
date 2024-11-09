ENTRY(_start)
MEMORY {
	mrom : ORIGIN = 0x20000000, LENGTH = 4K
	sram : ORIGIN = 0x0f000000, LENGTH = 8K
}

SECTIONS {
	.text : {
		_stext = .;
		*(entry);
		*(.text*);
	  _etext = .;
	} > mrom AT> mrom

	.rodata : {
		_srodata = .;
		*(.rodata*);
		*(.srodata*);
		_erodata = .;
  } > mrom AT> mrom
	.data : {
		_sdata = .;
		*(.data*);
		*(.sdata*);
		_edata = .; /* Note that this is VMA */
	} > sram AT> mrom
	_data_size = SIZEOF(.data);
	_data_load_start = LOADADDR(.data);

	.bss : {
		_sbss = .;
    *(.bss*);
    *(.sbss*);
    *(.scommon);
		_ebss = .;
  } > sram
	_end = .;
	_heap_start = ALIGN(0x1000);
	_stack_pointer = _sram_start + _sram_limit;
}

