assume cs:code

data segment
    db '1975','1976','1977','1978','1979','1980','1981','1982','1983','1984'
    db '1985','1986','1987','1988','1989','1990','1991','1992','1993','1994','1995'   ;0-83
    dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
    dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000    ;84-167
    dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
    dw 11542,14430,15257,17800    ;168-209
data ends

stack segment
    dw 128 dup(0)
stack ends

table segment   ;存放数据
    db 21 dup('year summ ne ?? ')
table ends

string segment   ;存放dtoc转换后的字符串
    db 32 dup(0)
string ends

code segment
start:
    mov ax, data
    mov ds, ax
    mov ax, table
    mov es, ax
    mov ax, stack
    mov ss, ax
    mov sp, 256
    mov bx, 84
    mov si, 5
    mov di, 0ah
    mov cx, 21   ;将收入和雇员数存在table中，并计算人均收入
s1:    
    mov ax, [bx]
    mov es:[si], ax
    mov ax, [bx + 2]
    mov es:[si + 2], ax
    add si, 10H
    add bx, 4
    loop s1
    mov bx, 168
    mov si, 0ah
    mov cx, 21
s2:
    mov ax, [bx]
    mov es:[si], ax
    add si, 10H
    add bx, 2
    loop s2
    mov bx, 0
    mov ax, 0
    mov di, 0
    mov si, 0
    mov cx, 21
s3:
    push cx
    mov cx, 4
    cld
    rep movsb
    pop cx
    add di, 12
    loop s3
    mov si, 5
    mov ax, 0
    mov dx, 0
    mov cx, 21
s4:
    mov ax, es:[si]
    mov dx, es:[si + 2]
    div word ptr es:[si + 5]
    mov es:[si + 8], ax
    add si, 10H
    loop s4
    call  clear
    call show_table
    mov ax, 4c00h
    int 21h
show_table:
    push si
    push di
    push cx
    push dx
    push es
    push ax
    push bx
    mov si, 0
    mov di, 0
    mov dh, 1
    mov dl, 0
    mov cx, 21
s5:   ;输出年份
    push cx
    mov ch, 0
    mov cl, 00000111b
    mov es:[si + 4], 0
    call show_str
    add dh, 1
    add si, 10H
    pop cx
    loop s5
    mov dh, 1
    mov dl, 10
    mov si, 84
    mov cx, 21
s6:   ;输出收入
    push es
    push si
    push dx
    mov ax, [si]
    mov dx, [si + 2]
    mov bx, string
    mov es, bx
    mov si, 0
    call dtoc
    pop dx
    push cx
    mov ch, 0
    mov cl, 00000111b
    call show_str
    inc dh
    pop cx
    pop si
    add si, 4
    pop es
    loop s6
    mov dh, 1
    mov dl, 20
    mov si, 168
    mov cx, 21
s7:    ;输出雇员数
    push es
    push si
    push dx
    mov ax, [si]
    mov dx, 0
    mov bx, string
    mov es, bx
    mov si, 0
    call dtoc
    pop dx
    push cx
    mov ch, 0
    mov cl, 00000111b
    call show_str
    inc dh
    pop cx
    pop si
    add si, 2
    pop es
    loop s7
    mov dh, 1
    mov dl, 30
    mov si, 0dh
    mov cx, 21
s8:   ;输出人均收入
    push es
    push si
    push dx
    mov ax, es:[si]
    mov dx, 0
    mov bx, string
    mov es, bx
    mov si, 0
    call dtoc
    pop dx
    push cx
    mov ch, 0
    mov cl, 00000111b
    call show_str
    inc dh
    pop cx
    pop si
    add si, 10h
    pop es
    loop s8
    pop bx
    pop ax
    pop es
    pop dx
    pop cx
    pop di
    pop si
    ret
show_str:
    push si
    push cx
    push ds
    push di
    mov ax, 0b800h
    mov ds, ax
    mov al, 0a0h
    mul dh
    add al, dl
    add al, dl
    mov di, ax
    mov ax, 0
    mov al, cl
    mov bx, 0
s9:
    mov ch, 0
    mov cl, es:[si]
    jcxz ok1
    mov byte ptr [di], cl
    mov byte ptr [di + 1], al
    add di, 2
    inc si
    jmp short s9
ok1:
    pop di
    pop ds
    pop cx
    pop si
    ret
clear:
    push ax
    push cx
    push es
    push di
    mov ax, 0b800h
    mov es, ax
    mov di, 0
    mov cx, 4000
s10:
    mov es:[di], 0
    inc di
    loop s10
    pop di
    pop es
    pop cx
    pop ax
    ret
dtoc:
    push bx    ;es:si指向字符串，dx:ax存储数字
    push ax
    push si
    push cx
    mov bx, 0
s11:
    mov cx, 10
    call divdw
    add cx, 30h
    push cx
    inc bx
    mov cx, ax
    add cx, dx
    jcxz ok2
    jmp short s11
ok2:
    mov cx, bx
s12:
    pop bx
    mov es:[si], bl
    inc si
    loop s12
    mov es:[si], 0
    pop cx
    pop si
    pop ax
    pop bx
    ret
divdw:
    push bx
    push ax
    mov ax, dx    ;ax=H,cx=N,L存储在栈中
    mov dx, 0
    div cx
    mov bx, ax  ;bx=int(H/N),dx=rem(H/N)
    pop ax   ;ax=L,此时dx和ax一起表示rem(L/N)*65536+L
    div cx  ;bx和ax表示int(H/N)*65536+(rem(H/N)*65536+L)/N，dx表示余数
    mov cx, dx
    mov dx, bx
    pop bx
    ret
code ends
end start