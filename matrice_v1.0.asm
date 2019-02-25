

data segment


;sectiune mesaje
randNou db 10,13,32,32,'$'
mesaj1 db 'Program de inmultire a 2 matrice cu dimensiunea maxima 10x10 $'
mesaj2 db 10,13,'Introduceti numarul de linii al matricei 1: $'
mesaj3 db 10,13,'Introduceti numarul de coloane al matricei 1: $'
mesaj4 db 10,13,'Introduceti numarul de linii al matricei 2: $'  
mesaj5 db 10,13,'Introduceti numarul de coloane al matricei 2: $'
mesaj6 db 10,13,'Introduceti elementele matricei 1 linie cu linie: $'
mesaj7 db 10,13,'Introduceti elementele matricei 2 linie cu linie: $'
mesaj8 db 10,13,'Matricea 1 este: $'
mesaj9 db 10,13,'Matricea 2 este: $' 
iesi_din_program db 10,10,13,'Eroare. Program terminat xD$'


;sectiune date matrice
mat1 db 100 dup(1)     
mat2 db 100 dup(1)
prod dw 100 dup(0) 
string db 10 dup('$')
linii1 dw ?   ; m 
col1 dw ?    ; n
linii2 dw ?   ; p
col2 dw ?     ; r 
dimensiune_max dw 10

 ;sectiune date procedura citeste_numar
 sir db ?,?
 msg_citire db 10,13,'Introduceti un numar 0-80: $'
; msg_eroare db 10,13,10,13, 'Eroare. Program terminat xD$'
 numar db ?  
 contor_eroare db 0 
 maxim db 80     


data ends

cod segment  
    
    ;macro afisare mesaje
MESAJ MACRO nume_mesaj           ;ce functie jmechera
    mov dx, offset nume_mesaj
    mov ah, 9  
    int 21h        
ENDM  

EXIT MACRO iesi_din_program 
    mov ah,2
    mov dx,7
    int 21h
    lea dx, iesi_din_program 
    mov ah,9
    int 21h 
    mov ah,4ch
    int 21h      
ENDM    

citeste_numar PROC

   ; mov ah,9,
   ; lea dx, msg_citire
   ; int 21h 
    xor si,si
    mov cl,2      
    
    repeta:
    
    mov ah,1
    int 21h 
    add contor_eroare,1
    cmp al,57        ;testeaza daca am citit cifra, altfel eroare
    ja eroare 
    
    cmp al,48        ;testeaza daca am citit cifra
    jb eroare
    
    revenire:
    
    mov sir[si],al    ;stocheaza caracterul ascii citit in sir
     
    inc si
    cmp si,2          ;daca am citit deja 2 cifre, fa conversia
    je conversie 
    cmp al,13         ;daca am citit 1 cifra si apas enter, atunci fa conversia
    jne repeta
     
     conversie: 
      
    xor ax, ax
    cmp sir[si-1],13   ;daca am citit doar 1 cifra, sari peste constructie
    je sari_peste
    mov al,sir[si-2]   ; daca am citit 2 cifre, atunci construieste nr
    sub al, 48
    mov bl, 10
    mul bl
    inc si 
    
    sari_peste:              
    mov bl,sir[si-2]   ;adauga unitatea la nr construit
    sub bl,48
    add al, bl
    mov numar, al      ;nr citit este stocat in "numar" 
    
    mov al,maxim
    cmp numar, al    ; daca numarul este mai mare ca limita maxima, eroare
    ja eroare
    
    jmp finish
    
    eroare:          ;eroare citire eronata, iesi din program
    cmp al,13
    je revenire
    EXIT iesi_din_program
    
    finish: 
    cmp contor_eroare,2   ;daca am introdus doar 1 enter (fara nicio cifra), eroare
    je ok  
    cmp al,15
    je eroare
    cmp al,80  
    
    ok: 
     
ret 
ENDP  citeste_numar




; inceputul efectiv al programului
START: 


mov ax, data
mov ds,ax

MESAJ mesaj1 ; afisarea functiei programului 

; citire dimensiuni matrice 1
    MESAJ mesaj2 
    call citeste_numar   ;citeste numar linii matrice1
    xor ax,ax
    mov al,numar      ; numar pe 8 biti, linii1 pe 16 biti
    mov linii1, ax 
    
    MESAJ mesaj3
    call citeste_numar ;citeste numar coloane matrice1
    xor ax, ax
    mov al, numar
    mov col1,ax  
    
    MESAJ mesaj4
    call citeste_numar ;citeste numar linii matrice2
    xor ax,ax
    mov al, numar
    mov linii2,ax
    
    MESAJ mesaj5
    call citeste_numar ;citeste numar coloane matrice2    
    xor ax, ax
    mov al, numar
    mov col2,ax

;testare conditii dimensiuni matrice
mov ax, linii2           ; nr coloane matrice1 = nr linii matrice2 
cmp ax,col1
je ok1:
EXIT iesi_din_program

