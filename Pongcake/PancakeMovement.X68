*-----------------------------------------------------------
* Title      : Pancake Movement - Pongcake
* Written by : Gabrielle Tristani
* Date       : 10/17/2022
* Description: Contains a selection of functions used to govern pancake movement left, right, up, and down based on state.
*-----------------------------------------------------------
MovingRight:   
    move.l #2,(sp) ;Sets pancake to moving right

MovingLeft:
    cmp.l #0,(sp)
    bne UpOrDown
    move.l #1,(sp) ;Sets pancake to move left, as long as it is not already moving right, then dropping into MoveCake
    
UpOrDown:  
    lea $00FFFF88,sp ;Grabs value indicating whether pancake is going up or down, branching to GoUp if it is moving up, or dropping to GoDown otherwise   
    cmp.l #0,(sp)
    bne GoUp
    
GoDown: ;Has the pancake continue falling downward
    lea $00FFFF74,sp
    jsr VerticalData
    lea $00FFFF84,sp
    
    cmp.l #1,(sp)
    beq LeftDown
    cmp.l #0,(sp)
    beq LeftDown

SwitchToRightDown:
    lea $00FFFF84,sp ;Sets pancake to head right and down
    move.l #2,(sp)

RightDown:
    lea $00FFFF74,sp
    jsr MoveDown
    
    lea $00FFFF9C,sp
    add.l (sp),d3
    cmp.l #700,d3 ;But before moving right, we need to ensure that new x < 700 (right wall), and switch to moving left otherwise.
    bge SwitchToLeftDown ;We need to go left instead.
    
    add.l d1,(sp) ;Adds x velocity to x position value to get new location
    lea $00FFFFC0,sp ;Jumps to subroutine that will actually draw pancake onscreen
    jsr DrawTheCake

SwitchToLeftDown:
    lea $00FFFF84,sp ;Switches pancake to moving left and downwards if pancake is no longer moving right or up
    move.l #1,(sp)
    
LeftDown:  
    lea $00FFFF74,sp
    jsr MoveDown
    
    lea $00FFFF9C,sp
    cmp.l (sp),d3 ;But before moving left, we need to ensure that d3 < the current x to ensure it doesnt hit wall.
    bge SwitchToRightDown ;We need to go right instead otherwise.
    
    sub.l d1,(sp) ;Gets new x value if it is value and stores in stack

    lea $00FFFFC0,sp ;Goes to actually draw pancake entity
    jsr DrawTheCake
    
GoUp:
    lea $00FFFF88,sp
    sub.l #1,(sp) ;Decrements number of spaces we will continue moving upwards by one since we're moving up again here
    
    lea $00FFFF74,sp
    jsr VerticalData
    
    lea $00FFFF84,sp
    cmp.l #1,(sp) ;Checks if we're moving left, otherwise dropping into function SwitchToRightUp
    beq LeftUp

SwitchToRightUp:
    lea $00FFFF84,sp ;Sets pancake to moving in the right direction
    move.l #2,(sp)
    
RightUp:
    lea $00FFFF74,sp
    jsr MoveUp
    
    lea $00FFFF9C,sp
    add.l (sp),d3
     
    cmp.l #700,d3 ;But before moving right, we need to ensure that d3 < 700 to ensure it doesnt hit wall.
    bge SwitchToLeftUp ;We need to go left instead otherwise.
    
    add.l d1,(sp) ;If valid, adds displacement to current x position value  
    lea $00FFFFC0,sp
    jsr DrawTheCake
    
SwitchToLeftUp:
    lea $00FFFF84,sp
    move.l #1,(sp)
    
LeftUp:
    lea $00FFFF74,sp
    jsr MoveUp
    
    lea $00FFFF9C,sp
     
    cmp.l (sp),d3 ;But before moving left, we need to ensure that d1 < the current x to ensure it doesnt hit wall.
    bgt SwitchToRightUp ;We need to go right instead.
    
    sub.l d1,(sp)
    
    lea $00FFFFC0,sp ;Goes to function to actually draw pancake onscreen
    jsr DrawTheCake
    
MoveUp:
    lea $00FFFF7C,sp ;Repeats shared segments for pancake movement
    jsr SharedMovement
    lea $00FFFF98,sp
    
    sub.l d0,(sp) ;Gets new y value by subtracting acceleration
      
    lea $00FFFF7C,sp
    jsr SharedEnding
    
MoveDown:
    lea $00FFFF7C,sp ;Repeats shared segments for pancake movement
    jsr SharedMovement
    lea $00FFFF98,sp
    
    add.l d0,(sp) ;Changes y position by adding our calculated acceleration   
    
    lea $00FFFF7C,sp
    jsr SharedEnding
    
SharedMovement:
    ;Grabs y velocity and adds y acceleration
    lea $00FFFFA4,sp
    add.l d0,(sp)
    move.l (sp),d0
    
    lsr.l #6,d0 ;Shifts to get rid of decimal remainder, we now have the number of spaces traversed vertically
    lea $00FFFF78,sp
    rts
    
SharedEnding:
    lea $00FFFF98,sp
    move.l (sp),d2 ;Moves y position into d2 for drawing rectangle
    
    lsr.l #4,d1 ;Shifts x velocity right by 4 bits since we are dealing with decimal values
    add.l #0,(sp)+ ;Grabs x position
    
    move.l #PancakeWidth,d3 ;Moves width of cake plus x veloctiy plus current x into d3 to get rightmost value of new cake
    add.l d1,d3
    
    lea $00FFFF70,sp
    rts
    
VerticalData:
    lea $00FFFFA0,sp
    move.l (sp),d0 ;Saves acceleration to d0
    
    lea $00FFFFA8,sp
    move.l (sp),d1 ;moves x velocity into d1
    
    lea $00FFFF70,sp
    rts



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
