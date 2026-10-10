`timescale 1ns / 1ps

module tb_Smart_RPM_Limiter;

    reg clk;
    reg rst;
    reg [3:0] engine_rpm;
    reg [8:0] vehicle_speed;
    reg brake_pedal;
    reg [1:0] throttle_in;
    wire spark_retard;
    wire fuel_cut;

    
    always #5 clk = ~clk;

    
    Smart_RPM_Limiter uut (
        .clk(clk),
        .rst(rst),
        .engine_rpm(engine_rpm),
        .vehicle_speed(vehicle_speed),
        .brake_pedal(brake_pedal),
        .throttle_in(throttle_in),
        .spark_retard(spark_retard),
        .fuel_cut(fuel_cut)
    );

    task data_in ;
        input [8:0] speed;
        input [1:0] throttle;
        input       brake;
        input [3:0] rpm;
        begin
            vehicle_speed = speed;
            throttle_in   = throttle;
            brake_pedal   = brake;
            engine_rpm = rpm;
            #10; 
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        engine_rpm    = 4'd0;
        vehicle_speed = 9'd0;
        brake_pedal   = 1'b0;
        throttle_in   = 2'b00;

        #12;
        rst = 0;

        //lanch control 
        data_in(0,3,1,5);
        data_in(0,3,1,3);
        data_in(0,3,1,8);
        data_in(0,3,1,4);
        // Normal Driving & Engine Protection 
        data_in(100,3,0,4);
        data_in(200,3,0,7);
        data_in(300,3,0,9);
        data_in(330,3,0,7);
        data_in(350,3,0,10);
        data_in(150,3,0,3);
      
        $display(" test COMPLETE ");
        $finish;
    end

endmodule