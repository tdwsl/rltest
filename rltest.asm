; simple roguelike test for c64

; kernal
getin = $ffe4
rdtim = $ffde

mapw = 40
maph = 22
mapszr = 80
map = $c000
randomseed = $d000

  *= 2049-2
  .dw 2049

  ; entry point

  ; 10 sys 2062
  .db 12,8,10,0,158," 2062",0,0,0

start:
  jsr rdtim
  sta randomseed
  jsr genmap
  jsr clear
  jsr drawmap
l0:
  jsr getin
  cmp #32
  bne l0
  brk

clear:
  ldx #$00
  lda #32
clear0:
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $0700,x
  inx
  bne clear0

mul:
  dex
  beq mul2
  sta mul0+1
  clc
mul0:
  adc #$ff
  bcc mul1
  iny
  clc
mul1:
  dex
  bne mul0
mul2:
  rts

drawmap:
  ldx #$00
drawmap0:
  lda map,x
  sta $0400,x
  lda map+256,x
  sta $0500,x
  lda map+512,x
  sta $0600,x
  inx
  bne drawmap0
  ldx #$00
drawmap1:
  lda map+768,x
  sta $0700,x
  inx
  cpx #mapszr
  bne drawmap1
  rts

random:
  sta random0+1
  sta random1+1
  eor #$ff
  adc randomseed
  eor #$ff
  sta randomseed
  eor #$ff
random0:
  cmp #$ff
  bcc random2
  clc
random1:
  sbc #$ff
  jmp random0
random2:
  rts

genmapx = $19
genmapy = $20
genmapaddr = $61
genmapnrooms = $63
genmapx1 = $64
genmapy1 = $65
genmapt1 = $66
genmapx2 = $43
genmapy2 = $44
genmapt2 = $45
genmaprooms = $c500
genmaptrooms = 5
genmap:
  ; clear map
  ldx #$00
  lda #32
genmapclr0:
  sta map,x
  sta map+256,x
  sta map+512,x
  inx
  bne genmapclr0
  ldx #$00
genmapclr1:
  sta map+768,x
  inx
  cpx #mapszr
  bne genmapclr1
  ; room locations
  lda #$00
  sta genmapnrooms
genmaprm0:
  lda #12
  jsr random
genmaprm1:
  tay
  iny
  tya
  and #$0f
  cmp #12
  bcc genmaprm1le
  sbc #11
genmaprm1le
  ldx #$00
genmaprm2:
  cmp genmaprooms,x
  beq genmaprm1
  inx
  cpx genmapnrooms
  bne genmaprm2
  ldx genmapnrooms
  sta genmaprooms,x
  inx
  stx genmapnrooms
  cpx #genmaptrooms
  bne genmaprm0
  ; place rooms
  ldx #$00
genmappl0:
  lda genmaprooms,x
  and #3
  stx genmapt1
  ldx #10
  jsr mul
  adc #5
  sta genmapx
  ldx genmapt1
  lda genmaprooms,x
  and #12
  sta genmapy
  lsr genmapy
  lsr genmapy
  lda genmapy
  ldx #7
  jsr mul
  adc #4
  sta genmapy
  lda #46
  jsr placetile
  ldx genmapt1
  inx
  cpx genmapnrooms
  bne genmappl0
  ; rtsurn
  rts

placeroom:
  lda #10
  jsr random
  sta genmapt2
  lsr genmapt2
  lda genmapx
  clc
  sbc genmapt2
  pha
  sta genmapx1
  lda genmapx
  adc genmapt2
  sta genmapx2
  lda #7
  jsr random
  sta genmapt2
  lsr genmapt2
  lda genmapy
  sbc genmapt2
  pha
  sta genmapy1
  lda genmapy
  adc genmapt2
  sta genmapy2
  lda #102
  jsr placebox
  pla
  sta genmapy1
  inc genmapy1
  pla
  sta genmapx1
  inc genmapx1
  dec genmapy2
  dec genmapx2
  lda #46
  jsr placebox
  rts

placebox:
  lda genmapx
  pha
  lda genmapy
  pha
  lda genmapx1
  sta genmapx
  lda genmapy2
  sta genmapy
  lda #41
  jsr placetile
  lda genmapx2
  sta genmapx
  lda genmapy2
  sta genmapy
  lda #41
  jsr placetile
  pla
  sta genmapy
  pla 
  sta genmapx
  rts

  sta genmapt2
  ; push genmap xy
  lda genmapx
  pha
  lda genmapy
  pha
  ldy genmapy1
  ; loop
placebox0:
  ldx genmapx1
placebox1:
  stx genmapx
  sty genmapy
  lda genmapt2
  jsr placetile
  ldx genmapx
  ldy genmapy
  inx
  cpx genmapx2
  bne placebox1
  iny
  cpy genmapy2
  bne placebox0
  ; return
  pla
  sta genmapy
  pla
  sta genmapx
  rts

placetile:
  pha
  lda genmapy
  ldy #map/256
  ldx #40
  jsr mul
  adc genmapx
  bcc placetile0
  iny
placetile0:
  sta placetile1+1
  sty placetile1+2
  pla
placetile1:
  sta $ffff
  rts

