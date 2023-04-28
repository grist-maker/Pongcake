*-----------------------------------------------------------
* Title      : Pongcake - Title and Initialization
* Written by : Gabrielle Tristani
* Date       : 10/17/2022
* Description: A program containing starting functions to initialize game state and replay the game. It handles drawing the initial title bitmap, waiting for user input to begin the game,
* and initializing values for the pancake before drawing it in other programs.
*-----------------------------------------------------------
FirstTimeCheck: ;Checks if this is the first time the game has booted, if so, loading in sounds, and otherwise skipping it
    lea $00FFFFD4,sp
    cmp.l #1,(sp)
    beq DrawingTitle
    
LoadInSound:
     lea backgroundMusic,a1 ;Loads in title screen music
     move.l #0,d1
     move.l #74,d0
     TRAP #15
       
     lea pancakeFlip,a1 ;Loads in pancake flip sound effect
     move.l #0,d1
     move.l #71,d0
     TRAP #15  
     
     lea pancakeDropped,a1 ;Loads in loss sound effect
     move.l #1,d1
     move.l #71,d0
     TRAP #15  
     
     lea pancakeFall,a1 ;Loads in game start sound effect
     move.l #2,d1
     move.l #71,d0
     TRAP #15

FirstTime: ;First function, used to draw the start screen. Includes bitmap drawing function.
    move.l #92,d0 ;Sets double buffer mode
    move.l #17,d1
    TRAP #15
    
     move.b #0,d1 ;Play title screen music loop
     move.l #1,d2
     move.l #77,d0
     TRAP #15

DrawingTitle:
    lea $01000000,sp
    lea startMap,a0
    INCLUDE 'BitmapDrawer.X68'
    move.l #94,d0 ;Loads the start screen ONLY after fully loaded
    TRAP #15
    
WaitToBegin: ;Imposes a wait on the start screen until the user presses the spacebar
    move.l #5,d0
    TRAP #15
    
    cmp.b #32,d1 ;Checks that user input (if received) was in fact the spacebar
    bne WaitToBegin

ResetStack: ;Sets stack to draw new bitmap background for the scene, which should stay consistent for gameplay with moving entities.
     move.b #0,d1 ;Play pancake hit sound effect to let player know game is about to start
     move.l #72,d0
     TRAP #15 
     
    lea bitmap,a0 ;Sets proper bitmap image
    
    ;Initializes stack values to match specifications of bitmap size and start/end points
    lea $00FFFFFC,sp
    move.l #0,(sp)
    move.l #150,-(sp)
    move.l #700,-(sp)
    move.l #550,-(sp)
    move.l #0,-(sp)
    move.l #150,-(sp)
    
    lea $00FFFFE4,sp
    move.l #700,-(sp)
    move.l #700,-(sp)

    jsr CreatePixelArrayValues ;Jumps to portion to reset data register values and reprint array
    
    lea $00FFFFDC,sp
    
    INCLUDE 'D:\FIEA Class Notes\Programming Fundamentals\Assignment3\SevenSegmentLEDFunctionTable.X68'
        jsr ScoreInitializer ;Includes and calls seven segment LED counter with proper starting point in stack
    
    move.l #$00FFFFBC,sp ;Reset stack pointer

    move.l #350,-(sp) ;Saves x coordinate for frying pan to stack
    
    lea $00FFFFDC,sp ;Goes on to draw the player frying pan
    jsr DrawRectanglePlayer
    
InitializeCake: ;Initializes pancake and calls function to draw it onscreen 
    lea $00FFFFA8,sp
    move.l #0,(sp)
    move.l #0,-(sp)
    
    move.l #49,-(sp) ;Saves 25 to y acceleration so this can be converted to -.25 pixels per .04 seconds, simulates gravity acting at about -9.8 / -10 pixels per 1.6 seconds
    
    move.l #350,-(sp) ;Set x position to 350

    move.l #150,-(sp) ;Set y position to 150
    
    move.l #0,-(sp) ;Initializes several pancake variables to 0
    move.l #0,-(sp)
    move.l #0,-(sp)
    move.l #0,-(sp)
    move.l #0,-(sp)
    
    lea $00FFFF9C,sp ;Puts proper value in d5 (x position of pancake) for draw rectangle trap command to be called
    move.l (sp),d5
    lea $00FFFF14,sp
    jsr DrawRectanglePancake








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
