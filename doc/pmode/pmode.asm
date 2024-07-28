;设置堆栈段和栈指针
mov ax,cs      ; 将当前代码段寄存器值放入AX
mov ss,ax      ; 将AX值放入栈段寄存器SS
mov sp,0x7c00  ; 将栈指针SP指向0x7C00位置

;计算GDT所在的逻辑段地址
mov ax,[cs:gdt_base+0x7c00]        ; 获取GDT的低16位地址
mov dx,[cs:gdt_base+0x7c00+0x02]   ; 获取GDT的高16位地址
mov bx,16        
div bx            ; 除以16，转换为段地址
mov ds,ax         ; DS指向GDT所在段
mov bx,dx         ; BX存储段内偏移地址

;创建0#描述符，它是空描述符，这是处理器的要求
mov dword [bx+0x00],0x00
mov dword [bx+0x04],0x00  

;创建#1描述符，保护模式下的代码段描述符
mov dword [bx+0x08],0x7c0001ff     ; 基址0x7C00，限长0x01FF
mov dword [bx+0x0c],0x00409800     ; 代码段特权级0，存在位1，执行位1

;创建#2描述符，保护模式下的数据段描述符（文本模式下的显示缓冲区） 
mov dword [bx+0x10],0x8000ffff     ; 基址0x8000，限长0xFFFF
mov dword [bx+0x14],0x0040920b     ; 数据段特权级0，存在位1

;创建#3描述符，保护模式下的堆栈段描述符
mov dword [bx+0x18],0x00007a00     ; 基址0x0000，限长0x7A00
mov dword [bx+0x1c],0x00409600     ; 堆栈段特权级0，存在位1

;初始化描述符表寄存器GDTR
mov word [cs: gdt_size+0x7c00],31  ; 设置GDT大小（字节数减1）
lgdt [cs: gdt_size+0x7c00]         ; 加载GDT

in al,0x92                         ; 读取南桥芯片内的端口
or al,0000_0010B                   ; 设置A20地址线，使能1MB以上内存访问
out 0x92,al                        ; 打开A20

cli                                ; 关闭中断
mov eax,cr0
or eax,1                           ; 设置CR0的PE位，进入保护模式
mov cr0,eax

;以下进入保护模式...
jmp dword 0x0008:flush             ; 远跳转至保护模式的代码段

[bits 32]                          ; 从此开始，代码为32位模式

flush:
mov cx,00000000000_10_000B         ; 加载数据段选择子(0x10)
mov ds,cx                          ; 设置数据段寄存器

;以下在屏幕上显示"Protect mode OK."
mov byte [0x00],'P'  
mov byte [0x02],'r'
mov byte [0x04],'o'
mov byte [0x06],'t'
mov byte [0x08],'e'
mov byte [0x0a],'c'
mov byte [0x0c],'t'
mov byte [0x0e],' '
mov byte [0x10],'m'
mov byte [0x12],'o'
mov byte [0x14],'d'
mov byte [0x16],'e'
mov byte [0x18],' '
mov byte [0x1a],'O'
mov byte [0x1c],'K'

;以下用简单的示例来帮助阐述32位保护模式下的堆栈操作
mov cx,00000000000_11_000B         ; 加载堆栈段选择子
mov ss,cx                          ; 设置栈段寄存器
mov esp,0x7c00                     ; 设置栈顶指针

mov ebp,esp                        ; 保存栈基指针
push byte '.'                      ; 压入立即数（字节）
sub ebp,4
cmp ebp,esp                        ; 比较ESP是否减少4字节
jnz ghalt                          ; 如果不相等，跳转到ghalt
pop eax                            ; 弹出栈顶的值到EAX
mov [0x1e],al                      ; 显示句点

ghalt:     
hlt                                ; 挂起系统

;定义GDT表结构
gdt_size         dw 0
gdt_base         dd 0x00007e00     ; GDT的物理地址 

times 510-($-$$) db 0              ; 填充到510字节
db 0x55,0xaa                       ; MBR签名