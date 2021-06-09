`timescale 1ns/1ps
module test( );

    reg clk=0;
    reg rst = 1;
    always  begin
        #1 clk = clk + 1;
    end

    wire[31:0] code_addr;
    reg[31:0] code_data;
    reg code_rdl=0;
    wire ram_r_en;
    wire ram_w_en;
    wire[31:0] ram_w_data;
    reg[31:0] ram_r_data;
    wire[31:0] ram_wr_addr;



    cpu c0(
        .clk (clk),
        .rst (rst),
        .code_rdl (code_rdl),
        .code_addr (code_addr),
        .code_data (code_data),
        .ram_r_en (ram_r_en),
        .ram_r_data (ram_r_data),
        .ram_w_en (ram_w_en),
        .ram_w_data (ram_w_data),
        .ram_wr_addr (ram_wr_addr)
    );




    reg[31:0] ram[16:0];

    always @(posedge clk) begin
        if(ram_r_en == 1)begin
            ram_r_data = ram[ram_wr_addr];
        end
        else if(ram_w_en)begin
            ram[ram_wr_addr] = ram_w_data;
        end
    end



    reg[31:0] rom[8*1024-1:0];
    `define CODE_FILE "D:/Desktop/out.list"
    initial begin
        $readmemh(`CODE_FILE,rom,0,1024*8*4);
    end

    always @(posedge clk) begin
        code_rdl = 1;
        code_data = rom[code_addr];
    end




endmodule
