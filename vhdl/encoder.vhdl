LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;
USE work.consts.ALL;

ENTITY encoder IS
  PORT (
    msg : IN MESSAGE;
    -- generator matrix
    gen : IN GEN_MAT;
    encoded : OUT MSG_ENC;
    done : OUT STD_LOGIC;
    rst, clk : IN STD_LOGIC
  );
END encoder;

ARCHITECTURE Encoder OF encoder IS
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
  encoding : PROCESS (msg, gen, clk, rst)
    VARIABLE temp : MSG_ENC;
    VARIABLE m, g, t : BIT;
  BEGIN
    IF rst = '1' THEN
      done <= '0';
    ELSIF rising_edge(clk) THEN
      temp := (OTHERS => '0');
      FOR col IN 0 TO CODEWORD_LENGTH LOOP
        FOR row IN 0 TO MSG_LENGTH LOOP
          m := msg(row);
          g := gen(row, col);
          matrix_multiplex_mux(a => m, b => g, c => t);
          matrix_multiplex_add(a => t, b => temp(col), c => temp(col));
        END LOOP;
      END LOOP;
      done <= '1';
    END IF;
    encoded <= temp;
  END PROCESS;
END ARCHITECTURE;