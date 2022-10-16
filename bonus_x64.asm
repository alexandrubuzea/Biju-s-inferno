section .text
	global intertwine

;; void intertwine(int *v1, int n1, int *v2, int n2, int *v);
;
;  Take the 2 arrays, v1 and v2 with varying lengths, n1 and n2,
;  and intertwine them
;  The resulting array is stored in v
intertwine:
	enter 0, 0

	; rdi -> v1
	; rsi -> n1
	; rdx -> v2
	; rcx -> n2
	; r8 -> v

	xor r10, r10

; we simultaneously iterate through arrays in order to fill the v array
iterate_through_arrays:

	; put the corresponding value from the first array
	mov eax, dword[rdi + 4 * r10]
	mov dword[r8 + 8 * r10], eax

	; put the corresponding value from the second array
	mov eax, dword[rdx + 4 * r10]
	mov dword[r8 + 8 * r10 + 4], eax

	; increase counter (r10)
	inc r10
	cmp r10, rsi ; the first array's length
	jge done_iterating

	cmp r10, rcx ; the second array's length
	jge done_iterating

	jmp iterate_through_arrays

done_iterating:

	; determining which array still has elements which we haven't moved yet
	cmp rsi, rcx
	jl second_array_is_longer

	cmp rsi, rcx
	jg first_array_is_longer

	; if both arrays have the same length, the algorithm is over
	jmp function_final

second_array_is_longer:
	; create a separate counter for the v array
	mov r11, rsi
	shl r11, 1

second_array_loop:
	; move elements from array v2 to v
	mov eax, dword[rdx + 4 * r10]
	mov dword[r8 + 4 * r11], eax

	inc r10
	inc r11
	cmp r10, rcx
	jnz second_array_loop

	jmp function_final

first_array_is_longer:
	; create a separate counter for the v array
	mov r11, rcx
	shl r11, 1

first_array_loop:
	; move elements from array v1 to v
	mov eax, dword[rdi + 4 * r10]
	mov dword[r8 + 4 * r11], eax

	inc r10
	inc r11
	cmp r10, rsi
	jnz first_array_loop

	jmp function_final

function_final:

	leave
	ret
