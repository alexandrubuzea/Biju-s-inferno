section .text
	global cmmmc

;; int cmmmc(int a, int b)
;
;; calculate least common multiplier for 2 numbers, a and b
cmmmc:
	; first step in creating a stack frame
	push ebp

	; the equivalent of mov ebp, esp - creating stack frame
	push esp
	pop ebp

	; saving the values of the registers - x86 calling convention
	push ebx
	push ecx
	push edx
	push edi
	push esi

	; move the first number in eax register
	push dword[ebp + 8]
	pop eax

	; move the second number in ebx register
	push dword[ebp + 12]
	pop ebx

	; empty the ecx and edx registers
	xor ecx, ecx
	xor edx, edx

	; get the product
	mov edx, eax
	imul edx, ebx

	; save the value of the product on the stack
	push edx

	xor edx, edx

	; using euclid's algorithm (with substractions) in order to determine
	; gcd - greatest common divisor of a and b
loop_euclid:

	; see if a or b is greater - we need to save the higher value in eax
	cmp eax, ebx

	jge continue_euclid

	; if b is greater than a, exchange the registers
	xchg eax, ebx

continue_euclid:
	; the existing substraction in the euclid's algorithm
	sub eax, ebx

	cmp ebx, edx

	jne loop_euclid

	; move the gcd into ebx
	push eax
	pop ebx

	; get the previously saved product
	pop eax
	
	; the division -> lcm (lowest common multiplier) = product / gcd
	div ebx

	; restoring the registers - x86 calling convention
	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx

	; restore old base pointer - instead of leave
	pop ebp

	ret
