import slave_package::*;
module slave_2_tb;
reg HCLK;
reg HRESETn;
reg HSEL;
wire HREADY;
HSIZE_E HSIZE;
reg [31:0] HWDATA;
wire [7:0] LEDS;

slave_2 DUT ( 
      .HRESETn (HRESETn ) ,
      .HCLK (HCLK ) ,
      .HREADY (HREADY ) ,
      .HWDATA (HWDATA ) ,
      .HSIZE (HSIZE ) ,
      .HSEL(HSEL),
      .LEDS(LEDS));
parameter T_period =10;
parameter tcounttb=32'd10;
initial 
begin
HCLK=0;
HSEL=0;
HSIZE=WORD;
forever #(T_period/2) HCLK=~HCLK;
end 

initial
begin
HRESETn=0;
@(negedge HCLK)
HRESETn=1;
HSIZE=WORD;
HWDATA=32'hDEADBEEF;
HSEL=1;
@(negedge HCLK)
HSEL=0;
#(T_period*tcounttb*5)
@(negedge HCLK)
HSIZE=HALF_WORD;
HWDATA=32'hFEDCBA98;
HSEL=1;
@(negedge HCLK)
HSEL=0;
#(T_period*tcounttb*5)
$stop;
end
endmodule
