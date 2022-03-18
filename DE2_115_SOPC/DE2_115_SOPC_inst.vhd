	component DE2_115_SOPC is
		port (
			clk_clk                            : in  std_logic                    := 'X'; -- clk
			pio_led_external_connection_export : out std_logic_vector(7 downto 0);        -- export
			reset_reset_n                      : in  std_logic                    := 'X'; -- reset_n
			spi_led_matrix_external_MISO       : in  std_logic                    := 'X'; -- MISO
			spi_led_matrix_external_MOSI       : out std_logic;                           -- MOSI
			spi_led_matrix_external_SCLK       : out std_logic;                           -- SCLK
			spi_led_matrix_external_SS_n       : out std_logic                            -- SS_n
		);
	end component DE2_115_SOPC;

	u0 : component DE2_115_SOPC
		port map (
			clk_clk                            => CONNECTED_TO_clk_clk,                            --                         clk.clk
			pio_led_external_connection_export => CONNECTED_TO_pio_led_external_connection_export, -- pio_led_external_connection.export
			reset_reset_n                      => CONNECTED_TO_reset_reset_n,                      --                       reset.reset_n
			spi_led_matrix_external_MISO       => CONNECTED_TO_spi_led_matrix_external_MISO,       --     spi_led_matrix_external.MISO
			spi_led_matrix_external_MOSI       => CONNECTED_TO_spi_led_matrix_external_MOSI,       --                            .MOSI
			spi_led_matrix_external_SCLK       => CONNECTED_TO_spi_led_matrix_external_SCLK,       --                            .SCLK
			spi_led_matrix_external_SS_n       => CONNECTED_TO_spi_led_matrix_external_SS_n        --                            .SS_n
		);

