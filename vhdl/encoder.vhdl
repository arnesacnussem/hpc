LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.consts.ALL;

ENTITY encoder IS
  PORT (
    msg : IN bit_vector(MSG_LENGTH TO 0);
    -- generator matrix
    g : IN generator_matrix;
    encoded : OUT bit_vector(MSG_LENGTH TO 0)
  );
END encoder;

ARCHITECTURE Encoder OF encoder IS
  COMPONENT MatrixTransposer
    PORT (
      input : IN code_matrix;
      output : OUT code_matrix_transpose
    );
  END COMPONENT;
BEGIN
  PROCESS
  BEGIN

  END PROCESS;
END ARCHITECTURE;