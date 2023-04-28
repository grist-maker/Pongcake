*-----------------------------------------------------------
* Title      : Seven Segment LED Score Counter - Pongcake
* Written by : Gabrielle Tristani
* Date       : 10/17/2022
* Description: A collection of functions used to handle a seven-segment LED score bar that appears in the upper left corner of the game Pongcake. It makes use
* of a function pointer table to accomplish incrementation of digits and display when necessary. A seven segment LED is one that uses 7 rectangular lines, called segments,
* to represent any digit from 0 through 9. Each digit is composed of some mix of the 7 segments, with the digit 8 composed of every one. As a reult, each digit must be
* manually printed in a way separate from all other digits. The program is divided to alow a simple, easy to understand view of the process. The printing of each segment
* is handled in its own subroutine. A function pointer table is coupled with this to define which segments are needed to print each individual digit automatically. Thus, when
* the desired digit is known, that section of the table is jumped to, and each listed segment printer function is called in order until the digit is finished being printed. 
* The program starts by printing the ones digit, then the tens digit, then the hundreds digit, each with some different amount of distance from the leftmost side of the application.
*-----------------------------------------------------------

StartOfLED: ;This is used to wipe the top section of the screen to be cleared for the score bar display
    move.l #80, d0
    move.l #$00000000, d1 ;Set pen color to black
    TRAP #15
    
    move.l #81, d0
    move.l #$00000000, d1 ;Set fill color to black
    TRAP #15
    
    move.l #87,d0 ;Wipes current score bar by drawing a solid black rectangle over the top
    move.w #0, d1
    move.w #0, d2
    move.w #700, d3
    move.w #150, d4
    TRAP #15
    
    jmp Finish ;Goes to Finish afterwards, as clearing this segment is all that needs to happen to start the program
    
SetValues:  ;Function used to determine which digit is to be printed and where, based on current hundreds, tens, or ones value.
    move.l sp,a3
    add.l #156,sp
    
    move.l (sp),d5 ;Current value is saved in d5
    
    cmp.l #10,d5 ;Ensures digit falls within a single digit value, zeroing it and incrementing the digit of the next highest order by one otherwise
    blt GetPrintTableIndex ;Skips ahead if the digit is valid
    
ZeroValue: ;Function used to zero a value and increment that of the next order
    move.l #0,(sp)

    add.l #4,sp ;Moves to next value in stack, incrementing by one. This would be tens or hundreds digit
    add.l #1,(sp)
    sub.l #4,sp

    move.l #0,d5 ;We also zero the value that should be equivalent to the pixel being operated on
    
GetPrintTableIndex:
    add.l #12,sp ;number of pixels incremented from base value for target digit is saved to d6
    move.l (sp),d6
    
    lea PrintTable,a0 ;We load PrintTable into a0, then pointer to address of function that prints value we want to print into d1
    
    mulu.w #4,d5 ;Multiplies d5 by 4 and adds to d1, used to provide number of spaces that should be incremented in a0 for proper digit
    move.l d5,d1
    divu.w #4,d5
    
    move.l (a0,d1),a0
    
CyclingValues:
    move.l (a0),d2 ;Moves the segment to be printed into d2
    
    add.l #4,a0 ;goes to next index
    
    cmp.l #0,d2 ;As long as the value is not 0, we still have more segments to pring
    beq EndCycle ;get out if 0 is set here
    
    move.l d2,a1 ;We jump to correct segment print function
    lea $00FFFF64,sp
    jsr (a1)
    
EndCycle:
    cmp.l #0,d2
    bne CyclingValues
    
    move.l a3,sp
    rts
    
SegmentA:
    move.l #87,d0 ;Draws A segment then returns to CyclingValues
    move.w #5, d1
    add.l d6,d1
    move.w #0, d2
    move.w #25, d3
    add.l d6,d3
    move.w #5, d4
    TRAP #15
    
    rts
    
SegmentB:
    move.l #87,d0 ;Draws B segment then returns to CyclingValues
    move.w #25, d1
    add.l d6,d1
    move.w #5, d2
    move.w #30, d3
    add.l d6,d3
    move.w #25, d4
    TRAP #15
    
    rts
    
SegmentC:
    move.l #87,d0 ;Draws C segment then returns to CyclingValues
    move.w #25, d1
    add.l d6,d1
    move.w #30, d2
    move.w #30, d3
    add.l d6,d3
    move.w #50, d4
    TRAP #15
    
    rts
    
SegmentD:
    move.l #87,d0 ;Draws D segment then returns to CyclingValues
    move.w #5, d1
    add.l d6,d1
    move.w #50, d2
    move.w #25, d3
    add.l d6,d3
    move.w #55, d4
    TRAP #15
    
    rts
    
SegmentE:
    move.l #87,d0 ;Draws E segment then returns to CyclingValues
    move.w #0, d1
    add.l d6,d1
    move.w #30, d2
    move.w #5, d3
    add.l d6,d3
    move.w #50, d4
    TRAP #15
    
    rts
    
