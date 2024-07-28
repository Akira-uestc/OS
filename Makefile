boot:
	@nasm doc/pmode/pmode.asm -o img/boot

run:
	@if [ -f img/boot.img ]; then \
		img/start.sh; \
	else \
		img/create.sh; \
		img/write.sh; \
		img/start.sh; \
	fi