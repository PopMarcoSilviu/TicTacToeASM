.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf :proc
includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "X si 0",0
area_width EQU  1024
area_height EQU 768
area DD 0
DimPatrat DD 200
DimPatratMare  DD 0
GrosimeLinie DD 4
culoare2 DD 0
counter DD 0 ; numara evenimentele de tip timer
filler DD 0
filler2 DD 0
filler3 DD 0
filler4 DD 0
filler5 DD 0
resetX DD 0
resetY DD 0
runda DD 1
terminat DD 0
egalitatePar DD 1
varOFFset DD 0
DimPatratSecundara DD 0
offsett DD 15
arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

castig DD 9 dup(0)

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

x dd ?
y dd ?
x_normalizat dd ?
y_normalizat dd ?
x_sec dd ?
y_sec dd ?

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0C8C8C8h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm	

pepega macro n
    pushad
    mov ebp, esp
    sub esp, 4
    
    mov al, '%'
    mov [ebp - 4], al
    
    mov al, 'd'
    mov [ebp - 3], al
    
    mov al, 10
    mov [ebp - 2], al
    
    mov al, 0
    mov [ebp - 1], al
    
    push n
    lea eax, [ebp - 4]
    push eax
    call printf
    add esp, 8
    

    mov esp, ebp
    popad
endm


;macro pt linii(dreptunghiuri) orizontale

linie_orizontala macro x,y,lungime,inaltime, culoarea


local bucla,jump,buclaMare,afara

pushad

xor esi,esi

buclaMare:

xor edx,edx

mov eax,y
add eax,esi    ;offset

mov ebx, area_width
mul ebx

add eax, x
shl eax,2
add eax,area

mov ecx,-1
mov edx,x
dec edx

bucla:
inc ecx
inc edx ; pozitia absoluta pe x

; vreau sa ies cand  edx >= area_width
cmp edx,area_width
jae jump

; vreau sa ies cand  esi + y >= area_height
add esi, y
cmp esi, area_height
jae afara
sub esi, y

push ebp
mov ebp,culoarea
mov dword ptr[eax],ebp
add eax, 4

pop ebp

cmp ecx,lungime
jbe bucla

jump:

inc esi
cmp esi,inaltime 
jb buclaMare

afara:
popad
endm

matrice macro
    local etloop, inloop, break
    pushad
    mov ebp, esp
    sub esp, 4
    
    mov ecx, 0
    etloop:
    cmp ecx, 36
    jz break
    
    xor edx, edx
    inloop:
        cmp edx, 12
        jz skip
        
        pushad
        
        mov al, '%'
        mov [ebp - 4], al
        mov al, 'd'
        mov [ebp - 3], al
        mov al, ' '
        mov [ebp - 2], al
        mov al, 0
        mov [ebp - 1], al

        mov ebx, castig[ecx + edx]
        push ebx
        lea eax, [ebp - 4]
        push eax
        call printf
        add esp, 8

        popad
        
        add edx, 4
    jmp inloop
    
    skip:
    
    pushad
    
    mov al, 10
    mov [ebp - 2], al
    mov al, 0
    mov [ebp - 1], al
    lea eax, [ebp - 2]
    
    push eax
    call printf
    add esp, 4
    
    popad
    
    add ecx, 12
    jmp etloop
    break:
	mov esp,ebp
    popad
endm




linie_diagonala macro x,y,lungime, dir,culoare  ;  dir=1 => DP , dir=-1=>DS

local inloop
push eax
push edx
push ebp
push ecx 
push ebx
push x
push y
push DimPatrat
push filler

mov filler, 0


xor ecx,ecx
xor edx,edx
mov ebx,lungime
add ebx,y

	inloop:

    ; avem in eax adresa la care schimbam culoarea
	mov eax,y 
	mov ebp,area_width
	mul ebp
	add eax,x
	shl eax,2
	add eax, area
		
	inc y
	add x,dir

	push ebx
	mov ebx,culoare 
	mov dword ptr[eax],ebx
	pop ebx
	
	cmp y,ebx

	jl inloop


pop filler
pop DimPatrat
pop y
pop x
pop ebx
pop ecx
pop ebp
pop edx
pop eax
endm

