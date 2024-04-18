`timescale 1ns / 1ps
`define P 20

module test_padder1;

    // Inputs
    reg [63:0] in;
    reg [2:0] byte_num;

    // Outputs
    wire [63:0] out;
    
    reg [63:0] wish;

    // Instantiate the Unit Under Test (UUT)
    padder1 uut (
        .in(in),
        .byte_num(byte_num),
        .out(out)
    );

    initial begin
        // Initialize Inputs
        in = 0;
        byte_num = 0;

        // Wait 100 ns for global reset to finish
        #100;

        // Add stimulus here
        in = 64'h1234567890ABCDEF;
        byte_num = 0;
        wish = {8'h01, 56'h0};
        check;
        byte_num = 1;
        wish = 64'h1201000000000000;
        check;
        byte_num = 2;
        wish = 64'h1234010000000000;
        check;
        byte_num = 3;
        wish = 64'h1234560100000000;
        check;
        byte_num = 4;
        wish = 64'h1234567801000000;
        check;
        byte_num = 5;
        wish = 64'h1234567890010000;
        check;
        byte_num = 6;
        wish = 64'h1234567890AB0100;
        check;
        byte_num = 7;
        wish = 64'h1234567890ABCD01;
        check;
        $display("Good!");
        $finish;
    end

    task check;
      begin
        #(`P);
        if (out !== wish)
          begin
            $display("E");
            $finish;
          end
      end
    endtask
endmodule

`undef P