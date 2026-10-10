`timescale 1ns / 1ps

module tb_Drive_Mode_Controller;
    reg clk;
    reg rst;
    reg [1:0] throttle_in;
    reg [1:0] drive_mode;
    wire motor_pwm;

    drive_Mode_Controller d1 (
        .clk(clk),
        .rst(rst),
        .throttle_in(throttle_in),
        .drive_mode(drive_mode),
        .motor_pwm(motor_pwm)
    );

    task data_in(input [1:0] mode,
                 input [1:0] throttle);
        integer req; // required time to wait 
        begin
            drive_mode  = mode;
            throttle_in = throttle;
            @(posedge clk);  
            if (d1.target_duty > d1.current_duty)  // req = |tar - cur| 
                req = d1.target_duty - d1.current_duty;  
            else
                req = d1.current_duty - d1.target_duty; 

            repeat ((req * 51) + 256) @(posedge clk); // Wait until current reach target (51 smooth timer  + 256  full PWM cycle)
        end
    endtask


    always #5 clk = ~clk; // 10ns

    initial begin
        clk = 0;
        rst = 1;
        throttle_in = 2'b00;
        drive_mode  = 2'b00;
        #15;
        rst = 0;
        @(posedge clk);
        
        //Test ECO Mode
        data_in(2'b00, 2'b01); // Target: 32
        data_in(2'b00, 2'b10); // Target: 64
        data_in(2'b00, 2'b11); // Target: 128
        //Test SPORT Mode 
        data_in(2'b10, 2'b11); // Target: 255 
        data_in(2'b10, 2'b00); // Target: 0   
        // Test TRACK Mode 
        data_in(2'b11, 2'b01); // Target: 192
        // Test NORMAL Mode 
        data_in(2'b01, 2'b01); // Target: 64
        //Test Async Rst
        #12; 
        rst = 1;
        #20;
        rst = 0;

        $display("TEST COMPLETE");
        $finish;
    end

endmodule