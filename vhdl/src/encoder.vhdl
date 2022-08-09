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
        ready   : OUT STD_LOGIC;    -- signal of work ready
        rst     : IN STD_LOGIC;     -- reset ready status and clock of work
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
            ready <= '0';
        ELSIF ready = '1' THEN
            REPORT "Already ready, do nothing";
        ELSIF rising_edge(clk) THEN

            REPORT "[ENC] Encoding first round.";
            encode_lines_r1 : FOR L IN 0 TO MSG_LENGTH LOOP
                msg_lin := msg(L);
                line_encoder(lin => msg_lin, lout => temp(L));
            END LOOP; -- encode_lines_r1

            REPORT "[ENC] Transpose.";
            transpose_temp : FOR row IN 0 TO temp'length - 1 LOOP
                FOR col IN 0 TO temp(0)'length - 1 LOOP
                    temp_transposed(col)(row) := temp(row)(col);
                END LOOP;
            END LOOP; -- transpose_temp

            REPORT "[ENC] Encoding second round.";
            encode_lines_r2 : FOR L IN 0 TO CODEWORD_LENGTH LOOP
                msg_lin := temp_transposed(L);
                line_encoder(lin => msg_lin, lout => codeword(L));
            END LOOP; -- encode_lines_r2
            ready <= '1';
            REPORT "Finished encoding";
        END IF;
        encoded <= codeword;
    END PROCESS;
END ARCHITECTURE;