; Desenat x in patrat in care este punctul (x,y)
desenatX proc ; grosime x y ,culoare

pop filler2
pop filler3
push filler2


push ebp
mov ebp,esp
push eax
push edx

xor edx,edx

mov eax,dword ptr[ebp+arg2]
div DimPatrat
mul DimPatrat
mov x_normalizat,eax


xor edx,edx
mov eax,dword ptr[ebp+arg1]
div DimPatrat
mul DimPatrat
mov y_normalizat,eax


push DimPatrat

mov eax, offsett
add x_normalizat,eax
add y_normalizat,eax
sub DimPatrat,eax
sub DimPatrat,eax

xor eax,eax

	start:
	
	mov ecx,y_normalizat
	add ecx,eax
	mov filler2,ecx

	linie_diagonala x_normalizat,filler2,DimPatrat,1,filler3
	
	mov ecx,x_normalizat
	add ecx,eax
	mov filler2,ecx

	linie_diagonala filler2,y_normalizat,DimPatrat,1, filler3

	
	inc eax
	dec DimPatrat
	cmp eax,[ebp+arg3]
	jl start 

	
	
	
push x_normalizat
mov eax,x_normalizat
add eax,DimPatrat
mov x_normalizat,eax

	xor eax,eax

	start2:
	mov ecx,y_normalizat
	add ecx,eax
	mov filler2,ecx
		
	linie_diagonala x_normalizat,filler2,DimPatrat,-1,filler3
		
		
	mov ecx,x_normalizat
	sub ecx,eax
	mov filler2,ecx
		
	linie_diagonala filler2,y_normalizat,DimPatrat,-1, filler3
		
	inc eax
	dec DimPatrat

	cmp eax,[ebp+arg3]
	jl start2 

	
pop x_normalizat
pop DimPatrat
pop edx
pop eax

mov esp,ebp
pop ebp

ret 
desenatX endp



desenat0 proc ; x,y,culoarea

	mov esi,esp
	
	push eax
	push edx
	push ebx
	push filler2
	
	
xor edx,edx
mov eax,dword ptr[esi+12]
div DimPatrat
mul DimPatrat
mov x_normalizat,eax


xor edx,edx
mov eax,dword ptr[esi+8];y
div DimPatrat
mul DimPatrat
mov y_normalizat,eax


	xor edx,edx
	xor eax,eax
	
	mov eax, DimPatrat
	shr eax,1


	mov filler2, eax ; dim/2
	
	
	mov edx,[esi+4]
	mov culoare2 ,edx
	
	mov eax, DimPatrat
	shr eax,2
	add eax,x_normalizat ;y
	mov filler, eax ; dim/2
 
	mov ebx,GrosimeLinie
	mov eax, y_normalizat
	add ebx,eax
	
	mov filler3, ebx
	
	linie_orizontala filler,filler3,filler2 ,GrosimeLinie, culoare2
	;x y lungime inaltime culoare

	 mov ebx, DimPatrat
	 sub ebx,GrosimeLinie
	 sub ebx,GrosimeLinie

	add ebx,y_normalizat ;y
	mov filler3, ebx
	
	
	linie_orizontala filler,filler3,filler2 ,GrosimeLinie, culoare2
	
		
	mov eax,DimPatrat
	shr eax,3 ; dim/8
	add eax,x_normalizat
	mov filler ,eax
	mov eax,y_normalizat
	mov ebx,DimPatrat
	shr ebx,3
	add eax,ebx
	mov filler2,eax
	mov eax,GrosimeLinie
	shr eax,1
	mov filler3 ,eax
	mov eax,DimPatrat
	shr eax,1
	mov ebx,DimPatrat
	shr ebx,2
	mov filler4,0
	add filler4, ebx
	add filler4, eax
	
	linie_orizontala filler,filler2, filler3,filler4,culoare2 
	
	mov eax,DimPatrat
	shr eax,1
	mov ebx, DimPatrat
	shr ebx,2
	add eax,ebx
	add filler,eax

	linie_orizontala filler,filler2, filler3,filler4,culoare2 
	
	; x,y,lungime,dir,culoare
	
	
	
	
	
	pop filler2
	pop ebx
	pop edx
	pop eax

