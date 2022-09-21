LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.config.ALL;
USE work.utils.ALL;
USE work.decoder_utils.ALL;

ENTITY decoder_ma2 IS
    PORT (
        codeIn  : IN CODEWORD_MAT;      -- codeword matrix
        msg     : OUT MSG_MAT;          -- message matrix
        ready   : OUT STD_LOGIC := '0'; -- signal of work ready
        rst     : IN STD_LOGIC  := '0'; -- reset ready status and clock of work
        clk     : IN STD_LOGIC;         -- clock
        has_err : OUT STD_LOGIC
    );
END ENTITY decoder_ma2;

ARCHITECTURE DecoderMa2 OF decoder_ma2 IS
    TYPE state_t IS (COPY, R1, R2, R3_EQUAL, R3_INEQUAL, EXTRACT, RDY);
    SIGNAL stat : state_t := COPY;

    TYPE row_error_array IS ARRAY(0 TO CODEWORD_MAT'length - 1) OF INTEGER;
    TYPE col_error_array IS ARRAY(0 TO CODEWORD_LINE'length - 1) OF INTEGER;

BEGIN
    PROCESS (clk)
        VARIABLE code      : CODEWORD_MAT;
        VARIABLE index     : INTEGER := 0;
        VARIABLE err_exist : BOOLEAN;
        VARIABLE err_pos   : INTEGER;

        VARIABLE row_error     : row_error_array := (OTHERS => 0);
        VARIABLE col_error     : col_error_array := (OTHERS => 0);
        VARIABLE row_err_index : INTEGER         := 0;
        VARIABLE col_err_index : INTEGER         := 0;

        VARIABLE synd        : INTEGER;
        VARIABLE column_temp : CODEWORD_LINE;
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                msg   <= (OTHERS => MXIO_ROW(ieee.numeric_bit.to_unsigned(0, msg(0)'length)));
                ready <= '0';
                stat  <= COPY;
            ELSE
                CASE stat IS
                    WHEN COPY =>
                        code := codeIn;
                        stat <= R1;
                    WHEN R1 =>
                        syndrome(lin => code(index), synd => synd);
                        IF synd /= 0 THEN
                            row_err_index            := row_err_index + 1;
                            row_error(row_err_index) := index;
                        END IF;

                        index := index + 1;
                        IF index = CODEWORD_MAT'length THEN
                            REPORT "[DEC/MAJ2] R1 ok";
                            index := 0;
                            stat <= R2;
                        END IF;
                    WHEN R2 =>
                        extract_column(mat => code, index => index, col => column_temp);
                        syndrome(lin => column_temp, synd => synd);
                        IF synd /= 0 THEN
                            col_err_index            := col_err_index + 1;
                            col_error(col_err_index) := index;
                        END IF;

                        index := index + 1;
                        -- 这玩意是正方形的，所以col和row长度一样...
                        IF index = CODEWORD_MAT'length THEN
                            REPORT "[DEC/MAJ2] R2 ok";
                            index := 0;
                            IF col_err_index = row_err_index THEN
                                stat <= R3_EQUAL;
                            ELSE
                                stat <= R3_INEQUAL;
                            END IF;
                        END IF;
                    WHEN R3_EQUAL   =>
                    WHEN R3_INEQUAL =>
                    WHEN EXTRACT    =>

                    WHEN RDY =>

                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;