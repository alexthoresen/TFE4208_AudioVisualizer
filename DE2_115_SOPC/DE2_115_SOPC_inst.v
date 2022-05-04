	DE2_115_SOPC u0 (
		.clk_clk                             (<connected-to-clk_clk>),                             //                          clk.clk
		.pio_keys_external_connection_export (<connected-to-pio_keys_external_connection_export>), // pio_keys_external_connection.export
		.reset_reset_n                       (<connected-to-reset_reset_n>),                       //                        reset.reset_n
		.spi_led_matrix_external_MISO        (<connected-to-spi_led_matrix_external_MISO>),        //      spi_led_matrix_external.MISO
		.spi_led_matrix_external_MOSI        (<connected-to-spi_led_matrix_external_MOSI>),        //                             .MOSI
		.spi_led_matrix_external_SCLK        (<connected-to-spi_led_matrix_external_SCLK>),        //                             .SCLK
		.spi_led_matrix_external_SS_n        (<connected-to-spi_led_matrix_external_SS_n>)         //                             .SS_n
	);

