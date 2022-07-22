LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;
USE work.types.ALL;
USE work.config.ALL;

ENTITY encoder IS
    PORT (
        msg     : IN MSG_MAT;       -- message matrix
        gen     : IN GEN_MAT;       -- generator matrix
        encoded : OUT CODEWORD_MAT; -- codeword matrix
        done    : OUT STD_LOGIC;    -- signal of work done
        rst     : IN STD_LOGIC;     -- reset done status and clock of work
        clk     : IN STD_LOGIC      -- clock
    );
END encoder;

ARCHITECTURE Encoder OF encoder IS
    -- This is a transpose of the message after one round of encoding
    TYPE HALF_CODEMSG_MAT_TRANSPOSED IS ARRAY (0 TO CODEWORD_LENGTH) OF MSG_LINE;
    TYPE HALF_CODEMSG_MAT IS ARRAY (0 TO MSG_LENGTH) OF CODEWORD_LINE;
    PROCEDURE line_encoder (
        VARIABLE lin  : IN MSG_LINE;
        VARIABLE lout : OUT CODEWORD_LINE
    ) IS
        VARIABLE mux : BIT;
    BEGIN
        lout := (OTHERS => '0');
        FOR col IN 0 TO CODEWORD_LENGTH LOOP
            FOR row IN 0 TO MSG_LENGTH LOOP
                lout(col) := (lin(row) AND gen(row, col)) XOR lout(col);
            END LOOP;
        END LOOP;
    END PROCEDURE;
BEGIN
    encoding : PROCESS (msg, gen, clk, rst)
        VARIABLE temp            : HALF_CODEMSG_MAT;
        VARIABLE temp_transposed : HALF_CODEMSG_MAT_TRANSPOSED;
        VARIABLE codeword        : CODEWORD_MAT;
        VARIABLE msg_lin         : MSG_LINE;
    BEGIN
        IF rst = '1' THEN
            done <= '0';
        ELSIF done = '1' THEN
            REPORT "Already done, do nothing";
        ELSIF rising_edge(clk) THEN
            REPORT "Start encoding";
            encode_lines_r1 : FOR L IN 0 TO MSG_LENGTH LOOP
                msg_lin := msg(L);
                line_encoder(lin => msg_lin, lout => temp(L));
            END LOOP; -- encode_lines_r1

            transpose_temp : FOR row IN 0 TO temp'length - 1 LOOP
                FOR col IN 0 TO temp(0)'length - 1 LOOP
                    temp_transposed(col)(row) := temp(row)(col);
                END LOOP;
            END LOOP; -- transpose_temp

            REPORT "temp'=";
            debug_output : FOR row IN 0 TO temp_transposed'length - 1 LOOP
                REPORT INTEGER'image(row) & " => " & to_string(temp_transposed(row));
                REPORT INTEGER'image(row) & " => " & to_string(temp_transposed(row));
            END LOOP; -- debug_output
            REPORT "temp=";
            debug_output2 : FOR row IN 0 TO temp'length - 1 LOOP
                REPORT INTEGER'image(row) & " => " & to_string(temp(row));
            END LOOP; -- debug_output

            encode_lines_r2 : FOR L IN 0 TO CODEWORD_LENGTH LOOP
                msg_lin := temp_transposed(L);
                line_encoder(lin => msg_lin, lout => codeword(L));
            END LOOP; -- encode_lines_r2
            done <= '1';
        END IF;
        encoded <= codeword;
    END PROCESS;
END ARCHITECTURE;