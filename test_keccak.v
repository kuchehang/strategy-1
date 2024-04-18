`timescale 1ns / 1ps
`define P 20

module test_keccak;

    // Inputs
    reg clk;
    reg reset;
    reg [63:0] in;
    reg in_ready;
    reg is_last;
    reg [2:0] byte_num;

    // Outputs
    wire buffer_full;
    wire [511:0] out;
    wire out_ready;

    // Var
    integer i;

    // Instantiate the Unit Under Test (UUT)
    keccak uut (
        .clk(clk),
        .reset(reset),
        .in(in),
        .in_ready(in_ready),
        .is_last(is_last),
        .byte_num(byte_num),
        .buffer_full(buffer_full),
        .out(out),
        .out_ready(out_ready)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        in = 0;
        in_ready = 0;
        is_last = 0;
        byte_num = 0;

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        @ (negedge clk);

      
        // // SHA3-512("The quick brown fox jumps over the lazy dog")
        reset = 1; #(`P); reset = 0;
        in_ready = 1; is_last = 0;
        in = "The quic"; #(`P);
        in = "k brown "; #(`P);
        in = "fox jump"; #(`P);
        in = "s over t"; #(`P);
        in = "he lazy "; #(`P);
        in = "dog     "; byte_num = 3; is_last = 1; #(`P); /* !!! not in = "dog" */
        in_ready = 0; is_last = 0;

        // add a pipe
        #(5*`P)
        in_ready = 1; is_last = 0;
        in = "The quic"; #(`P);
        in = "k brown "; #(`P);
        in = "fox jump"; #(`P);
        in = "s over t"; #(`P);
        in = "he lazy "; #(`P);
        in = "dog.    "; byte_num = 4; is_last = 1; #(`P); /* !!! not in = "dog." */
        in_ready = 0; is_last = 0;

        // add a pipe
        // hash an string "\xA1\xA2\xA3\xA4\xA5", len == 5
        #(5*`P); // wait some cycles
        in = 64'hA1A2A3A4A5000000;
        byte_num = 5;
        in_ready = 1;
        is_last = 1;
        #(`P);
        in = 64'h12345678; // next input
        in_ready = 1;
        is_last = 1;
        #(`P/2);
        if (buffer_full === 1) error; // should be 0
        #(`P/2);
        in_ready = 0;
        is_last = 0;

        // add a pipe
        // hash an (576-8) bit string
        #(9*`P); // wait some cycles
        in_ready = 1;
        byte_num = 7; /* should have no effect */
        is_last = 0;
        for (i=0; i<8; i=i+1)
          begin
            in = 64'hEFCDAB9078563412;
            #(`P);
          end
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;
        
        #(10*`P);
        in_ready = 1; is_last = 0;
        in = "The quic"; #(`P);
        in = "k brown "; #(`P);
        in = "fox jump"; #(`P);
        in = "s over t"; #(`P);
        in = "he lazy "; #(`P);
        in = "dog     "; byte_num = 3; is_last = 1; #(`P); /* !!! not in = "dog" */
        in_ready = 0; is_last = 0;
        
        #(5*`P)
        in_ready = 1; is_last = 0;
        in = "The quic"; #(`P);
        in = "k brown "; #(`P);
        in = "fox jump"; #(`P);
        in = "s over t"; #(`P);
        in = "he lazy "; #(`P);
        in = "dog.    "; byte_num = 4; is_last = 1; #(`P); /* !!! not in = "dog." */
        in_ready = 0; is_last = 0;
        
        #(5*`P); // wait some cycles
        in = 64'hA1A2A3A4A5000000;
        byte_num = 5;
        in_ready = 1;
        is_last = 1;
        #(`P);
        in = 64'h12345678; // next input
        in_ready = 1;
        is_last = 1;
        #(`P/2);
        if (buffer_full === 1) error; // should be 0
        #(`P/2);
        in_ready = 0;
        is_last = 0;
        
        // hash an (576-8) bit string
        #(9*`P); // wait some cycles
        in_ready = 1;
        byte_num = 7; /* should have no effect */
        is_last = 0;
        for (i=0; i<8; i=i+1)
          begin
            in = 64'hEFCDAB9078563412;
            #(`P);
          end
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;
        

        $display("pipeline successful!!!");
        #(30*`P);
        in_ready = 1; is_last = 0;
        in = "The quic"; #(`P);
        in = "k brown "; #(`P);
        in = "fox jump"; #(`P);
        in = "s over t"; #(`P);
        in = "he lazy "; #(`P);
        in = "dog     "; byte_num = 3; is_last = 1; #(`P); /* !!! not in = "dog" */
        in_ready = 0; is_last = 0;

        // add a pipe
        #(9*`P)
        in_ready = 1; is_last = 0;
        in = "The quic"; #(`P);
        in = "k brown "; #(`P);
        in = "fox jump"; #(`P);
        in = "s over t"; #(`P);
        in = "he lazy "; #(`P);
        in = "dog.    "; byte_num = 4; is_last = 1; #(`P); /* !!! not in = "dog." */
        in_ready = 0; is_last = 0;

        // add a pipe
        // hash an string "\xA1\xA2\xA3\xA4\xA5", len == 5
        #(9*`P); // wait some cycles
        in = 64'hA1A2A3A4A5000000;
        byte_num = 5;
        in_ready = 1;
        is_last = 1;
        #(`P);
        in = 64'h12345678; // next input
        in_ready = 1;
        is_last = 1;
        #(`P/2);
        if (buffer_full === 1) error; // should be 0
        #(`P/2);
        in_ready = 0;
        is_last = 0;

        // add a pipe

        // hash an (576-8) bit string
        #(9*`P); // wait some cycles
        in_ready = 1;
        byte_num = 7; /* should have no effect */
        is_last = 0;
        for (i=0; i<8; i=i+1)
          begin
            in = 64'hEFCDAB9078563412;
            #(`P);
          end
        is_last = 1;
        #(`P);
        in_ready = 0;
        is_last = 0;

        #(10*`P);

        while (out_ready !== 1)
            #(`P);

         // SHA3-512("The quick brown fox jumps over the lazy dog")
     
         #(50*`P);
         reset = 1; #(`P); reset = 0;
         in_ready = 1; is_last = 0;
         in = "The quic"; #(`P);
         in = "k brown "; #(`P);
         in = "fox jump"; #(`P);
         in = "s over t"; #(`P);
         in = "he lazy "; #(`P);
         in = "dog     "; byte_num = 3; is_last = 1; #(`P); /* !!! not in = "dog" */
         in_ready = 0; is_last = 0;
         while (out_ready !== 1)
             #(`P);
         check(512'hd135bb84d0439dbac432247ee573a23ea7d3c9deb2a968eb31d47c4fb45f1ef4422d6c531b5b9bd6f449ebcc449ea94d0a8f05f62130fda612da53c79659f609);
    
         #(30*`P);

         // SHA3-512("The quick brown fox jumps over the lazy dog.")
         reset = 1; #(`P); reset = 0;
         in_ready = 1; is_last = 0;
         in = "The quic"; #(`P);
         in = "k brown "; #(`P);
         in = "fox jump"; #(`P);
         in = "s over t"; #(`P);
         in = "he lazy "; #(`P);
         in = "dog.    "; byte_num = 4; is_last = 1; #(`P); /* !!! not in = "dog." */
         in_ready = 0; is_last = 0;
         while (out_ready !== 1)
             #(`P);
         check(512'hab7192d2b11f51c7dd744e7b3441febf397ca07bf812cceae122ca4ded6387889064f8db9230f173f6d1ab6e24b6e50f065b039f799f5592360a6558eb52d760);

         // hash an string "\xA1\xA2\xA3\xA4\xA5", len == 5
         #(10*`P); // wait some cycles
         reset = 1; #(`P); reset = 0;
         #(10*`P); // wait some cycles
         in = 64'hA1A2A3A4A5000000;
         byte_num = 5;
         in_ready = 1;
         is_last = 1;
         #(`P);
         in = 64'h12345678; // next input
         in_ready = 1;
         is_last = 1;
         #(`P/2);
//         if (buffer_full === 1) error; // should be 0
         #(`P/2);
         in_ready = 0;
         is_last = 0;

         while (out_ready !== 1)
             #(`P);
         check(512'h12f4a85b68b091e8836219e79dfff7eb9594a42f5566515423b2aa4c67c454de83a62989e44b5303022bfe8c1a9976781b747a596cdab0458e20d8750df6ddfb);
         for(i=0; i<5; i=i+1)
           begin
             #(`P);
             if (buffer_full !== 0) error; // should keep 0
           end

         // hash an empty string, should not eat next input

         #(10*`P); // wait some cycles
         reset = 1; #(`P); reset = 0;
         #(7*`P); // wait some cycles
         in = 64'h12345678; // should not be eat
         byte_num = 0;
         in_ready = 1;
         is_last = 1;
         #(`P);
         in = 64'hddddd; // should not be eat
         in_ready = 1; // next input
         is_last = 1;
         #(`P);
         in_ready = 0;
         is_last = 0;

         while (out_ready !== 1)
             #(`P);
         check(512'h0eab42de4c3ceb9235fc91acffe746b29c29a8c366b7c60e4e67c466f36a4304c00fa9caf9d87976ba469bcbe06713b435f091ef2769fb160cdab33d3670680e);
         for(i=0; i<5; i=i+1)
           begin
             #(`P);
             if (buffer_full !== 0) error; // should keep 0
           end

         // hash an (576-8) bit string
         #(10*`P); // wait some cycles
         reset = 1; #(`P); reset = 0;
         #(4*`P); // wait some cycles
         in_ready = 1;
         byte_num = 7; /* should have no effect */
         is_last = 0;
         for (i=0; i<8; i=i+1)
           begin
             in = 64'hEFCDAB9078563412;
             #(`P);
           end
         is_last = 1;
         #(`P);
         in_ready = 0;
         is_last = 0;
         while (out_ready !== 1)
             #(`P);
         check(512'hf7f6b44069dba8900b6711ffcbe40523d4bb718cc8ed7f0a0bd28a1b18ee9374359f0ca0c9c1e96fcfca29ee2f282b46d5045eff01f7a7549eaa6b652cbf6270);

         // pad an (576-64) bit string
         #(10*`P); // wait some cycles
         reset = 1; #(`P); reset = 0;
         // don't wait any cycle
         in_ready = 1;
         byte_num = 7; /* should have no effect */
         is_last = 0;
         for (i=0; i<8; i=i+1)
           begin
             in = 64'hEFCDAB9078563412;
             #(`P);
           end
         is_last = 1;
         byte_num = 0;
         #(`P);
         in_ready = 0;
         is_last = 0;
         in = 0;
         while (out_ready !== 1)
             #(`P);
         check(512'hccd91653872c106f6eea1b8b68a4c2901c8d9bed9c180201f8a6144e7e6e6c251afcb6f6da44780b2d9aabff254036664719425469671f7e21fb67e5280a27ed);

        $display("Good!");
        $finish;
    end

    always #(`P/2) clk = ~ clk;

    task error;
        begin
              $display("E");
//              $finish;
        end
    endtask

    task check;
        input [511:0] wish;
        begin
          if (out !== wish)
            begin
              $display("%h %h", out, wish); error;
            end
        end
    endtask
endmodule

`undef P