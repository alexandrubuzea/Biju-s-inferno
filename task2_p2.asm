section .text
	global par

;; int par(int str_length, char* str)
;
; check for balanced brackets in an expression
par:
	; creating the stack frame
	push ebp
	push esp 
	pop ebp

	; x86 calling convention - save the values of the registers
	pushad

	; push the string length - first parameter
	push dword[ebp + 8]
	pop ebx

	; push the string pointer - second parameter
	push dword[ebp + 12]
	pop eax

	; empty the values of these registers for use
	xor ecx, ecx
	xor edx, edx
	xor edi, edi

	; iterate/loop through string
	loop_through_string:
		; if the current character is an open paranthesis
		cmp byte[eax + ecx], '('
		je open_parenthesis

		; if the current character is a closed paranthesis
		cmp byte[eax + ecx], ')'
		je closed_parenthesis

		; any other possible case -> our implementation is
		; useful when checking expression's validity
		jmp iteration_final

	open_parenthesis:
		; using edi as a counter for the difference between the number of
		; open parenthesis and the number of closed parenthesis
		inc edi
		jmp iteration_final
	
	closed_parenthesis:
		; if edi is already 0, there are more closed than open paranthesis
		; up to the current character -> invalid expression
		cmp edi, 0
		jz not_enough_open_parentheses

		; else, just close a parenthesis (substract 1)
		dec edi
		jmp iteration_final

	; increase index and check for the bounds of the string
	iteration_final:
		inc ecx
		cmp ecx, ebx

		jnz loop_through_string

	; if there are no open parenthesis left -> valid expression
	cmp edi, 0
	jz success

too_many_open_parantheses:
	; restoring the values of the registers
	popad

	; put 0 in eax (invalid expression)
	xor eax, eax

	; exit function
	jmp function_final

not_enough_open_parentheses:
	; restoring the values of the registers
	popad

	; put 0 in eax (invalid expression)
	xor eax, eax

	; exit function
	jmp function_final

success:
	; restoring the values of the registers
	popad

	; put 1 in eax (success <-> valid expression)
	xor eax, eax
	inc eax

	; exit function
	jmp function_final

function_final:

	; restoring ebp
	pop ebp

	ret
