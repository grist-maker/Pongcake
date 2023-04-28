*-----------------------------------------------------------
* Title      : Pongcake - 32-Bit Bitmap Printer
* Written by : Gabrielle Tristani
* Date       : 10/17/2022
* Description: This project reads in a 32 bit  non-paletted bitmap, and prints it onscreen according to given constraints.
* Bitmaps store the data making up an image, including a data header, other components, and a pixel array that defines
* the color of each pixel. Pixel data is stored in little-endian byte storage format, while EASy68K stores bytes in big-endian.
* This program provides a conversion that the bitmap can be displayed properly using pixel output in the EASy68K system.
* The program goes through the header to get relevant data to print each pixel onscreen, then grabs the pixel array address.
* In the beginning, it retrieves input that is loaded into the stack, with other variables stored in data registers for ease of access.
* The arguments specify coordinates that should be considered the top left point of the printed chunk, width of the chunk, its height,
* and coordinates that will be considered the top left point on the output window. The original program has been modified to suit the
* purposes of the game Pongcake without having unnecessary overhead.

* A0 holds the bitmap address, A1 holds necessary input for trap commands
*d1 and d0 are used in trap commands
*d2 holds current y on output window, d3 holds current x on output window, d4 holds current row number / y value
*d5 holds current column number / x value, d6 holds ending x value, d7 holds beginning y value to initialize the bitmap
*-----------------------------------------------------------
SetWindow:
        ;Change output window to match desired dimensions
        lea $00FFFFA0,sp ;Checks if y acceleration was initialized, otherwise, going to start without adjusting window dimensions
        cmp.l #49,(sp)
        beq DrawTitle
    
        move.l #0,d1
        move.l #0,d0
        
        move.l #700, d1
        lsl.l #8, d1
        lsl.l #8, d1 
        add.l #700, d1
        move.l #33, d0
        trap #15
        
        cmp.l #49,(sp)
        bne DrawTitle

CreatePixelArrayValues:  
        move.l a0, d0 ;Creates placeholder for pixel array address in d0
        add.w #0, (a0)+ ;skips through header to parse information
        add.l #0, (a0)+
        add.l #0, (a0)+
        add.b (a0),d0   ;saves pointer to pixel data to d0
        
        move.l d0,a0
        
        move.l #699,d2 ;Starting y value
        move.l #0,d3
        move.l #699,d4
        move.l #1,d5
        move.l #700,d6
        move.l #699,d7
        
        lea $00FFFF24,sp
        jsr XYChecks
        
        lea $00FFFFD8,sp
        rts   
           
InitialY:
    lea $00FFFFE0,sp
    
    move.l (sp),d0 ;Loads number of pixels per row into d0, multiplies by 4 to get bytes per row
    mulu.w #4,d0
    
    move.l d4,d1 ;Moves d4 to d1 to have d1 carry difference between initial y value and current y value, how many rows must be traversed
    sub.l d7,d1
    
    mulu.w d1,d0 ;Multiplies number of rows by bytes per row
    
    add.l d0,a0 ;Increments a0 to get to right position
    
    move.l d7,d4 ;Initializes d4 properly
    
    cmp.l d4,d7
    
    lea $00FFFFD4,sp
    
XYChecks:
    cmp.l d4,d7 ;Checks if starting y has been reached yet, branching to InitialY to initialize if not
    blt InitialY
    
    move.l #$00FFFFFC,sp
    
    cmp.l (sp),d5 ;Checks if current x value is at least one greater than leftmost x value, otherwise branching to ChangeXPlus
    blt ChangeXPlus
    
    cmp.l d5,d6 ;Check to make sure current x value does not exceed rightmost x value, else branching to ChangeXMinus
    blt ChangeXMinus
    
