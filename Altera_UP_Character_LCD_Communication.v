/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_Character_LCD_Communication                       *
 * Description:                                                              *
 *      This module read and write data to the 16x2 Character LCD on the DE2 *
 *   Board.                                                                  *
 *                                                                           *
 *****************************************************************************/

module Altera_UP_Character_LCD_Communication (
	// Inputs
	clk,
	reset,

	data_in,
	enable,
	rs,
	rw,

	on,
	back_light_on,

	// Bidirectionals
	LCD_DATA,

	// Outputs
	LCD_ON,
	LCD_BLON,

	LCD_EN,
	LCD_RS,
	LCD_RW,

	data_out,
	transfer_complete
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

// Timing info for minimum wait between consecutive communications 
//   if using a 50MHz Clk
parameter	CLOCK_CYCLES_FOR_IDLE_STATE			= 7'h7F;	// Minimum 2500 ns
parameter	NUM_BITS_FOR_IDLE_COUNTER			= 7;
parameter	IDLE_COUNTER_INCREMENT				= 7'h01;

parameter	CLOCK_CYCLES_FOR_OPERATION_STATE	= 3;		// Minimum  40 ns
parameter	CLOCK_CYCLES_FOR_ENABLE_STATE		= 15;		// Minimum 230 ns
parameter	CLOCK_CYCLES_FOR_HOLD_STATE			= 1;		// Minimum  10 ns
parameter	NUM_BITS_FOR_STATES_COUNTER			= 4;
parameter	COUNTER_INCREMENT					= 4'h1;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				clk;
input				reset;

input		[7:0]	data_in;
input				rs;
input				rw;
input				enable;

input				on;
input				back_light_on;

// Bidirectionals
inout		[7:0]	LCD_DATA;

// Outputs
output	reg			LCD_ON;
output	reg			LCD_BLON;

output	reg			LCD_EN;
output	reg			LCD_RS;
output	reg			LCD_RW;

output	reg	[7:0]	data_out;			// Stores data read from the LCD
output	reg			transfer_complete;	// Indicates the end of the transfer

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/
// states
parameter	LCD_STATE_4_IDLE		= 3'h4,
			LCD_STATE_0_OPERATION	= 3'h0,
			LCD_STATE_1_ENABLE		= 3'h1,
			LCD_STATE_2_HOLD		= 3'h2,
			LCD_STATE_3_END			= 3'h3;

/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/
// Internal Wires

// Internal Registers
reg			[7:0]	data_to_lcd;

reg			[NUM_BITS_FOR_IDLE_COUNTER:1]	idle_counter;
reg			[NUM_BITS_FOR_STATES_COUNTER:1]	state_0_counter;
reg			[NUM_BITS_FOR_STATES_COUNTER:1]	state_1_counter;
reg			[NUM_BITS_FOR_STATES_COUNTER:1]	state_2_counter;

// State Machine Registers
reg			[2:0]	ns_lcd;
reg			[2:0]	s_lcd;

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/

always @(posedge clk)	// sync reset
begin
	if (reset == 1'b1)
	begin
		s_lcd <= LCD_STATE_4_IDLE;
	end
	else
	begin
		s_lcd <= ns_lcd;
	end
end

always @(*)
begin
	ns_lcd = LCD_STATE_4_IDLE;

    case (s_lcd)
	LCD_STATE_4_IDLE:
		begin
			if ((idle_counter == CLOCK_CYCLES_FOR_IDLE_STATE) && 
				(enable == 1'b1))
			begin
				ns_lcd = LCD_STATE_0_OPERATION;
			end
			else
			begin
				ns_lcd = LCD_STATE_4_IDLE;
			end
		end
	LCD_STATE_0_OPERATION:
		begin
			if (state_0_counter == CLOCK_CYCLES_FOR_OPERATION_STATE)
			begin
				ns_lcd = LCD_STATE_1_ENABLE;
			end
			else
			begin
				ns_lcd = LCD_STATE_0_OPERATION;
			end
		end
	LCD_STATE_1_ENABLE:
		begin
			if (state_1_counter == CLOCK_CYCLES_FOR_ENABLE_STATE)
			begin
				ns_lcd = LCD_STATE_2_HOLD;
			end
			else
			begin
				ns_lcd = LCD_STATE_1_ENABLE;
			end
		end
	LCD_STATE_2_HOLD:
		begin
			if (state_2_counter == CLOCK_CYCLES_FOR_HOLD_STATE)
			begin
				ns_lcd = LCD_STATE_3_END;
			end
			else
			begin
				ns_lcd = LCD_STATE_2_HOLD;
			end
		end
	LCD_STATE_3_END:
		begin
			if (enable == 1'b0)
			begin
				ns_lcd = LCD_STATE_4_IDLE;
			end
			else
			begin
				ns_lcd = LCD_STATE_3_END;
			end
		end
	default:
		begin
			ns_lcd = LCD_STATE_4_IDLE;
		end
	endcase
end


/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		LCD_ON <= 1'b0;
		LCD_BLON <= 1'b0;
	end
	else
	begin
		LCD_ON <= on;
		LCD_BLON <= back_light_on;
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		LCD_EN				<= 1'b0;
		LCD_RS				<= 1'b0;
		LCD_RW				<= 1'b0;
		data_out			<= 8'h00;
		transfer_complete	<= 1'b0;
	end
	else
	begin
		if (s_lcd == LCD_STATE_1_ENABLE)
		begin
			LCD_EN		<= 1'b1;
		end
		else
		begin
			LCD_EN		<= 1'b0;
		end

		if (s_lcd == LCD_STATE_4_IDLE)
		begin
			LCD_RS		<= rs;
			LCD_RW		<= rw;
			
			data_to_lcd <= data_in;
		end

		if (s_lcd == LCD_STATE_1_ENABLE)
		begin
			data_out	<= LCD_DATA;
		end

		if (s_lcd == LCD_STATE_3_END)
		begin
			transfer_complete	<= 1'b1;
		end
		else
		begin
			transfer_complete	<= 1'b0;
		end
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		idle_counter <= {NUM_BITS_FOR_IDLE_COUNTER{1'b0}};
	end
	else
	begin
		if (s_lcd == LCD_STATE_4_IDLE)
		begin
			idle_counter <= idle_counter + IDLE_COUNTER_INCREMENT;
		end
		else
		begin
			idle_counter <= {NUM_BITS_FOR_IDLE_COUNTER{1'b0}};
		end
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		state_0_counter <= {NUM_BITS_FOR_STATES_COUNTER{1'b0}};
		state_1_counter <= {NUM_BITS_FOR_STATES_COUNTER{1'b0}};
		state_2_counter <= {NUM_BITS_FOR_STATES_COUNTER{1'b0}};
	end
	else
	begin
		if (s_lcd == LCD_STATE_0_OPERATION)
		begin
			state_0_counter <= state_0_counter + COUNTER_INCREMENT;
		end
		else
		begin
			state_0_counter <= {NUM_BITS_FOR_STATES_COUNTER{1'b0}};
		end

		if (s_lcd == LCD_STATE_1_ENABLE)
		begin
			state_1_counter <= state_1_counter + COUNTER_INCREMENT;
		end
		else
		begin
			state_1_counter <= {NUM_BITS_FOR_STATES_COUNTER{1'b0}};
		end

		if (s_lcd == LCD_STATE_2_HOLD)
		begin
			state_2_counter <= state_2_counter + COUNTER_INCREMENT;
		end
		else
		begin
			state_2_counter <= {NUM_BITS_FOR_STATES_COUNTER{1'b0}};
		end
	end
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/

assign LCD_DATA	= 
		(((s_lcd == LCD_STATE_1_ENABLE) ||
		  (s_lcd == LCD_STATE_2_HOLD)) &&
		  (LCD_RW == 1'b0)) ? data_to_lcd : 8'hzz;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

