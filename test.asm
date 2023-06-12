DATAS SEGMENT
    ;此处输入数据段代码  
    STRING DB 'Hello world!',0DH,0AH,'$'	;0DH,0AH分别为 回车符 和 换行符 的ASCII码，加'$'是因为DOS软中断调用的字符串输出功能要求被显示的字符串以'$'作为结束标志
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;此处输入代码段代码
    LEA  DX,STRING
    MOV AH,09H							
    INT 21H								;DOS软中断-调用 字符串输出 功能（功能号：09H）
    MOV AH,4CH
    INT 21H								;DOS软中断-调用 返回DOS 功能（功能号：4CH）
CODES ENDS
    END START