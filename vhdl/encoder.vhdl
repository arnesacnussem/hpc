LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;
USE work.consts.ALL;

ENTITY encoder IS
  PORT (
    msg : IN BIT_VECTOR(0 TO MSG_LENGTH);
    -- generator matrix
    gen : IN generator_matrix;
    encoded : OUT BIT_VECTOR(0 TO CODEWORD_LENGTH);
    done : OUT STD_LOGIC := '0';
    rst, clk : IN STD_LOGIC
  );
END encoder;

ARCHITECTURE Encoder OF encoder IS
  COMPONENT MatrixTransposer
    PORT (
      input : IN code_matrix;
      output : OUT code_matrix_transpose
    );
  END COMPONENT;
  PROCEDURE matrix_multiplex_add(
    VARIABLE a, b : IN BIT;
    VARIABLE c : OUT BIT
  ) IS
  BEGIN
    IF a = '1' AND b = '1' THEN
      c := '0';
    ELSIF a = '0' AND b = '0' THEN
      c := '0';
    ELSE
      c := '1';
    END IF;
  END matrix_multiplex_add;
  PROCEDURE matrix_multiplex_mux(
    VARIABLE a, b : IN BIT;
    VARIABLE c : OUT BIT
  ) IS
  BEGIN
    IF a = '1' AND b = '1' THEN
      c := '1';
    ELSE
      c := '0';
    END IF;
  END matrix_multiplex_mux;
BEGIN
  PROCESS (msg, gen)
    VARIABLE temp : BIT_VECTOR(0 TO CODEWORD_LENGTH);
    VARIABLE m, g, t : BIT;
  BEGIN

    temp := (0 => '0', OTHERS => '0');
    FOR col IN 0 TO CODEWORD_LENGTH LOOP
      FOR row IN 0 TO MSG_LENGTH LOOP
        m := msg(row);
        g := gen(row, col);
        matrix_multiplex_mux(a => m, b => g, c => t);
        matrix_multiplex_add(a => t, b => temp(col), c => temp(col));
      END LOOP;
    END LOOP;
    encoded <= temp;
    done <= '1';
  END PROCESS;
END ARCHITECTURE;