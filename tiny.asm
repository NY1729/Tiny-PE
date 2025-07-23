; nasm

BITS 32
base equ 0x400000

;
; DOS header
;

mzhdr:
    dw "MZ"       ; DOS e_magic
    dw 0

;
; NT headers
;

    dd "PE"       ; PE signature

;
; NT file header
;

filehdr:
    dw 0x014C            ; Machine (Intel 386)
    dw 1                 ; NumberOfSections    
start:
    push base + msg      ; TimeDateStamp UNUSED
    jmp code2            ; PointerToSymbolTable UNUSED
    db 0,0               ; NumberOfSymbols UNUSED
    dw opthdrsize        ; SizeOfOptionalHeader
    dw 0x103             ; Characteristics

;
; NT optional header
;
code:

opthdr:
    dw 0x10B                    ; Magic (PE32)
    db 0                        ; MajorLinkerVersion UNUSED
    db 0                        ; MinorLinkerVersion UNUSED
iat:
printf:   dd 0x800001B8         ; SizeOfCode UNUSED                 ; Import printf by ordinal
exit:   dd 0x80000167           ; SizeOfInitializedData UNUSED      ; Import exit by ordinal
    dd 0                        ; SizeOfUninitializedData UNUSED
    dd start                    ; AddressOfEntryPoint
    dd 0                        ; BaseOfCode UNUSED
    dd 0                        ; BaseOfData UNUSED
    dd base                     ; ImageBase
    dd 4        ; DOS e_lfanew  ; SectionAlignment
    dd 4                        ; FileAlignment
crt:
    db "crtdll",0               ; MajorOperatingSystemVersion UNUSED ; Import dll file
                                ; MinorOperatingSystemVersion UNUSED
                                ; MajorImageVersion UNUSED
    db 0                        ; MinorImageVersion UNUSED
    dw 4                        ; MajorSubsystemVersion
    dw 0                        ; MinorSubsystemVersion UNUSED
    dd 0                        ; Win32VersionValue UNUSED
    dd 1024                     ; SizeOfImage
    dd 1                        ; SizeOfHeaders          nonzero for Windows XP
    dd 0                        ; CheckSum UNUSED
    dw 3                        ; Subsystem (Console)
    dw 0                        ; DllCharacteristics UNUSED
idata:
code2:
    call [base+printf]          ; SizeOfStackReserve
    call [base+exit]            ; SizeOfStackCommit
                                ; SizeOfHeapReserve
    dd crt                      ; SizeOfHeapCommit UNUSED           ; Name
    dd iat                      ; LoaderFlags UNUSED                ; FirstThunk
    dd 2                        ; NumberOfRvaAndSizes    for Windows 10; UNUSED in Windows XP

;
; Data directories (part of optional header)
;
    dd 0,0                      ; Export Table UNUSED
    dd idata, 0                 ; Import Table

opthdrsize equ $ - opthdr

;
; Code section header
;

    db ".text", 0, 0, 0         ; Name
    dd codesize                 ; VirtualSize
    dd code                     ; VirtualAddress
    dd codesize                 ; SizeOfRawData
    dd code                     ; PointerToRawData

align 4, db 0

msg:
    db "This executable file is as small as possible because Windows can still run exe files at only 268 bytes.", 0

codesize equ $ - code

;
; Padding for Windows 10
;
    times 268 - ($-$$) db 0