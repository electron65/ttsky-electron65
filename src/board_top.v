`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2026 06:30:15 PM
// Design Name: 
// Module Name: board_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module board_top(
    // input  wire [7:0] ui_in,    // Dedicated inputs
    // output wire [7:0] uo_out,   // Dedicated outputs
    // input  wire [7:0] uio_in,   // IOs: Input path
    // output wire [7:0] uio_out,  // IOs: Output path
    // output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    // input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    // input  wire       clk,      // clock
    // input  wire       rst_n     // reset_n - low to reset
    input               clk     ,
    input               nrst    ,
    input       [3:0]   button  ,
    output wire [5:0]   sec     ,
    output wire [5:0]   min     ,
    output wire [5:0]   hour    ,
    output wire         ctl_mode,
    output wire [1:0]   ctl_time
    );

  // All output pins must be assigned. If not used, assign to 0.
//   assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
//   assign uio_out = 0;
//   assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
//   wire _unused = &{ena, clk, rst_n, 1'b0};
    wire [3:0] deb_button;
    wire [3:0] lh_button;
    
    //DEBOUNCE INPUT BUTTON
    debounce U_DEB0(
        .clk (clk          ),
        .nrst(nrst         ),
        .x   (button[0]    ),
        .y   (deb_button[0])
    );

    debounce U_DEB1(
        .clk (clk          ),
        .nrst(nrst         ),
        .x   (button[1]    ),
        .y   (deb_button[1])
    );

    debounce U_DEB2(
        .clk (clk          ),
        .nrst(nrst         ),
        .x   (button[2]    ),
        .y   (deb_button[2])
    );

    debounce U_DEB3(
        .clk (clk          ),
        .nrst(nrst         ),
        .x   (button[3]    ),
        .y   (deb_button[3])
    );

    //EDGE DETECT
    positive_edge U_EDGE0(
        .clk (clk          ),
        .nrst(nrst         ),
        .x   (deb_button[0]),
        .y   (lh_button[0] )
    );

    positive_edge U_EDGE1(
        .clk (clk          ),
        .nrst(nrst         ),
        .x   (deb_button[1]),
        .y   (lh_button[1] )
    );

    positive_edge U_EDGE2(
        .clk (clk          ),
        .nrst(nrst         ),
        .x   (deb_button[2]),
        .y   (lh_button[2] )
    );

    positive_edge U_EDGE3(
        .clk (clk          ),
        .nrst(nrst         ),
        .x   (deb_button[3]),
        .y   (lh_button[3] )
    );

    //TOP MODULE OF CLOCK
    clock_top U1_CLOCK_TOP(
        .clk     (clk      ),
        .nrst    (nrst     ),
        .button  (lh_button),
        .sec     (sec      ),
        .min     (min      ),
        .hour    (hour     ),
        .ctl_mode(ctl_mode ),
        .ctl_time(ctl_time )
    );


endmodule

module positive_edge (
    input           clk     ,
    input           nrst    ,
    input           x       ,
    output wire     y       
);

reg x_1D;

    always @(posedge clk or negedge nrst) begin
        if(!nrst) begin
            x_1D    <= 1'b0;
        end
        else begin
            x_1D <= x; 
        end
    end

assign y = x & (~x_1D);

endmodule


module debounce #(
    parameter NUM_DEB = 12
)(
    input clk,
    input nrst,
    input x,
    output wire y
);

reg [NUM_DEB-1:0] DEB;

always @(posedge clk or negedge nrst) begin
    if(!nrst)
        DEB <= {NUM_DEB{x}};
    else
        DEB <= {DEB[NUM_DEB-2:0], x};
end

assign y = &DEB;

endmodule
