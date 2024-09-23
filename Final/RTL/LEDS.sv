import slave_package::*;
module slave_2(	    input HCLK,HRESETn,
		    input HSEL,
                    output reg HREADY,
                    input  HSIZE_E HSIZE,
                    input  [31:0] HWDATA,
		    output reg [7:0] LEDS);
localparam tcount=32'd10,tcount_2=32'd20,tcount_3=32'd30,tcount_4=32'd40;
reg [28:0] counter;
reg [31:0] HWDATA_REG;
reg HSEL_reg;
always@(posedge HCLK or negedge HRESETn)
begin
	if(!HRESETn)
	begin
		counter<='d0;
		LEDS<='d0;
		HREADY<=1;
		HSEL_reg<=0;
		HWDATA_REG<=0;
	end
	else if(HSEL)
		begin
		HSEL_reg<=HSEL;
		HWDATA_REG<=HWDATA;
                counter<='d0;
		end
	else if(HSEL_reg)
	begin
	case(HSIZE)
	 	BYTE:
		begin
		if(counter == tcount)
		begin
			LEDS <= HWDATA[7:0];
			counter <=0;
			HREADY<=1;
			HSEL_reg<=0;
		end
		else
			begin
			counter <= counter + 'd1;
			HREADY<=0;
			end
		end
	 	HALF_WORD:
		begin
		if(counter == tcount_2)
		begin
			LEDS <= HWDATA[15:8];
			counter <= 0;
			HREADY<=1;
			HSEL_reg<=0;
		end
		else if(counter == tcount)
		begin
			LEDS <= HWDATA[7:0];
			counter <= counter + 'd1;
			HREADY<=0;
		end
		else begin
			counter <= counter + 'd1;
			HREADY<=0;
			end
		end
	 	WORD:
		begin
		if(counter == tcount_4)
		begin
			LEDS <= HWDATA[31:24];
			counter <= 0;
			HREADY<=1;
			HSEL_reg<=0;
		end
		else if(counter == tcount_3)
		begin
			LEDS <= HWDATA[23:16];
			counter <= counter + 'd1;
			HREADY<=0;
		end
		else if(counter == tcount_2)
		begin
			LEDS <= HWDATA[15:8];
			counter <= counter + 'd1;
			HREADY<=0;
		end
		else if(counter == tcount)
		begin
			LEDS <= HWDATA[7:0];
			counter <= counter + 'd1;
			HREADY<=0;
		end
		else begin
			counter <= counter + 'd1;
			HREADY<=0;
			end
		end
	endcase
	end

end 
endmodule
