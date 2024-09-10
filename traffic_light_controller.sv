module TLC ( //traffic_light_controller
    //input logic north ,south ,west ,east,
    input logic Pedestrian_req, //ambulance_NS,ambulance_EW,
    input logic clk, reset, 
    output logic [2:0]NS_LEDS ,EW_LEDS,
    output logic Pedestrian_allow
);

//time for each LED
parameter int green_time = 10;
parameter int yellow_time = 5;
parameter int red_time = 15;
parameter int Pedestrian_time=15;
logic pedestrian_wait = 0 ;

int time_counter =0;
int pedestrian_timer =0;

//outputs for the NS_LEDS & EW_LEDS
logic[2:0] RED =    3'b100,     // Red light (binary 100)
           YELLOW = 3'b010,    // Yellow light (binary 010)
           GREEN =  3'b001;   // Green light (binary 001)

// States for traffic light phases //no need for red state 
parameter[2:0]  NS_GREEN =  3'b000,
                NS_YELLOW = 3'b001,
                EW_GREEN =  3'b010,
                EW_YELLOW = 3'b011,
                PEDESTRIAN =3'b100; //pedestian state

reg [2:0] current_state, next_state;

// Next state logic 
always @(*) begin
    case (current_state)
        NS_GREEN:  next_state = NS_YELLOW;     // Move from NS green to NS yellow
        NS_YELLOW: next_state = EW_GREEN;     // Then switch to EW green
        EW_GREEN:  next_state = EW_YELLOW;   // After EW green, switch to EW yellow
        EW_YELLOW:
        begin
        if (pedestrian_wait) next_state = PEDESTRIAN;  // If pedestrian is waiting, go to pedestrian mode
        else next_state = NS_GREEN;     // Cycle back to NS green
        end 
        PEDESTRIAN: next_state = NS_GREEN;
        default:    next_state = NS_GREEN;  // Default state
    endcase
end

// State transition logic (sequential)
always @(posedge clk or posedge reset) 
begin
    if (reset) 
    begin
        current_state <= NS_GREEN;  // Start with North-South green light
        time_counter <= green_time;
        pedestrian_timer <= 0;
        pedestrian_wait <= 0 ;
        Pedestrian_allow <=0 ;
    end else
    begin
        //check every clock if the pedestrian_req is pressed
         if (Pedestrian_req && pedestrian_timer == 0 && !pedestrian_wait) begin
                pedestrian_timer <= Pedestrian_time;  // Set pedestrian timer if request is made
                pedestrian_wait <= 1;
                end    
        if (time_counter == 0) 
        begin
            current_state <= next_state;  // Move to the next state when counter hits zero       
             case (current_state)
                NS_GREEN:  time_counter <= green_time;  // Reset counter for green time
                NS_YELLOW: time_counter <= yellow_time;
                EW_GREEN:  time_counter <= green_time;
                EW_YELLOW: time_counter <= yellow_time;
                PEDESTRIAN:time_counter <= Pedestrian_time;  
             endcase
        end else 
        begin
            time_counter <= time_counter - 1;  // Decrease counter
        end

            // Reset the pedestria_wait flag when transitioning from PEDESTRIAN state
            if (current_state == PEDESTRIAN && next_state == NS_GREEN) begin
                pedestrian_wait <= 0;  // Allow future pedestrian requests after a full cycle
            end
    end
end


// Output logic (combinational)
always @(*) begin 
    Pedestrian_allow = 0;
    case (current_state)
        NS_GREEN: begin
            NS_LEDS = GREEN;
            EW_LEDS = RED;
        end
        NS_YELLOW: begin
            NS_LEDS = YELLOW;
            EW_LEDS = RED;
        end

        EW_GREEN: begin
            NS_LEDS = RED;
            EW_LEDS = GREEN;
        end
        EW_YELLOW: begin
            NS_LEDS = RED;
            EW_LEDS = YELLOW;
        end
        PEDESTRIAN: begin
            NS_LEDS = RED;
            EW_LEDS = RED;
            Pedestrian_allow = 1;  // Pedestrians can cross when all lights are red
        end
        default: begin
            NS_LEDS = RED;
            EW_LEDS = RED;
        end
    endcase
end
endmodule