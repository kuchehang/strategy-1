module f_permutation (
    clk,
    reset,
    in,
    in_ready,
    ack,
    out,
    out_ready
);
    input clk, reset;
    input [575:0] in;
    input in_ready;
    output ack;
    output reg [1599:0] out;
    output out_ready;

    reg [10:0] i;  // select round constant 
    reg [10:0] i1_r, i2_r, i3_r, i4_r;
    reg [10:0]
        i1_d_r, i2_d_r, i3_d_r, i4_d_r; 
    reg [10:0] i1_d_r1, i2_d_r1, i3_d_r1, i4_d_r1;  
    reg [10:0] i1_d_r2, i2_d_r2, i3_d_r2, i4_d_r2;
    reg [10:0] i1_d_r3, i2_d_r3, i3_d_r3, i4_d_r3;
    reg [10:0] i1_d_r4, i2_d_r4, i3_d_r4, i4_d_r4;
    reg i1_next_exce, i2_next_exce, i3_next_exce, i4_next_exce;
    reg [3:0] i1_h_rr, i2_h_rr, i3_h_rr, i4_h_rr;
    wire i1_h_fall, i2_h_fall, i3_h_fall, i4_h_fall;
    reg [ 3:0] pp_state_r;  
    reg [ 3:0] pp_state_r1;
    reg [10:0] i_d_r1;
    reg [ 3:0] clk_shift;
    wire [1599:0] round_in, round_out;
    wire [63:0] rc1, rc2;
    reg [11:0] rconst_i1, rconst_i2;

    reg  [575:0] in_buf; 

    wire         update;
    reg update_r1, update_r2, update_r3, update_r4;
    wire accept;
    reg accept_r1, accept_r2;
    reg        calc;  /* == 1: calculating rounds */
    wire       in_ready_rise;
    reg  [1:0] in_ready_rr;
    reg input_change_r1, input_change_r2;
    wire input_hold;

    assign update        = calc | accept;
    assign accept        = in_ready_rise;
    assign in_ready_rise = in_ready_rr == 2'b01 ? 1'b1 : 1'b0;
    assign ack           = accept;

  
    always @(posedge clk) begin
        if (reset) begin
            in_buf <= 0;
        end else if (in_ready_rise) begin
            in_buf <= in;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            in_ready_rr <= 0;
        end else begin
            in_ready_rr <= {in_ready_rr[0], in_ready};
        end
    end

    always @(posedge clk)
        if (reset) begin
            calc <= 0;
        end else begin
            calc <= (pp_state_r != 4'b0000) | accept;
        end

    always @(posedge clk) begin
        if (reset) begin
            accept_r1 <= 0;
        end else begin
            accept_r1 <= accept;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            update_r1 <= 0;
            update_r2 <= 0;
            update_r3 <= 0;
            update_r4 <= 0;
        end else begin
            update_r1 <= update;
            update_r2 <= update_r1;
            update_r3 <= update_r2;
            update_r4 <= update_r3;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            clk_shift <= 2'b01;
        end else begin
            clk_shift <= {clk_shift[2:0], clk_shift[3]};
        end
    end

    always @(posedge clk)
        if (reset) begin
            i <= 0;
        end else if (accept) begin
            i <= {i[9:0], 1'b1};
        end else if (clk_shift == 2'd1) begin
            i <= {i[9:0], 1'b0};
        end

    always @(posedge clk) begin
        if (reset) begin
            i_d_r1 <= 0;
        end else begin
            i_d_r1 <= i;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            input_change_r1 <= 0;
            pp_state_r      <= 0;
            i1_r = 0;
            i2_r = 0;
            i3_r = 0;
            i4_r = 0;
            i1_d_r       <= 0;
            i2_d_r       <= 0;
            i3_d_r       <= 0;
            i4_d_r       <= 0;
            pp_state_r   <= 0;
            i1_next_exce <= 0;
            i2_next_exce <= 0;
            i3_next_exce <= 0;
            i4_next_exce <= 0;
        end else begin
            input_change_r1 <= 0;
            if (i1_h_fall) pp_state_r[0] <= 0;
            else if (i2_h_fall) pp_state_r[1] <= 0;
            else if (i3_h_fall) pp_state_r[2] <= 0;
            else if (i4_h_fall) pp_state_r[3] <= 0;
                
            case (clk_shift)
                'b0001: begin
                    i1_r        <= {i1_r[9:0], 1'b0};
                    i1_d_r      <= i1_r;
                 
                    if (accept & ~pp_state_r[0]) begin
                        input_change_r1 <= 1;
                        pp_state_r[0]   <= 1;
                        i1_next_exce    <= 1;
                        i1_r            <= {10'b0, 1'b1};
                    end else if (i1_next_exce) begin
                        i1_next_exce <= 0;
                    end

                end
                'b0010: begin
                    i2_r   <= {i2_r[9:0], 1'b0};
                    i2_d_r <= i2_r;
                 
                    if (accept & ~pp_state_r[1]) begin
                        input_change_r1 <= 1;
                        pp_state_r[1]   <= 1;
                        i2_next_exce    <= 1;
                        i2_r            <= {10'b0, 1'b1};
                    end else if (i2_next_exce) begin
                        i2_next_exce <= 0;
                    end
                end
                'b0100: begin
                    i3_r   <= {i3_r[9:0], 1'b0};
                    i3_d_r <= i3_r;
               
                    if (accept & ~pp_state_r[2]) begin
                        input_change_r1 <= 1;
                        pp_state_r[2]   <= 1;
                        i3_next_exce    <= 1;
                        i3_r            <= {10'b0, 1'b1};
                    end else if (i3_next_exce) begin
                        i3_next_exce <= 0;
                    end
                end
                'b1000: begin
                    i4_r   <= {i4_r[9:0], 1'b0};
                    i4_d_r <= i4_r;
             
                    if (accept & ~pp_state_r[3]) begin
                        input_change_r1 <= 1;
                        pp_state_r[3]   <= 1;
                        i4_next_exce    <= 1;
                        i4_r            <= {10'b0, 1'b1};
                    end else if (i4_next_exce) begin
                        i4_next_exce <= 0;
                    end
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            i1_d_r1 <= 0;
            i2_d_r1 <= 0;
            i3_d_r1 <= 0;
            i4_d_r1 <= 0;
            i1_d_r2 <= 0;
            i2_d_r2 <= 0;
            i3_d_r2 <= 0;
            i4_d_r2 <= 0;
            i1_d_r3 <= 0;
            i2_d_r3 <= 0;
            i3_d_r3 <= 0;
            i4_d_r3 <= 0;
            i1_d_r4 <= 0;
            i2_d_r4 <= 0;
            i3_d_r4 <= 0;
            i4_d_r4 <= 0;
        end else begin
            i1_d_r1 <= i1_r;
            i1_d_r2 <= i1_d_r1;
            i1_d_r3 <= i1_d_r2;
            i1_d_r4 <= i1_d_r3;
            i2_d_r1 <= i2_r;
            i2_d_r2 <= i2_d_r1;
            i2_d_r3 <= i2_d_r2;
            i2_d_r4 <= i2_d_r3;
            i3_d_r1 <= i3_r;
            i3_d_r2 <= i3_d_r1;
            i3_d_r3 <= i3_d_r2;
            i3_d_r4 <= i3_d_r3;
            i4_d_r1 <= i4_r;
            i4_d_r2 <= i4_d_r1;
            i4_d_r3 <= i4_d_r2;
            i4_d_r4 <= i4_d_r3;
        end
    end

    always @(posedge clk) begin
        if (reset) input_change_r2 <= 0;
        else input_change_r2 <= input_change_r1;
    end

    assign i1_h_fall = i1_h_rr[3:0] == 4'b1111 ? 1'b1 : 1'b0;
    assign i2_h_fall = i2_h_rr[3:0] == 4'b1111 ? 1'b1 : 1'b0;
    assign i3_h_fall = i3_h_rr[3:0] == 4'b1111 ? 1'b1 : 1'b0;
    assign i4_h_fall = i4_h_rr[3:0] == 4'b1111 ? 1'b1 : 1'b0;
    always @(posedge clk) begin
        if (reset) begin
            i1_h_rr <= 0;
            i2_h_rr <= 0;
            i3_h_rr <= 0;
            i4_h_rr <= 0;
        end else begin
            i1_h_rr <= {i1_h_rr[2:0], i1_d_r[10]};
            i2_h_rr <= {i2_h_rr[2:0], i2_d_r[10]};
            i3_h_rr <= {i3_h_rr[2:0], i3_d_r[10]};
            i4_h_rr <= {i4_h_rr[2:0], i4_d_r[10]};
        end
    end

    assign out_ready  = i1_h_fall | i2_h_fall | i3_h_fall | i4_h_fall;


    assign input_hold = input_change_r1 | input_change_r2;
    // assign round_in   = input_change_r1 ? {in_buf ^ 576'b0, 1024'b0} : out;
    assign round_in   = input_change_r1 ? {in_buf ^ 576'b0, 1024'b0} : out;
    // assign round_in = 0;



    always @(posedge clk) begin
        if (reset) begin
            rconst_i1 <= 0;
            rconst_i2 <= 0;
        end else begin
            case (clk_shift)
                'b0001: begin 

                    rconst_i1 <= {i4_d_r[10], i4_r};
                    rconst_i2 <= {i2_d_r[10], i2_r};

                end
                'b0010: begin 

                    rconst_i1 <= {i1_d_r[10], i1_r};
                    rconst_i2 <= {i3_d_r[10], i3_r};
                end
                'b0100: begin 

                    rconst_i1 <= {i2_d_r[10], i2_r};
                    rconst_i2 <= {i4_d_r[10], i4_r};
                end
                'b1000: begin 

                    rconst_i1 <= {i3_d_r[10], i3_r};
                    rconst_i2 <= {i1_d_r[10], i1_r};
                end
                default: begin
                    rconst_i1 <= 0;
                    rconst_i2 <= 0;
                end
            endcase
        end
    end

    rconst2in1 rconst_ (
        rconst_i1,
        rconst_i2,
        rc1,
        rc2
    );

    round2in1 round_ (
        clk,
        reset,
        round_in,
        rc1,
        rc2,
        round_out
    );



    always @(posedge clk)
        if (reset) begin
            out <= 0;
        end else if (update_r3) begin
            out <= round_out;
        end else begin
            out <= 0;
        end
endmodule