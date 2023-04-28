*-----------------------------------------------------------
* Title      : Draw Functions - Pongcake
* Written by : Gabrielle Tristani
* Date       : 10/17/2022
* Description: A collection of functions that draw onscreen entities, as well as cover their past positions, in the game Pongcake.
* This is done for both the player and the onscreen pancake and repeated throughout the program's execution.
*-----------------------------------------------------------

DrawRectanglePancake: ;Function that draws pancake as a rectangle in new position on the screen
    move.l #FillColor, d0
    move.l #PancakeColor,d1
    TRAP #15
    
    move.l #PenColor, d0
    move.l #PancakeOutline,d1
    TRAP #15 
        
    move.l #DrawRec,d0
    move.l d5,d1
    add.l #PancakeWidth,d1
    
    move.l d5,d3
    sub.l #PancakeWidth,d3
    
    move.l d2,d4
    add.l #PancakeHeight,d4
    
    TRAP #15
    
    lea $00FFFF10,sp
    rts
    
DrawRectanglePlayer: ;Function that draws player as a rectangle in new position on the screen
    lea $00FFFFB8,sp
    
    move.l #PenColor,d0
    move.l #OutlineColor,d1
    TRAP #15

    move.l #FillColor,d0
    move.l #PlayerColor,d1
    TRAP #15
    
    move.l #DrawRec,d0
    move.l (sp),d1
    add.l #PlayerWidth,d1
    
    move.l #PlayerY,d2
    
    move.l (sp),d3
    sub.l #PlayerWidth,d3
    
    move.l #PlayerY,d4
    add.l #PlayerHeight,d4
    TRAP #15
    
    lea $00FFFFD8,sp
    rts
    
SetPlayerBitmap: ;Sets variables to define the bitmap portion to cover the player's previous position
    move.l #$01000000,sp ;Goes back to relevant player data section of the stack
    
    move.l d0,-(sp) ;Moves leftmost value occupied by player into top left x value for bitmap
    move.l #PlayerY,-(sp) ;Moves topmost y value of player to top left y value for bitmap
    
    move.l #PlayerWidth,-(sp)
    add.l #PlayerWidth,(sp)  ;Sets width of chunk to draw to 2 * player's width 
    add.l #1,(sp)
    move.l #PlayerHeight,-(sp) ;Sets height of chunk to player's height
    
    move.l d0,-(sp) ;Sets top left x value on output screen to top left x for bitmap
    move.l #PlayerY,-(sp) ;Sets top left y value on output screen to top left y for bitmap
    
    move.l #PlayerHeight,d2 ;Starting y value
    add.l #PlayerY,d2
    
    move.l d0,d3
    
    move.l #699,d4
    move.l #1,d5
    
    move.l d0,d6
    add.l #PlayerWidth,d6
    add.l #PlayerWidth,d6
    add.l #1,d6
    
    move.l #PlayerHeight,d7
    add.l #PlayerY,d7
    
    lea $00FFFFDC,sp
    jsr LoadCover
    
    lea $00FFFFE4,sp
    rts

SetCakeBitmap: ;Sets variables to define the bitmap portion to cover the pancake's previous position
    lea $00FFFF9C,sp
    move.l sp,A3
    move.l (sp),d0

    sub.l #PancakeWidth,d0 ;save leftmost value of pancake 1 to d0
    
    move.l -(sp),d1 ;Save bottom height of pancake 1 to d0
    
    move.l #$01000000,sp ;Goes back to relevant player data section of the stack
    
    move.l d0,-(sp) ;Moves leftmost value occupied by player into top left x value for bitmap
    move.l d1,-(sp) ;Moves topmost y value of player to top left y value for bitmap
    
    move.l #PancakeWidth,-(sp)
    add.l #PancakeWidth,(sp)  ;Sets width of chunk to draw to 2 * pancake's width 
    add.l #1,(sp)
    move.l #PancakeHeight,-(sp) ;Sets height of chunk to pancake's height
    
    move.l d0,-(sp) ;Sets top left x value on output screen to top left x for bitmap
    move.l d1,-(sp) ;Sets top left y value on output screen to top left y for bitmap
    
    move.l #PancakeHeight,d7
    
    add.l d2,d7
    
    add.l #PancakeHeight,d2 ;Starting y value
    
    move.l d0,d3
    
    move.l #699,d4
    move.l #1,d5
    
    move.l d0,d6
    add.l #PancakeWidth,d6
    add.l #PancakeWidth,d6
    add.l #1,d6

LoadCover: ;Loads the bitmap portion to cover previous position of entity based on previously entered values in SetCakeBitmap or SetPlayerBitmap
    move.l #$00FFFF24,sp
    lea bitmap,a0    ;load the address of the bitmap into a0
    
    move.w a0, d0 ;Creates placeholder for pixel array address in d0
    add.w #0, (a0)+ ;skips through header to parse information
    add.l #0, (a0)+
    add.l #0, (a0)+
    add.b (a0),d0   ;saves pointer to pixel data to d0
        
    move.l d0,a0

    jsr XYChecks
    lea $00FFFFD8,sp
    rts



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
