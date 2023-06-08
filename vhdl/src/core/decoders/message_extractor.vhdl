LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;

ENTITY message_extractor IS
    PORT (
        trigger : IN STD_LOGIC;
        rec     : IN CODEWORD_MAT;
        msg     : OUT MSG_MAT
    );
END ENTITY message_extractor;

ARCHITECTURE rtl OF message_extractor IS
    SIGNAL message : MSG_MAT;
BEGIN
    debug : PROCESS (trigger)
    BEGIN
        IF rising_edge(trigger) THEN
            REPORT "[DEC/EHPC] rec = " & LF & MXIO_toString(rec);
            REPORT "[DEC/EHPC] msg = " & LF & MXIO_toString(message);
        END IF;
    END PROCESS;

    msg <= message;
    row_gen : FOR row IN 0 TO MSG_LENGTH GENERATE
        col_gen : FOR col IN 0 TO MSG_LENGTH GENERATE
            message(row)(col) <= rec(4 + col)(3 - row);
        END GENERATE;
    END GENERATE;
END ARCHITECTURE rtl;