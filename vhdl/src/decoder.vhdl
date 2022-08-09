LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.config.ALL;

ENTITY decoder IS
    PORT (
        code  : IN CODEWORD_MAT; -- codeword matrix
        chk   : IN CHK_MAT;      -- check matrix
        msg   : OUT MSG_MAT;     -- message matrix
        ready : OUT STD_LOGIC;   -- signal of work ready
        rst   : IN STD_LOGIC;    -- reset ready status and clock of work
        clk   : IN STD_LOGIC     -- clock
    );
END decoder;

ARCHITECTURE Decoder OF decoder IS
    PROCEDURE find (
        VARIABLE val : IN INTEGER;
        VARIABLE pos : OUT INTEGER
    ) IS
    BEGIN
        pos := (-1);
        FOR i IN 0 TO REF_TABLE'length - 1 LOOP
            IF REF_TABLE(i) = val THEN
                pos := i;
            END IF;
        END LOOP;
    END PROCEDURE;

    PROCEDURE Hdecode (
        VARIABLE lin             : IN CODEWORD_LINE;
        VARIABLE err_exist       : OUT STD_LOGIC;
        VARIABLE err_correctable : OUT STD_LOGIC;
        VARIABLE err_position    : OUT STD_LOGIC
    ) IS
        VARIABLE syndrome : BIT_VECTOR(0 TO CHECK_LENGTH);
        VARIABLE dSyn     : INTEGER;
        VARIABLE pos      : INTEGER;
    BEGIN
        syndrome := (OTHERS => '0');
        FOR col IN 0 TO CODEWORD_LENGTH LOOP
            FOR row IN 0 TO CHECK_LENGTH LOOP
                syndrome(col) := (lin(row) AND chk(row, col)) XOR syndrome(col);
            END LOOP;
        END LOOP;

        dSyn := to_integer(unsigned(to_stdlogicvector(syndrome)));
        IF dSyn = 0 THEN
            err_exist       := '0';
            err_correctable := '0';
            err_position    := '0';
        ELSE
            err_exist := '1';
            find(val => dSyn, pos => pos);
            IF pos = (-1) THEN

            END IF;
        END IF;
    END PROCEDURE;

BEGIN
    PROCESS
    BEGIN
        REPORT "[DEC] Decoding first round.";
        decode_lines_r1 : FOR L IN 0 TO CODEWORD_LENGTH LOOP

        END LOOP; -- decode_lines_r1
    END PROCESS;

END ARCHITECTURE;