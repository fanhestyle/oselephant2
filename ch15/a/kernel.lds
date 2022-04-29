SECTIONS
{
    . = 0xc0001500;
    .text : {*(.text)}
}

OUTPUT_FORMAT(elf32-i386)
