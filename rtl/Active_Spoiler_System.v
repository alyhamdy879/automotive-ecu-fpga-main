`timescale 1ns / 1ps

module Active_Spoiler_System (
    input wire clk,
    input wire rst,
    input wire [8:0] vehicle_speed,
    input wire brake_pedal,
    
    output reg spoiler_pwm,
    output reg airbrake_led
);

    localparam SPEED_CITY    = 9'd80;
    localparam SPEED_HIGHWAY = 9'd150;

    localparam ANGLE_CLOSED   = 8'd0;
    localparam ANGLE_CRUISE   = 8'd64;
    localparam ANGLE_TRACK    = 8'd128;
    localparam ANGLE_AIRBRAKE = 8'd255;

    
    reg [7:0] target_angle;
    reg [7:0] current_angle;
    
    reg [15:0] spoiler_timer;
    reg [7:0]  pwm_counter;

    // Airbrake 
    always @(*) begin
        airbrake_led = 1'b0;
        
        if (brake_pedal == 1'b1 && vehicle_speed > SPEED_CITY) begin
            target_angle = ANGLE_AIRBRAKE;
            airbrake_led = 1'b1;
        end 
        else if (vehicle_speed > SPEED_HIGHWAY) begin
            target_angle = ANGLE_TRACK; // 0.5
        end 
        else if (vehicle_speed > SPEED_CITY) begin
            target_angle = ANGLE_CRUISE; //0.25
        end 
        else begin
            target_angle = ANGLE_CLOSED; //0
        end
    end

    // Smooth Movement 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_angle <= ANGLE_CLOSED;
            spoiler_timer <= 0;
        end 
        else begin
            if (spoiler_timer >= 40) begin // 40 * 255 * 10 ns  = 102 us  resonable for sim (irl shuold be >40000  ) 
                spoiler_timer <= 0;
                
                if (current_angle < target_angle)
                    current_angle <= current_angle + 1;
                else if (current_angle > target_angle)
                    current_angle <= current_angle - 1;
            end
            else begin
                spoiler_timer <= spoiler_timer + 1;
            end
        end
    end

    // Servo PWM 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pwm_counter <= 8'd0;
            spoiler_pwm <= 1'b0;
        end else begin
            pwm_counter <= pwm_counter + 1;
            
            if (pwm_counter < current_angle)
                spoiler_pwm <= 1'b1;
            else
                spoiler_pwm <= 1'b0;
        end
    end

endmodule