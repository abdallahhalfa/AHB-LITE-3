module instr_reg ( input HCLK, HRESETn,stall_flag,HREADY,INTERRUPT_FLAG,
                   output reg START,
                   output reg [31:0] ADDR_INPUT_REG
                   );
reg [31:0] pc; 
reg [31:0] instr_mem [0:31];
initial
  begin
    //instr_mem[0] = 32'h0200_000A;//BURST_SINGLE_BYTE (for read use 0200_000A)
    //instr_mem[1] = 32'h0600_000C;//BURST_SINGLE_HALF_WORD (for read use 0600_000A)
    //instr_mem[2] = 32'h0A00_000D;//BURST_SINGLE_WORD (for read use 0A00_000A)
//    instr_mem[0] = 32'h0D00_000A;// BURST_INCR_BYTE with 8 incr steps
//    instr_mem[1] = 32'h0D00_000A;// BURST_INCR_BYTE with 8 incr steps
//    instr_mem[2] = 32'h1100_000A;//BURST_INCR_HALF_WORD with 8 incr steps
//    instr_mem[3] = 32'h1100_000A;//BURST_INCR_HALF_WORD with 8 incr steps
//    instr_mem[4] = 32'h1500_000A;//BURST_INCR_WORD  with 8 incr steps
//    instr_mem[5] = 32'h1500_000A;//BURST_INCR_WORD  with 8 incr steps
//    instr_mem[6] = 32'hFFFF_FFFF;//UNDEFIEND INSTRUCTION
$readmemh("instr_mem.txt",instr_mem);

  end             
always@(posedge HCLK, negedge HRESETn)
  begin
    if(!HRESETn)
      begin
        ADDR_INPUT_REG <= instr_mem[0];
        START<=1;
        pc<=1;
      end
    else if(!stall_flag&&HREADY&&!INTERRUPT_FLAG)
      begin
        pc<=pc+1;
        ADDR_INPUT_REG <= instr_mem[pc];
        START<=1;
      end
    else
      START<=0;
  end
  
  
endmodule



