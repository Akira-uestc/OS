run:boot
	@if [ -f img/boot.img ]; then \
		img/start.sh; \
	else \
		img/create.sh; \
		img/write.sh; \
		img/start.sh; \
	fi

boot:
	@nasm src/boot/boot.asm -o img/boot

clean:
	@rm img/boot; \
	rm img/boot.img