
module DE2_115_SOPC (
	clk_clk,
	pio_led_external_connection_export,
	reset_reset_n,
	spi_led_matrix_external_MISO,
	spi_led_matrix_external_MOSI,
	spi_led_matrix_external_SCLK,
	spi_led_matrix_external_SS_n);	

	input		clk_clk;
	output	[7:0]	pio_led_external_connection_export;
	input		reset_reset_n;
	input		spi_led_matrix_external_MISO;
	output		spi_led_matrix_external_MOSI;
	output		spi_led_matrix_external_SCLK;
	output		spi_led_matrix_external_SS_n;
endmodule
