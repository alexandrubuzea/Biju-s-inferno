section .text
	global cpu_manufact_id
	global features
	global l2_cache_info

;; void cpu_manufact_id(char *id_string);
;
;  reads the manufacturer id string from cpuid and stores it in id_string
cpu_manufact_id:
	enter 	0, 0
	
	; x86 calling convention - saving the values of the registers
	pushad

	xor eax, eax

	; using cpuid with eax = 0 will give us the vendor/manufacturer ID 
	; in the three registers: ebx, edx and eax

	cpuid

	mov eax, dword[ebp + 8]
	mov dword[eax], ebx
	mov dword[eax + 4], edx
	mov dword[eax + 8], ecx

	; restore the values of the registers
	popad

	leave
	ret

;; void features(char *vmx, char *rdrand, char *avx)
;
;  checks whether vmx, rdrand and avx are supported by the cpu
;  if a feature is supported, 1 is written in the corresponding variable
;  0 is written otherwise
features:
	enter 	0, 0
	
	; x86 calling convention - saving the values of the registers
	pushad
	
	; using cpuid when eax = 1
	xor eax, eax
	inc eax
	cpuid

	; the 5th bit is the answer for VMX
	mov edi, dword[ebp + 8] ; vmx
	xor esi, esi

	inc esi
	shl esi, 5
	and esi, ecx
	shr esi, 5
	mov dword[edi], esi

	; the 30th bit is the answer for RDRAND
	mov edi, dword[ebp + 12]; rdrand
	xor esi, esi

	inc esi

	shl esi, 30
	and esi, ecx
	shr esi, 30
	mov dword[edi], esi

	; the 28th bit is the answer for AVX
	mov edi, dword[ebp + 16]; avx
	xor esi, esi

	inc esi

	shl esi, 28
	and esi, ecx
	shr esi, 28
	mov dword[edi], esi

	; restoring the values of the registers
	popad

	leave
	ret

;; void l2_cache_info(int *line_size, int *cache_size)
;
;  reads from cpuid the cache line size, and total cache size for the current
;  cpu, and stores them in the corresponding parameters
l2_cache_info:
	enter 	0, 0
	
	; x86 calling convention - saving the values of the registers
	pushad

	; using cpuid when eax = 0x80000006
	mov eax, 0x80000006
	cpuid

	; take the first byte from ecx for the line size
	mov edx, dword[ebp + 8]
	xor ebx, ebx
	mov bl, cl
	mov dword[edx], ebx

	; take the 3rd and 4th byte from ecx for the cache size
	mov edx, dword[ebp + 12]
	xor ebx, ebx
	shr ecx, 16
	mov ebx, ecx

	mov dword[edx], ebx

	; restoring the values of the registers
	popad

	leave
	ret
