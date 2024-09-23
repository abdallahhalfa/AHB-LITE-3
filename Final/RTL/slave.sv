import master_package::*;
module slave_1(	    input HCLK,HRESETn,
		    input ERROR_FLAG,READY_FLAG,HSEL,
                    output HREADY,
		    output HRESP_E HRESP,
                    output reg [31:0] HRDATA,
                    input  HWRITE,
                    input  HSIZE_E HSIZE,
		    input HBURST_E HBURST,
                    input  HTRANS_E HTRANS,
                    input  [31:0] HADDR,
                    input  [31:0] HWDATA);

reg [7:0] DATA_MEM [0:255];
reg HWRITE_REG,HSEL_REG;
reg [31:0] HADDR_REG,HWDATA_REG;
HSIZE_E HSIZE_REG;
HTRANS_E HTRANS_REG;
HBURST_E HBURST_REG;

always@(posedge HCLK, negedge HRESETn)
 begin
  if(!HRESETn)
   begin
    HWRITE_REG<=0;
    HSEL_REG<=0;
    HADDR_REG<=0;
    HWDATA_REG<=0;
    HSIZE_REG <=WORD;
    HTRANS_REG<=IDLE;
    HBURST_REG<=SINGLE; 
   end
  else
   begin
    HWRITE_REG<=HWRITE;
    HSEL_REG<=HSEL;
    HADDR_REG<=HADDR;
    HWDATA_REG<=HWDATA;
    HSIZE_REG <=HSIZE;
    HTRANS_REG<=HTRANS;
    HBURST_REG<=HBURST; 
   end
 end

always@(posedge HCLK, negedge HRESETn)
begin
 if(!HRESETn)
  begin
   HRDATA<=0;
  end
 else if(HSEL_REG && (HTRANS_REG == NONSEQ || HTRANS_REG == SEQ) && HWRITE_REG && !ERROR_FLAG && READY_FLAG)
  begin
   case(HSIZE_REG)
	BYTE:
	 begin
 	  DATA_MEM[HADDR_REG[7:0]]<=HWDATA[7:0];
         end
	HALF_WORD:
	 begin
 	  {DATA_MEM[HADDR_REG[7:0]+1],DATA_MEM[HADDR_REG[7:0]]}<=HWDATA[15:0];
         end
	WORD:
	 begin
 	  {DATA_MEM[HADDR_REG[7:0]+3],DATA_MEM[HADDR_REG[7:0]+2],DATA_MEM[HADDR_REG[7:0]+1],DATA_MEM[HADDR_REG[7:0]]}<=HWDATA;
         end
	default:
	 begin
 	  DATA_MEM[HADDR_REG[7:0]]<=0;
         end
   endcase
  end
 else if(HSEL && (HTRANS == NONSEQ || HTRANS == SEQ) && !HWRITE && !ERROR_FLAG && READY_FLAG)//////////////////////////removed the reg///////////////
  begin
   case(HSIZE)
	BYTE:
	 begin
 	  HRDATA<={{24{1'b0}},DATA_MEM[HADDR[7:0]]};
         end
	HALF_WORD:
	 begin
 	  HRDATA<={{16{1'b0}},DATA_MEM[HADDR[7:0]+1],DATA_MEM[HADDR[7:0]]};
         end
	WORD:
	 begin
 	  HRDATA<={DATA_MEM[HADDR[7:0]+3],DATA_MEM[HADDR[7:0]+2],DATA_MEM[HADDR[7:0]+1],DATA_MEM[HADDR[7:0]]};
         end
	default:
	 begin
 	  HRDATA<=0;
         end
   endcase
  end	   
end

assign HREADY = (!HRESETn)? 1:READY_FLAG;
assign HRESP = (!HRESETn)? OKAY: (ERROR_FLAG)? ERROR:OKAY;
endmodule