
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.decoder_utils.ALL;

ENTITY record_to_error_mask IS
    GENERIC (
        rotate_input  : BOOLEAN := false; -- transpose the input codeword
        rotate_output : BOOLEAN := false  -- transpose the output error mask matrix
    );
    PORT (
        rec  : IN CODEWORD_MAT;
        mask : OUT CODEWORD_MAT;
        mark : OUT CODEWORD_LINE
    );
END ENTITY;
ARCHITECTURE rtl OF record_to_error_mask IS
    SIGNAL internal_in  : CODEWORD_MAT;
    SIGNAL internal_out : CODEWORD_MAT;
BEGIN
    rotate_in : IF rotate_input GENERATE
        transposer_input : ENTITY work.mxio_transposer
            GENERIC MAP(
                row_count => CODEWORD_LENGTH,
                col_count => CODEWORD_LENGTH
            )
            PORT MAP(
                input  => rec,
                output => internal_in
            );
    ELSE GENERATE
            internal_in <= rec;
        END GENERATE;

        decode_proc : FOR i IN 0 TO CODEWORD_LENGTH GENERATE
            PROCESS (internal_in)
                VARIABLE code_line : CODEWORD_LINE;
                VARIABLE err_exist : BOOLEAN;
                VARIABLE err_mask  : CODEWORD_LINE;
            BEGIN
                code_line := internal_in(i);
                line_decode_mask(code_line, err_exist, err_mask);
                internal_out(i) <= err_mask;
                IF err_exist THEN
                    mark(i) <= '1';
                ELSE
                    mark(i) <= '0';
                END IF;
            END PROCESS;
        END GENERATE;

        rotate_out : IF rotate_output GENERATE
            transposer_output : ENTITY work.mxio_transposer
                GENERIC MAP(
                    row_count => CODEWORD_LENGTH,
                    col_count => CODEWORD_LENGTH
                )
                PORT MAP(
                    input  => internal_out,
                    output => mask
                );
        ELSE GENERATE
                mask <= internal_out;
            END GENERATE;
        END ARCHITECTURE rtl;