DrawPixel:
    lea $00FFFF20,sp
    
    ;Grabs and operates on pixel color value
    move.l (a0),d1
    move.b #00, d1 ;Zeroes out the junk data to be in correct format
    
    rol.w #8, d1
    rol.l #8, d1
    swap.w d1
    rol.l #8, d1
    rol.w #8, d1
    ror.l #8, d1 ;leaves us with 00BBGGRR, meaning pen color is set for pixel color
    
    move.b #80, d0
    TRAP #15 ;Sets pen color
    
    move.w d3, d1 ;Sets coordinate in x for pixel, with y pixel coordinate already in d2
    move.b #82, d0 ;Draws pixel
    TRAP #15
    
    add.l #1, d3 ;Increments the x counter for output window
    add.l #1, d5 ;Increments x counter for bitmap traversal
    
    add.l #0, (A0)+ ;Increments a0 to get to next value
   
    cmp d5,d6 ;If curent x is greater than maximum x, we can check to see if the same is true for y and every pixel is printed.
    bge XYChecks
    
    ;To check y, we want to see if its less than the top left corner y
    move.l #$00FFFFF8,sp
    move.l (sp),d0
    lea $00FFFF20,sp
    
    cmp d4,d0 ;Compares current y to highest row, if not equal, repeats XYChecks. Otherwise returns
    blt XYChecks
    rts
    
ChangeXPlus:
    move.l (sp),d0 ;puts the leftmost x value into d0
    sub.l d5,d0 ;Subtracts current x value from the leftmost x value to get difference between the two, how many spaces a0 needs to increment
    
    add.l #1,d0
    move.l (sp),d5 ;set d5 to proper leftmost value
    
    add.l #1,d5
    mulu.w #4,d0 ;Multiplies by bytes per pixel
    
    add.l d0, A0 ;Increments the address value to right location
    
    lea $00FFFF20,sp
    
    cmp.l #0,d5
    bge XYChecks
    
ChangeXMinus:
   ;Since current x has surpassed the rightmost x value, address should be incremented by the total bitmap width - chunk width 
    
    move.l #$00FFFFE0,sp
    
    move.l (sp),d0 ;Saves bitmap width to d0
    
    move.l #$00FFFFF4,sp
    sub.l (sp),d0 ;Subtracts chunk width from d0
    
    sub.l #1, d4 ;Decrements y values as well to change to new row logically and in chunk
    sub.l #1,d2

    move.l #$00FFFFEC,sp
    
    move.l (sp),d3 ;Resets current x values to be leftmost values

    move.l #$00FFFFFC,sp
    
    move.l (sp),d5 ;Sets to leftmost x value on output window logically
    add.l #1,d5
    
    lea $00FFFF20,sp
    mulu.w #4,d0
    
    add.l d0,a0 ;Increments a0 to proper address index
    
    cmp.l d5,d6
    bge XYChecks
    
    rts
    
DrawTitle:
        lea $01000000,sp
        move.l a0, d0 ;Creates placeholder for pixel array address in d0
        add.w #0, (a0)+ ;skips through header to parse information
        add.l #0, (a0)+
        add.l #0, (a0)+
        add.b (a0),d0   ;saves pointer to pixel data to d0
        
        move.l d0,a0
        
        ;Now, we can load in the bitmap and establish relevant stack variables
        move.l #0, -(sp) ;Add top left x value. (00FFFFFC)
        move.l #0,-(sp) ;Add top left y value. (00FFFFF8)
        move.l #700, -(sp) ;Add width of chunk.(00FFFFF4)        
        move.l #700, -(sp) ;Add height of chunk. (00FFFFF0)
        move.l #0, -(sp) ;Add top left x value on output screen. (00FFFFEC)
        move.l #0, -(sp) ;Add top left y value on output screen.(00FFFFE8)
        
        move.l #0, -(sp) ;Add dummy stack variable as buffer space (00FFFFE4)
        move.l #700,-(sp) ;Create new index in stack to store total width of bitmap. (00FFFFE0)
        move.l #700,-(sp) ;Create new index in stack to store total height of bitmap. (00FFFFDC)
        
        move.l a0, d0 ;Creates placeholder for pixel array address in d0
        add.w #0, (a0)+ ;skips through header to parse information
        add.l #0, (a0)+
        add.l #0, (a0)+
        add.b (a0),d0   ;saves pointer to pixel data to d0
        
        move.l d0,a0
        
        move.l #699,d2 ;Initializes starting data register values to properly fit title
        move.l #0,d3
        move.l #699,d4
        move.l #1,d5
        move.l #700,d6
        move.l #699,d7
        
        lea $00FFFF24,sp
        
        jsr XYChecks     ;Checks that x and y are at proper positions before printing pixels, repeating until no pixels are left, then exiting
    
Exit: ;Releases program from execution




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
