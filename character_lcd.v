/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_Avalon_Character_LCD                              *
 * Description:                                                              *
 *      This module controls 16x2 character LCD on the Altera DE2 Board.     *
 *                                                                           *
 *****************************************************************************/

module character_lcd (
	// Inputs
	clk,
	reset,

	address,
	chipselect,
	read,
	write,
	writedata,

	// Bidirectionals
	LCD_DATA,

	// Outputs
	LCD_ON,
	LCD_BLON,

	LCD_EN,
	LCD_RS,
	LCD_RW,

	readdata,
//	readdatavalid,
	waitrequest
);


/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter	CURSOR_ON	= 1'b1;
parameter	BLINKING_ON	= 1'b0;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				clk;
input				reset;

input				address;
input				chipselect;
input				read;
//wire				read;
input				write;
input		[31:0]	writedata;

// Bidirectionals
inout		[7:0]	LCD_DATA;			//	LCD Data bus 8 bits

// Outputs
output				LCD_ON;				//	LCD Power ON/OFF
output				LCD_BLON;			//	LCD Back Light ON/OFF

output				LCD_EN;				//	LCD Enable
output				LCD_RS;				//	LCD 0-Command/1-Data Select
output				LCD_RW;				//	LCD 1-Read/0-Write Select

output		[31:0]	readdata;
//output				readdatavalid;
output				waitrequest;
//wire		[31:0]	readdata;
//wire				readdatavalid;
//wire				waitrequest;

/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/
// states
localparam	LCD_STATE_0_IDLE				= 3'h0,
			LCD_STATE_1_INITIALIZE			= 3'h1,
			LCD_STATE_2_START_CHECK_BUSY	= 3'h2,
			LCD_STATE_3_CHECK_BUSY			= 3'h3,
			LCD_STATE_4_BEGIN_TRANSFER		= 3'h4,
			LCD_STATE_5_TRANSFER			= 3'h5,
			LCD_STATE_6_COMPLETE			= 3'h6;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
//reg				done_current_state;

wire				transfer_complete;
wire				done_initialization;

wire				init_send_command;
wire		[8:0]	init_command;

wire				send_data;

wire		[7:0]	data_received;


// Internal Registers
//reg					begin_data_transfer;
reg					initialize_lcd_display;

reg			[7:0]	data_to_send;
reg					rs;
reg					rw;

//reg					has_pending_transfer;
//reg			[9:0]	pending_transfer;

// State Machine Registers
reg			[2:0]	ns_lcd_controller;
reg			[2:0]	s_lcd_controller;

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		s_lcd_controller <= LCD_STATE_0_IDLE;
	end
	else
	begin
		s_lcd_controller <= ns_lcd_controller;
	end
end

