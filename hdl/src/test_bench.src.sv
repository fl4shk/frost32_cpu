

module TestBench;
	struct
	{
		logic clk, half_clk;
	} __locals;

	MainClockGenerator __inst_main_clk_gen(.clk(__locals.clk));
	HalfClockGenerator __inst_half_clk_gen(.clk(__locals.half_clk));

endmodule
