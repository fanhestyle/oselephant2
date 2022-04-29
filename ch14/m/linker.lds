SECTIONS
{
  . = 0x7c00;
  .text : { *(.text) }
}

OUTPUT_FORMAT(binary)