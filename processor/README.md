# Project Checkpoint 4
 - Author: Cathy Wang
 - Date: October 19, 2020
 - Course: ECE/CS 350, Duke University, Durham, NC
 - Term: Fall 2020
 - Professor Board
## Duke Community Standard, Affirmation
I understand that each `git` commit I create in this repository is a submission. I affirm that each submission complies with the Duke Community Standard and the guidelines set forth for this assignment. I further acknowledge that any content not included in this commit under the version control system cannot be considered as a part of my submission. Finally, I understand that a submission is considered submitted when it has been pushed to the server.
## Pipelined Processor
This is a five-stage single-issue 32-bit processor that handles hazards, implements bypassing, has stalls, and has fast branches. 
## Pipelined Processor
This is a five-stage single-issue 32-bit processor that handles hazards, implements bypassing, has stalls, and has fast branches. 
## Stalls
The processor stalls operations follwing a multiplication or division operation for the entirity of the process. The processor also stalls when a load output is needed for the next operation (for example, as an ALU input or for a jump register or a register you are comparing for branching). This stall is only once cycle long and works in conjunction with WX bypassing.
## Bypassing
Bypassing handles most data haards (and if it can't bypass, it must stal). Bypassing is needed when the value from the register has been changed. This happens because instructions further along the pipeline may have changed it but have yet to write back into the register. In the memory stage, we check the writeback stage to see if we changed the data we need to store. In the execute stage, we look at memory and writeback to see if we changed one of the ALU inputs. In the decode stage, we look at the end of execute stage, the beginning of memory stage, the end of memory stage (what we loaded from memory), and writeback to check if we changed one of the registers we needed to read for jumping or branching.
## Fast Branch
With the exception of blt which happens in the execute stage because the ALU is needed, the rest of the branching and jumping happens in the decode stage. Checking if two things are equal or if something is equal to zero can be used with simple combinational logic, which allows us to do this in the half cycle after reading from the register file and before the DX latch. 
For branching, we assume a branch is not taken. If we find out that we do need ot take the branch, the instruction we assumed we took is then flushed out and the PC is updated to the next instruction where we do branch.