SegmentF:
    move.l #87,d0 ;Draws F segment then returns to CyclingValues
    move.w #0, d1
    add.l d6,d1
    move.w #5, d2
    move.w #5, d3
    add.l d6,d3
    move.w #25, d4
    TRAP #15
    
    rts
    
SegmentG:
    move.l #87,d0 ;Draws G segment then returns to CyclingValues
    move.w #5, d1
    add.l d6,d1
    move.w #25, d2
    move.w #25, d3
    add.l d6,d3
    move.w #30, d4
    TRAP #15 
    
    rts  
    
AddScore:
    lea $00FFFFC8, sp ;Grab current hundreds to see if its 9, continuing to check other values if so
    cmp.l #9,(sp)
    bne Valid
    
    add.l #0,-(sp) ;Grab current tens to see if its 9, continuing to check other values if so
    cmp.l #9,(sp)
    bne Valid
    
    add.l #0,-(sp) ;Grab current ones to see if its 9, stopping addition to the score if 999 is reached
    cmp.l #9,(sp)
    beq GameLoop
       
Valid:
    lea $00FFFFC0,sp ;grab current ones value and increments by one since an add has been requested
    add.l #1,(sp)
    
    move.l #80, d0
    move.l #$00000000, d1 ;Set pen color to black
    TRAP #15
    
    move.l #81, d0
    move.l #$00000000, d1 ;Set fill color to black
    TRAP #15
    
    move.l #87,d0 ;Wipes current score bar
    move.w #0, d1
    move.w #0, d2
    move.w #700, d3
    move.w #120, d4
    TRAP #15
    
    move.l #80, d0
    move.l #$0000FF00, d1 ;Set pen color to green
    TRAP #15
    
    move.l #81, d0
    move.l #$0000FF00, d1 ;Set fill color to green
    TRAP #15
    
ScoreInitializer:
    lea $00FFFFD4, sp 
    cmp.l #0,(sp) ;if value has already been initialized (hundreds digit distance from left of screen is set to 0), we can just go to PrintScore
    beq PrintScore
                
    lea $00FFFFD8,sp
    move.l #80, d0
    move.l #$0000FF00, d1 ;Set pen color to green
    TRAP #15
    
    move.l #81, d0
    move.l #$0000FF00, d1 ;Set fill color to green
    TRAP #15
    
    ;Begins value initialization for this program
    move.l #0,-(sp) ;How many pixels are incremented from base value for hundreds digit FFD4
    move.l #70,-(sp) ;How many pixels are incremented from base value for tens digit FFD0
    move.l #140,-(sp) ; Pixels incremented from base value for ones digit FFCC
    move.l #0,-(sp) ;Curren hundreds value FFC8
    move.l #0,-(sp) ;Current tens value FFC4
    move.l #0,-(sp) ;Current ones value FFC0
    
PrintScore:
    lea $00FFFF28,sp ;Prints the ones digit
    jsr SetValues
    
    lea $00FFFF2C,sp ;Prints the tens digit
    jsr SetValues
    
    lea $00FFFF30,sp ;Prints the hundreds digit
    jsr SetValues
    
GameLoop:
    move.l #81, d0
    move.l #$00000000, d1 ;Set fill color to black and then returns to program
    TRAP #15
    
    lea $00FFFFD8,sp
    rts

SegmentFunctionTable: ;Function pointer table that has references to the ordered list of function to print any given digit
                ZeroPrint:
                    dc.l SegmentA, SegmentB, SegmentC, SegmentD, SegmentE, SegmentF,0 ;References segments used to print 0
                OnePrint:
                    dc.l SegmentB,SegmentC,0 ;References segments used to print 1
                TwoPrint:
                    dc.l SegmentA,SegmentB, SegmentD, SegmentE, SegmentG,0 ;References segments used to print 2
                ThreePrint:
                    dc.l SegmentA,SegmentB,SegmentC,SegmentD,SegmentG,0 ;References segments used to print 3
                FourPrint:
                    dc.l SegmentB,SegmentC,SegmentF,SegmentG,0 ;References segments used to print 4
                FivePrint:
                    dc.l SegmentA,SegmentC,SegmentD,SegmentG,SegmentF,0 ;References segments used to print 5
                SixPrint:
                    dc.l SegmentA,SegmentC,SegmentD,SegmentE,SegmentF,SegmentG,0 ;References segments used to print 6
                SevenPrint:
                    dc.l SegmentA,SegmentB,SegmentC,0 ;References segments used to print 7
                EightPrint:
                    dc.l SegmentA,SegmentB,SegmentC,SegmentD,SegmentE,SegmentF,SegmentG,0 ;References segments used to print 8
                NinePrint:
                    dc.l SegmentA,SegmentB,SegmentC,SegmentF,SegmentG,0 ;References segments used to print 9
                
PrintTable: ;A table that contains references to each of the number printer routines, with each index correlating to the digit printed
                dc.l ZeroPrint,OnePrint,TwoPrint,ThreePrint,FourPrint,FivePrint,SixPrint,SevenPrint,EightPrint,NinePrint
                
Finish:


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
