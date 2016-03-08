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
    MOVE.B  #25,D2 ; output x lines at a time
    MOVE.B  D3,D4 ; store 128 (size of buffer)
    MOVE.B  D2,D3 ; store x
    MOVE.B  #1,D1 ; 1 byte long
    BRA OUTLOOP
OUTLOOP:
    MOVEA.W A2,A1 ; load (next) data at data buffer to A1
    ADDA.W  #1,A2
    MOVE.B  #0,D0 ; output string at A1 with CRLF
    TRAP    #15
    SUBI.B  #1,D4 ; decrement D4 (128~0)
    CMPI.B  #0,D4 ; if all data is read, go to end
    BEQ     END
    SUBI.B  #1,D2 ; decrement D2 (x~0)
    CMPI.B  #0,D2 ; if the x lines are displayed, goto branch
    BEQ     END_BATCH
    BRA     OUTLOOP
    
END_BATCH:
    LEA     LOAD_MORE,A1 ; load "load more..." message to A1
    MOVE.B  #13,D0 ; display the message
    TRAP    #15
    MOVE.B  #5,D0 ; wait for user to press a key (note: D1 stores the input)
    TRAP    #15
    MOVE.B  #1,D1 ; reload byte size
    MOVE.B  D3,D2 ; reload x, then go back to outloop
    BRA     OUTLOOP
    

    
END:
    LEA     START_OVER,A1
    MOVE.B  #18,D0
    TRAP    #15
    CMPI.B  #1,D1
    BEQ     START
    LEA     END_PROCESS,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #9,D0
    TRAP    #15
    

CR  EQU $0D
LF  EQU $0A

LOAD_MORE     DC.B    CR,LF,'Press enter to load more...',0
START_OVER    DC.B    CR,LF,'That was exciting! Would you like to try again? (1: yes, other keys: no)',CR,LF,0
END_PROCESS   DC.B    CR,LF,':( See you again soon!',0
DATA_BUFFER   DS.B    128

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
