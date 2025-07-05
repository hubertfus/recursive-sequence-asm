%ifdef COMMENT

seq(1) = 3
seq(2) = 4
seq(n) = 0.5 * seq(n - 1) + 2 * seq(n - 2)
%endif

         [bits 32]

;        esp -> [ret]  ; ret - adres powrotu do asmloader

prompt_loop:
         call getaddr  ; push on the stack the run-time address of format_n and jump to getaddr
format_n:
         db "n = ", 0
getaddr:

;        esp -> [format_n][ret]

         call [ebx+3*4]  ; printf(format_n)

;        esp -> [n][ret]  ; zmienna n, adres format_n nie jest juz potrzebny
                                                               
         push esp  ; esp -> stack = addr_n
                                                          
;        esp -> [addr_n][n][ret]

         call getaddr2  ; push on the stack the run-time address of format_s and jump to getaddr2
format_s:
         db "%d", 0
getaddr2:

;        esp -> [format_s][addr_n][n][ret]

         call [ebx+4*4]  ; scanf(format_s, addr_n)
         add esp, 2*4    ; esp = esp + 8

;        esp -> [n][ret]

         cmp eax, 1         ; eax - 1           ; OF SF ZF AF PF CF affected
         jne invalid_input  ; jump if not equal ; jump if ZF = 0

         call [ebx+2*4]     ; getchar()
         cmp al, 0x0A       ; al - '\n'        ; OF SF ZF AF PF CF affected
         jne invalid_input  ; jump if not equal ; jump if ZF = 0

         mov ecx, [esp]  ; eax = n

         cmp ecx, 1      ; ecx - 1       ; OF SF ZF AF PF CF affected
         jl prompt_loop  ; jump if less  ; jump if SF != OF

         jmp compute_seq  ; jump always

invalid_input:

clear_stdin:
         call [ebx+2*4]  ; getchar()

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

         call getaddr3  ; push on the stack the run-time address of format and jump to getaddr3
format:
         db "seq(%d) = %f", 0xA, 0
getaddr3:

;        esp -> [format][ecx][fl][fh][ret] ;

         call [ebx+3*4]  ; printf(format, ecx, f);
         add esp, 4*4    ; esp = esp + 16

;        esp -> [ret]

         push 0          ; esp -> [0][ret]
         call [ebx+0*4]  ; exit(0);

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
         

%ifdef COMMENT
eax = seq(ecx)

;        esp -> [raddr][ret]

* seq(3) = 0.5 * seq(2) + 2 * seq(1)
  ecx = ecx - 1 = 2                ecx = ecx - 1 = 2
  ecx -> stack = 2                 ecx -> stack = 2
  eax = seq(2) =                   eax = seq(2) = 4
                                     
  ecx <- stack = 2                 ecx <- stack = 2
  ecx = ecx - 1 = 1                ecx = ecx - 1 = 1
  eax -> stack =                   eax -> stack = 1
  eax = seq(1) =                   eax = seq(1) = 3
  ecx <- stack =                   ecx <- stack = 1
  eax =  0.5 * eax + 2 * ecx =     eax = eax + ecx = 0.5 * 4 + 2 * 3 = 8.0
  return eax =                     return eax = 8.0


* seq(1) =           * seq(1) = 3
  eax = 3               eax = 3
  return eax =3         return eax = 3
         
* seq(2) =           * seq(2) = 4
  eax = 4               eax = 4
  return eax =4         return eax = 4


%endif

; asmloader API
;
; ESP wskazuje na prawidlowy stos
; argumenty funkcji wrzucamy na stos
; EBX zawiera pointer na tablice API
;
; call [ebx + NR_FUNKCJI*4] ; wywolanie funkcji API
;
; NR_FUNKCJI:
;
; 0 - exit
; 1 - putchar
; 2 - getchar
; 3 - printf
; 4 - scanf
;
; To co funkcja zwr�ci jest w EAX.
; Po wywolaniu funkcji sciagamy argumenty ze stosu.
;
; https://gynvael.coldwind.pl/?id=387

%ifdef COMMENT

ebx    -> [ ][ ][ ][ ] -> exit
ebx+4  -> [ ][ ][ ][ ] -> putchar
ebx+8  -> [ ][ ][ ][ ] -> getchar
ebx+12 -> [ ][ ][ ][ ] -> printf
ebx+16 -> [ ][ ][ ][ ] -> scanf

%endif

