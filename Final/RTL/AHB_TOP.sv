import master_package::*;
module AHB_TOP ( input HCLK,HRESETn,INTERRUPT_FLAG,ERROR_FLAG,READY_FLAG
		);

reg [3:0] HSEL_flag,HSEL_flag_reg;
reg [31:0] HADDR,HWDATA;
reg [31:0] HRDATA1,HRDATA2,HRDATA3,HRDATA;
reg HREADY1,HREADY2,HREADY3,HREADY;
HRESP_E HRESP1,HRESP2,HRESP3,HRESP;
HSIZE_E HSIZE;
HBURST_E HBURST;
HTRANS_E HTRANS;

MASTER_TOP MASTER ( .HCLK(HCLK),.HRESETn(HRESETn),
                    .INTERRUPT_FLAG(INTERRUPT_FLAG),
		    .HREADY(HREADY),.HRESP(HRESP),
                    .HRDATA(HRDATA),.HWRITE(HWRITE),.HSIZE(HSIZE),
		    .HBURST(HBURST),.HTRANS(HTRANS),
                    .HADDR(HADDR),.HWDATA(HWDATA));

always@(*)
begin
 HSEL_flag=0;
 case(HADDR[19:8])
  12'h000:
    begin
     HSEL_flag[0]=1;
    end
  12'h001:
    begin
     HSEL_flag[1]=1;
    end
  12'h002:
    begin
     HSEL_flag[2]=1;
    end
  default:
    begin
     HSEL_flag[3]=1;
    end
 endcase
end
always@(posedge HCLK, negedge HRESETn)
 begin
  if(!HRESETn)
   begin
    HSEL_flag_reg<=0;
   end
  else
   begin
    HSEL_flag_reg<=HSEL_flag;
   end
 end

always@(*)
 begin
  if(!HRESETn)
   begin
    HRDATA=0;
    HREADY=1;
    HRESP=OKAY;
   end
  else
   begin
    case(HSEL_flag_reg)
     4'b0001:
      begin
       HRDATA=HRDATA1;
       HREADY=HREADY1;
       HRESP=HRESP1;     
      end
     4'b0010:
      begin
       HRDATA=HRDATA2;
       HREADY=HREADY2;
       HRESP=HRESP2;      
      end
     4'b0100:
      begin
       HRDATA=HRDATA3;
       HREADY=HREADY3;
       HRESP=HRESP3;      
      end
     4'b1000:
      begin
       HRDATA=0;
       HREADY=1;
       HRESP=(HTRANS == IDLE || HTRANS == BUSY)? OKAY:ERROR;     
      end
     default:
      begin
       HRDATA=0;
       HREADY=1;
       HRESP=(HTRANS == IDLE || HTRANS == BUSY)? OKAY:ERROR;      
      end
    endcase
   end
 end

slave_1  slave1 (  .HCLK(HCLK),.HRESETn(HRESETn),
		   .ERROR_FLAG(ERROR_FLAG),.READY_FLAG(READY_FLAG),.HSEL(HSEL_flag[0]),
                   .HREADY(HREADY1),.HRESP(HRESP1),
                   .HRDATA(HRDATA1),.HWRITE(HWRITE),.HSIZE(HSIZE),
		   .HBURST(HBURST),.HTRANS(HTRANS),
                   .HADDR(HADDR),.HWDATA(HWDATA));

slave_1  slave2 (  .HCLK(HCLK),.HRESETn(HRESETn),
		   .ERROR_FLAG(ERROR_FLAG),.READY_FLAG(READY_FLAG),.HSEL(HSEL_flag[1]),
                   .HREADY(HREADY2),.HRESP(HRESP2),
                   .HRDATA(HRDATA2),.HWRITE(HWRITE),.HSIZE(HSIZE),
		   .HBURST(HBURST),.HTRANS(HTRANS),
                   .HADDR(HADDR),.HWDATA(HWDATA));

slave_1  slave3 (  .HCLK(HCLK),.HRESETn(HRESETn),
		   .ERROR_FLAG(ERROR_FLAG),.READY_FLAG(READY_FLAG),.HSEL(HSEL_flag[2]),
                   .HREADY(HREADY3),.HRESP(HRESP3),
                   .HRDATA(HRDATA3),.HWRITE(HWRITE),.HSIZE(HSIZE),
		   .HBURST(HBURST),.HTRANS(HTRANS),
                   .HADDR(HADDR),.HWDATA(HWDATA));



endmodule