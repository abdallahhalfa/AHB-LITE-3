# AHB LITE 3 
## Table of Contents
# Table of Contents
- [Introduction](#introduction)
- [Master Module](#master-module)
  - [Diagram](#digram)
  - [Instruction Memory and Program Counter](#instruction-memory-and-program-counter)
  - [Register File](#register-file)
  - [Control Unit](#control-unit)
  - [FSM](#fsm)
- [Slaves (Data Memory)](#slaves-data-memory)
- [Simulation Waveforms](#simulation-waveform)
  - [Single Transactions](#single-transactions)
  - [Burst Transactions](#burst-transactions)
  - [Master Read Burst Transaction](#master-read-burst-transaction)
  - [Busy and Unidentified Instruction](#busy-and-unidentified-instruction)

## Introduction
AMBA AHB-Lite addresses the requirements of high-performance synthesizable 
designs. It is a bus interface that supports a single bus master and provides high-bandwidth operation.

![alt text](images/AHB.png)

An AHB-Lite master provides address and control information to initiate read and write operations.

![alt text](images/master%20interface.jpg)

An AHB-Lite slave responds to transfers initiated by masters in the system. The slave 
uses the HSELx select signal from the decoder to control when it responds to a bus 
transfer. The slave signals back to the master:
- the success
- failure
-  or waiting of the data transfer.

![alt text](images/Slave.png)

## Master Module

To impelement the Master interface, A simple module was made which only consists of a instruction memory, control unit and regsiter file.
### Digram

![alt text](images/MASTER%20SYSTEM.jpg)

### Instruction Memory and Program Counter
First the Instruction Memory is intialized with all the instructions and then the Program counter passes by each instruction one by one.
In case of HREADY is low, it will make the program counter stall on the current instruction.

### Register File
This block is used to write data on the bus when HWRITE is HIGH and to read data on the bus while LOW.

### Control Unit
This block Takes the instruction and decodes it where
| Bits                  | Description  |
|-----------------------|--------------|
| Instruction[31:26]    | OPCODE         |
| Instruction[25]       | WRITE or READ
| Instruction[24:20]    | Number of INCR cycles         |       
| Instruction[19:8]     | Used later in slave    | 
| Instruction[7:0]      | Address for RegFile     |


| opcode                  | Description  |
|-----------------------|--------------|
| 6'b000_000    |     BURST SINGLE BYTE     |
| 6'b000_001    | BURST SINGLE HALF WORD         |       
| 6'b000_010       | BURST SINGLE WORD    | 
| 6'b000_011       | BURST INCR BYTE     |      
| 6'b000_100       | BURST INCR HALF WORD    | 
| 6'b000_101       | BURST INCR WORD     |

### FSM
![alt text](images/states.jpg)

## Slaves (Data Memory)
The Slaves used are different Data memories that reads and Writes the data according to the master's control signals, then Responds with HREADY and HRESP signals.

| Slave                  | Address  |
|-----------------------|--------------|
| Data Memory 1   |     12'h000     |
| Data Memory 2  | 12'h001        |       
| Data Memory 3    | 12'h002    | 
| Default Slave       | Other    |  

## Simulation Waveform
**NOTE: To view the operation of each module alone check the folders in the Repository**

### Single Transactions 

The Figure below shows Single transcations from each slave and one Burst transaction while the final transaction doesnt map to any slave so the default slave gives an ERROR response

![alt text](images/single%20and%20error.JPG)

### Burst Transations

The Figure below shows different Burst transaction with a case of not ready slave

![alt text](images/burst1.JPG)

### Master Read Burst Transaction 

The Figure Below Shows a read from slave transaction where the slave puts the data on the HRDATA bus.

![alt text](images/burst%20read.JPG)

### Busy and Unidentified Instruction

The Figure below shows a Case of Busy Master in a Burst transaction and then an unidentified Instruction

![alt text](images/busy%20and%20finsh.JPG)

## Future Work
**More Slaves will be added to this module such as the timer LEDS module that was made before (you can view it in the current repository).**

**Busy at the end of an sequential incr to terminate the transaction was not handled in this module and will be handled in the future.**
