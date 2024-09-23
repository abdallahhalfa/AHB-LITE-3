import master_package::*;
module AHB_TOP_tb ();

reg HCLK,HRESETn,INTERRUPT_FLAG,ERROR_FLAG,READY_FLAG;

parameter T_period = 10;

AHB_TOP DUT (.HCLK(HCLK),.HRESETn(HRESETn),.INTERRUPT_FLAG(INTERRUPT_FLAG),.ERROR_FLAG(ERROR_FLAG),.READY_FLAG(READY_FLAG));

initial
 begin
  HCLK=0;
  READY_FLAG=1;
  ERROR_FLAG=0;
  INTERRUPT_FLAG=0;
  for (int i=0;i<256;i++)
     begin
	DUT.slave1.DATA_MEM[i]=$random;
	DUT.slave2.DATA_MEM[i]=$random;
	DUT.slave3.DATA_MEM[i]=$random;    
     end
  forever #(T_period/2) HCLK=~HCLK;
 end
 


initial
 begin
  HRESETn=0;
  @(negedge HCLK)
  HRESETn=1;
  #(T_period*20);
  READY_FLAG=0;
  #(T_period*3)
  READY_FLAG=1;
  #(T_period*10);
 INTERRUPT_FLAG=1;
  #(T_period*4);
INTERRUPT_FLAG=0;
 #(T_period*33)
 $stop;
 end

endmodule


