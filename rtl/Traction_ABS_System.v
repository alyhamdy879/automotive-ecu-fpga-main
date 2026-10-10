`timescale 1ns / 1ps

module traction_ABS_System (
    input wire clk,
    input wire rst,
    input wire [7:0] front_wheel_speed,
    input wire [7:0] rear_wheel_speed,
    input wire brake_pedal,
    input wire [7:0] ecu_motor_pwm_in,
    
    output reg [7:0] final_motor_pwm,
    output reg abs_brake_pulse,
    output reg tcs_active_led,
    output reg abs_active_led
);

    localparam MAX_SLIP = 8'd15;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            final_motor_pwm <= 8'd0;
            abs_brake_pulse <= 1'b0;
            tcs_active_led  <= 1'b0;
            abs_active_led  <= 1'b0;
        end else begin
            
            if (brake_pedal == 1'b1) begin // abs
                final_motor_pwm <= 8'd0;
                tcs_active_led  <= 1'b0;

                if (front_wheel_speed > rear_wheel_speed && (front_wheel_speed - rear_wheel_speed) > MAX_SLIP) begin
                    abs_brake_pulse <= ~abs_brake_pulse;
                    abs_active_led  <= 1'b1;
                end else begin
                    abs_brake_pulse <= 1'b1;
                    abs_active_led  <= 1'b0;
                end
            end
            
            else begin //trc
                abs_brake_pulse <= 1'b0;
                abs_active_led  <= 1'b0;

                if (rear_wheel_speed > front_wheel_speed && (rear_wheel_speed - front_wheel_speed) > MAX_SLIP) begin
                    final_motor_pwm <= (ecu_motor_pwm_in >> 1); // divide by 2
                    tcs_active_led  <= 1'b1;
                end else begin
                    final_motor_pwm <= ecu_motor_pwm_in;
                    tcs_active_led  <= 1'b0;
                end
            end
            
        end
    end

endmodule