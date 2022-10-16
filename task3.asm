global get_words
global compare_func
global sort

; libc used functions
section .text
    extern strlen
    extern qsort
    extern strcmp
    extern strtok

; global variabile (string of delimitators)
section .data
    delim db ',. ', 0xA, 0

; int compare_func(void *first, void *second)
compare_func:

    ; creating a stack frame
    push ebp
    mov ebp, esp
    
    ; x86 calling convention - save the values of the registers
    push ebx
    push ecx
    push edx
    push edi
    push esi

    ; move the first element into eax register (this element
    ; in our case is a char **, so we need to get the string
    ; aka char * in eax register)
    mov eax, dword[ebp + 8]
    mov eax, dword[eax]

    ; calculating the length of the string
    push eax
    call strlen
    add esp, 4

    ; save the value of the first string's length
    push eax

    ; the second string
    mov eax, dword[ebp + 12]
    mov eax, dword[eax]

    ; calculating the length of the second string
    push eax
    call strlen
    add esp, 4

    ; move the second string' length into ebx
    mov ebx, eax
    pop eax

    ; compare -> which string is longer
    cmp eax, ebx

    ; if they have different lengths, the compare function
    ; should return length(first) - length(second)

    jnz different_lengths

    ; get the strings
    mov eax, dword[ebp + 8]
    mov eax, dword[eax]
    mov ebx, dword[ebp + 12]
    mov ebx, dword[ebx]

    ; lexicograpically comparing the strings using strcmp
    push ebx
    push eax
    call strcmp
    add esp, 8

    ; final of the function
    jmp compare_func_final

    ; if the strings have different lengths
different_lengths:
    sub eax, ebx

compare_func_final:

    ; restore our registers's values
    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx

    leave
    ret

;; sort(char **words, int number_of_words, int size)
sort:
    enter 0, 0

    ; x86 calling convention - saving the values of the registerss
    pushad

    ; use qsort as a sorting algorithm to sort the word collection
    push compare_func
    push dword[ebp + 16]
    push dword[ebp + 12]
    push dword[ebp + 8]

    ; use qsort from libc
    call qsort
    add esp, 16

    ; restore the values of our registers
    popad
    leave
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    enter 0, 0

    ; save the values of the registers - x86 calling convention
    pushad

    mov eax, dword[ebp + 8]; the string

    ; get the first not-null token using strtok
    push delim
    push eax
    call strtok
    add esp, 8

    xor ecx, ecx
    mov edx, dword[ebp + 12]

iterate_through_words:
    ; put in the array the most recent word
    mov dword[edx + 4 * ecx], eax

    ; save the registers ecx and edx (for strtok)
    push ecx
    push edx

    ; push the delimitator's string and NULL pointer to call strtok
    push delim
    push 0
    call strtok
    add esp, 8

    ; restore the values of ecx and edx
    pop edx
    pop ecx

    ; iterate through string (for the next word)
    inc ecx
    cmp ecx, dword[ebp + 16]
    jnz iterate_through_words

    ; restore the values of the registers
    popad

    leave
    ret
