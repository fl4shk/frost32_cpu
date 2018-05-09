#!/bin/bash
m4 "$@" | ./frost32_cpu_assembler_disassembler -a
