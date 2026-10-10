`timescale 1ns / 1ps

module tb_Active_Spoiler_System;

    reg clk;
    reg rst;
    reg [7:0] vehicle_speed;
    reg brake_pedal;
    wire spoiler_pwm;
    wire airbrake_led;

    
    always #5 clk = ~clk;

    Active_Spoiler_System a1 (
        .clk(clk),
        .rst(rst),
        .vehicle_speed(vehicle_speed),
        .brake_pedal(brake_pedal),
        .spoiler_pwm(spoiler_pwm),
        .airbrake_led(airbrake_led)
    );

    
    task data_in;
        input [7:0]   speed;
        input         brake;
        integer req; // required time to wait 
        begin
            vehicle_speed = speed;
            brake_pedal   = brake;
            @(posedge clk); 
            if (a1.target_angle > a1.current_angle) // req = |tar - cur| 
                req = a1.target_angle - a1.current_angle;
            else
                req = a1.current_angle - a1.target_angle;
            repeat ((req * 41) + 512) @(posedge clk);
        end
    endtask

    initial begin
        clk           = 0;
        rst           = 1;
        vehicle_speed = 8'd0;
        brake_pedal   = 1'b0;

        #15;
        rst = 0;
        @(posedge clk);

        data_in(50,0);

        data_in(100,0);

        data_in(160,0);

        data_in(90,1);


        data_in(70,1);


        $display("test COMPLETE");
        $finish;
    end

endmodule