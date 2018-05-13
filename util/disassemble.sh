#!/bin/bash
m4 "$@" | $(dirname $0)/../assembler_disassembler/frost32_cpu_assembler_disassembler -d
