ENTRY(start)

SECTIONS {
    . = 1M;

    .boot :
    {
        /* multiboot header first */
        *(.multiboot_header)
    }

    .text :
    {
        *(.text)
    }
}
