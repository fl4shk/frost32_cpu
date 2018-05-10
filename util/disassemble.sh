#!/bin/bash
m4 "$@" | ../assembler_disassembler/frost32_cpu_assembler_disassembler -d
