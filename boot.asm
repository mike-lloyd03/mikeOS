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
    .map_p2_table:
        mov eax, 0x200000 ; 2MiB
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
    hlt

section .bss

align 4096

p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096
