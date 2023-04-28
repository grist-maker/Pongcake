*-----------------------------------------------------------
* Title      : Pongcake - Assembly Game
* Written by : Gabrielle Tristani
* Date       : 10/17/2022
* Description: A basic game written entirely in Assembly, using Easy68K. It is called "Pongcake". The game uses a variety of other, larger files that it accesses via
* Include statements. These files are specialized for specific puroses and documented fully. The game opens with a start screen, waits for the user to press space to begin,
* and then spawns them into a scene where they can control a frying pan with the left and right arrow keys. The goal is to catch an always-moving pancake as it accelerates to the ground.
* The player can do this by pressing the left and right arrow keys to move in the target direction, but is stopped at either wall of the application. The player must try to go beneath the cake.
* When struck by the player, the pancake gains upward velocity and randomly generated x velocity, and then falls back down for the player to hit again. The pancake can bounce off of the left
* and right walls as well. Every time the cake is hit, the score counter provided by a seven-segment LED system is incremented by one, up to the final value 999. When the player loses, they
* are brought back to the title screen to try again. The game uses a bitmap background that redraws segments of itself when entities move across it to give the impression of a fully static
* background. The game also includes a sound effect when the player collides with the pancake, the game begins, and the game is lost, as well as constant background music.
*-----------------------------------------------------------
    ORG    $1000 
PenColor   equ     80 ;Initializes trap command variables for ease of use in program
FillColor  equ     81
DrawRec     equ     87

Left equ $25 ;Variables for player movement direction
Right equ $27

UserInput equ 19

PlayerWidth		equ	22 ;Variables for player size
PlayerHeight	equ	11

PancakeWidth equ 18 ;Variables for pancake size
PancakeHeight equ 5

PlayerY     	equ	550 ;Saves player y position

PlayerColor	equ	$005a5a5a ;Saves color data for players and pancake
OutlineColor equ $0033CED7
PancakeColor equ $005491CE
PancakeOutline equ $00C94072
    
bitmap:
    INCBIN "SimpleKitchenBackground.bmp" ;Loads in the bitmap file    
startMap:
    INCBIN "PancakeStart.bmp" ;Loads in start screen file

Lose:
     move.b #1,d1 ;Play dropped sound effect
     move.l #72,d0
     TRAP #15 
     
    lea $00FFFFA0,sp ;Checks if y acceleration was initialized, otherwise, going to start.
    cmp.l #49,(sp)
    bne Start
     
    lea $00FFFFD4, sp 
    move.l #1,(sp) ;Force program to reinitalize score for next round

Start: ;Here, we include a file which presents the title screen, waits for the user to start, and initializes entity values
    
    INCLUDE 'BeginningStates.X68'
    
PancakeFallingSound:
     move.b #2,d1 ;Play dropped sound effect
     move.l #72,d0
     TRAP #15 
    
Game:   
    move.l #$00FFFF98,d0 ;Update for the pancake
    lea $00FFFFB0,sp
    jsr UpdateCake
    
    lea $00FFFFB4,sp ;Update for the player
    jsr UpdatePlayer
    
    move.l #94,d0
    TRAP #15
    
    move.l #1,d1 ;1/100 second delay, or .01 seconds
    move.l #23,d0
    TRAP #15
    
    jmp Game

UpdatePlayer: ;Collects right and left arrow key player input, branching to target move functions if received
    move.l #Right,d1
    move.l #UserInput,d0
    TRAP #15
    andi.l #$FF,d1
    bne MoveRight
    
    move.l #Left,d1
    move.l #UserInput,d0
    TRAP #15
    andi.l #$FF,d1
    bne MoveLeft
    
    lea $00FFFFDC,sp ;Draws the player in their current position and then returns to game
    jsr DrawRectanglePlayer
    
    move.l #$00FFFFB0,sp   
    rts
    
UpdateCake:   
    move.l d0,sp ;Set proper address and move y position of current cake to d0
    move.l (sp),d0

    lea $00FFFF88,sp
    move.l (sp),d1 ;Grabs up or down value. if going up (greater than 0), we want to keep executing

    cmp.l #0,d1
    bne ContinueUpdateCake
        
    cmp.l #PlayerY,d0 ;Check to ensure it hasn't fallen offscreen
    bgt Lose
    
    cmp.l #0,d0 ;Ensure pancake is valid and in scene
    beq Lose

ContinueUpdateCake: ;Updates the pancake's position and the bitmap beneath it
    lea $00FFFF14,sp
    jsr CoverCake
    
    lea $00FFFF10,sp
    jsr CheckCake
    
CoverCake: ;Periodically reprints the bitmap image over the space the pancake used to occupy
    lea $00FFFFDC,sp
    jsr SetCakeBitmap
    lea $00FFFF10,sp
    rts
    
DrawTheCake: ;Draws the pancake in its new location as a rectangle
    lea $00FFFF9C,sp
    move.l (sp),d5
    
    lea $00FFFF14,sp
    jsr DrawRectanglePancake
    
    lea $00FFFFAC,sp ;Return back to calling function
    rts

DrawPlayer:     ;Draws the player in their new position based on previously collected player input
    lea $00FFFFE8,sp
    jsr SetPlayerBitmap
    
    lea $00FFFFDC,sp
    jsr DrawRectanglePlayer
    
    move.l #$00FFFFB0,sp
    rts
    
BackToGame:  
    move.l #$00FFFFB0,sp
    rts
    
    INCLUDE 'DrawFunctions.X68' ;Functions that draw pancake and player on the screen
    INCLUDE 'RandomFunctions.X68' ;Functions that generate random data
    INCLUDE 'PancakeMovement.X68' ;Functions that control pancake movement
    INCLUDE 'PancakeCollisionChecks.X68' ;Functions that control pancake collisions
    INCLUDE 'PlayerMovement.X68' ;Functions that control player movement
    
    
pancakeDropped dc.b 'PancakeDropped.wav',0 ;Loads in loss sound effect
backgroundMusic dc.b 'BackgroundMusic.wav',0 ;Loads in background music
pancakeFlip dc.b 'PancakeFlip.wav',0 ;Loads in pancake hit sound effect
pancakeFall dc.b 'PancakeFall.wav',0 ;Load in pancake falling sound effect

    END    START        ; last line of source
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
