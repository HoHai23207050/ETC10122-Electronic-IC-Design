`timescale 1ns/1ps
`default_nettype none

// =============================================================================
// Self-checking testbench for ram_2port
//
// The testbench verifies:
//   1. Active-high asynchronous reset of both registered outputs.
//   2. Concurrent independent accesses through ports A and B.
//   3. Output retention when a read enable is low.
//   4. Same-port READ_FIRST behavior on ports A and B.
//   5. Cross-port READ_FIRST behavior in both directions.
//   6. Visibility of newly written data on subsequent reads.
//
// The DUT is instantiated without parameter overrides so that this same
// testbench can be used for both default RTL and a flattened mapped netlist.
// =============================================================================

module ram_2port_tb;

    localparam integer DATA_WIDTH      = 8;
    localparam integer ADDR_WIDTH      = 4;
    localparam integer EXPECTED_CHECKS = 12;

    reg                   clk;
    reg                   r;

    reg                   we_a;
    reg                   re_a;
    reg  [ADDR_WIDTH-1:0] addr_a;
    reg  [DATA_WIDTH-1:0] wdata_a;
    wire [DATA_WIDTH-1:0] rdata_a;

    reg                   we_b;
    reg                   re_b;
    reg  [ADDR_WIDTH-1:0] addr_b;
    reg  [DATA_WIDTH-1:0] wdata_b;
    wire [DATA_WIDTH-1:0] rdata_b;

    integer errors;
    integer checks;

    ram_2port dut (
        .clk    (clk),
        .r      (r),

        .we_a   (we_a),
        .re_a   (re_a),
        .addr_a (addr_a),
        .wdata_a(wdata_a),
        .rdata_a(rdata_a),

        .we_b   (we_b),
        .re_b   (re_b),
        .addr_b (addr_b),
        .wdata_b(wdata_b),
        .rdata_b(rdata_b)
    );

    // 100 MHz clock: Tclk = 10 ns.
    always #5 clk = ~clk;

    // The RAM specification excludes simultaneous writes to the same address.
    // Convert any accidental illegal stimulus into a visible test failure.
    always @(posedge clk) begin
        if (!r && we_a && we_b && (addr_a == addr_b)) begin
            $display(
                "ERROR: illegal dual-write collision time=%0t address=%0h",
                $time,
                addr_a
            );
            errors = errors + 1;
        end
    end

    // Apply one complete clock transaction. Inputs change on the falling edge,
    // the DUT samples them on the next rising edge, and outputs are observed
    // 1 ns later to avoid a race with nonblocking assignments.
    task apply_cycle;
        input                  wea_i;
        input                  rea_i;
        input [ADDR_WIDTH-1:0] addra_i;
        input [DATA_WIDTH-1:0] dataa_i;

        input                  web_i;
        input                  reb_i;
        input [ADDR_WIDTH-1:0] addrb_i;
        input [DATA_WIDTH-1:0] datab_i;

        begin
            @(negedge clk);

            we_a    = wea_i;
            re_a    = rea_i;
            addr_a  = addra_i;
            wdata_a = dataa_i;

            we_b    = web_i;
            re_b    = reb_i;
            addr_b  = addrb_i;
            wdata_b = datab_i;

            @(posedge clk);
            #1;
        end
    endtask

    task check_outputs;
        input [8*80-1:0]       test_name;
        input [DATA_WIDTH-1:0] expected_a;
        input [DATA_WIDTH-1:0] expected_b;

        begin
            checks = checks + 1;

            if ((rdata_a !== expected_a) ||
                (rdata_b !== expected_b)) begin
                $display(
                    "FAIL [%0s] time=%0t A=%0h expected=%0h B=%0h expected=%0h",
                    test_name,
                    $time,
                    rdata_a,
                    expected_a,
                    rdata_b,
                    expected_b
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS [%0s] time=%0t A=%0h B=%0h",
                    test_name,
                    $time,
                    rdata_a,
                    rdata_b
                );
            end
        end
    endtask

    // Reset checks contribute to the error total, but are kept separate from
    // the 12 normal-operation checks expected by the post-synthesis script.
    task check_reset_outputs;
        input [8*80-1:0] test_name;

        begin
            if ((rdata_a !== {DATA_WIDTH{1'b0}}) ||
                (rdata_b !== {DATA_WIDTH{1'b0}})) begin
                $display(
                    "FAIL [%0s] time=%0t A=%0h expected=00 B=%0h expected=00",
                    test_name,
                    $time,
                    rdata_a,
                    rdata_b
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS [%0s] time=%0t A=%0h B=%0h",
                    test_name,
                    $time,
                    rdata_a,
                    rdata_b
                );
            end
        end
    endtask

    initial begin
        $dumpfile("ram_2port_postsyn.vcd");
        $dumpvars(0, ram_2port_tb);

        clk     = 1'b0;
        r       = 1'b0;

        we_a    = 1'b0;
        re_a    = 1'b0;
        addr_a  = {ADDR_WIDTH{1'b0}};
        wdata_a = {DATA_WIDTH{1'b0}};

        we_b    = 1'b0;
        re_b    = 1'b0;
        addr_b  = {ADDR_WIDTH{1'b0}};
        wdata_b = {DATA_WIDTH{1'b0}};

        errors  = 0;
        checks  = 0;

        // Generate an explicit rising edge on r to exercise asynchronous reset.
        #1;
        r = 1'b1;
        #1;
        check_reset_outputs("initial asynchronous reset");
        r = 1'b0;

        // Initialize address 1 and address 2 through different write ports.
        apply_cycle(
            1'b1, 1'b0, 4'h1, 8'h11,
            1'b1, 1'b0, 4'h2, 8'h22
        );

        // Check 1: simultaneous independent reads.
        apply_cycle(
            1'b0, 1'b1, 4'h1, 8'h00,
            1'b0, 1'b1, 4'h2, 8'h00
        );
        check_outputs("dual independent read", 8'h11, 8'h22);

        // Write address 3 and address 4 while both read enables are low.
        apply_cycle(
            1'b1, 1'b0, 4'h3, 8'h33,
            1'b1, 1'b0, 4'h4, 8'h44
        );

        // Check 2: registered read outputs retain their previous values.
        check_outputs("read outputs hold", 8'h11, 8'h22);

        // Check 3: cross-address independent reads.
        apply_cycle(
            1'b0, 1'b1, 4'h4, 8'h00,
            1'b0, 1'b1, 4'h3, 8'h00
        );
        check_outputs("cross-address read", 8'h44, 8'h33);

        // Check 4: same-port READ_FIRST on port A. Address 1 changes from 11
        // to AA, but rdata_a receives the old value 11 on this edge.
        apply_cycle(
            1'b1, 1'b1, 4'h1, 8'hAA,
            1'b0, 1'b1, 4'h2, 8'h00
        );
        check_outputs("port A READ_FIRST", 8'h11, 8'h22);

        // Check 5: the new port-A value is visible on the following read.
        apply_cycle(
            1'b0, 1'b1, 4'h1, 8'h00,
            1'b0, 1'b0, 4'h0, 8'h00
        );
        check_outputs("new port A value", 8'hAA, 8'h22);

        // Check 6: same-port READ_FIRST on port B. Address 2 changes from 22
        // to BB, but rdata_b receives the old value 22 on this edge.
        apply_cycle(
            1'b0, 1'b1, 4'h3, 8'h00,
            1'b1, 1'b1, 4'h2, 8'hBB
        );
        check_outputs("port B READ_FIRST", 8'h33, 8'h22);

        // Check 7: the new port-B value is visible on the following read.
        apply_cycle(
            1'b0, 1'b0, 4'h0, 8'h00,
            1'b0, 1'b1, 4'h2, 8'h00
        );
        check_outputs("new port B value", 8'h33, 8'hBB);

        // Check 8: A writes address 3 while B reads that address. B must see
        // the old value 33; A's disabled read output retains 33.
        apply_cycle(
            1'b1, 1'b0, 4'h3, 8'hCC,
            1'b0, 1'b1, 4'h3, 8'h00
        );
        check_outputs("A write B READ_FIRST", 8'h33, 8'h33);

        // Check 9: the new address-3 value CC is visible afterward.
        apply_cycle(
            1'b0, 1'b1, 4'h3, 8'h00,
            1'b0, 1'b0, 4'h0, 8'h00
        );
        check_outputs("new cross-port A value", 8'hCC, 8'h33);

        // Check 10: B writes address 4 while A reads that address. A must see
        // the old value 44; B's disabled read output retains 33.
        apply_cycle(
            1'b0, 1'b1, 4'h4, 8'h00,
            1'b1, 1'b0, 4'h4, 8'hDD
        );
        check_outputs("B write A READ_FIRST", 8'h44, 8'h33);

        // Check 11: the new address-4 value DD is visible afterward.
        apply_cycle(
            1'b0, 1'b0, 4'h0, 8'h00,
            1'b0, 1'b1, 4'h4, 8'h00
        );
        check_outputs("new cross-port B value", 8'h44, 8'hDD);

        // Check 12: both ports concurrently read the final updated words.
        apply_cycle(
            1'b0, 1'b1, 4'h3, 8'h00,
            1'b0, 1'b1, 4'h4, 8'h00
        );
        check_outputs("final concurrent read", 8'hCC, 8'hDD);

        // Recheck that r acts asynchronously and clears both output registers.
        @(negedge clk);
        we_a = 1'b0;
        re_a = 1'b0;
        we_b = 1'b0;
        re_b = 1'b0;
        #1;
        r = 1'b1;
        #1;
        check_reset_outputs("final asynchronous reset");
        r = 1'b0;

        if ((errors == 0) && (checks == EXPECTED_CHECKS)) begin
            $display("RESULT: PASS - 12 checks passed.");
        end
        else begin
            $fatal(
                1,
                "RESULT: FAIL - %0d error(s), %0d/%0d checks executed.",
                errors,
                checks,
                EXPECTED_CHECKS
            );
        end

        #2;
        $finish;
    end

endmodule

`default_nettype wire
