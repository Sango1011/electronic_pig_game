`timescale 1ns / 1ps

module pig(enable,clock,reset,en_roll,stop,sum,dice,point,state,turn);
	input enable,clock,reset,stop;
	input [3:0] dice;
	output reg en_roll;
	output reg [3:0] state, turn;
	output reg [15:0] point, sum;
	reg [2:0] next;
	reg SD,S_0,T,PT,T0,P0;
	
	parameter S0=3'b000, S1=3'b001, S2=3'b010, S3=3'b011, S4=3'b100, S5=3'b101;
	
	//next state logic
	always@(state,dice,turn,stop,enable)
    begin
		case(state)
			S0: if(enable) next=S1; else next=S0;
			S1: if(enable) next=S1; else next=S2;
			S2: if(dice==3'b001) next=S4;
				else next=S3;
			S3: if(enable) next=S1;
				else if (stop) next=S4;
				else next=S3;
			S4: if(enable) next=S1;
				else if (turn>3'b101) next=S5;
				else next=S4;
			S5: next=S5;
			default: next=S0;
		endcase
	end
	
	//reset logic
	always@(posedge clock or posedge reset)
	begin
		if (reset) state<=S0;
		else state<=next;
	end
	
	//control signal assertion
	always@(state,dice,turn,stop,enable)
	begin
		PT=1'b0; S_0=1'b0; SD=1'b0; T=1'b0; en_roll=1'b0; T0=1'b0; P0=1'b0;    //setting defaults
		case(state)
			S0: begin  //clear all registers
			     PT=1'b0; S_0=1'b1; SD=1'b0; T=1'b0; en_roll=1'b0; T0=1'b1; P0=1'b1; end			
			S1: begin  //enable dice rolling module
			     PT=1'b0; S_0=1'b0; SD=1'b0; T=1'b0; en_roll=1'b1; T0=1'b0; P0=1'b0; end
			S2: if (dice==3'b1) begin //add the dice value to the sum
			     PT=1'b0; S_0=1'b0; SD=1'b0; T=1'b1; en_roll=1'b0; T0=1'b0; P0=1'b0; end
			    else begin PT=1'b0; S_0=1'b0; SD=1'b1; T=1'b0; en_roll=1'b0; T0=1'b0; P0=1'b0; end
			S3: if (stop) begin //add the sum to the points, increment the turn
			     PT=1'b1; S_0=1'b0; SD=1'b0; T=1'b1; en_roll=1'b0; T0=1'b0; P0=1'b0; end     
			    else begin PT=1'b0; S_0=1'b0; SD=1'b0; T=1'b0; en_roll=1'b0; T0=1'b0; P0=1'b0; end
			S4: if (enable) begin //clear the sum
			     PT=1'b0; S_0=1'b1; SD=1'b0; T=1'b0; en_roll=1'b0; T0=1'b0; P0=1'b0; end
			    else begin PT=1'b0; S_0=1'b0; SD=1'b0; T=1'b0; en_roll=1'b0; T0=1'b0; P0=1'b0; end
		endcase
	end
	
	//Sum register
	always@(posedge clock or posedge reset)
	begin
		if (reset) sum<=16'b0;
		else if (S_0) sum<=16'b0;
		else if (SD) sum<=sum+dice;
		else sum<=sum;
	end
	
	//Point register
	always@(posedge clock or posedge reset)
	begin
		if (reset) point<=16'b0;
		else if (PT) point<=point+sum;
		else if (P0) point<=16'b0;
		else point<=point;
	end

	//turn counter
	always@(posedge clock or posedge reset)
	begin
		if (reset) turn<=3'b001;
		else if (T) turn<=turn+1'b1;
		else if (T0) turn<=3'b1;
		else turn<=turn;
	end
	
endmodule