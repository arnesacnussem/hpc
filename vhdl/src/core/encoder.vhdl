LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_bit.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;

ENTITY encoder IS
    PORT (
        msg   : IN MSG_MAT;           -- message matrix
        code  : OUT CODEWORD_MAT;     -- codeword matrix
        ready : OUT STD_LOGIC := '0'; -- signal of work ready
        rst   : IN STD_LOGIC;         -- reset ready status and clock of work
        clk   : IN STD_LOGIC          -- clock
    );
END encoder;

ARCHITECTURE Encoder OF encoder IS
    -- This is a transpose of the message after one round of encoding
    TYPE HALF_CODEMSG_MAT_TRANSPOSED IS ARRAY (0 TO CODEWORD_LENGTH) OF MSG_LINE;
    TYPE HALF_CODEMSG_MAT IS ARRAY (0 TO MSG_LENGTH) OF CODEWORD_LINE;
    TYPE state_t IS (R1, T, R2, RDY);
    SIGNAL stat : state_t := R1;

    PROCEDURE line_encoder (
        VARIABLE lin  : IN MSG_LINE;
        VARIABLE lout : OUT CODEWORD_LINE
    ) IS
    BEGIN
        lout := (OTHERS => '0');
        FOR col IN 0 TO CODEWORD_LENGTH LOOP
            FOR row IN 0 TO MSG_LENGTH LOOP
                lout(col) := (lin(row) AND GENERATE_MATRIX(row)(col)) XOR lout(col);
            END LOOP;
        END LOOP;
    END PROCEDURE;
BEGIN
    encoding : PROCESS (clk)
        VARIABLE temp            : HALF_CODEMSG_MAT;
        VARIABLE temp_transposed : HALF_CODEMSG_MAT_TRANSPOSED;
        VARIABLE codeword        : CODEWORD_MAT;
        VARIABLE msg_tmp         : MSG_MAT := msg;
        VARIABLE index           : NATURAL := 0;
    BEGIN
        code <= codeword;
        msg_tmp := msg;
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                codeword := (OTHERS => (others => '0'));
                index    := 0;
                ready <= '0';
                stat  <= R1;
            ELSE
                CASE stat IS
                    WHEN R1 =>
                        ready <= '0';
                        line_encoder(lin => msg_tmp(index), lout => temp(index));
                        index := index + 1;
                        IF index = msg'length THEN
                            index := 0;
                            stat <= T;
                            REPORT "[ENC] R1 ready";
                        END IF;
                    WHEN T =>
                        REPORT "[ENC] Transpose.";
                        transpose_temp : FOR row IN temp'RANGE LOOP
                            FOR col IN 0 TO temp(0)'length - 1 LOOP
                                temp_transposed(col)(row) := temp(row)(col);
                            END LOOP;
                        END LOOP; -- transpose_temp
                        index := 0;
                        stat <= R2;
                        REPORT "[ENC] T ready";
                    WHEN R2 =>
                        line_encoder(lin => temp_transposed(index), lout => codeword(index));
                        index := index + 1;
                        IF index = temp_transposed'length THEN
                            index := 0;
                            stat <= RDY;
                            REPORT "[ENC] R2 ready";
                        END IF;
                    WHEN RDY =>
                        ready <= '1';
                        REPORT LF & "[ENC] message=" & LF & MXIO_toString(msg);
                        REPORT LF & "[ENC] codeword=" & LF & MXIO_toString(codeword);
                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;