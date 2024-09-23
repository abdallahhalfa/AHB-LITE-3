import master_package::*;
module REG_FILE  (
    //input
    input wire          HCLK      ,
    input wire          HRESETn      ,
    input wire          HWRITE      ,
    input HSIZE_E    HSIZE,
    input wire [7:0]    A1       ,     
    input wire [31:0]   WD3      ,
    input wire HREADY,INTERRUPT_FLAG,
    //output    
    output  reg [31:0]   RD1      
);
//localparam BYTE = 3'b000 , HALF_WORD = 3'b001 , WORD = 3'b010;   
reg [7:0]  Mem_Reg  [255:0]      ;
integer i;
reg HREADY_REG,HWRITE_REG,INTERRUPT_FLAG_REG;
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn)
	begin
		for(i=0 ; i<256 ; i=i+1)
		begin
			Mem_Reg[i]<=8'd0;
		end
		for(i=0;i<50;i=i+1)
			Mem_Reg[i]<=$random;
	end
    else
    begin
        if (!HWRITE&&HREADY_REG&&!INTERRUPT_FLAG_REG)
          begin
            case(HSIZE)
              BYTE:
                begin
                  Mem_Reg[A1] <= WD3[7:0] ;
                end
              HALF_WORD:
                begin
                  {Mem_Reg[A1+1],Mem_Reg[A1]} <= WD3[15:0] ;
                end
              WORD:
                begin
                  {Mem_Reg[A1+3],Mem_Reg[A1+2],Mem_Reg[A1+1],Mem_Reg[A1]} <= WD3 ;
                end
              default:
                begin
                  Mem_Reg[A1]<=32'b0;  
                end
            endcase
          end
          
        else if(HWRITE&&HREADY_REG&&!INTERRUPT_FLAG_REG)
          begin
            case(HSIZE)
              BYTE:
                begin
                  RD1 <= {{24{1'b0}},Mem_Reg[A1]};
                end
              HALF_WORD:
                begin
                  RD1 <= {{16{1'b0}},Mem_Reg[A1+1],Mem_Reg[A1]};
                end
              WORD:
                begin
                  RD1 <= {Mem_Reg[A1+3],Mem_Reg[A1+2],Mem_Reg[A1+1],Mem_Reg[A1]};
                end
              default:
                begin
                  RD1<=32'b0;  
                end
            endcase
          end
	end
end
always@(posedge HCLK or negedge HRESETn)
  begin
    if(!HRESETn)
	begin
      HREADY_REG<=1;
      INTERRUPT_FLAG_REG<=0;
      //HWRITE_REG<=1;
	end
    else
	begin
      HREADY_REG<=HREADY;
      INTERRUPT_FLAG_REG<=INTERRUPT_FLAG;
      //HWRITE_REG<=HWRITE;
	end
  end
endmodule


    


