*-----------------------------------------------------------
* Title      : Pongcake - Pancake Collision Checks
* Written by : Gabrielle Tristani
* Date       : 10/17/2022
* Description: Contains a variety of functions that check for and handle collisions between the player and the pancake.
*-----------------------------------------------------------
LargerD4:
    sub.l d3,d4
    cmp.l d2,d4
    bgt UpOrDown ;If difference is too far, keep moving normally
    
    move.l #18,d7 ;Sets d7 to 18 to show that we went through larger d4 and need to get to TouchingXs.

CheckCake:
    cmp.l #18,d7 ;Checks if we came from dropping from LargerD4, if so, going to TouchingXs.
    beq TouchingXs
    
    ;If it moves, will it hit the pan?
    move.l #PlayerWidth,d2
    add.l #PancakeWidth,d2 ;Get difference between the sizes to see if they touch and if we should check y values for collision
    
    ;Loads X position of pancake into stack and then d3
    move.l A3,sp
    move.l (sp),d3 
    
    move.l #$00FFFFB8,sp ;Grabs player's x position and moves to d4
    move.l (sp),d4
    
    ;Find if x velocity is positive or negative
    lea $00FFFF84,sp
    cmp.l #2,(sp)
    beq XVelocityRight
    
XVelocityLeft:
    lea $00FFFFA8,sp
    move.l (sp),d6
    lsr.l #4,d6
    sub.l d6,d3
    
    ;We want to subtract whichever is smaller (d3 or d4) from the larger one. So if we ran through VelocityLeft, we move sp to a5.
    move.l sp,a5

XVelocityRight:
    cmpa sp,a5 ;When we go into XVelocityRight, we immediately check if XVelocityLeft just ran. If so, we go into FindSmallerValue. Otherwise, we run the code below and drop into it after
    bne FindSmallerValue
    
    lea $00FFFFA8,sp
    move.l (sp),d6
    lsr.l #4,d6
    add.l d6,d3
    ;we need to add this velocity to get next point

FindSmallerValue:   
    move.l 0,a5 ;Wipes our check address a5
    ;We want to subtract whichever is smaller (d3 or d4) from the larger one.
    cmp.l d3,d4
    bgt LargerD4

SmallerD4:
    sub.l d4,d3
    cmp.l d2,d3
    bgt UpOrDown ;If difference is too far, keep moving normally
    
TouchingXs:
    move.l #0,d7 ;Zeroes our check d7 since we have just gotten to TouchingXs.
    
    move.l #PlayerHeight,d0 ;Gets sum of heights
    add.l #PancakeHeight,d0
    
    lea $00FFFFA0,sp
    move.l (sp),d1
    
    add.l #0,(sp)+ ;Grabs y velocity and adds downward acceleration to d1 as well
    add.l (sp),d1
    
    lsr.l #6,d1 ;Gets rid of remainder for spaces traveled

    lea $00FFFF98,sp
    add.l (sp),d1 ;Gets new anticipated y value
    add.l d0,d1
    
    cmp.l #PlayerY,d1
    blt UpOrDown ;If the player's static y value is now higher up than the anticipated pancake y, then we know it hits and continue. otherwise, we keep moving it up or down
    
    lea $00FFFF88,sp

    cmp.l #0,(sp)
    bne UpOrDown
    
PancakeHit:  ;Called when pancake and pan collide
    move.l #20,(sp) ;Have pancake go up for 20 frames
    
    lea $00FFFFDC,sp ;Adds 1 in the score counter
    jsr AddScore
    
    move.l #$00FFFF64,sp ;Sets random number for x velocity, storing the value in d6
    jsr SetRandomNumber
    
    lsr.l #8,d6 ;Shifts left to get proper velocity since a full register of random data is unreasonable for velocity
    lsr.l #8,d6
    lsr.l #8,d6
    
    lea $00FFFFA4,sp
    move.l #90,(sp)+ ;Sets y velocity to 100
    move.l d6,(sp) ;Sets x velocity randomly
      
     move.b #0,d1 ;Play pancake hit sound effect
     move.l #72,d0
     TRAP #15 
     
    lea $00FFFF84,sp
    
    move.l #0,(sp) ;Randomly selects whether movement is left or right based on value generated previously
    cmp.l #$7F,d6
    bgt MovingLeft
    
    cmp.l #$7F,d6
    ble MovingRight



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
