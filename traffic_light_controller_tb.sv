`timescale 1ns/1ps // Specifies the time unit and precision in the simulation
module TLC_tb; //traffic_light_controller_tb

     logic Pedestrian_req_t;
     logic clk_t, reset_t;
     logic [2:0]NS_LEDS_t ,EW_LEDS_t;
     logic Pedestrian_allow_t;
    
    TLC TEST (Pedestrian_req_t,clk_t, reset_t,NS_LEDS_t ,EW_LEDS_t,Pedestrian_allow_t);
      
always #10 clk_t = ~clk_t;

initial begin  // Stimulus generation
           // Initialize inputs
        clk_t = 0;
        reset_t = 1;
        Pedestrian_req_t = 0;

        // Apply reset pulse
        #20 reset_t = 0;

        // Let the system run for a while in the default state
        #100;

        // Apply pedestrian request at different times
        #50 Pedestrian_req_t = 1;  // Request pedestrian crossing
        #20 Pedestrian_req_t = 0;  // Release pedestrian crossing
        #100;  // Wait for some time

        #50 Pedestrian_req_t = 1;  // Request pedestrian crossing again
        #20 Pedestrian_req_t = 0;  // Release pedestrian crossing

        // Let the simulation run for enough time to observe all states
        #600;
        $finish ;
            
      end

      initial 
        begin	// Response monitor
            $monitor("NS_LEDS: %b | EW_LEDS: %b | Pedestrian_allow: %b |reset: %b |pedestrian_req_t: %b",
             NS_LEDS_t, EW_LEDS_t, Pedestrian_allow_t ,reset_t ,Pedestrian_req_t);  
        end
endmodule
