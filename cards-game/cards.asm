Name  Muhammad Ibrahim i13-1821




.model small
;===============================CARD STRUCTURE ==================
card struct
	char db ?
card ends

.data
;===============================DATA  VARIABLES =================
	tempx word ?    ; to have temporary value
	tempy word ?
	dtx word ?
	dty word ?
	char1 dw 0
	char2 dw 0
	msg db 10,13,"valid try = +2",10,13,"Invalid try = -1",10,13,"Scores: $"
	msg2 db "Prss Enter to paly again",10,13,"else press any other key$"
	sc word 05d
	pos word ?
	check word 0
	cards card 10 dup(<>)

	stpx dw 40,150,260,370,480,40,150,260,370,480
	stpy dw 40,40,40,40,40,190,190,190,190,190
	speaker  =  61h	; address of speaker port
	timer    =  42h	; address of timer port
	delay1   = 500
	delay2   = 12h	; delay between notes
	startPitch = 30
	bufer db 10 dup(0)
	col db 10 dup(0)
	row db 10 dup(0)
	tim db 4 dup(?)
	i db 0
	a db 0
	msec db ?
	sec db ?
	min db ?
	hr db ?

;==================================================================
.stack
.code
;=================================CODE STARTS HERE=================
dod proc
	mov cx,0
	mov dx,0
	mov bx,10d

  	loop1:
    	mov dx,0	;ax: Quotient

    	div bx	        
	
    	push dx		
    	inc cx
    	cmp ax,0	

    	jnz loop1	

  	loop2:
    	mov ah,02
    	pop dx
	
	
    	add dl,48
    	int 21h

    	dec cx

    	cmp cx,0	;if cx!=0 then
    	jnz loop2	;Loop will be repeated
	ret
dod endp
;=================================procedure set video mode=========
setvideo proc
		mov ah,0
		mov al,12h
		int 10h
ret
setvideo endp
;==================================================================
background proc    ; For background color
	mov ah,06h
	mov al,0d
	mov ch,0d
	mov cl,0d
	mov dh,30d
	mov dl,85d
	mov bh,14h
	int 10h

	mov ax,0d
	mov dx,0d
	mov bx,0d
	mov cx,0d

ret
background endp
;==================================procedure to draw a single card
drawcard proc
	mov dtx,cx
	mov dty,dx
	mov tempx,cx
	mov tempy,dx
	add dtx,100d
	add dty,130d

q:
mov cx,tempx
	p:
		
		mov ah,0ch
		int 10h
		inc cx
		cmp cx,dtx
		jne p
inc dx
cmp dx,dty
jne q

	mov cx,dtx
	mov dx,tempy

ret
drawcard endp
;==================================================================
setrc proc

mov si,0d

mov i ,05d

p:
mov a,0d
		q:
		mov al,a
		mov col[si],al
		add col[si],10d
		mov al,i
		mov row[si],al
		
		inc si
		add a,15d
		cmp a,75d
		jb q

		add i,10d
cmp i,16d
jb p


ret
setrc endp
;=================================procedure to draw all cards=======

setcards proc


	mov dx ,30d
	mov si,0d

lup:
	add dx,10d
	mov cx,30d
		lup1:
			add cx,10d
			mov al,12h
			call drawcard
			
			inc si
			
		cmp cx,540d
		jb lup1
		
		

		add dx,140d
		cmp	dx,190d
jb lup	

call setrc
call score
ret
setcards endp		
;===============================================================
sound proc
	in   al,speaker	; get speaker status
	push ax             	; save status
	or   al,00000011b   	; set lowest 2 bits
	out  speaker,al     	; turn speaker on
	mov  al,startPitch          ; starting pitch
L2:
	out  timer,al       	; timer port: pulses speaker

   ; Create a delay loop between pitches:
	mov  cx,delay1
L3:	push cx	; outer loop
	mov  cx,delay2
L3a:	; inner loop
	loop L3a
	pop  cx
	loop L3

	sub  al,1           	; raise pitch
	jnz  L2             	; play another note

	pop  ax              	; get original status
	and  al,11111100b    	; clear lowest 2 bits
	out  speaker,al	; turn
	
ret
sound endp
;===============================procedure that generates random number
genrandom proc

	mov a,0
	mov ah,2ch
	int 21h
	mov ah,0
	mov al,dl
	mov bl,10d
	div bl
	mov al,ah
	mov ah,0
	mov di,ax
	mov al,a
	mov bufer[di],al
	inc a
	inc di
lop:
	mov ax,di
	mov bl,10d
	div bl
	mov al,ah
	mov ah,0
	mov di,ax
	mov al,a
	mov bufer[di],al
	inc a
	inc di
cmp a,10d
jne lop



	mov ah,2ch
	int 21h

	mov tim[0],dl
	mov tim[1] ,dh
	mov tim[2] ,cl
	mov tim[3],ch

	mov a,04d
	mov cx,0d
g:
	mov ax,0
	mov si,cx
	mov al,tim[si]
	mov bl,05d
	div bl
	mov al,ah
	mov ah,0
	mov si,ax
	mov di,si
	add di,05d
	mov al,bufer [si]
	mov ah,bufer[di]
	mov bufer[si],ah
	mov bufer[di],al
	inc cx
	cmp cx,04d
jne g
	
	
ret
genrandom endp
;====================================================================
deny proc 

    in   al,speaker	; get speaker status
	push ax             	; save status
	or   al,00000011b   	; set lowest 2 bits
	out  speaker,al     	; turn speaker on
	mov  ax,10000d          ; starting pitch
	out  42h,ax       	; timer port: pulses speaker

	mov  cx,500d
