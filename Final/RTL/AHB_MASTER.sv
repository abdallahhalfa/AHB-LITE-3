import master_package::*;

module AHB_Master ( input HCLK,HRESETn,
                    input HREADY,INTERRUPT_FLAG,
		    input HRESP_E HRESP,
                    input [31:0] ADDR_INPUT,
                    input START,
                    output reg stall_flag,
                    //input [31:0] HRDATA,
                    output HWRITE,
                    output HSIZE_E HSIZE,
		    output HBURST_E HBURST,
                    output HTRANS_E HTRANS,
                    output reg [7:0] ADDR_REG,
                    output  [31:0] HADDR
                    );
                    
//localparam IDLE = 2'b00,BUSY = 2'b01, NONSEQ = 2'b10, SEQ = 2'b11;
//localparam SINGLE = 3'b000, INCR = 3'b001;
//localparam OKAY = 1'b1, ERROR = 1'b0;
//localparam BYTE = 3'b000 , HALF_WORD = 3'b001 , WORD = 3'b010;
localparam BURST_SINGLE_BYTE=6'b000000, BURST_SINGLE_HALF_WORD=6'b000001, BURST_SINGLE_WORD=6'b000010, BURST_INCR_BYTE=6'b000011, BURST_INCR_HALF_WORD=6'b000100, BURST_INCR_WORD=6'b000101;                
reg SINGLE_FLAG;
HBURST_E HBURST_comp;
HSIZE_E HSIZE_comp;
reg HWRITE_comp;
HTRANS_E HTRANS_comp;
reg HWRITE_REG;

reg [23:0]ADDR_FIRST;
reg [31:0] HADDR_REG;
reg [7:0] ADDR_REG_comp;
reg [7:0] ADDR_INPUT_REG_comp;
reg [7:0]  COUNTER_BYTE,COUNTER_BYTE_comp;
reg [7:0]  COUNTER_HALF,COUNTER_HALF_comp;
reg [7:0]  COUNTER_WORD,COUNTER_WORD_comp;
always@(posedge HCLK, negedge HRESETn)
   begin
      if(!HRESETn)
        begin
          HTRANS <= IDLE;
          HBURST <= SINGLE;
          HWRITE_REG <= 1;
	  //HWRITE<=1;
          HSIZE  <= WORD;
          ADDR_REG <= 0;
          HADDR_REG <= 0;//////////
          COUNTER_BYTE<=0;
          COUNTER_HALF<=0;
          COUNTER_WORD<=0;
	  ADDR_FIRST<=0;
        end
      else if(!INTERRUPT_FLAG&&HREADY && HRESP == OKAY)
        begin
          HBURST   <= HBURST_comp;
          HSIZE    <= HSIZE_comp;
          HTRANS   <= HTRANS_comp;
          HWRITE_REG   <= ADDR_FIRST[17];
	  //HWRITE<=HWRITE_REG;
          ADDR_REG <= (START)? ADDR_INPUT[7:0]:((SINGLE_FLAG)? ADDR_INPUT[7:0]:HADDR_REG[7:0]);
	  ADDR_FIRST <= ADDR_INPUT[31:8];
          HADDR_REG    <= {ADDR_INPUT[31:8],ADDR_INPUT_REG_comp};/////////////
          COUNTER_BYTE  <= COUNTER_BYTE_comp;
          COUNTER_HALF<=COUNTER_HALF_comp;
          COUNTER_WORD<=COUNTER_WORD_comp;
        end
      else if(INTERRUPT_FLAG)
        begin
          ADDR_REG <= (SINGLE_FLAG)? ADDR_INPUT[7:0]:HADDR_REG[7:0];
	  ADDR_FIRST <= ADDR_INPUT[31:8];
	  HBURST   <= HBURST_comp;
          HSIZE    <= HSIZE_comp;
          HTRANS   <= BUSY;
	  HWRITE_REG   <= ADDR_FIRST[17];
	  //HWRITE<=HWRITE_REG;
        end
      else
        begin
          ADDR_REG <= (SINGLE_FLAG)? ADDR_INPUT[7:0]:HADDR_REG[7:0];
	  ADDR_FIRST <= ADDR_INPUT[31:8];
	  HBURST   <= HBURST_comp;
          HSIZE    <= HSIZE_comp;
          HTRANS   <= HTRANS_comp;
	  HWRITE_REG   <= ADDR_FIRST[17];
	  //HWRITE<=HWRITE_REG;
        end
   end
   
