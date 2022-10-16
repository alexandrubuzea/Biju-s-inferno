section .text

global expression
global term
global factor

; `factor(char *p, int *i)`
;       Evaluates "(expression)" or "number" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
factor:
        push    ebp
        mov     ebp, esp
        
        ; x86 calling convention: saving the values for all registers

        push ebx
        push ecx
        push edx
        push edi
        push esi

        ; put the parameters in registers
        mov ebx, dword[ebp + 8]
        mov edi, dword[ebp + 12]

        ; put the current index in ecx register
        mov ecx, dword[edi]

        ; if the current character is an open parenthesis, we have an
        ; expression
        cmp byte[ebx + ecx], '('
        jne fact_not_an_open_paranthesis

        inc ecx
        mov dword[edi], ecx

        ; using recursivity (call the expression function)
        push dword[ebp + 12]
        push dword[ebp + 8]
        call expression

        add esp, 8
        jmp factor_final

fact_not_an_open_paranthesis:
        xor eax, eax
        xor edx, edx

; here we build the number to be returned (as an integer)
fact_loop:
        cmp byte[ebx + ecx], '0'
        jl factor_final

        cmp byte[ebx + ecx], '9'
        jg factor_final

        imul eax, 10
        mov dl, byte[ebx + ecx]
        sub dl, '0'
        add eax, edx
        inc ecx
        mov dword[edi], ecx

        jmp fact_loop

factor_final:
        pop esi
        pop edi
        pop edx
        pop ecx
        pop ebx

        leave
        ret

; `term(char *p, int *i)`
;       Evaluates "factor" * "factor" or "factor" / "factor" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
term:
        push    ebp
        mov     ebp, esp
        
        ; x86 calling convention: saving the values for all registers

        push ebx
        push ecx
        push edx
        push edi
        push esi

        ; push parameters on stack
        push dword[ebp + 12]
        push dword[ebp + 8]

        ; call function and clear stack
        call factor
        add esp, 8

        ; move in registers the parameters
        mov ebx, dword[ebp + 8] ; the string
        mov ecx, dword[ebp + 12] ; the position

        ; move in ecx register the current index (as an integer, not as a
        ; pointer)
        mov ecx, dword[ecx]

; iterate through string, while we can calculate factors from the same term
term_iteration_loop:
        ; if we have a slash, calculate a new factor and perform the division
        cmp byte[ebx + ecx], '/'
        jnz term_not_a_slash_sign

        inc ecx
        mov edx, dword[ebp + 12]
        mov dword[edx], ecx

        push eax

        ; recursively call factor
        push dword[ebp + 12]
        push dword[ebp + 8]
        call factor

        add esp, 8

        mov ecx, dword[ebp + 12]
        mov ecx, dword[ecx]

        pop edx
        xchg eax, edx

        ; dividing integer values (signed numbers)
        mov edi, edx
        xor edx, edx
        cdq
        idiv edi

term_not_a_slash_sign:

        ; if the current character is a star, we extract a new factor and
        ; perform multiplication
        cmp byte[ebx + ecx], '*'
        jnz term_not_a_multiply_sign

        inc ecx
        mov edx, dword[ebp + 12]
        mov dword[edx], ecx

        push eax

        ; recursively calling factor function
        push dword[ebp + 12]
        push dword[ebp + 8]
        call factor

        add esp, 8

        mov ecx, dword[ebp + 12]
        mov ecx, dword[ecx]

        pop edx
        xchg eax, edx

        imul eax, edx

term_not_a_multiply_sign:
        ; if we have a closed parenthesis or a first order operator (+ or -),
        ; the term is finished and we can return its value
        cmp byte[ebx + ecx], ')'
        je term_final

        cmp byte[ebx + ecx], '+'
        je term_final

        cmp byte[ebx + ecx], '-'
        je term_final

        cmp byte[ebx + ecx], 0
        je term_final

term_not_a_closed_paranthesis:
        ; continue the iteration
        cmp byte[ebx + ecx], 0
        jne term_iteration_loop

term_final:

        ; restoring the values of the registers
        pop esi
        pop edi
        pop edx
        pop ecx
        pop ebx

        leave
        ret

; `expression(char *p, int *i)`
;       Evaluates "term" + "term" or "term" - "term" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
expression:
        push    ebp
        mov     ebp, esp
        
        ; x86 calling convention: saving the values for all registers

        push ebx
        push ecx
        push edx
        push edi
        push esi

        ; push parameters on stack
        push dword[ebp + 12]
        push dword[ebp + 8]

        ; call function and clear stack
        call term
        add esp, 8

        mov ebx, dword[ebp + 8] ; the string
        mov ecx, dword[ebp + 12] ; the position
        mov ecx, dword[ecx] ; the current index (as an integer)

expr_iteration_loop:
        ; if we have a + sign, extract a term and perform addition
        cmp byte[ebx + ecx], '+'
        jnz expr_not_a_plus_sign

        inc ecx
        mov edx, dword[ebp + 12]
        mov dword[edx], ecx

        push eax

        ; recursively calling the term function
        push dword[ebp + 12]
        push dword[ebp + 8]
        call term

        add esp, 8

        mov ecx, dword[ebp + 12]
        mov ecx, dword[ecx]

        pop edx
        xchg eax, edx

        add eax, edx

expr_not_a_plus_sign:
        ; if we have a - sign, extract a new term and perform substraction
        cmp byte[ebx + ecx], '-'
        jnz expr_not_a_minus_sign

        inc ecx
        mov edx, dword[ebp + 12]
        mov dword[edx], ecx

        ; save the result
        push eax

        ; recursively calling term function.
        push dword[ebp + 12]
        push dword[ebp + 8]
        call term

        add esp, 8

        mov ecx, dword[ebp + 12]
        mov ecx, dword[ecx]

        ; get back the result and perform substraction
        pop edx
        xchg eax, edx

        sub eax, edx

expr_not_a_minus_sign:
        ; if we have a closed parenthesis, we stop the function
        cmp byte[ebx + ecx], ')'
        jne expr_not_a_closed_paranthesis

        ; increase the current position and then stop the function
        inc ecx
        mov edx, dword[ebp + 12]
        mov dword[edx], ecx
        jmp expr_final

expr_not_a_closed_paranthesis:
        ; iterating through expression
        cmp byte[ebx + ecx], 0
        jne expr_iteration_loop

expr_final:

        ; restoring the values of the registers

        pop esi
        pop edi
        pop edx
        pop ecx
        pop ebx
        leave
        ret
