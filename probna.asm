TITLE	************* Proektna zadaca po MPE *************

COMMENT *----------------------------------------------------
				Angry birds for poor
		-----------------------------------------------------*
.386
.model small, c

;----------------------------------------------------------------
; Stek segment

stack_seg SEGMENT stack

	DB 100 DUP(?)

stack_seg ENDS
;----------------------------------------------------------------
; Podatocen segment

data_seg SEGMENT USE16 'DATA'
	
	koordinata_x DW 032h, 050h, 078h, 08Ch, 0A0h, 0C8h, 0F0h, 0FAh				;, 0FCh, 0Ah	;78h problem, 
	koordinata_y DW 0BEh, 096h, 06Eh, 05Ah, 04Bh, 064h, 096h, 064h				;, 96h, 0BEh		;5Ah problem, kako za 64h mn visoko bega
	
	topce_x dw 32h
	topce_y dw 0BEh
	
	meta_x DW 0FFF8h
	meta_y DW 096h
	golemina_meta DW 05h
	
	topce_brz_x dw 06h
	topce_brz_y dw 04h
	golemina_topce dw 05h
	
	prozor_sirina dw 140h													;320pix
	prozor_visina dw 0C8h													;200pix
	prozor_granica dw 6														;za da proverva ko kje udri topcheto vo granicata od prozorot da vrakja nazad
	
	msg1 db	'P'
	msg2 db 'O'
	msg3 db 'G'
	msg4 db 'O'
	msg5 db 'D'
	msg6 db 'I'

data_seg ends

code_seg SEGMENT USE16 'CODE'

ASSUME cs:code_seg, ds:data_seg, ss:stack_seg
	
start:
	mov ax, data_seg
	mov ds, ax
main PROC

;===============================
	call ISCISTI_EKRAN
;===============================	
	call CRTAJ_OSNOVA
	call CRTAJ_META
	call delay
	call MRDAJ

ret
main endp

CRTAJ_OSNOVA proc
	mov cx, topce_x
	mov dx, topce_y
	CRTAJ_HORIZ_TOPCE:
		mov ah, 0Ch			;Crttanje piksel
		mov al, 0Fh			; bela boja na pikselo
		mov bh, 00h			;broj na stranata = 0
		int 10h
		
		inc cx
		mov ax, cx					
		sub ax, topce_x			;cx-meta_x>golemina_topche::::::DA-> odime naredna redica:::::::NE->prodolzuvame naredna kolona
		cmp ax, golemina_topce
		jng CRTAJ_HORIZ_TOPCE
		mov cx, topce_x			;CX odi vo inicijalnata kolona
		inc dx				;Odime eden red ponatamu
		mov ax,dx					
		sub ax,topce_y			;DX-meta_y>golemina_meta:::::::DA-> izleguvame od procedurata::::::::::::::::NE-> prodolzuvame vo nareden red
		cmp ax,golemina_topce
		jng CRTAJ_HORIZ_TOPCE
			
ret
CRTAJ_OSNOVA endp

MRDAJ proc
;==============================================================
;proveri dali nekoe dugme voopsto e pricnato? ako ne e izlezi od procedurata?
	mov ah, 01h
	int 16h
	jz MRDAJ_KRAJ
;proveri koe dugme e pricnato AL=ASCII od dugmeto 
	mov ah, 0h
	int 16h
;Proveri za desno 'D'
	cmp al, 44h
	je MRDAJ_DESNO
	
	cmp al, 64h
	je MRDAJ_DESNO
;Proveri za pukanje 'R'	
	cmp al, 52h
	je PUKAJ_3
	
	cmp al, 72h
	je PUKAJ
	
	jmp MRDAJ_KRAJ
;=======================================================================
		MRDAJ_DESNO:
		mov ax, topce_brz_x		
		mov bx, topce_x
		add bx,ax
		mov topce_x, bx
		
		cmp topce_x, 086h
		je PUKAJ_2
		
		mov ax, prozor_sirina
		sub ax, prozor_granica
		cmp topce_x, ax
		jg reset_pozicija
;======================================================================	
	reset_pozicija:
		call ISCISTI_EKRAN
		RET
;======================================================================		
		PUKAJ:
			call CRTAJ_TRAEKTORIJA
			ret
			
		PUKAJ_2:
			call CRTAJ_TRAEKTORIJA2
			ret
			
			call ISCISTI_EKRAN
			ret
		PUKAJ_3:
			call CRTAJ_TRAEKTORIJA3
			ret		
;=============================================================
MRDAJ_KRAJ:
ret
MRDAJ endp
;============================================================
delay proc
	mov ah, 2Ch
	int 21h
	mov al, dl ;stotinki 
wait_loop:
        ;nop        
        int 21h
        sub dl,al  ; (-99..+99) presmetaj razlika vo stotinkite
        jnc delta_positive
	add dl,10 ; 1-99 nashtimaj ja razlikata da bide pozitivna
delta_positive:
        cmp dl,50	;dali pominale 50ms?
        jb wait_loop
