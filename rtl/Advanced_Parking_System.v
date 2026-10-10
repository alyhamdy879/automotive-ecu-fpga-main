module Advanced_Parking_System (
    input wire clk,
    input wire rst,  // asynchronous active high reset 
    input wire echo_pulse, // ultrasonic sensor I/P active high (when pulse sent start counting) 
    output reg led_green,
    output reg led_yellow,
    output reg led_red,
    output reg buzzer_out   
);

    localparam ZONE_MID    = 16'd10000;
    localparam ZONE_CLOSE  = 16'd5000;       //thresholds
    localparam ZONE_DANGER = 16'd2000;

    reg [15:0] pulse_arr_time;   //counts how many clks echo pulse take to arrive 
    reg [1:0]  distance_zone;  
    reg [15:0] tone_timer;       // tone maker by adjusting the freq buzzer on off 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pulse_arr_time <= 0;
            distance_zone <= 0;
        end 
        else begin
            if (echo_pulse) begin // 1 pulse sent 
                if (pulse_arr_time < 16'hFFFF) begin // to avoid overflow 
                pulse_arr_time <= pulse_arr_time + 1;
                end
            end
            else if (pulse_arr_time > 0) begin // 0 pulse arrived 
                if      (pulse_arr_time < ZONE_DANGER)      distance_zone <= 3;
                else if (pulse_arr_time < ZONE_CLOSE)       distance_zone <= 2;
                else if (pulse_arr_time < ZONE_MID)         distance_zone <= 1;
                else                                        distance_zone <= 0;
                
                pulse_arr_time <= 0; // rst counter
            end
        end // count
    end

    always @(*) begin
        led_green  = (distance_zone >= 1);
        led_yellow = (distance_zone >= 2);
        led_red    = (distance_zone == 3); // leds
    end

    always @(posedge clk or posedge rst) begin  // tone 
        if (rst || distance_zone == 0) begin
            tone_timer <= 0;
            buzzer_out <= 0;
        end 
        else begin
            tone_timer <= tone_timer + 1;
            case (distance_zone)
                1: begin // MID
                    if (tone_timer >= 500) begin 
                        tone_timer <= 0;
                        buzzer_out <= ~buzzer_out;
                    end
                end
                2: begin // CLOSE
                    if (tone_timer >= 100) begin 
                        tone_timer <= 0;
                        buzzer_out <= ~buzzer_out;
                    end
                end
                3: begin // DANGER
                    if (tone_timer >= 30) begin 
                        tone_timer <= 0;
                        buzzer_out <= ~buzzer_out;
                    end 
                end
            endcase
        end
    end

endmodule