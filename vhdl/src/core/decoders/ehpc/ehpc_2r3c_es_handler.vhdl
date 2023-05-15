LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.core_util.ALL;

ENTITY ehpc_2r3c_es_handler IS
    PORT (
        rec          : IN CODEWORD_MAT;
        recOut       : OUT CODEWORD_MAT;
        col_err_site : IN CODEWORD_MAT
    );
END ENTITY ehpc_2r3c_es_handler;

ARCHITECTURE rtl OF ehpc_2r3c_es_handler IS
    SIGNAL rec_t : CODEWORD_MAT;
    SIGNAL reg   : CODEWORD_MAT;
BEGIN

    transposer_input : ENTITY work.mxio_transposer
        GENERIC MAP(
            row_count => CODEWORD_LENGTH,
            col_count => CODEWORD_LENGTH
        )
        PORT MAP(
            input  => rec,
            output => rec_t
        );

    proc : PROCESS (rec_t, col_err_site)
    BEGIN
        FOR i IN rec_t'RANGE LOOP
            reg(i) <= rec_t(i) XOR col_err_site(i);
        END LOOP;
    END PROCESS;

    transposer_output : ENTITY work.mxio_transposer
        GENERIC MAP(
            row_count => CODEWORD_LENGTH,
            col_count => CODEWORD_LENGTH
        )
        PORT MAP(
            input  => reg,
            output => recOut
        );
END ARCHITECTURE rtl;