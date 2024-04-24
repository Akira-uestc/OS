#!/bin/bash
dd if=mbr.bin of=image_file bs=512 count=1 conv=notrunc
