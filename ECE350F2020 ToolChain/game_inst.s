.text

nop
nop
nop
addi $r1, $r0, 40
addi $r2, $r0, 275

io_loop:
  jio     buttonPress
  j       io_loop

buttonPress:
  wait
  wait
  wait
  wait
  wait
  addi $r2, $r2, -40
  wait
  wait
  wait
  wait
  wait
  addi $r2, $r2, -20
  wait
  wait
  wait
  wait
  wait
  addi $r2, $r2, -10
  wait
  wait
  wait
  wait
  wait
  addi $r2, $r2, -5
  wait
  wait
  wait
  wait
  wait
  addi $r2, $r2, 5
  wait
  wait
  wait
  wait
  wait
  addi $r2, $r2, 10
  wait
  wait
  wait
  wait
  wait
  addi $r2, $r2, 20
  wait
  wait
  wait
  wait
  wait
  addi $r2, $r2, 40
  wait
  wait
  j io_loop
