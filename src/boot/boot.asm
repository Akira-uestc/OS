[BITS 16]
[ORG 0x7C00]

KERNEL_SECTOR equ 2             ; 内核开始的扇区（假设引导扇区是第1个）
KERNEL_LOAD_ADDR equ 0x100000   ; 内核加载的内存地址（通常是1MB以上）
KERNEL_SECTORS equ 10           ; 内核占用的扇区数

start:
    ; 设置段寄存器
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; 加载GDT
    lgdt [gdt_descriptor]

    ; 启用A20地址线
    call enable_a20

    ; 切换到保护模式
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp CODE_SEG:init_pm

[BITS 32]

init_pm:
    ; 设置段寄存器到新的GDT值
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; 加载内核
    call load_kernel

    ; 跳转到内核
    jmp KERNEL_SEG:0x0000

enable_a20:
    in	al, 0x92
    or al, 0x02
    out 0x92, al
    ret

load_kernel:
    mov si, KERNEL_SECTOR
    mov di, KERNEL_LOAD_ADDR
    mov cx, KERNEL_SECTORS

    ; 设置BIOS中断13h参数
    mov ah, 0x02         ; 功能号：读取扇区
    mov al, cl         ; 扇区数量
    mov ch, 0x00         ; 磁道号
    mov cl, 0x02         ; 起始扇区号（1表示引导扇区，2表示内核的开始）
    mov dh, 0x00         ; 磁头号
    mov dl, 0x80         ; 驱动器号（0x80表示第一个硬盘）

int13_retry:
    int 0x13             ; 调用BIOS中断
    jc int13_retry       ; 如果出错，重试
    ret

gdt_start:
    ; GDT内容
    ; null descriptor
    dw 0, 0, 0, 0
    ; code segment descriptor
    dw 0xFFFF, 0, 0x9A, 0xCF
    ; data segment descriptor
    dw 0xFFFF, 0, 0x92, 0xCF

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10
KERNEL_SEG equ 0x10  ; 通常DATA_SEG和KERNEL_SEG在基本设置中相同

times 510-($-$$) db 0
dw 0xAA55  ; 启动扇标识

