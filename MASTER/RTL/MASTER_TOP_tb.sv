import master_package::*;
module MASTER_TOP_tb  ; 
  typedef enum {BURST_SINGLE_BYTE,BURST_SINGLE_HALF_WORD,BURST_SINGLE_WORD,BURST_INCR_BYTE,BURST_INCR_HALF_WORD,BURST_INCR_WORD}opcode_e;
  opcode_e opcode;
  HTRANS_E  HTRANS   ; 
  reg    HRESETn   ; 
  reg    HCLK   ;  
  wire   HWRITE   ; 
  reg  [31:0]  HRDATA   ; 
  reg    HREADY   ; 
  HBURST_E  HBURST   ; 
  wire  [31:0]  HWDATA   ; 
  HRESP_E    HRESP   ; 
  HSIZE_E  HSIZE   ; 
  wire  [31:0]  HADDR   ; 
  reg INTERRUPT_FLAG;
  MASTER_TOP  
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
      .INTERRUPT_FLAG(INTERRUPT_FLAG)); 
parameter T_period = 10;
//localparam OKAY = 1'b1, ERROR = 1'b0;
initial
begin
forever
@(posedge HCLK)opcode=opcode_e'(DUT.master_control.ADDR_INPUT[31:26]);
end
initial 
  begin
    HCLK=0;
    HREADY = 1;
    INTERRUPT_FLAG=0;
    HRDATA = 32'hda1a3ead;
    HRESP = OKAY;
    forever #(T_period/2) HCLK=~HCLK;  
  end

initial
  begin
    HRESETn = 0;
    //ADDR_INPUT = 32'h0D00_000A;// BURST_INCR_BYTE with 8 incr steps
    @(negedge HCLK)
    HRESETn = 1;
        /*@(negedge HCLK);
        HRDATA=32'h76BF_02EA;
        @(negedge HCLK);
        HRDATA=32'hDC62_8019;
        @(negedge HCLK);
        HRDATA=32'hABCD_EF07;*/
	repeat(5)
      begin
        @(negedge HCLK);
      end
   INTERRUPT_FLAG=1;
        repeat(2)
      begin
        @(negedge HCLK);
      end
   INTERRUPT_FLAG=0;
    repeat(6)
      begin
        @(negedge HCLK);
      end
   HREADY=0;
    repeat(5)
      begin
        @(negedge HCLK);
      end
    HREADY=1;
    #(T_period*80);
    $stop;
  end
endmodule