L3:	push cx	; outer loop
	mov  cx,01cch
L3a:	; inner loop
	loop L3a
	pop  cx
	loop L3
	
	
	

	pop  ax              	; get original status
	and  al,11111100b    	; clear lowest 2 bits
	out  speaker,al	; turn speaker off
	

ret
deny endp
		
;===============================procedure to set generated random numbers
setrandom proc
	mov al,01d
	mov cx,10d
	mov si,0d
l:
	mov bx,0d
	mov bl,bufer[si]
	mov cards[bx].char,al
	inc si
	mov bx,0d
	mov bl,bufer[si]
	mov cards[bx].char,al
	inc si
	inc al
cmp si,10d
jne l


ret
setrandom endp
;===============================

;========================================goto procedure
;==========================================================
;================================
showmouse proc
	mov ax,0d
	int 33h

	mov ax,07
	mov cx,40d
	mov dx,580d
	int 33h


	mov ax,08
	mov cx,40d
	mov dx,320d
	int 33h

	mov ax,01h
	int 33h
ret 
showmouse endp
;====================================================================
print proc

	mov ah,09h
	mov al,cards[si].char	
	mov bh,0d
	mov bl,14d
	mov cx,01d
	int 10h

ret
print endp
;=========================procedure to recognise the card no=========
getxpos  proc


	mov check,0d
cmp tempy,170d
jbe up
jmp clow
up:

	mov check,01d
	mov pos,0d
jmp addd

clow:
cmp tempy ,190d
jae down
jmp no
down:
	mov check,01d
	mov pos ,01d
jmp addd

addd:
	mov ax,pos
	mov bl,05d
	mul bl 
	mov tempy,ax
jmp chkx
no:
	mov check,0d
jmp retback


chkx:
	mov si,0d
lc:
	mov check,0d
	mov ax,tempx
cmp ax,stpx[si]
jae rc
jmp retback

rc:
	mov bx,stpx[si]
	add bx,100d
cmp ax,bx
jbe retvalue
jmp lup

lup:
	inc si 
	inc si
jmp lc
retvalue:
	mov ax,si
	mov bl,02d
	div bl
	mov ah,00d
	add ax,tempy
	mov pos,ax
	mov check,01d


retback:
ret
getxpos endp
;=================================procedure to get mouse click information
updown proc
	mov check,0d
	mov si,pos
cmp char1,0d
je first
jmp second
first:
	mov ax,si
	mov i,al
	mov bx,0
	mov bl,cards[si].char	
	mov char1,bx
jmp return
second:
	mov ax,0
	mov al,i
	mov di,ax
cmp si,di
je return
jmp yes
yes:
	mov ax,si
	mov a,al
	mov bx,0
	mov bl,cards[si].char
	mov char2,bx
	mov ax,char1
cmp ax,char2
je rm
jmp nrm

nrm:
	dec sc
call deny
call score

	mov char1,0d
jmp return
rm:
	mov check,01d

return:
ret
updown endp
;==========================================
play proc
	mov sec,0d
	mov hr,0d
 
xyz:
	mov pos,02d
	mov ax,05d
	int 33h

cmp sc,0d
je return

cmp hr,05d
je return

cmp ax,01d

jne xyz
jmp x

x:

	mov tempx,cx
	mov tempy,dx
call getxpos
cmp check,01d
je show
jmp again
show:
	mov si,ax
	mov bx,si
	mov dh,row[bx]
	mov dl,col[bx]
	mov pos,bx
	mov ah,02h
	int 10h
call print
call sound
call updown

cmp check,01d
je remove
jmp nremove


remove:
	mov ax,0
	mov al,i
	mov bl,02d
	mul bl
	mov si,ax

	mov ax,0
	mov al,a
	mov bl,02d
	mul bl
	mov di,ax

	mov cx,stpx[si]
	mov dx,stpy[si] 
	mov al,04d
call drawcard


	mov cx,stpx[di]
	mov dx,stpy[di] 
	mov al,04d
call drawcard
	inc sc
	inc sc
	inc hr
call score

	mov char1,0d
	mov char2,0d

jmp again
nremove:

	mov ax,pos
	mov bl,02d
	mul bl
	mov si,ax
	mov cx,stpx[si]
cmp cx,0d
je again
jmp yes
yes:

	mov dx,stpy[si] 
	mov al,12h
call drawcard

again:

jmp xyz
return:
ret
play endp
;====================================================================
score proc

	mov ah,02h
	mov dh,23d
	int 10h

	mov dx,offset msg
	mov ah,09h
	int 21h

	mov ah,06h
	mov al,0 
	MOV Ch, 26
	mov cl,08d
	MOV DH, 27
	MOV DL, 10
	MOV BH, 04d
	INT 10h

	mov ax,0
	mov ax,sc
call dod

ret
score endp
;=======================================
clear proc
	mov al,03
	mov ah,0
	int 10h
	
	mov dx,offset msg2
	mov ah,09h
	int 21h
	mov ah,01h
	int 21h
	
	
ret
clear endp
;=================================MAIN PROCEDURE=====================
main proc

	mov ax,@data
	mov ds,ax

;=============================calling of procedures==================

start:

	call setvideo	
	call background	
	call setcards  	  
	call genrandom       
	call setrandom       
	call showmouse      
	call play 
	call clear   

		mov sc,05d
		cmp al,13d
	
	
	je start

        
;=============================end of game============================


mov ax,4c00h
int 21h

main endp
end main