`timescale 1ns / 1ps

module Traction_ABS_System_tb;

    
    reg clk;
    reg rst;
    reg [7:0] front_wheel_speed;
    reg [7:0] rear_wheel_speed;
    reg brake_pedal;
    reg [7:0] ecu_motor_pwm_in;

    wire [7:0] final_motor_pwm;
    wire abs_brake_pulse;
    wire tcs_active_led;
    wire abs_active_led;

    traction_ABS_System t1 (
        .clk(clk),
        .rst(rst),
        .front_wheel_speed(front_wheel_speed),
        .rear_wheel_speed(rear_wheel_speed),
        .brake_pedal(brake_pedal),
        .ecu_motor_pwm_in(ecu_motor_pwm_in),
        .final_motor_pwm(final_motor_pwm),
        .abs_brake_pulse(abs_brake_pulse),
        .tcs_active_led(tcs_active_led),
        .abs_active_led(abs_active_led)
    );

    task data_in ;
        input [7:0] speedf;
        input [7:0] speedr;
        input       brake;
        input [7:0] pwm;
        begin
            front_wheel_speed = speedf;
            rear_wheel_speed   = speedr;
            brake_pedal   = brake;
            ecu_motor_pwm_in = pwm;
            #10; 
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        front_wheel_speed = 8'd0;
        rear_wheel_speed = 8'd0;
        brake_pedal = 0;
        ecu_motor_pwm_in = 8'd0;

        #20;
        rst = 0;
        #12;

        //Normal Driving (No Slip)
        // Slip = 5 
        data_in(95,100,0,200);
        #30;

        // TCS Activation
        // Slip = 30 
        data_in(90,120,0,200);
        #30; 

        //  Normal Braking 
        // Slip = 5
        data_in(80,75,1,200);
        #30;

        //  ABS Activation
        // Slip = 40 
        data_in(80,40,1,200);
        #50; 

        //  Normal Driving
        
        data_in(50,50,0,150);
        #30;

        $display("test Complete.");
        $finish;
    end

endmodule