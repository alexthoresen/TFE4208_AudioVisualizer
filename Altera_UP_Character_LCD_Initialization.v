/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_Character_LCD_Initialization                      *
 * Description:                                                              *
 *      This module runs through the 16x2 Character LCD initialization       *
 *   commands for the DE2 Board.                                             *
 *                                                                           *
 *****************************************************************************/


module Altera_UP_Character_LCD_Initialization (
	// Inputs
	clk,
	reset,

	initialize_LCD_display,

	command_was_sent,
	
	// Bidirectionals

	// Outputs
	done_initialization,

	send_command,
	the_command
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter	CURSOR_ON					= 1'b1;
parameter	BLINKING_ON					= 1'b0;

// Timing info for waiting for power up 
//   when using a 50MHz system clock
parameter	CLOCK_CYCLES_FOR_15MS		= 750000;
parameter	NUMBER_OF_BITS_FOR_15MS		= 20;
parameter	COUNTER_INCREMENT_FOR_15MS	= 20'h00001;

// Timing info for waiting between commands 
//   when using a 50MHz system clock
parameter	CLOCK_CYCLES_FOR_5MS		= 250000;
parameter	NUMBER_OF_BITS_FOR_5MS		= 18;
parameter	COUNTER_INCREMENT_FOR_5MS	= 18'h00001;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				clk;
input				reset;

input				initialize_LCD_display;

input				command_was_sent;

// Bidirectionals

// Outputs
output				done_initialization;

output				send_command;
output	reg	[8:0]	the_command;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/
// states
localparam	LCD_INIT_STATE_0_WAIT_POWER_UP	= 2'h0,
			LCD_INIT_STATE_1_SEND_COMMAND	= 2'h1,
			LCD_INIT_STATE_2_CHECK_DONE		= 2'h2,
			LCD_INIT_STATE_3_DONE			= 2'h3;

localparam	AUTO_INIT_LENGTH				= 4'h8;

/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/
// Internal Wires
reg			[8:0]	command_rom;


// Internal Registers
reg			[NUMBER_OF_BITS_FOR_15MS:1]		waiting_power_up;
reg			[NUMBER_OF_BITS_FOR_5MS:1]		waiting_to_send;

reg			[3:0]	command_counter;

// State Machine Registers
reg			[1:0]	ns_lcd_initialize;
reg			[1:0]	s_lcd_initialize;

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		s_lcd_initialize <= LCD_INIT_STATE_0_WAIT_POWER_UP;
	end
	else
	begin
		s_lcd_initialize <= ns_lcd_initialize;
	end
end

always @(*)
begin
	// Defaults
	ns_lcd_initialize = LCD_INIT_STATE_0_WAIT_POWER_UP;

    case (s_lcd_initialize)
	LCD_INIT_STATE_0_WAIT_POWER_UP:
		begin
			if ((waiting_power_up == CLOCK_CYCLES_FOR_15MS) &&
				(initialize_LCD_display == 1'b1))
			begin
				ns_lcd_initialize = LCD_INIT_STATE_1_SEND_COMMAND;
			end
			else
			begin
				ns_lcd_initialize = LCD_INIT_STATE_0_WAIT_POWER_UP;
			end
		end
	LCD_INIT_STATE_1_SEND_COMMAND:
		begin
			if (command_was_sent == 1'b1)
			begin
				ns_lcd_initialize = LCD_INIT_STATE_2_CHECK_DONE;
			end
			else
			begin
				ns_lcd_initialize = LCD_INIT_STATE_1_SEND_COMMAND;
			end
		end
	LCD_INIT_STATE_2_CHECK_DONE:
		begin
			if (command_counter == AUTO_INIT_LENGTH)
			begin
				ns_lcd_initialize = LCD_INIT_STATE_3_DONE;
			end
			else if (waiting_to_send == CLOCK_CYCLES_FOR_5MS)
			begin
				ns_lcd_initialize = LCD_INIT_STATE_1_SEND_COMMAND;
			end
			else
			begin
				ns_lcd_initialize = LCD_INIT_STATE_2_CHECK_DONE;
			end
		end
	LCD_INIT_STATE_3_DONE:
		begin
			ns_lcd_initialize = LCD_INIT_STATE_3_DONE;
		end
	default:
		begin
			ns_lcd_initialize = LCD_INIT_STATE_0_WAIT_POWER_UP;
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
		the_command <= 9'h000;
	end
	else
	begin
		the_command <= command_rom;
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		waiting_power_up <= {NUMBER_OF_BITS_FOR_15MS{1'b0}};
	end
	else
	begin
		if (s_lcd_initialize == LCD_INIT_STATE_0_WAIT_POWER_UP)
		begin
			if (waiting_power_up != CLOCK_CYCLES_FOR_15MS)
			begin
				waiting_power_up <= waiting_power_up + 
					COUNTER_INCREMENT_FOR_15MS;
			end
		end
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		waiting_to_send <= {NUMBER_OF_BITS_FOR_5MS{1'b0}};
	end
	else
	begin
		if (s_lcd_initialize == LCD_INIT_STATE_2_CHECK_DONE)
		begin
			if (waiting_to_send != CLOCK_CYCLES_FOR_5MS)
			begin
				waiting_to_send <= waiting_to_send + 
					COUNTER_INCREMENT_FOR_5MS;
			end
		end
		else
		begin
			waiting_to_send <= {NUMBER_OF_BITS_FOR_5MS{1'b0}};
		end
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		command_counter <= 4'h0;
	end
	else
	begin
		if (s_lcd_initialize == LCD_INIT_STATE_1_SEND_COMMAND)
		begin
			if (command_was_sent == 1'b1)
			begin
				command_counter <= command_counter + 4'h1;
			end
		end
		else if (s_lcd_initialize == LCD_INIT_STATE_0_WAIT_POWER_UP)
		begin
			command_counter <= 4'h0;
		end
	end
end

/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/

// Output Assignments
assign send_command	= (s_lcd_initialize == LCD_INIT_STATE_1_SEND_COMMAND);
assign done_initialization = (s_lcd_initialize == LCD_INIT_STATE_3_DONE);

// Internal Assignments
always @(*)
begin
	case (command_counter)
	0		:	command_rom	<=	9'h030;
	1		:	command_rom	<=	9'h030;
	2		:	command_rom	<=	9'h030;
	3		:	command_rom	<=	9'h03C;
	4		:	command_rom	<=	9'h008;
	5		:	command_rom	<=	9'h001;
	6		:	command_rom	<=	9'h006;
	7		:	command_rom	<=	{7'h03, CURSOR_ON, BLINKING_ON};
	default	:	command_rom	<=	9'h000;
	endcase
end

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


endmodule

