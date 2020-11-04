.text

addi $r1, $r0, 30
addi $r2, $r0, 275

io_loop:
    jio     buttonPress

buttonPress:
  addi $r2, $r2, 10
  wait
  addi $r2, $r2, 5
  wait
  addi $r2, $r2, 3
  wait
  addi $r2, $r2, 1
  wait
  addi $r2, $r2, -1
  wait    
  addi $r2, $r2, -3
  wait
  addi $r2, $r2, -5
  wait
  addi $r2, $r2, -10
  j io_loop
