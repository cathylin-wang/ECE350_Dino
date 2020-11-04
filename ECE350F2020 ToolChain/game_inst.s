.text

addi $r1, $r0, 30
addi $r2, $r0, 275

io_loop:
  jio     buttonPress
  j       io_loop

buttonPress:
  addi $r2, $r2, 40
  wait
  wait
  addi $r2, $r2, 20
  wait
  wait
  addi $r2, $r2, 10
  wait
  wait
  addi $r2, $r2, 5
  wait
  wait
  addi $r2, $r2, -5
  wait
  wait    
  addi $r2, $r2, -10
  wait
  wait
  addi $r2, $r2, -20
  wait
  wait
  addi $r2, $r2, -40
  j io_loop
