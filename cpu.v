module cpu(
    input clk,
    input rst,

    input code_rdl,
    output[31:0] code_addr,
    input[31:0] code_data,

    output reg ram_r_en,
    input[31:0] ram_r_data,

    output reg ram_w_en,
    output reg[31:0] ram_w_data,

    output reg[31:0] ram_wr_addr
 );


    reg[31:0] r[15:0];
    wire[31:0] r0 = r[0];
    wire[31:0] r1 = r[1];
    wire[31:0] r2 = r[2];
    wire[31:0] r3 = r[3];
    wire[31:0] r4 = r[4];
    wire[31:0] r5 = r[5];
    wire[31:0] r6 = r[6];
    wire[31:0] r7 = r[7];
    wire[31:0] r8 = r[8];





    assign code_addr = r[15];
    initial begin
        r[15] = 32'h0;
        ram_r_en = 0;
        ram_w_en = 0;
    end

    reg[31:0] temp;
    integer  ocode,icode,tag=0;
    always @(negedge clk or negedge rst) begin
        if((rst == 0) || (code_rdl == 0)) begin//重置
            r[15] = 32'h0;
        end 
        else begin
            case(tag)
                0:begin
                    r[15] = r[15] + 1;
                    ocode = code_data[31-:3];
                    icode = code_data[28-:5];  
                    case(ocode)
                        0:begin//跳转 if
                            if(r[code_data[23-:4]] != 0)begin
                               r[15] = r[15] + 1;
                            end
                        end
                        1:begin//寄存器运算
                            case(icode)
                                0:begin//写寄存器低16位 
                                    r[code_data[23-:4]][15:0] = code_data[19-:16];
                                end
                                1:begin//写寄存器高16位
                                    r[code_data[23-:4]][31:16] = code_data[19-:16];
                                end
                                2:begin//加
                                    temp = r[code_data[19-:4]];
                                    r[code_data[23-:4]] = temp + r[code_data[15-:4]];
                                end
                                3:begin//减
                                    temp = r[code_data[19-:4]];
                                    r[code_data[23-:4]] = temp - r[code_data[15-:4]];
                                end
                                4:begin//或
                                     temp = r[code_data[19-:4]];
                                    r[code_data[23-:4]] = temp | r[code_data[15-:4]];
                                end
                                5:begin//且
                                     temp = r[code_data[19-:4]];
                                    r[code_data[23-:4]] = temp & r[code_data[15-:4]];
                                end
                                6:begin//翻转
                                    temp = r[code_data[19-:4]];
                                    r[code_data[23-:4]] = ~temp;
                                end
                                7:begin//左移
                                     temp = r[code_data[19-:4]];
                                    r[code_data[23-:4]] = temp << r[code_data[15-:4]];
                                end
                                8:begin//右移
                                     temp = r[code_data[19-:4]];
                                    r[code_data[23-:4]] = temp >> r[code_data[15-:4]];
                                end
                                9:begin//大于 返回0或1
                                    if(r[code_data[19-:4]] > r[code_data[15-:4]])begin
                                        r[code_data[23-:4]]  = 32'd1;
                                    end
                                    else begin
                                        r[code_data[23-:4]]  = 32'd0;
                                    end
                                end
                                10:begin//小于
                                    if(r[code_data[19-:4]] < r[code_data[15-:4]])begin
                                        r[code_data[23-:4]]  = 32'd1;
                                    end
                                    else begin
                                        r[code_data[23-:4]]  = 32'd0;
                                    end
                                end
                            endcase
                        end
                        2:begin//内存读准备 r0：地址，r1:目标寄存器
                            tag = 1;
                            ram_r_en = 1;//使能读
                            ram_wr_addr = r[code_data[23-:4]];
                        end
                        3:begin//内存写准备 r0:地址，r1:待写入
                            tag = 2;
                            ram_w_en = 1;//使能写
                            ram_wr_addr = r[code_data[23-:4]];
                            ram_w_data = r[code_data[19-:4]];
                        end
                    endcase
                end
                1:begin//读完成
                    r[code_data[19-:4]] = ram_r_data;
                    tag = 0;
                    ram_r_en = 0;
                end
                2:begin//写完成
                    tag = 0;
                    ram_w_en = 0;
                end
            endcase
        end
    end

endmodule
