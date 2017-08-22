// Author: Jianfeng An
// 2016-8-15 20:43:05
// Original Data memory address: 0x0000~0x2fff
// Code memory address:0x3000~0x7eff
// UART address: 0x7F00~0x7FFF
// 0x7F00: send data, write only
// 0x7F04: received data, read only
// 0x7F08: send done flag - tx_done, read only
// 0x7F0C: recv done flag - rx_done, read only
// 0x7F10: send busy flag - tx_busy, read only
// 0x7F14: recv busy flag - rx_busy, read only

module DMUART(
  clk,
  rst,
  wea,
  addra,
  dina,
  douta,
  uart_rx,
  uart_tx
);

input clk, rst;
input [0 : 0] wea;
input [31 : 0] addra;
input [31 : 0] dina;
output [31 : 0] douta;
input   uart_rx;
output  uart_tx;

reg dm_wea, tx_wr;
reg [31 : 0] douta;
wire [31 : 0] dm_dout;
wire [7:0] rx_data;
wire tx_done, rx_done;
wire tx_busy, rx_busy;

always@(wea, addra)begin
	tx_wr=1'b0;
	dm_wea=1'b0;
	if (addra[15:8]=='h7F) begin
    if (addra[7:2]==0)
    	tx_wr=wea;
  end else
    dm_wea=wea;    
end

always@(dm_dout, rx_data, addra,tx_done,rx_done,tx_busy,rx_busy)begin
	douta=dm_dout;
	if (addra[15:8]=='h7F) begin
  	case (addra[4:2])
  		'b000: douta=0; // write only register
  		'b001: douta=rx_data;
  		'b010: douta=tx_done; // for interrupt only
  		'b011: douta=rx_done; // for interrupt only
  		'b100: douta=tx_busy; // check the bit by software
  		'b101: douta=rx_busy; // check the bit by software
  	endcase
  end
end

 DM U_DM ( 
      .addra(addra[9:2]), .dina(dina), .wea(dm_wea), 
      .clka(clk), .douta(dm_dout)
   );
   
 uart_transceiver UART(
	. sys_rst(rst),
	. sys_clk(clk),
	. uart_rx(uart_rx),
	. uart_tx(uart_tx),
	`ifdef MODEL_TECH
	. divisor(16'd2),   // Modelsim Simulation only!
  `else
	. divisor(16'd651), // 100000000/16/9600=651
	`endif

	. rx_data(rx_data),
	. rx_done(rx_done),
	. rx_busy(rx_busy),

	. tx_data(dina[7:0]),
	. tx_wr(tx_wr),
	. tx_done(tx_done),
	. tx_busy(tx_busy)
);  

endmodule