always @(*)
begin
	// Defaults
	ns_lcd_controller = LCD_STATE_0_IDLE;

    case (s_lcd_controller)
	LCD_STATE_0_IDLE:
		begin
			if (initialize_lcd_display == 1'b1)
			begin
				ns_lcd_controller = LCD_STATE_1_INITIALIZE;
			end
			else if (chipselect == 1'b1) // if (begin_data_transfer == 1'b1)
			begin
				ns_lcd_controller = LCD_STATE_2_START_CHECK_BUSY; 
			end
			else
			begin
				ns_lcd_controller = LCD_STATE_0_IDLE;
			end
		end
	LCD_STATE_1_INITIALIZE:
		begin
			if (done_initialization == 1'b1)
			begin
				ns_lcd_controller = LCD_STATE_0_IDLE;
			end
			else
			begin
				ns_lcd_controller = LCD_STATE_1_INITIALIZE;
			end
		end
	LCD_STATE_2_START_CHECK_BUSY:
		begin
			if (transfer_complete == 1'b0)
			begin
				ns_lcd_controller = LCD_STATE_3_CHECK_BUSY;
			end
			else
			begin
				ns_lcd_controller = LCD_STATE_2_START_CHECK_BUSY;
			end
		end
	LCD_STATE_3_CHECK_BUSY:
		begin
			if ((transfer_complete == 1'b1) && (data_received[7] == 1'b1))
			begin
				ns_lcd_controller = LCD_STATE_2_START_CHECK_BUSY;
			end
			else if ((transfer_complete == 1'b1) && (data_received[7] == 1'b0))
			begin
				ns_lcd_controller = LCD_STATE_4_BEGIN_TRANSFER;
			end
			else
			begin
				ns_lcd_controller = LCD_STATE_3_CHECK_BUSY;
			end
		end
	LCD_STATE_4_BEGIN_TRANSFER:
		begin
			if (transfer_complete == 1'b0)
			begin
				ns_lcd_controller = LCD_STATE_5_TRANSFER;
			end
			else
			begin
				ns_lcd_controller = LCD_STATE_4_BEGIN_TRANSFER;
			end
		end
	LCD_STATE_5_TRANSFER:
		begin
			if (transfer_complete == 1'b1)
			begin
				ns_lcd_controller = LCD_STATE_6_COMPLETE;
			end
			else
			begin
				ns_lcd_controller = LCD_STATE_5_TRANSFER;
			end
		end
	LCD_STATE_6_COMPLETE:
		begin
			ns_lcd_controller = LCD_STATE_0_IDLE;
		end
	default:
		begin
			ns_lcd_controller = LCD_STATE_0_IDLE;
		end
	endcase
end

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		initialize_lcd_display <= 1'b1;
	end
	else if (done_initialization == 1'b1)
	begin
		initialize_lcd_display <= 1'b0;
	end
end

//always @(posedge clk)
//begin
//	if (reset == 1'b1)
//	begin
//		has_pending_transfer	<= 1'b0;
//		pending_transfer		<= 10'h000;
//	end
//	else if ((chipselect == 1'b1) && (has_pending_transfer == 1'b0))
//	begin
//		has_pending_transfer	<= 1'b1;
//		pending_transfer		<= {address,~write,writedata[7:0]};
//	end
////	else if ((s_lcd_controller == LCD_STATE_4_BEGIN_TRANSFER) &&
////			(transfer_complete == 1'b0) &&
////			(pending_transfer[8] == 1'b0))
////	begin
////		has_pending_transfer	<= 1'b0;
////	end
//	else if (readdatavalid == 1'b1)
//	begin
//		has_pending_transfer	<= 1'b0;
//	end
//end

//always @(posedge clk)
//begin
//	begin_data_transfer <= has_pending_transfer;
////	if (reset == 1'b1)
////	begin
////		begin_data_transfer <= 1'b0;
////	end
////	else if ((has_pending_transfer == 1'b1) && (readdatavalid == 1'b0))
////	begin
////		begin_data_transfer <= 1'b1;
////	end
////	else if (transfer_complete == 1'b1)
////	begin
////		begin_data_transfer <= 1'b0;
////	end
//end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		data_to_send <= 8'h00;
	end
	else if (s_lcd_controller == LCD_STATE_1_INITIALIZE)
	begin
		data_to_send <= init_command[7:0];
	end
	else if (s_lcd_controller == LCD_STATE_4_BEGIN_TRANSFER)
	begin
		data_to_send <= writedata[7:0]; //pending_transfer[7:0];
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		rs <= 1'b0;
	end
	else if (s_lcd_controller == LCD_STATE_1_INITIALIZE)
	begin
		rs <= init_command[8];
	end
	else if (s_lcd_controller == LCD_STATE_2_START_CHECK_BUSY)
	begin
		rs <= 1'b0;
	end
	else if (s_lcd_controller == LCD_STATE_4_BEGIN_TRANSFER)
	begin
		rs <= address; // pending_transfer[9];
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
	begin
		rw <= 1'b0;
	end
	else if (s_lcd_controller == LCD_STATE_2_START_CHECK_BUSY)
	begin
		rw <= 1'b1;
	end
	else if (s_lcd_controller == LCD_STATE_4_BEGIN_TRANSFER)
	begin
		rw <= ~write;// pending_transfer[8];
	end
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign readdata			= {24'h000000, data_received};

//assign readdatavalid	= //pending_transfer[8] & transfer_complete &
//		(s_lcd_controller == LCD_STATE_6_COMPLETE);
assign waitrequest		= chipselect & (s_lcd_controller != LCD_STATE_6_COMPLETE);
//	(chipselect & (read | has_pending_transfer) & ~readdatavalid)/* | 
//	(chipselect & read & ~readdatavalid)*/; 

assign send_data		= 
	(s_lcd_controller == LCD_STATE_1_INITIALIZE) ?	init_send_command :
	(s_lcd_controller == LCD_STATE_3_CHECK_BUSY) ?	1'b1 :
	(s_lcd_controller == LCD_STATE_5_TRANSFER) ?	1'b1 : 1'b0;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Altera_UP_Character_LCD_Communication Char_LCD_Comm (
	// Inputs
	.clk				(clk),
	.reset				(reset),

	.data_in			(data_to_send),
	.enable				(send_data),
	.rs					(rs),
	.rw					(rw),

	.on					(1'b1),
	.back_light_on		(1'b1),

	// Bidirectionals
	.LCD_DATA			(LCD_DATA),

	// Outputs
	.LCD_ON				(LCD_ON),
	.LCD_BLON			(LCD_BLON),

	.LCD_EN				(LCD_EN),
	.LCD_RS				(LCD_RS),
	.LCD_RW				(LCD_RW),

	.data_out			(data_received),
	.transfer_complete	(transfer_complete)
);

Altera_UP_Character_LCD_Initialization Char_LCD_Init (
	// Inputs
	.clk					(clk),
	.reset					(reset),

	.initialize_LCD_display	(initialize_lcd_display),

	.command_was_sent		(transfer_complete),
	
	// Bidirectionals

	// Outputs
	.done_initialization	(done_initialization),

	.send_command			(init_send_command),
	.the_command			(init_command)
);
	defparam
		Char_LCD_Init.CURSOR_ON			= CURSOR_ON,
		Char_LCD_Init.BLINKING_ON		= BLINKING_ON;

endmodule

