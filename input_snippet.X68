*-----------------------------------------------------------
* Title      : 
* Written by : Kei C.
* Date       : 3/1/2016
* Description: Gets value of two addresses in hex format
*-----------------------------------------------------------
    ORG    $1000
START:
    LEA     WELCOME,A1 
    MOVE.B  #14,D0
    TRAP    #15 ; display welcome
    BRA     INPUT_HANDLER
    
INPUT_HANDLER:                  

    LEA     PROMPTST,A1 
    MOVE.B  #14,D0
    TRAP    #15 ; display st address prompt
    
    LEA     ADDR_BUFFER,A1
    MOVE.B  #2,D0
    TRAP    #15 ; read starting address as ascii. stores it in (A1) as a buffer. 
                ; length gets stored in D1
    
    ; can check for invalid length first
    ; address must be between $0 and $FFFFFF (highest 6-digit) inclusive
    CMP.B   #0,D1
    BLE     INVALID
    CMP.B   #7,D1
    BGE     INVALID

    
    ; temporarily store string length value in D2
    ; and store address in A2 (D1, A1 for use in LOOP later)
    MOVE.B  D1,D2
    MOVEA.W A1,A2
    ; check for invalid characters
    BRA     CHECKLOOP
    
CLEARED: ; address is valid so far
    CLR.L   D0
    BRA     LOOP ; go to conversion loop

ENDLOOP:    
    
    CLR.L   D0
    
    LEA     PROMPTEND,A1 
    MOVE.B  #14,D0
    TRAP    #15 ; display end address prompt
    
    LEA     ADDR_BUFFER,A1
    MOVE.B  #2,D0
    TRAP    #15 ; read starting address as ascii. stores it in (A1) as a buffer. 
                ; length gets stored in D1


    ; can check for invalid length first
    ; address must be between $0 and $FFFFFF (highest 6-digit) inclusive
    CMP.B   #0,D1
    BLE     INVALID
    CMP.B   #7,D1
    BGE     INVALID

    ; temporarily store string length value in D2
    ; and store address in A2 (D1, A1 for use in LOOP later)
    MOVE.B  D1,D2
    MOVEA.W A1,A2
    ; check for invalid characters
    BRA     CHECKLOOP

SEND_ADDR: ; gets called after conversion loop. puts the address value in memory.
    
    ; now check for odd address
    BTST.L  #0,D0   ; checks if bit 0 of address is set, which indicates odd address
    BNE     INVALID
    
    CMPI.B   #1,D3 ; if starting address flag is set, go to SEND_END_ADDR instead 
    
    BEQ     SEND_END_ADDR
    
    MOVEA.L  D0,A3
    MOVE.B   #1,D3 ; flag set for successfully entering starting address
    BRA ENDLOOP
SEND_END_ADDR:
    MOVEA.L D0,A4 ; A4 is ending address
    CMPA.L  A4,A3
    BGT     INVALID ; starting addr > ending addr
    MOVE.L  A3,START_ADDR 
    MOVE.L  A4,END_ADDR
    BRA END    
    
INVALID:
    LEA     INVALID_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15 ; display error message
    CMPI.B  #1,D3
    BNE     ENDLOOP ; if 1st addr is already set, goto second input loop
    BRA     INPUT_HANDLER ; go back to starting prompt
    
CHECKLOOP: ; loop that checks for invalid characters in an address
    CMPI.B  #$47,(A2) ; checks if character is over 'F'
    BGE     INVALID
    CMPI.B  #$2F,(A2)+ ; checks if character is under '0'
    BLE     INVALID
    SUBI.B  #1,D2
    CMPI.B  #0,D2
    BEQ     CLEARED ; reached end of string, no errors
    BRA     CHECKLOOP
LOOP: ; conversion loop
    CMPI.B  #$41,(A1)
    BGE     TEN_OR_HIGHER
    CMPI.B  #$39,(A1)
    BLE     NINE_OR_LESS
CONT:    
    OR.B    (A1)+,D0 ; add byte value to D0, move A1 to next byte

    SUBI.B  #1,D1 ; decrement D1, which holds # of chars in input
    CMPI.B  #0,D1 ; check if D1 reached 0. if so, end of iteration
    BEQ     SEND_ADDR
    
    ASL.L   #4,D0 ; shift hex digit in D0 left
    
    BRA     LOOP 
    
TEN_OR_HIGHER:
    SUB.B   #55,(A1)  ; get hex value for char, store in A1
    JMP     CONT
NINE_OR_LESS:
    SUB.B   #48,(A1)  ; get hex value for number, store in A1
    JMP     CONT
    
END:
    MOVE.B  #9,D0
    TRAP    #15
    
CR  EQU $0D
LF  EQU $0A

WELCOME     DC.B    'Welcome to the disassembler!',CR,LF,0
PROMPTST    DC.B    'Enter starting address in hex:',CR,LF,0
PROMPTEND   DC.B    'Enter ending address in hex:',CR,LF,0
INVALID_MSG DC.B    'Invalid input!',CR,LF,0
ADDR_BUFFER DS.B    80
START_ADDR  DS.L    80
END_ADDR    DS.L    80

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
