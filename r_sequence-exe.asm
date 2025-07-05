         [bits 32]

extern   _printf
extern   _scanf
extern   _exit
extern   _getchar

global   _main         
section  .text

_main:

prompt_loop:
         push dword format_n  ; format_n -> stack

;        esp -> [format_n][ret]

         call _printf  ; printf(format_n)

;        esp -> [n][ret]  ; zmienna n, adres format_n nie jest juz potrzebny
                                                               
         push esp  ; esp -> stack = addr_n
                                                          
;        esp -> [addr_n][n][ret]

         push dword format_s  ; format_s -> stack 

;        esp -> [format_s][addr_n][n][ret]

         call _scanf   ; scanf(format_s, addr_n)
         add esp, 2*4  ; esp = esp + 8

;        esp -> [n][ret]

         cmp eax, 1         ; eax - 1           ; OF SF ZF AF PF CF affected
         jne invalid_input  ; jump if not equal ; jump if ZF = 0

         call _getchar      ; getchar()
         cmp al, 0x0A       ; al - '\n'        ; OF SF ZF AF PF CF affected
         jne invalid_input  ; jump if not equal ; jump if ZF = 0

         mov ecx, [esp]  ; eax = n

         cmp ecx, 1      ; ecx - 1       ; OF SF ZF AF PF CF affected
         jl prompt_loop  ; jump if less  ; jump if SF != OF

         jmp compute_seq  ; jump always

invalid_input:

clear_stdin:
         call _getchar  ; getchar()

         cmp al, 0x0A     ; al - '\n'        ; OF SF ZF AF PF CF affected
         jne clear_stdin  ; jump if not equal ; jump if ZF = 0
         jmp prompt_loop  ; jump always

compute_seq:
         finit  ; fpu init
         
;        st = []  ; fpu stack

         call seq  ; st0 = seq(ecx) = seq(n)  ; fastcall
raddr:

;        st = [seq(n)]

;        esp -> [n][ret]                                                     

         pop ecx  ; ecx <- stack = n

         sub esp, 8  ; esp = esp - 8
         
;        esp -> [ ][ ][ret] ; 

;        st = [seq(n)]

         fstp qword [esp]  ; *(double*)esp <- st

;        st = []

;        esp -> [fl][fh][ret] ;

         push ecx  ; ecx -> stack = n

;        esp -> [ecx][fl][fh][ret] ;

         push dword format  ; format -> stack

;        esp -> [format][ecx][fl][fh][ret] ;

         call _printf  ; printf(format, ecx, f);
         add esp, 4*4    ; esp = esp + 16

;        esp -> [ret]

         push 0      ; esp -> [0][ret]
         call _exit  ; exit(0);

seq:
         cmp ecx, 1  ; ecx - 1       ; OF SF ZF AF PF CF affected
         je base1    ; jump if equal ; jump if ZF = 1

         cmp ecx, 2  ; ecx - 1       ; OF SF ZF AF PF CF affected
         je base2    ; jump if equal ; jump if ZF = 1

         push ecx  ; ecx -> stack

;        esp -> [ecx][ret]

         dec ecx  ; ecx--

         call seq  ; st0 = seq(ecx) = seq(n - 1)  ; fastcall

;        st = [seq(n-1)]

         sub esp, 8  ; esp = esp - 8
         
;        esp ->  [ ][ ][ecx][ret]

         fstp qword [esp]  ; *(double*)esp <- st
         
;        st = []

;        esp -> [fl][fh][ecx][ret]

         mov ecx, [esp+8]  ; ecx = *(int*)(esp + 8)

         sub ecx, 2  ; ecx = ecx - 2

         call seq  ; st0 = seq(ecx) = seq(n - 2)  ; fastcall
         
;        st = [seq(n-2)]

         fld qword [esp]  ; *(double*)esp -> st
         
;        st = [seq(n-1), seq(n-2)]

         fld1  ; 1.0 -> st

;        st = [1.0 ,seq(n-1), seq(n-2)]

         fadd st0, st0  ; st0 = st0 + st0

;        st = [2.0 ,seq(n-1), seq(n-2)]

         fdivp st1, st0  ; st1 = st1 : st0 and pop

;        st = [seq(n-1)/2.0, seq(n-2)]

         fxch st1  ; (st0, st1) = (st1, st0)
         
;        st = [seq(n-2), seq(n-1)/2.0]

         fld1  ; 1.0 -> st    

;        st = [1.0, seq(n-2), seq(n-1)/2.0]

         fadd st0, st0  ; st0 = st0 + st0
         
;        st = [2.0, seq(n-2), seq(n-1)/2.0]

         fmulp st1, st0  ; st1 = st1 * st0 and pop

;        st = [seq(n-2)*2.0, seq(n-1)/2.0]

         faddp st1, st0  ; st1 = st1 + st0 and pop
         
;        st = [seq(n-2)*2.0 + seq(n-1)/2.0]

         add esp, 12  ; esp = esp + 12

;        esp ->  [ret]

         ret

base1:

;        st = []

         fld1  ; 1.0 -> st

;        st = [1.0]

         fld1  ; 1.0 -> st
         
;        st = [1.0, 1.0]

         faddp st1, st0  ; st1 = st1 + st0 and pop

;        st = [1.0+1.0]

         fld1  ; 1.0 -> st
         
;        st = [1.0, 1.0+1.0]

         faddp st1, st0  ; st1 = st1 + st0 and pop

;        st = [1.0+1.0+1.0]

         ret

base2:   
;        st = []

         fld1  ; 1.0 -> st

;        st = [1.0]

         fadd st0, st0  ; st0 = st0 + st0

;        st = [1.0+1.0]

         fadd st0, st0  ; st0 = st0 + st0
         
;        st = [1.0+1.0+1.0+1.0]

         ret


format_n: 
         db "n = ", 0
format_s:
         db "%d", 0
format: 
         db "seq(%d) = %f", 0xA, 0

%ifdef COMMENT
Kompilacja:

nasm r_sequence-exe.asm -o r_sequence-exe.o -f win32
gcc r_sequence-exe.o -o r_sequence-exe.exe -m32
r_sequence-exe.exe

Sekwencja:
seq(1) = 3
seq(2) = 4
seq(n) = 0.5 * seq(n - 1) + 2 * seq(n - 2)
%endif