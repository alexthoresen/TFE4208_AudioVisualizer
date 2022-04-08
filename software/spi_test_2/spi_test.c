/*
 * spi_test.c
 *
 *  Created on: 18 Mar 2022
 *      Author: Alexander Thoresen
 */

#include <stdio.h>
#include "alt_types.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_spi.h"

int main() {

	printf("fdfefde\n");

    alt_u8 tx_buf[2] = {0};
    alt_u8 rx_buf[2] = {0};

    tx_buf[0] = 0x0C;
    tx_buf[1] = 0x01;

    alt_avalon_spi_command(SPI_LED_MATRIX_BASE, 0, 2, &tx_buf[0], 2, &rx_buf[0], 0);

    tx_buf[0] = 0x0A;
    tx_buf[1] = 0x08;

    alt_avalon_spi_command(SPI_LED_MATRIX_BASE, 0, 2, &tx_buf[0], 2, &rx_buf[0], 0);

    tx_buf[0] = 0x01;
    tx_buf[1] = 0x00;

    alt_avalon_spi_command(SPI_LED_MATRIX_BASE, 0, 2, &tx_buf[0], 2, &rx_buf[0], 0);

    tx_buf[0] = 0x02;
    tx_buf[1] = 0x24;

    alt_avalon_spi_command(SPI_LED_MATRIX_BASE, 0, 2, &tx_buf[0], 2, &rx_buf[0], 0);

    tx_buf[0] = 0x03;
    tx_buf[1] = 0x24;

    alt_avalon_spi_command(SPI_LED_MATRIX_BASE, 0, 2, &tx_buf[0], 2, &rx_buf[0], 0);

    tx_buf[0] = 0x04;
    tx_buf[1] = 0x00;

    alt_avalon_spi_command(SPI_LED_MATRIX_BASE, 0, 2, &tx_buf[0], 2, &rx_buf[0], 0);

    tx_buf[0] = 0x05;
    tx_buf[1] = 0x42;

    alt_avalon_spi_command(SPI_LED_MATRIX_BASE, 0, 2, &tx_buf[0], 2, &rx_buf[0], 0);

    tx_buf[0] = 0x06;
    tx_buf[1] = 0x24;

    alt_avalon_spi_command(SPI_LED_MATRIX_BASE, 0, 2, &tx_buf[0], 2, &rx_buf[0], 0);

    tx_buf[0] = 0x07;
    tx_buf[1] = 0x18;

    alt_avalon_spi_command(SPI_LED_MATRIX_BASE, 0, 2, &tx_buf[0], 2, &rx_buf[0], 0);

    tx_buf[0] = 0x08;
    tx_buf[1] = 0x00;

    alt_avalon_spi_command(SPI_LED_MATRIX_BASE, 0, 2, &tx_buf[0], 2, &rx_buf[0], 0);

    return 0;
}
