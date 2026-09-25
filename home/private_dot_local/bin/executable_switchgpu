#!/bin/bash

help(){
	echo "help message"
	echo "1. Integrated"
	echo "2. Hybrid"
	echo "3. dGPU"
}

modes=("Integrated" "Hybrid" "AsusMuxDgpu")
in=$1
if [ "$in" == "-h" ] || [ "$in" == "--help" ]; then
	help
elif [ $in -gt 0 2>/dev/null ] && [ $in -le ${#modes[@]} 2>/dev/null ]; then
	echo "Current mode: $(supergfxctl --get)"
	supergfxctl --mode ${modes[$in-1]} &>/dev/null
	echo "Switched to: $(supergfxctl --get)"
else
	echo "Enter valid number"
	echo "switchgpu.sh --help for help"
	exit 1
fi
exit 0
