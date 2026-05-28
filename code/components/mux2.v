// MUX-2 module "width" sized i/p
module mux2 #(parameter width = 32)(
	input    [width-1:0] d0, d1,
	input    sel,
	output   [width-1:0] y
	);
	
	assign y = sel ? d1 : d0;
endmodule 