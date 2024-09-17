import slave_package::*;
module slave_1_tb  ; 
  HTRANS_E  HTRANS   ; 
  reg    HRESETn   ; 
  reg    HCLK   ;  
  reg   HWRITE   ; 
  wire  [31:0]  HRDATA   ; 
  wire    HREADY   ; 
  HBURST_E  HBURST   ; 
  reg  [31:0]  HWDATA   ; 
  HRESP_E    HRESP   ; 
  HSIZE_E  HSIZE   ; 
  reg  [31:0]  HADDR   ; 
  reg ERROR_FLAG;
  reg READY_FLAG;
  reg HSEL;
  slave_1  
   DUT  ( 
       .HTRANS (HTRANS ) ,
      .HRESETn (HRESETn ) ,
      .HCLK (HCLK ) ,
      .HWRITE (HWRITE ) ,
      .HRDATA (HRDATA ) ,
      .HREADY (HREADY ) ,
      .HBURST (HBURST ) ,
      .HWDATA (HWDATA ) ,
      .HRESP (HRESP ) ,
      .HSIZE (HSIZE ) ,
      .HADDR (HADDR ) ,
      .ERROR_FLAG(ERROR_FLAG),
      .READY_FLAG(READY_FLAG),
      .HSEL(HSEL)); 
parameter T_period = 10;

initial
 begin
  HCLK=0;
  READY_FLAG=1;
  ERROR_FLAG=0;
  HBURST = INCR;
  HSIZE = BYTE;
  HTRANS = IDLE;
  HWRITE = 1;
  HSEL=1;
  for (int i=0;i<256;i++)
	DUT.DATA_MEM[i]=$random;
  forever #(T_period/2) HCLK=~HCLK;
 end

initial
 begin
  HRESETn=0;
  @(negedge HCLK);
  HRESETn = 1;
  //READY_FLAG = $random;
  //ERROR_FLAG = $random;
  repeat(50)begin
  HWRITE = $random;
  HWDATA = $random;
  HADDR = $random;

  std::randomize(HSIZE) with { HSIZE inside {BYTE, HALF_WORD, WORD}; };
  std::randomize(HTRANS) with { HTRANS inside {IDLE, BUSY, NONSEQ,SEQ}; };
  @(negedge HCLK);
  end
  $stop;
 end 
endmodule