ok1:   
mov ax, linii1          ; maxim 10 linii si 10 coloane
cmp ax,dimensiune_max
jl ok2:
EXIT iesi_din_program

ok2:
mov ax, col1  
cmp ax,dimensiune_max
jl ok3:
EXIT iesi_din_program 

ok3:
mov ax, linii2  
cmp ax,dimensiune_max
jl ok4:
EXIT iesi_din_program
                      
ok4:
mov ax, col2  
cmp ax,dimensiune_max
jl ok5:
EXIT iesi_din_program

ok5: 

;introducerea elementelor din matrice
MESAJ mesaj6
mov ax, linii1    ;calculez nr de elemente din matrice
mul col1
mov cx,ax 
xor di, di


bucla_citire1:      ;citesc numerele si le salvez in matrice
  MESAJ randNou
  push cx           ;cx este modificat de proc si trebuie stivuit   
  call citeste_numar 
  pop cx
  mov al, numar
  mov  mat1[di],al
  inc di 
  mov ah,2
  mov dx,32
  int 21h
loop bucla_citire1 

MESAJ mesaj7
mov ax,linii2   ;calculez nr de elemente din matrice
mul col2
mov cx,ax
xor di,di


bucla_citire2: 
  MESAJ randNou
  push cx           ;cx este modificat de proc si trebuie stivuit
  call citeste_numar  
  pop cx
  mov al, numar
  mov mat2[di],al
  inc di   
  mov ah,2
  mov dx,32
  int 21h
loop bucla_citire2


  
 

xor si, si  ; i, initializari contoare la zero
xor di, di ; j
xor bx, bx  ; k 
xor cx,cx 




bucla_1:
 xor di,di
 

bucla_2:
 xor bx, bx

bucla_3: 
  push si 
  mov ax, si      ; pozitioneaza pe linia aferenta 
  mul col1        ; matricei 1
  mov si, ax
  
  mov cl, mat1[si][bx]
  pop si
  
  push bx 
  mov ax, bx      ; pozitioneaza pe linia aferenta
  mul col2        ; matricei 2
  mov bx,ax 
  
  mov al, cl       
  mul mat2[bx][di]  ;inmultirea elementelor din matrice
  pop bx
   
  push si 
  mov cx,ax       ; salveza rezultatul inmultirii din ax
  shl si,1
  mov ax,si
  mul col2 
  mov si,ax
  
  push bx  
  mov bx,di 
  shl bx,1
  add prod[si][[bx],cx
  pop bx
  pop si
  
  
  inc bx
  cmp bx,col1 
  jb bucla_3
  
  inc di 
  cmp di,col2 
  jb bucla_2
  
  inc si
  cmp si,linii1
  jb bucla_1

;afisare matrice1 
xor si,si
xor di,di
mov ax,linii1
mul col1
mov cx,ax

MESAJ mesaj8 
MESAJ randNou
repeat_1:
push cx
xor ax,ax
mov al, mat1[si]
mov bx, 10
mov cx,0

l1_1:
mov dx,0
div bx
add dx,48
push dx
inc cx
cmp ax,0
jne l1_1

mov bx,offset string

l2_2:
pop dx
mov [bx],dx
inc bx
loop l2_2

mov ah,9
mov dx,offset string
int 21h

inc di
mov ax,di
xor dx,dx
div col1
cmp dl,0
jne sari_1 
mov ah,09
lea dx,randnou
int 21h
sari_1:
pop cx
inc si
loop repeat_1 

;afisare matrice2 
xor si,si
xor di,di
mov ax,linii2
mul col2
mov cx,ax

MESAJ mesaj9
MESAJ randNou
repeat_2:
push cx
xor ax,ax
mov al, mat2[si]
mov bx, 10
mov cx,0

l1_2:
mov dx,0
div bx
add dx,48
push dx
inc cx
cmp ax,0
jne l1_2

mov bx,offset string

l2_3:
pop dx
mov [bx],dx
inc bx
loop l2_3

mov ah,9
mov dx,offset string
int 21h

inc di
mov ax,di
xor dx,dx
div col2
cmp dl,0
jne sari_2 
mov ah,09
lea dx,randnou
int 21h
sari_2:
pop cx
inc si
loop repeat_2 



;afisare matrice finala  

xor si, si  
xor di,di
mov ax, linii1
mul col2
mov cx, ax

MESAJ randNou  
repeat:
push cx
mov ax,prod[di]

mov bx ,10

mov cx,0

l1:

mov dx,0

div bx

add dx,48

push dx

inc cx

cmp ax,0

jne l1


mov bx ,offset string 

l2:

pop dx           

mov [bx],dx

inc bx



loop l2 


mov ah,09

mov dx,offset string

int 21h

add di,2
inc si 

mov ax,si   
xor dx,dx
div col2
cmp dl,0
jne sari
mov ah,09
lea dx,randnou
int 21h
sari:

pop cx 

loop repeat

mov ah,4ch
int 21h  
  
  
 cod ends
end start





