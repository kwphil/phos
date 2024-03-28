%xdefine PML4_BASE 0x70000
%xdefine CR0_PE    1 << 0
%xdefine CR0_PG    1 << 31
%xdefine CR4_PAE   1 << 5
%xdefine CR4_PGE   1 << 7
%xdefine EFER_LME  1 << 8
%xdefine EFER_MSR  0xC0000080

[bits 32]
switch_64:  push    ebp                         ; Overhead for calling from C
            mov     esp,    ebp
            mov     eax,    CR4_PAE | CR4_PGE   ; Set PAE- (Physical Address Extensions) and
            mov     cr4,    eax                 ;   PGE- (Page Global Enable).
            mov     eax,    PML4_BASE           ; Address of PML4
            mov     cr3,    eax                 ; Point CR3 to PML4
            mov     ecx,    EFER_MSR            ; EFER MSR selector
            rdmsr                               ; Read from model specific register
            or      eax,    EFER_LME            ; SET LME (Long Mode Enable)
            wrmsr                               ; Write to moele specific register
            mov     ebx,    cr0                 ; Get CR0
            or      ebx,    CR0_PG | CR0_PE     ; Set PG (Paging) and PE (Protection Enabled)
            mov     cr0,    ebx                 ; Set flags to cr0
            lgdt    [GDT.ptr]                   ; Load global descriptor table
            jmp     GDT.code_0:kernel64_entry   ; Jump to long mode.

SWITCHMSG db "Successfully switched to 64-bit", 0

[bits 64]
kernel64_entry:     mov     ebx,    SWITCHMSG
                    call    print32
                    pop     ebp
                    ret