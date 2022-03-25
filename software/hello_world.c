/*
 * Demonstration of the LED Matrix and key interrupts
 */

#include <stdio.h>
#include "system.h"
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "altera_avalon_spi.h"

// Send 8 bit data to register at address addr in the led matrix
void spi_send(alt_u8 addr, alt_u8 data) {
	alt_u8 write_buf[2] = {addr, data};

	alt_avalon_spi_command(SPI_MATRIX_BASE, 0, 2, &write_buf[0], 0, 0, 0);
}

void led_matrix_setup() {
	// Set medium brightness
	spi_send(0x0A, 0x08);

	// Set scan limit to max
	spi_send(0x0B, 0x07);

	// Set display test mode off
	spi_send(0x0F, 0x00);

	// Set shutdown mode off
	spi_send(0x0C, 0x01);
}

// Takes in (a pointer to) an array, and sets the rows of the led matrix according to the array
void led_matrix_set_rows(alt_u8* data_rows) {
	for (alt_u8 i = 0; i < 8; i++) {
		spi_send(i+1, data_rows[i]);
	}
}

const alt_u8 smiley[8] = {0x00, 0x08, 0x64, 0x02, 0x02, 0x64, 0x08, 0x00};

const alt_u8 heart[8] = {0x38, 0x7C, 0x7E, 0x3F, 0x3F, 0x7E, 0x7C, 0x38};

const alt_u8 blank[8] = {0};

const alt_u8 letter_H[8] = {0x00, 0x00, 0x7F, 0x08, 0x08, 0x08, 0x7F, 0x00};

const alt_u8 letter_E[8] = {0x00, 0x00, 0x41, 0x49, 0x49, 0x49, 0x7F, 0x00};

const alt_u8 letter_L[8] = {0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x7F, 0x00};

const alt_u8 letter_O[8] = {0x00, 0x00, 0x7F, 0x41, 0x41, 0x41, 0x7F, 0x00};

const alt_u8 letter_W[8] = {0x00, 0x00, 0x7E, 0x01, 0x06, 0x01, 0x7E, 0x00};

const alt_u8 letter_R[8] = {0x00, 0x00, 0x31, 0x4A, 0x4C, 0x48, 0x7F, 0x00};

const alt_u8 letter_D[8] = {0x00, 0x00, 0x3E, 0x41, 0x41, 0x41, 0x7F, 0x00};

void led_matrix_hello_world() {
	alt_u8* text[13] = {letter_H, letter_E, letter_L, letter_L, letter_O, blank, letter_W, letter_O, letter_R, letter_L, letter_D, smiley, blank};

	int delay;

	for (int i = 0; i < 13; i++) {
		led_matrix_set_rows(text[i]);

		delay = 0;
		while (delay < 1500000) {
			delay++;
		}

		led_matrix_set_rows(blank);

		delay = 0;
		while (delay < 250000) {
			delay++;
		}
	}
}

// Interrupt routine for the keys
static void keys_isr(void * context) {
	int irq_cause = IORD_ALTERA_AVALON_PIO_EDGE_CAP(PIO_KEYS_BASE) & 0xf;

	// Clear interrupt
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_KEYS_BASE, irq_cause);

	if (irq_cause & 0x1) {
		printf("Hello from key 0\n");
		led_matrix_hello_world();
	}
	if (irq_cause & 0x2) {
		printf("Hello from key 1\n");
		led_matrix_set_rows(smiley);
	}
	if (irq_cause & 0x4) {
		printf("Hello from key 2\n");
		led_matrix_set_rows(heart);
	}
	if (irq_cause & 0x8) {
		printf("Hello from key 3\n");
		led_matrix_set_rows(blank);
	}
}

void keys_init() {
	// Enable key pio interrupt generation
	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_KEYS_BASE, 0xf);

	// Clear interrupt
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_KEYS_BASE, 0xf);

	// Register keys isr
	alt_ic_isr_register(PIO_KEYS_IRQ_INTERRUPT_CONTROLLER_ID, PIO_KEYS_IRQ, keys_isr, 0, 0);
}

int main()
{
  printf("Hello World 2 from Nios II!\n");

  keys_init();

  led_matrix_setup();

  int count = 0;

  while (1) {
	  // Just busy work for the CPU so it doesn't exit the program
	  count++;
  }

  return 0;
}
