`timescale 1ns / 1ps

module Smart_RPM_Limiter (
    input wire clk,
    input wire rst,
    input wire [3:0] engine_rpm,
    input wire [8:0] vehicle_speed,
    input wire brake_pedal,
    input wire [1:0] throttle_in,
    output reg spark_retard,
    output reg fuel_cut
);

    localparam RPM_LAUNCH    = 4'd4;   //4000 rpm
    localparam RPM_SOFT_MAX  = 4'd9;  //9000 rpm
    localparam RPM_HARD_MAX  = 4'd10;//10000 rpm

    // Control & Protection
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            spark_retard <= 1'b0; 
            fuel_cut <= 1'b0;
        end 
        else begin
            
            // Launch Control (Drag Mode) 
            if (vehicle_speed == 9'd0 && brake_pedal == 1'b1 && throttle_in == 2'b11) begin
                
                if (engine_rpm >= RPM_LAUNCH) begin 
                    spark_retard <= 1'b1; // Soft Cut to hold RPM to 4000rpm  
                    fuel_cut <= 1'b0;
                end 
                else begin
                    spark_retard <= 1'b0;
                    fuel_cut <= 1'b0;
                end
            end
            
            // Normal Driving & Engine Protection 
            else begin
                
                if (engine_rpm >= RPM_HARD_MAX) begin
                    // Hard Cut Danger zone (Cut Fuel)
                    fuel_cut <= 1'b1;
                    spark_retard <= 1'b0;
                end 
                else if (engine_rpm >= RPM_SOFT_MAX) begin
                    // Soft Cut Redline warning (Retard Spark)
                    fuel_cut <= 1'b0;
                    spark_retard <= 1'b1;
                end 
                else begin
                    // Normal 
                    fuel_cut <= 1'b0;
                    spark_retard <= 1'b0;
                end
                
            end
        end
    end

endmodule