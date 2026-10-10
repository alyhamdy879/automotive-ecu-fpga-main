module drive_Mode_Controller (
    input wire clk,
    input wire rst,
    input wire [1:0] throttle_in,
    input wire [1:0] drive_mode,
    output reg motor_pwm
);

    reg [7:0] target_duty;
    reg [7:0] current_duty;
    
    reg [7:0] pwm_counter;
    reg [15:0] smooth_timer;

    //  drive Modes
    always @(*) begin
        case (drive_mode)
            2'b01: begin // Normal  1:1 Ratio
                case (throttle_in)
                    2'b00: target_duty = 8'd0;
                    2'b01: target_duty = 8'd64;
                    2'b10: target_duty = 8'd128;
                    2'b11: target_duty = 8'd255;
                endcase
            end
            
            2'b00: begin // Eco 1:2 Ratio
                case (throttle_in)
                    2'b00: target_duty = 8'd0;
                    2'b01: target_duty = 8'd32;
                    2'b10: target_duty = 8'd64;
                    2'b11: target_duty = 8'd128;
                endcase
            end
            
            2'b10: begin // Sport 
                case (throttle_in)
                    2'b00: target_duty = 8'd0;
                    2'b01: target_duty = 8'd128;   // 2:1 Ratio 
                    2'b10: target_duty = 8'd192;   // 4:3 Ratio
                    2'b11: target_duty = 8'd255;   // 1:1 Ratio
                endcase
            end
            
            2'b11: begin // Track
                case (throttle_in)
                    2'b00: target_duty = 8'd0;
                    2'b01: target_duty = 8'd192;   // 3:1 Ratio
                    2'b10: target_duty = 8'd255;   // 2:1 Ratio
                    2'b11: target_duty = 8'd255;   // 1:1 Ratio
                endcase
            end
            
            default: target_duty = 8'd0; 
        endcase
    end

    // Smooth Rate Limiter (Engine Protection) 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_duty <= 8'd0;
            smooth_timer <= 0;
        end 
        else 
        begin
            if (smooth_timer >= 50) begin // 50 * 255 * 10 ns  = 127.5 us  resonable for sim (irl shuold be >50000  ) 
                smooth_timer <= 0;
                
                if (current_duty < target_duty)
                    current_duty <= current_duty + 1;
                else if (current_duty > target_duty)
                    current_duty <= current_duty - 1;
            end
            else begin
                smooth_timer <= smooth_timer + 1;
            end
        end
    end

    //PWM Signal 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pwm_counter <= 8'd0;
            motor_pwm <= 1'b0;
        end 
        else begin
            pwm_counter <= pwm_counter + 1;
            
            if (pwm_counter < current_duty) 
                motor_pwm <= 1'b1;
            else
                motor_pwm <= 1'b0;
        end
    end

endmodule