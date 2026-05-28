// Adder with "width" sized i/p

module adder #(parameter width=32)(
	input   [width-1:0] d0, d1,
	output  [width-1:0] sum
	);
	
	assign sum = d0 + d1;
	
endmodule 