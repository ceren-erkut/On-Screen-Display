`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    13:45:30 01/18/2017
// Design Name:
// Module Name:    frame_grabber_camlink_signals
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module file_frame_grabber #(
	parameter int WIDTH=640,
    parameter int HEIGHT=512,
    parameter int BPP=12,
	parameter string OUTPUT_PATH = "output/",
	parameter SCALETO8BIT = 1,
	parameter COLORED = 0,
	parameter DATA_WIDTH = COLORED ? 24 : BPP
	)(
	input rstb,
	input pix_clk,
	input fval,
	input lval,
	input dval,
	input [DATA_WIDTH-1:0] pix_data
    );


	localparam string FILE_PREFIX = "img";
	localparam string FILE_EXT = COLORED ? ".ppm" : ".pgm";
	localparam GRAYSCALE_BPP = SCALETO8BIT ? 8 : BPP;
	localparam COLORED_BPP = 8;
	localparam ACT_BPP = COLORED ? COLORED_BPP : GRAYSCALE_BPP;


	string width;
	string height;
	string max_val;

	string HDR0;
	string HDR1;
	string HDR2;

	// States
	parameter IDLE		= 0;
	parameter FILEOPEN	= 1;
	parameter NFRAME	= 2;
	parameter NLINE		= 3;
	parameter COLL		= 4;
	parameter HOLD		= 5;


	// State variables
	reg[2:0] state;
	reg[2:0] next_state;


	reg[DATA_WIDTH-1:0] frame[0:HEIGHT-1][0:WIDTH-1];


	reg[15:0] lineCntr;
	reg[15:0] pixCntr;
	reg[1:0] dval_sync;

	reg [7:0] msb;
	reg [7:0] lsb;
	reg [(BPP+8)-1:0] data;

	// File descriptor
	integer file;
	byte frame_no;
	integer i, j;
	/*reg[40*8:0]*/ string output_path;


	always @(*) begin
		case(state)
			IDLE:			next_state = FILEOPEN;
			FILEOPEN:		next_state = NFRAME;
			NFRAME:			next_state = fval ? NLINE : NFRAME;
			NLINE:			next_state = dval ? COLL : (fval ? NLINE : NFRAME);
			COLL:			next_state = dval ? COLL : HOLD;
			HOLD:			next_state = !lval ? NLINE : (dval ? COLL : HOLD);
		endcase
	end

	always @(posedge pix_clk or negedge rstb) begin
		if(!rstb) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end


	always @(posedge pix_clk or negedge rstb) begin
		if(!rstb) begin
			i <= 0;
			j <= 0;
			file <= 0;
			lineCntr <= 0;
			pixCntr <= 0;
			dval_sync <= 2'b00;
			frame_no <= 0;

			msb <=0;
			lsb <= 0;

			data <= 0;

			//output_path = 321'd0;
			for(i=0; i<HEIGHT; i=i+1) begin
				for(j=0; j<WIDTH; j=j+1) begin
					frame[i][j] = 0;
				end
			end
		end else begin
			dval_sync <= {dval_sync[0], dval};
			case (state)
				FILEOPEN: begin
					lineCntr <= 0;
					pixCntr <= 0;

				end

				NFRAME: begin


				end

				NLINE: begin
					if(!fval) begin
						// Frame finished. Write to file
						width.itoa(WIDTH);
						height.itoa(HEIGHT);
						max_val.itoa((2**ACT_BPP) - 1);

						HDR0 = COLORED ? "P6\n" : "P5\n";
						HDR1 = {width, " ", height, "\n"};
						HDR2 = {max_val, "\n"};
						output_path = {OUTPUT_PATH, FILE_PREFIX, string'(frame_no + 48), FILE_EXT};
						file = $fopen (output_path,  "wb");
						$fwrite(file, "%s", HDR0);
						$fwrite(file, "%s", HDR1);
						$fwrite(file, "%s", HDR2);

						for(i=0; i<HEIGHT; i=i+1) begin
							for(j=0; j<WIDTH; j=j+1) begin
								if(COLORED) begin
									$fwriteb(file, "%c", frame[i][j][23:16]);
									$fwriteb(file, "%c", frame[i][j][15:8]);
									$fwriteb(file, "%c", frame[i][j][7:0]);
								end else begin
									if(SCALETO8BIT) begin
										data = frame[i][j][BPP-1:0] >> (BPP-8);
										$fwriteb(file, "%c", data[7:0]);
									end else begin
										if(BPP>8) begin
											$fwriteb(file, "%c", {4'h0, frame[i][j][BPP-1:8]});
											$fwriteb(file, "%c", frame[i][j][7:0]);
										end else begin
											$fwriteb(file, "%c", frame[i][j][7:0]);
										end
									end
								end
							end
						end
						frame_no = frame_no +  1;
						lineCntr = 0;
						$fclose(file);
					end else if(dval) begin
						frame[lineCntr][pixCntr] <= pix_data;
						pixCntr <= pixCntr + 1;
					end
				end

				COLL: begin
					if(dval) begin
						frame[lineCntr][pixCntr] <= pix_data;
						pixCntr <= pixCntr + 1;
					end
				end

				HOLD: begin
					if(!lval) begin
						lineCntr <= lineCntr + 1;
						pixCntr <= 0;
					end else if(dval) begin
						frame[lineCntr][pixCntr] <= pix_data;
						pixCntr <= pixCntr + 1;
					end
				end


			endcase
		end
	end

endmodule
