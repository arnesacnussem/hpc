LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.consts.ALL;

ENTITY encoder IS
  PORT (
    msg : IN bit_vector(MSG_LENGTH TO 0);
    -- generator matrix
    gen : IN generator_matrix;
    encoded : OUT bit_vector(CODEWORD_LENGTH TO 0)
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
BEGIN
  PROCESS (msg, gen)
    VARIABLE temp : bit_vector(CODEWORD_LENGTH DOWNTO 0);
    VARIABLE m, g, t : BIT;

  BEGIN
    temp := (0 => '0', OTHERS => '0');
    FOR col IN CODEWORD_LENGTH - 1 TO 0 LOOP
      FOR row IN MSG_LENGTH - 1 TO 0 LOOP
        m := msg(row);
        g := gen(col, row);
        matrix_multiplex_add(a => m, b => g, c => t);

      END LOOP;
      REPORT "value of " & INTEGER'image(col) & "=" & BIT'image(temp(col));
    END LOOP;
  END PROCESS;
END ARCHITECTURE;