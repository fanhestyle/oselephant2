SECTIONS
{
  . = 0x900;
  .text : { *(.text) }
}

OUTPUT_FORMAT(binary)