always@(*)
  begin
    SINGLE_FLAG=0;
    stall_flag = 0;
    ADDR_INPUT_REG_comp = 0;
    HBURST_comp = SINGLE;
    HSIZE_comp =  WORD;
    HTRANS_comp = IDLE;
    HWRITE_comp = 1;
    COUNTER_BYTE_comp=0;
    COUNTER_HALF_comp=0;
    COUNTER_WORD_comp=0;
    case(ADDR_INPUT[31:26])
      BURST_SINGLE_BYTE:
        begin
              HBURST_comp = SINGLE;
              HSIZE_comp =  BYTE;
              HTRANS_comp = NONSEQ;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = ADDR_INPUT[7:0] + 1;
              SINGLE_FLAG=1;
        end
      BURST_SINGLE_HALF_WORD:
        begin
              HBURST_comp = SINGLE;
              HSIZE_comp =  HALF_WORD;
              HTRANS_comp = NONSEQ;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = ADDR_INPUT[7:0] + 2;
              SINGLE_FLAG=1;
        end
      BURST_SINGLE_WORD:
        begin
              HBURST_comp = SINGLE;
              HSIZE_comp =  WORD;
              HTRANS_comp = NONSEQ;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = ADDR_INPUT[7:0] + 4;
              SINGLE_FLAG=1;
        end
      BURST_INCR_BYTE:
        begin
          if(!COUNTER_BYTE)
            begin
              HBURST_comp = INCR;
              HSIZE_comp =  BYTE;
              HTRANS_comp = NONSEQ;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = ADDR_INPUT[7:0] + 1;
              COUNTER_BYTE_comp = COUNTER_BYTE +1;
              stall_flag = 1;
            end
          else if(COUNTER_BYTE!=HADDR_REG[24:20])
            begin
              HBURST_comp = INCR;
             	HSIZE_comp =  BYTE;
              HTRANS_comp = SEQ;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = (HADDR_REG[7:0] + 1);
              COUNTER_BYTE_comp = (COUNTER_BYTE == HADDR_REG[24:20]-1)? 0:(COUNTER_BYTE +1);
              stall_flag =!(COUNTER_BYTE == HADDR_REG[24:20]-1);
              
            end
          else
            begin
              HBURST_comp = INCR;
             	HSIZE_comp =  BYTE;
              HTRANS_comp = IDLE;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = HADDR_REG[7:0];
              COUNTER_BYTE_comp = 0;
            end
        end
      BURST_INCR_HALF_WORD:
        begin
          if(!COUNTER_HALF)
            begin
              HBURST_comp = INCR;
              HSIZE_comp =  HALF_WORD;
              HTRANS_comp = NONSEQ;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = ADDR_INPUT[7:0] + 2;
              COUNTER_HALF_comp = COUNTER_HALF +1;
              stall_flag = 1;
            end
          else if(COUNTER_HALF!=HADDR_REG[24:20])
            begin
              HBURST_comp = INCR;
             	HSIZE_comp =  HALF_WORD;
              HTRANS_comp = SEQ;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = (HADDR_REG[7:0] + 2);
              COUNTER_HALF_comp = (COUNTER_HALF == HADDR_REG[24:20]-1)? 0:COUNTER_HALF +1;
              stall_flag =!(COUNTER_HALF == HADDR_REG[24:20]-1);
            end
          else
            begin
              HBURST_comp = INCR;
             	HSIZE_comp =  HALF_WORD;
              HTRANS_comp = IDLE;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = HADDR_REG[7:0];
              COUNTER_HALF_comp = 0;
            end
        end
      BURST_INCR_WORD:
        begin
          if(!COUNTER_WORD)
            begin
              HBURST_comp = INCR;
              HSIZE_comp =  WORD;
              HTRANS_comp = NONSEQ;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = ADDR_INPUT[7:0] + 4;
              COUNTER_WORD_comp = COUNTER_WORD +1;
              stall_flag = 1;
            end
          else if(COUNTER_WORD!=HADDR_REG[24:20])
            begin
              HBURST_comp = INCR;
             	HSIZE_comp =  WORD;
              HTRANS_comp = SEQ;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = (HADDR_REG[7:0] + 4);
              COUNTER_WORD_comp = (COUNTER_WORD == HADDR_REG[24:20]-1)? 0:COUNTER_WORD +1;
              stall_flag =!(COUNTER_WORD == HADDR_REG[24:20]-1);
            end
          else
            begin
              HBURST_comp = INCR;
             	HSIZE_comp =  WORD;
              HTRANS_comp = IDLE;
              HWRITE_comp = 1;//read_en in reg file
              ADDR_INPUT_REG_comp = HADDR_REG[7:0];
              COUNTER_WORD_comp = 0;
            end
        end
      default:
        begin
          HTRANS_comp = IDLE;
          HBURST_comp = SINGLE;
          HWRITE_comp = 1;
          HSIZE_comp  = WORD;
          ADDR_INPUT_REG_comp = HADDR_REG[7:0];
          COUNTER_BYTE_comp=0;
          COUNTER_HALF_comp=0;
      	   COUNTER_WORD_comp=0;
        end
    endcase
  end
 assign  HADDR = {ADDR_FIRST,ADDR_REG}; 
assign HWRITE = ADDR_FIRST[17];
endmodule   
