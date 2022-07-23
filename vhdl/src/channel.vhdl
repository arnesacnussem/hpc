LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.uniform;
USE ieee.math_real.floor;
USE work.types.ALL;
USE work.config.ALL;

ENTITY channel IS
    PORT (
        clk, en : IN STD_LOGIC;
        dat_in  : IN CODEWORD_MAT;
        dat_out : OUT CODEWORD_MAT
    );
END channel;

ARCHITECTURE DataChannel OF channel IS
    TYPE CH_STATE_TYPE IS (DISABLED, ENABLED);
    SIGNAL STATE : CH_STATE_TYPE := DISABLED;

    PROCEDURE shouldBitError (
        VARIABLE should : OUT STD_LOGIC
    ) IS
        VARIABLE seed1 : POSITIVE;
        VARIABLE seed2 : POSITIVE;
        VARIABLE x     : real;
        VARIABLE y     : INTEGER;
    BEGIN
        seed1 := 1;
        seed2 := 1;
        FOR n IN 1 TO 10 LOOP
            uniform(seed1, seed2, x);
            y := INTEGER(floor(x * 100.0));
            IF y > CHANNEL_ERROR_RATE THEN
                should := 1;
            ELSE
                should := 0;
            END IF;
        END LOOP;
    END PROCEDURE;
BEGIN

    unit_state : PROCESS (clk, en)
    BEGIN
        IF en = '1' THEN
            STATE <= ENABLED;
        ELSE
            STATE <= DISABLED;
        END IF;
    END PROCESS;

    PROCESS (STATE)
        VARIABLE shouldError : STD_LOGIC;
    BEGIN
        CASE(STATE) IS
            WHEN ENABLED =>
            FOR row IN 0 TO dat_in'length - 1 LOOP
                FOR col IN 0 TO dat_in(0)'length - 1 LOOP
                    shouldBitError(should => shouldError);
                    IF shouldError THEN
                        dat_out(row)(col) <= NOT dat_in(row)(col);
                    ELSE
                        dat_out(row)(col) <= dat_in(row)(col);
                    END IF;
                END LOOP;
            END LOOP;
            WHEN DISABLED =>
            REPORT "CHANNEL DISABLED.";
        END CASE;

    END PROCESS;

END ARCHITECTURE;