ret
delay endp
;=============================================================
ISCISTI_EKRAN proc
	mov ah,00h
	mov al,13h
	int 10h
	mov ah, 0bh
	mov bh, 00h
	mov bl, 00h
	int 10h
	ret
ISCISTI_EKRAN endp
;=================================================
CRTAJ_TRAEKTORIJA proc 
	mov si, 0d
	mov di, 0d
	
VCITAJ:
	lea si, koordinata_x
	lea di, koordinata_y	
CRTAJ:	
	mov cl, [si]
	mov dl, [di]
	;mov ch,0h
	;mov dl,0h
	add ch, 0h
	add cl, 0Ah
	
	add si, 2d
	add di, 2d

	mov ah, 0Ch			;Crttanje piksel
	mov al, 0Fh			; bela boja na pikselo
	mov bh, 00h			;broj na stranata = 0
	int 10h 
	
;==============================================================
	call delay
	call ISCISTI_EKRAN	; da go brisi ekrano posle sekoj nacrtan piksel
	call CRTAJ_META
;==============================================================	
	cmp si, 0Eh
	jne CRTAJ
	
	cmp [si], 0FFF8h
	jge KRAJ

KRAJ:
	call POGODOK

ret
CRTAJ_TRAEKTORIJA endp
;======================================================================
CRTAJ_TRAEKTORIJA2 proc

	mov si, 0d
	mov di, 0d
	
VCITAJ:
	lea si, koordinata_x
	lea di, koordinata_y	
CRTAJ:	
	mov cl, [si]
	mov dl, [di]
	
	add cl, 14h
	
	add si, 2d
	add di, 2d
	
	mov ah, 0Ch			;Crttanje piksel
	mov al, 0Fh			; bela boja na pikselo
	mov bh, 00h			;broj na stranata = 0
	int 10h 
	
;==============================================================
	call delay
	call ISCISTI_EKRAN	; da go brisi ekrano posle sekoj nacrtan piksel
	call CRTAJ_META
;==============================================================	
	cmp si, 0Eh
	jne CRTAJ

ret
CRTAJ_TRAEKTORIJA2 endp
;======================================================================
CRTAJ_TRAEKTORIJA3 proc

	mov si, 0d
	mov di, 0d
	
VCITAJ:
	lea si, koordinata_x
	lea di, koordinata_y	
CRTAJ:	
	mov cl, [si]
	mov dl, [di]
	
	add si, 2d
	add di, 2d
	
	mov ah, 0Ch			;Crttanje piksel
	mov al, 0Fh			; bela boja na pikselo
	mov bh, 00h			;broj na stranata = 0
	int 10h 
	
;==============================================================
	call delay
	call ISCISTI_EKRAN	; da go brisi ekrano posle sekoj nacrtan piksel
	call CRTAJ_META
;==============================================================	
	cmp si, 0Eh
	jne CRTAJ

ret
CRTAJ_TRAEKTORIJA3 endp
;=============================================================
CRTAJ_META PROC
;treba da iscrtame 5*5pikseli za goleminata na METATA(TARGET)
		mov cx, meta_x			;koordinati na pikselot(X) startni pozicii
		mov dx, meta_y			;koordinati na pikselot(Y)
			
		CRTAJ_HORIZ:
			mov ah, 0Ch			;Crttanje piksel
			mov al, 04h 			; 0Fh za bela boja na metata
			mov bh, 00h			;broj na stranata = 0
			int 10h 
			
			inc cx
			mov ax, cx					;cx-meta_x>golemina_topche::::::DA-> odime naredna redica:::::::NE->prodolzuvame naredna kolona
			sub ax, meta_x
			cmp ax, golemina_meta
			jng CRTAJ_HORIZ
			mov cx, meta_x		;CX odi vo inicijalnata kolona
			inc dx				;Odime eden red ponatamu
			mov ax,dx					;DX-meta_y>golemina_meta:::::::DA-> izleguvame od procedurata::::::::::::::::NE-> prodolzuvame vo nareden red
			sub ax,meta_y
			cmp ax,golemina_meta
			jng CRTAJ_HORIZ
	
RET
CRTAJ_META endp
;==========================================================================
POGODOK proc
	call ISCISTI_EKRAN
;===
	mov ah, 09h
	mov al, msg1
	mov bh, 0h
	mov bl, 5h
	mov cx, 1h
	int 10h
	call delay
;====
	mov ah, 09h
	mov al, msg2
	mov bh, 0h
	mov bl, 5h
	mov cx, 1h
	int 10h
	call delay
	mov ah, 09h
	mov al, msg3
	mov bh, 0h
	mov bl, 5h
	mov cx, 1h
	int 10h
	call delay
	mov ah, 09h
	mov al, msg4
	mov bh, 0h
	mov bl, 5h
	mov cx, 1h
	int 10h
	call delay
	mov ah, 09h
	mov al, msg5
	mov bh, 0h
	mov bl, 5h
	mov cx, 1h
	int 10h
	call delay
	mov ah, 09h
	mov al, msg6
	mov bh, 0h
	mov bl, 5h
	mov cx, 1h
	int 10h
	call delay
ret
POGODOK endp
;=========================================================================
mov ax, 04c00h
int 021h
code_seg ends
END start