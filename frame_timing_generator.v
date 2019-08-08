

module frame_timing_generator #(
    parameter FPS=25,
    parameter CLK_PERIOD=40,
    parameter WIDTH=640,
    parameter HEIGHT=480,
    parameter T_IDLE2FVAL = 8192,
    parameter T_LVALHIGH_DVALHIGH = 16,
    parameter T_DVALLOW_LVALLOW = 16,
    parameter T_LVALLOW = 16

)(
		input clk,
		input rstb,

		input en,
		output reg fval,
		output reg lval,
		output reg dval,

        output reg [$clog2(WIDTH):0] pix,
        output reg [$clog2(HEIGHT):0] line
    );




	parameter IDLE=0;
	parameter READFILE=1;
	parameter NFRAME=2;
	parameter NLINE=3;
	parameter PIXELS=4;
	parameter EOL=5;
	parameter EOF=6;


	reg [2:0] state;
	reg [15:0] cntr;




    parameter FRAME_LEN_IN_CYCLE = 1000000000/(FPS * CLK_PERIOD);
    reg[$clog2(FRAME_LEN_IN_CYCLE) : 0] frame_counter;



	 always @(posedge clk or negedge rstb) begin
		if(!rstb) begin
			fval <= 0;
			lval <= 0;
			dval <= 0;
			cntr <= 0;
			pix <= 0;
            line <= 0;
			frame_counter <= 0;

			state <= IDLE;
		end else begin
			case(state)
				IDLE: begin
                    fval <= 0;
				    frame_counter <= 0;
					state <= en ? NFRAME : IDLE;
					cntr <= 0;
				end

				NFRAME: begin
				    frame_counter <= frame_counter + 1;
                    pix <= 0;
                    line <= 0;
					if(cntr<T_IDLE2FVAL)
						cntr <= cntr + 1;
					else begin
						fval <= 1'b1;
						cntr <= 0;
						state <= NLINE;
					end
				end

				NLINE: begin
				    frame_counter <= frame_counter + 1;
					if(cntr<T_LVALLOW)
						cntr <= cntr + 1;
					else begin
						lval <= 1'b1;
						cntr <= 0;
						pix <= 0;
						state <= PIXELS;
					end
				end

				PIXELS: begin
				    frame_counter <= frame_counter + 1;
                    if(cntr == T_LVALHIGH_DVALHIGH) begin
					   if(pix == (WIDTH - 1)) begin
							pix <= 0;
							cntr <= 0;
							if(pix ==(WIDTH - 1)) begin
                                dval <= 0;
								state <= EOL;
							end else begin
								state <= PIXELS;
                            end
						end else begin
                            dval <= 1'b1;
                            pix <= pix + dval;
						end
					end else begin
                        dval <= 1'b0;
                        cntr <= cntr + 1;
					end
				end

				EOL: begin
				    frame_counter <= frame_counter + 1;
					if(cntr == T_DVALLOW_LVALLOW) begin
                        lval <= 0;
                        cntr <= 0;
						if(line == HEIGHT - 1) begin
							state <= EOF;
						end else begin
							state <= NLINE;
							line <= line + 1;
						end
					end else begin
						cntr <= cntr + 1;
					end
				end

				EOF: begin
					fval <= 1'b0;
					frame_counter <= frame_counter + 1;
					if((cntr == 15)) begin
                        if(frame_counter == FRAME_LEN_IN_CYCLE) begin
                            cntr <= 0;
                            state <= IDLE;
                        end
					end else begin
						cntr <= cntr + 1;
					end
				end
			endcase
		end
	 end

endmodule