ret
desenat0 endp

verificareCastig macro suma

local continuare, absnot,aa,aa2



cmp suma,0
		xor edx,edx
		mov eax,runda
		mul suma
		mov suma,eax
		
		;pepega suma
		cmp suma,3
		jl continuare
		
		mov terminat,1
		mov egalitatePar,0
		
		xor edx,edx
		mov eax,DimPatrat
		mov edx,3
		mul edx
		mov edx,10
		add eax,edx
		mov x,eax
		mov y,0
		mov ebx,DimPatrat
		shr ebx,1
		add x,ebx
	
		add y,ebx
		sub y,10
		make_text_macro 'P' ,area, x,y
		add x,10
		make_text_macro 'I' ,area, x,y
		add x,10
		make_text_macro 'E' ,area, x,y
		add x,10
		make_text_macro 'R' ,area, x,y
		add x,10
		make_text_macro 'D' ,area, x,y
		add x,10
		make_text_macro 'E' ,area, x,y
	

		add y,5
		mov eax,DimPatrat
		add x,eax
		
		mov eax,1
		
		cmp runda,eax 
		je aa
		;castiga 0
		 
		 push GrosimeLinie
		push x
		push y
		push 255
		call desenatX
		add esp,16

		 jmp aa2
		aa:
		
		
		push x
		 push y
		 push 255
		 call desenat0
		 add esp,12

		; castiga X
	
		
		aa2:
		
		jmp terminare
		continuare:
		
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	
	

	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 200 ; CULOARE FUNDAL
	push area
	call memset
	add esp, 12
	
	;x,y lungime, inal
	push eax
	push edx
	mov eax,3
	mul DimPatrat
	mov DimPatratMare,eax
	push DimPatrat
	mov eax,GrosimeLinie
	shr eax,1
	sub DimPatrat,eax	
	
	
	linie_orizontala DimPatrat,0, GrosimeLinie,DimPatratMare,0 ;linie verticala
	linie_orizontala 0, DimPatrat,DimPatratMare,GrosimeLinie,0 ;linie orizonala
	
	
	mov eax,DimPatrat
	shl eax,1
	mov filler,eax
	mov edx,GrosimeLinie
	shr edx,1
	add filler,edx
	linie_orizontala filler,0,GrosimeLinie,DimPatratMare,0 ;linie verticala
	linie_orizontala 0,filler,DimPatratMare,GrosimeLinie,0 ;linie orizontala
	sub filler, edx
	
	mov filler,area_width
	mov eax, DimPatrat
	shl eax,1
	sub filler,eax
	
	mov filler2, area_height
	mov eax,DimPatrat
	shr eax,1
	sub filler2,eax
	
	linie_orizontala filler,filler2,filler2,DimPatratMare,0
	mov eax, GrosimeLinie
	add filler,eax
	add filler2,eax
	linie_orizontala filler,filler2,filler2,DimPatratMare,0c8c8c8h
	
	
	mov eax,filler
	mov resetX,eax
	mov eax,filler2
	mov resetY,eax
	
	mov eax,DimPatrat
	sub eax,25
	add filler,eax
	mov eax,DimPatrat
	shr eax,2
	sub eax,10
	add filler2,eax

	
		
		make_text_macro 'R' ,area, filler,filler2
		add filler,10
		make_text_macro 'E' ,area,  filler,filler2
		add filler,10
		make_text_macro 'S' ,area, filler,filler2
		add filler,10
		make_text_macro 'E' ,area,  filler,filler2
		add filler,10
		make_text_macro 'T' ,area,  filler,filler2

	

	
	
	pop DimPatrat
	pop edx
	pop eax
	
	jmp afisare_litere
	
evt_click:

mov eax,dword ptr[ebp+arg2]
cmp resetX,eax
jae afara3
mov eax,dword ptr[ebp+arg3]
cmp resetY,eax
jae afara3
;RESETAM
mov terminat,0
mov egalitatePar,1
mov runda,1

mov ecx,9

ett:

mov [castig+ecx*4-4],0

loop ett

push 0

call draw
add esp,4


afara3:

