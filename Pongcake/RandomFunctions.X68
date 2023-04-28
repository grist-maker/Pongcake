*-----------------------------------------------------------
* Title      : Random Functions - Pongcake
* Written by : Ustab Das
* Date       : 10/17/2022
* Description: A selection of functions that together generate a "random" number and store it inside of the variable D6 for later access.
* In the Pongcake game, it is used to generate a random velocity as well as a random velocity for the pancake upon its collision with the
* player's pan. While it is not entirely random and based on a number of manipulations on Easy68k's time value, it is a close enough representation
* for the purposes of the game itself.
*-----------------------------------------------------------
ALL_REG                 REG     D0-D7/A0-A6
GET_TIME_COMMAND        equ     8
    
SetRandomNumber:
        jsr     seedRandomNumber ;Starts by seeding a random number to begin operating with
	clr.l	d6
        jsr     getRandomByteIntoD6 ;Calls the subroutine getRandomByteIntoD6 6 times, then getRandomLongIntoD6 once, making all 8 bytes random values
	clr.l	d6
        jsr     getRandomByteIntoD6
	clr.l	d6
        jsr     getRandomByteIntoD6
	clr.l	d6
        jsr     getRandomByteIntoD6
	clr.l	d6
        jsr     getRandomByteIntoD6
	clr.l	d6
        jsr     getRandomByteIntoD6
	clr.l	d6
        jsr     getRandomLongIntoD6
        
        lea $00FFFF60,sp ;Returns to calling function with random value stored in d6
        rts

seedRandomNumber
        movem.l ALL_REG,-(sp) ;Moves contents of registers into the stack
        clr.l   d6
        
        move.b  #GET_TIME_COMMAND,d0 ;Gets the time and stores the result inside of d1, then moving it to the RandomVal variable
        TRAP    #15
        move.l  d1,RANDOMVAL
        
        movem.l (sp)+,ALL_REG ;Puts stack pointer back at the top of the stack to reaccess the rts value to return to SetRandomNumber
        rts
getRandomByteIntoD6 
        movem.l d0,-(sp) ;Stores d0, d1, and d2 to next positions on the stack
        movem.l d1,-(sp)
        movem.l d2,-(sp)
        
        move.l  RANDOMVAL,d0 ;Moves randomly calculated value into d0, then stores $AF and $100 in d1 and #18 in d2
       	moveq	#$AF-$100,d1
       	moveq	#18,d2
       	
Ninc0	
	add.l	d0,d0 ;Doubles the random value stored in d0, then branches to Ninc1 immediately if there's no carry bit.
	bcc	Ninc1     ;Otherwise, performs XOR on d1 and d0 then falls into ninc1 function.
	eor.b	d1,d0
	
Ninc1
	dbf	d2,Ninc0 ;Goes back to loop Ninc0 if d2 > 1, decrementing d2 by one in the process. If this makes d2 = -1, execution continues, otherwise branching back to ninc0
	
	move.l	d0,RANDOMVAL ;Moves d0 to Randomval, then moves a byte of it into the now empty d6
	clr.l	d6
	move.b	d0,d6
	
    movem.l (sp)+,d2 ;Puts stack pointer where it was prior to getRandomByteIntoD6 execution and resets d2 d1 and d0 to initial values, then returns to calling funciton
    movem.l (sp)+,d1
    movem.l (sp)+,d0
    rts
        
getRandomLongIntoD6
    movem.l ALL_REG,-(sp) ;Adds all register values to stack
    jsr     getRandomByteIntoD6 ;Calls getRandomByteIntoD6 4 times, each time moving the next data byte calculated into d5, stored in order generated via shifting commands
    move.b  d6,d5
    jsr     getRandomByteIntoD6
    lsl.l   #8,d5
    move.b  d6,d5
    jsr     getRandomByteIntoD6
    lsl.l   #8,d5
    move.b  d6,d5
    jsr     getRandomByteIntoD6
    lsl.l   #8,d5
    move.b  d6,d5
    
    move.l  d5,TEMPRANDOMLONG ;Moves d5 into TempRandomLong, then resets all register values and moves random value into d6.
    movem.l (sp)+,ALL_REG
    move.l  TEMPRANDOMLONG,d6
    rts

RANDOMVAL       ds.l    1
TEMPRANDOMLONG  ds.l    1


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
