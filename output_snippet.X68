*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    MOVE.B  #128,D3
    MOVE.B  D3,D2
    LEA     DATA_BUFFER,A2
    MOVEA.L A2,A3
POPULATE:                ; will remove from final program
    MOVE.B  #$4D,(A3)+
    SUBI.B  #1,D2
    CMPI.B  #0,D2
    BEQ     NEXT
    BRA POPULATE
NEXT:
    MOVE.B  #16,D2 ; output 16 lines at a time
    MOVE.B  D3,D4 ; store 128 (size of buffer)
    DIVU.W  D2,D3 ; 128/16, D2 = 16, D3 = 8, D4 = 128
    MOVE.B  D2,D5 ; store 16
    MOVE.B  #1,D1 ; 1 byte long
    BRA OUTLOOP
OUTLOOP:
    MOVEA.W A2,A1 ; load (next) data at data buffer to A1
    ADDA.W  #1,A2
    MOVE.B  #0,D0 ; output string at A1 with CRLF
    TRAP    #15
    SUBI.B  #1,D2 ; decrement D2 (16~0)
    CMPI.B  #0,D2 ; if the 16 lines are displayed, goto branch
    BEQ     END_BATCH
    BRA     OUTLOOP
    
END_BATCH:
    SUBI.B  #1,D3 ; decrement D3 (8~0)
    CMPI.B  #0,D3 ; if the 8 loops are completed, go to end
    BEQ     END
    LEA     LOAD_MORE,A1 ; load "load more..." message to A1
    MOVE.B  #13,D0 ; display the message
    TRAP    #15
    MOVE.B  #5,D0 ; wait for user to press a key (note: D1 stores the input)
    TRAP    #15
    MOVE.B  #1,D1 ; reload byte size
    MOVE.B  D5,D2 ; reload 16, then go back to outloop
    BRA     OUTLOOP
    

    
END:
    

CR  EQU $0D
LF  EQU $0A

LOAD_MORE     DC.B    'Press enter to load more...',CR,LF,0
DATA_BUFFER   DS.B    128

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
