import master_package::*;

module MASTER_TOP ( input HCLK,HRESETn,
                    input HREADY,INTERRUPT_FLAG,
		    input HRESP_E HRESP,
                    input [31:0] HRDATA,
                    output  HWRITE,
                    output  HSIZE_E HSIZE,
		    output HBURST_E HBURST,
                    output  HTRANS_E HTRANS,
                    output  [31:0] HADDR,
                    output  [31:0] HWDATA
                    );
wire [7:0] ADDR_REG;
wire [31:0] ADDR_INPUT_REG;                    
AHB_Master master_control ( .HCLK(HCLK),             .HRESETn(HRESETn), .INTERRUPT_FLAG(INTERRUPT_FLAG),
                            .HREADY(HREADY),         .HRESP(HRESP), .START(START),
                            .ADDR_INPUT(ADDR_INPUT_REG), .HWRITE(HWRITE),
                            .HSIZE(HSIZE),           .HBURST(HBURST),
                            .HTRANS(HTRANS),         .ADDR_REG(ADDR_REG),
                            .HADDR(HADDR),           .stall_flag(stall_flag)
                            );
                            
REG_FILE  REGFILE ( .HCLK(HCLK),             .HRESETn(HRESETn),
                    .HWRITE(HWRITE),         .HSIZE(HSIZE),  
                    .A1(ADDR_REG),           .WD3(HRDATA),
                    .RD1(HWDATA),            .HREADY(HREADY), .INTERRUPT_FLAG(INTERRUPT_FLAG)      
                    );
                    
instr_reg INSTR( .HCLK(HCLK),             .HRESETn(HRESETn),    .stall_flag(stall_flag),.HREADY(HREADY), .INTERRUPT_FLAG(INTERRUPT_FLAG),
                 .ADDR_INPUT_REG(ADDR_INPUT_REG), .START(START)  
                  );                    
                
endmodule
