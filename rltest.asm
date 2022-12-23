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

test:
  jsr clear
  jsr drawmap
test0:
  jsr getin
  cmp #32
  bne test0
  rts

clear:
  ldx #$00
  lda #32
clear0:
  sta $0400,x
  sta $0500,x
  sta $0600,x
  inx
  bne clear0
  ldx #$00
clear1:
  sta $0700,x
  inx
  cpx #$e7
  bne clear1
  rts

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
  inc random0+1
  sta random1+1
  ror randomseed
  eor #$ff
  adc randomseed
  eor #$ff
  sta randomseed
  ;eor #$ff
random0:
  cmp #$ff
  bcc random2
random1:
  sbc #$ff
  jmp random0
random2:
  rts

genmapx = $61
genmapy = $62
genmapnrooms = $63
genmapx1 = $64
genmapy1 = $65
genmapt1 = $66
genmapt2 = $67
genmapw = $68
genmaph = $69
genmapy2 = $6A
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
  stx genmapt1
  jsr getroomxy
  jsr placeroom
  ;jsr test
  ldx genmapt1
  inx
  cpx genmapnrooms
  bne genmappl0
  jmp genmappathdn

  ; add paths
  ldx #$01
genmappath0:
  lda genmaprooms,x
  stx genmapt1
  jsr getroomxy
  lda genmapx
  sta genmapx1
  lda genmapy
  sta genmapy1
  ldx genmapt1
  dex
  lda genmaprooms,x
  jsr getroomxy

genmappath1:
  lda genmapx
  cmp genmapx1
  bcc genmappath2
  beq genmappath3
  dec genmapx
  jmp genmappathnx
genmappath2:
  inc genmapx
  jmp genmappathnx
genmappath3:
  cmp genmapy1
  bcc genmappath4
  beq genmappathdn
  dec genmapy
  jmp genmappathnx
genmappath4:
  inc genmapy
genmappathnx:
  jsr getmapaddr
  sta genmappathlda+1
  sta genmappathsta+1
  sty genmappathlda+2
  sty genmappathsta+2
genmappathlda:
  lda $ffff
  cmp #32
  beq genmappathspace
  cmp #102
  bne genmappathsta
  lda #43
  jmp genmappathsta
genmappathspace:
  lda #35
genmappathsta:
  sta $ffff
  jmp genmappath1

genmappathdn:
  ldx genmapt1
  inx
  cpx genmapnrooms
  bne genmappath0

  ; return
  rts

getroomxy:
  pha
  and #3
  ldx #10
  jsr mul
  adc #5
  sta genmapx
  pla
  and #12
  sta genmapy
  lsr genmapy
  lsr genmapy
  lda genmapy
  ldx #7
  jsr mul
  adc #4
  sta genmapy
  rts

placeroom:
  lda genmapx
  pha
  lda genmapy
  pha

  lda #3
  jsr random
  adc #6
  sta genmapw
  sta genmapt2
  inc genmapw
  lsr genmapt2
  lda genmapx
  clc
  sbc genmapt2
  sta genmapx1
  lda #3
  jsr random
  adc #4
  sta genmaph
  sta genmapt2
  lsr genmapt2
  lda genmapy
  clc
  sbc genmapt2
  sta genmapy1
  lda #102
  jsr placebox
  inc genmapx1
  inc genmapy1
  dec genmapw
  dec genmapw
  dec genmaph
  dec genmaph
  lda #46
  jsr placebox

  pla
  sta genmapy
  pla
  sta genmapx
  rts

placebox:
  sta genmapt2
  lda genmapy1
  sta genmapy
  clc
  adc genmaph
  sta genmapy2
  lda genmapx1
  sta genmapx
placebox0:
  jsr getmapaddr
  sta placebox1+1
  sty placebox1+2
  ldx #$00
  lda genmapt2
placebox1:
  sta $ffff,x
  inx
  cpx genmapw
  bne placebox1
  inc genmapy
  lda genmapy
  cmp genmapy2
  bne placebox0
  rts

getmapaddr:
  lda genmapy
  ldy #map/256
  ldx #40
  jsr mul
  clc
  adc genmapx
  bcc getmapaddr0
  iny
getmapaddr0:
  rts

placetile:
  pha
  jsr getmapaddr
  sta placetile0+1
  sty placetile0+2
  pla
placetile0:
  sta $ffff
  rts

