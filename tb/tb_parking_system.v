`timescale 10ns / 10ps

module tb_Parking_System;

    reg  clk;
    reg  rst;
    reg  echo_pulse;
    wire led_green;
    wire led_yellow;
    wire led_red;
    wire buzzer_out;

    Advanced_Parking_System p1 (
        .clk       (clk),
        .rst       (rst),
        .echo_pulse(echo_pulse),
        .led_green (led_green),
        .led_yellow(led_yellow),
        .led_red   (led_red),
        .buzzer_out(buzzer_out)
    );

    
    task sn_echo(input [15:0] ckl);
        begin
            echo_pulse = 1;
            repeat (ckl) @(posedge clk);
            echo_pulse = 0;
            repeat (5000) @(posedge clk); 
        end
    endtask

    always #5 clk = ~clk;
    
    initial begin 
        clk        = 0;
        rst        = 1;
        echo_pulse = 0;
        #20;
        rst = 0;
        #20;
        sn_echo(16'd12000); // far dis 0
        sn_echo(16'd7000); // mid dis 1
        sn_echo(16'd3500);// close dis 2
        sn_echo(16'd1000);// danger dis 3

        $display("TEST COMPLETE");
        $finish;
    end

endmodule