section .text
	global sort

; struct node {
;     	int val;
;    	struct node* next;
; };

struc node
	val: resd 1
	next: resd 1
endstruc

;; struct node* sort(int n, struct node* node);
; 	The function will link the nodes in the array
;	in ascending order and will return the address
;	of the new found head of the list
; @params:
;	n -> the number of nodes in the array
;	node -> a pointer to the beginning in the array
; @returns:
;	the address of the head of the sorted list
sort:
	enter 0, 0
	; to save the values of the registers
	push ebx
	push ecx
	push edx
	push edi
	push esi

	mov ecx, [ebp + 8]; the number of nodes
	mov ebx, [ebp + 12]; the pointer to the first element

	xor eax, eax
	inc eax; eax needs to have a value equal to one

	; find the node with the value equals 1, and save the pointer to that
	; element on the stack

	label_for:

		; extracting the value of the node
		mov edx, dword [ebx + node_size * ecx - node_size + val]

		; compare to the value of 1
		cmp edx, eax

		; if we have not found the new minimum, continues
		jne not_found_new_minimum

		; if we found the minimum, take its address
		lea edx, [ebx + node_size * ecx - node_size];

		; push it twice on the stack, in order to use it for the
		; next iteration and for return
		push edx
		push edx

		; exit loop if minimum found
		jmp continue_label

	; go to the next element
	not_found_new_minimum:
		loop label_for

continue_label:
	; increase the value to be found by one
	inc eax

	; make the bindings between pointers
	label_for_again:

		; the number of nodes
		mov ecx, [ebp + 8]

		; iterate through the values and find the value equal to eax
		label_for_again_and_again:

			; get the value in the current node
			mov edx, dword[ebx + node_size * ecx - node_size + val]
			cmp edx, eax

			; if the value is not the one we are looking for
			jne next_step
			
			; get the pointer to the node with eax - 1
			pop edx

			; save the value of eax
			push eax

			; move the address of the node into eax
			lea eax, [ebx + node_size * ecx - node_size]

			; make the link
			mov dword[edx + next], eax
			mov edx, eax

			; restore the value and push the new pointer to previous node
			pop eax
			push edx

		next_step:
			loop label_for_again_and_again

		; the value we search for
		inc eax;
		cmp eax, [ebp + 8]

		jle label_for_again

	; clear the stack of local variables
	pop eax

	; the address of the head - to return
	pop eax
	
	; to restore the values of the registers - x86 calling convention
	pop esi
	pop edi
	pop edx
	pop ecx
	pop ebx

	leave
	ret
