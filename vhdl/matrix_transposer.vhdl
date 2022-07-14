LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.consts.ALL;

ENTITY matrix_transposer IS
    PORT (
        input : IN code_matrix;
        output : OUT code_matrix_transpose;
        start : IN STD_LOGIC;
        finished : OUT STD_LOGIC
    );
END matrix_transposer;

ARCHITECTURE MatrixTransposer OF matrix_transposer IS
BEGIN

    PROCESS (input)
        VARIABLE temp : code_matrix_transpose;
    BEGIN
        FOR I IN 0 TO CODEWORD_LENGTH LOOP
            FOR J IN 0 TO MSG_LENGTH LOOP
                temp(J, I) := input(I, J);
            END LOOP;
        END LOOP;
        output <= temp;
    END PROCESS;
END ARCHITECTURE;