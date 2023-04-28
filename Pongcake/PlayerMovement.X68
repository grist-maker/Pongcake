*-----------------------------------------------------------
* Title      : Pongcake - Player Movement
* Written by : Gabrielle Tristani
* Date       : 10/17/2022
* Description: A collection of functions that allows the player's frying pan to move left or right based on user input.
*-----------------------------------------------------------
MoveRight: ;Moves the player right as long as that is a valid place to be
    lea $00FFFFB8,sp
    ;Get the rightmost x value of the current position into d0
    move.l (sp),d0
    add.l #PlayerWidth,d0
    
    move.l #700, d2
    sub.l #PlayerWidth, d2
    
    cmp.l d2,d0 ;Makes sure that it is sufficiently far from the right wall
    bge BackToGame
    
    sub.l #PlayerWidth,d0
    sub.l #PlayerWidth,d0
    add.l #PlayerWidth,(sp)
    
    lea $00FFFFDC,sp
    jsr DrawPlayer
    
MoveLeft: ;Moves the player left as long as that is a valid place to be
    lea $00FFFFB8,sp
    ;Get the leftmost x value of the current position into d0
    move.l (sp),d0
    sub.l #PlayerWidth,d0
    
    cmp.l #PlayerWidth,d0 ;Makes sure that it is sufficiently far from the left wall
    ble BackToGame
    
    sub.l #PlayerWidth,(sp)
    
    lea $00FFFFDC,sp
    jsr DrawPlayer


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