cmp terminat,1
je final

pushad
	
xor edx,edx
mov eax,dword ptr[ebp+arg2]
div DimPatrat
mov x_normalizat,eax


xor edx,edx
mov eax,dword ptr[ebp+arg3];y
div DimPatrat
mov ebx,3
mul ebx
mov y_normalizat,eax


mov ebx, 1
cmp runda, 1
je jump
mov ebx, -1
jump:
mov esi,y_normalizat 
add esi,x_normalizat
shl esi,2

cmp castig[esi],0
jne terminare

mov castig[esi], ebx 

;x=[ebp+arg2]
;y=[ebp+arg3]


	 xor eax,eax
	 xor edx,edx
	
	 cmp eax,[ebp+arg2] ;x
	 ja jp1
	 cmp eax,[ebp+arg3];y
	 ja jp1
	 mov eax,DimPatrat
	 mov ebx,3
	 mul ebx
	 cmp [ebp+arg2],eax
	 jae jp1
	 cmp [ebp+arg3],eax
	 jae jp1
	
	mov ebx,1
	cmp ebx,runda
	jne notif
	 push GrosimeLinie
	 push [ebp+arg2]
	 push [ebp+arg3]
	 push 255
	 call desenatX
	 add esp,16
	
	jmp elsif
	
	notif:
	
	push [ebp+arg2]
	push [ebp+arg3]
	push 255
	call desenat0
	add esp,12
	elsif:
	
	
	
		mov ecx, 3
		
		eticheta:

		xor edx,edx
		xor eax,eax
		xor ebx,ebx
		mov eax,ecx
		dec eax
		mov esi,3
		mul esi
		shl eax,2
		add ebx,[castig+eax]
		add ebx,[castig+eax+4]
		add ebx, [castig+eax+8]

		;matrice
		verificareCastig ebx
		

		dec ecx
		xor ebx,ebx
		add ebx,[castig+ecx*4]
		add ebx ,[castig+12+ecx*4]
		add ebx, [castig+24+ecx*4]
		
		verificareCastig ebx
		
		inc ecx
		dec ECX
		cmp ecx,0
		ja eticheta
		
	
	mov ebx,[castig+8]
	add ebx,[castig+16]
	add ebx,[castig+24]
	
	verificareCastig ebx
	
	mov ebx,[castig]
	add ebx,[castig+16]
	add ebx,[castig+32]
	
	verificareCastig ebx
	
	sub edx,edx
	
	mov ecx,9
	
	et:
	
	mov ebx,ecx
	dec ebx
	shl ebx,2
	
	cmp [castig+ebx],0
	jne egalitatenot
	
	mov edx,1
	jmp egalitate 
	egalitatenot:
	loop et
	
	egalitate:
	
	cmp edx,1
	je trece
	mov terminat,1
	jmp terminare
	trece:

	
	
xor edx,edx
mov eax,-1
mul runda
mov runda,eax


terminare:

mov ecx,9
xor ebx,ebx
looop:

mov eax,ecx
dec eax
shl eax,2

mov edx,[castig+eax]

cmp edx,0
je sari
inc ebx
sari:

loop looop

cmp ebx,9
jne past



mov eax,1

cmp egalitatePar,eax
jne past

; caz de egalitate
;make_text_macro symbol, drawArea, x, y
xor edx,edx
mov eax,DimPatrat
mov edx,3
mul edx
mov edx,10
add eax,edx
add eax,DimPatrat
mov x,eax
mov eax,DimPatrat
shr eax,1
mov y,eax
make_text_macro 'E' ,area, x,y
add x,10
make_text_macro 'G' ,area, x,y
add x,10
make_text_macro 'A' ,area, x,y
add x,10
make_text_macro 'L' ,area, x,y
add x,10
make_text_macro 'I' ,area, x,y
add x,10
make_text_macro 'T' ,area, x,y
add x,10
make_text_macro 'A' ,area, x,y
add x,10
make_text_macro 'T' ,area, x,y
add x,10
make_text_macro 'E' ,area, x,y


jmp jp1
past:



jp1:

popad

final:
jmp afisare_litere

evt_timer:
	inc counter
	
afisare_litere:
	

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
