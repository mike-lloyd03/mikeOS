global start

section .text
bits 32
start:
    ; Point the first entry of the level 4 page table to the first
    ; entry in the p3 table
    mov eax, p3_table
    or eax, 0b11
    mov dword [p4_table + 0], eax
    ; Point the first entry of the level 3 page table to the first
    ; entry in the p2 table
    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax
    ; point each page table level two entry to a page
    mov ecx, 0 ; counter variable
    .map_p2_table: ; label our loop
        mov eax, 0x200000 ; 2MiB
        mul ecx ; multiply the counter variable by eax
        or eax, 0b10000011
        mov [p2_table + ecx * 8], eax
        inc ecx ; increment the counter
        cmp ecx, 512 ; compare the counter to 512
        jne .map_p2_table ; Jump if Not Equal to the top of the loop
        
    ; move page table address to cr3
    mov eax, p4_table
    mov cr3, eax

	; enable Physical Address Extension
    mov eax, cr4
    or eax, 1 << 5 ; 1 << 5 left bitshift 1 5 times = 100000
    mov cr4, eax

    ; set the long mode bit
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; enable paging
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax

    ; load gdt
    lgdt [gdt64.pointer]

    ; update selectors
    mov ax, gdt64.data
    mov ss, ax
    mov ds, ax
    mov es, ax

    mov word [0xb8000], 0x0F49 ; I
    mov word [0xb8002], 0x0F20 ; _
    mov word [0xb8004], 0x0F4C ; L
    mov word [0xb8006], 0x0F49 ; I
    mov word [0xb8008], 0x0F4B ; K
    mov word [0xb800a], 0x0F45 ; E
    mov word [0xb800c], 0x0F20 ; _
    mov word [0xb800e], 0x0254 ; T
    mov word [0xb8010], 0x0241 ; A
    mov word [0xb8012], 0x0F43 ; C
    mov word [0xb8014], 0x044F ; O
    mov word [0xb8016], 0x0453 ; S

    ; jump to long mode
    jmp gdt64.code:long_mode_start

section .bss

align 4096

p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096

; setup Global Descriptor Table
section .rodata ; read only data
gdt64:
    dq 0
.code: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)
.data: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41)
.pointer:
    dw .pointer - gdt64 - 1
    dq gdt64

section .text
bits 64
long_mode_start:
    ; mov rax, 0x2f592f412f4b2f4f
    ; mov qword [0xb8000], rax

    hlt
