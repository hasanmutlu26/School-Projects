module _32bit_AND_testbench();
reg [31:0] A, B;
wire [31:0] result;

_32bit_AND g0 (result, A, B);

initial begin
A = 32'd9999;
B = 32'd11111;
#20;

A = 32'b0000_0000_0000_0000_0000_0000_0000_0000_;
B = 32'b0000_0000_0000_0000_0000_0000_0000_0000_;
#20;

A = 32'b0000_0000_0000_0000_0000_1111_1111_0000_;
B = 32'b1111_1111_1111_1111_0000_0000_1111_1111_;
#20;

end

endmodule