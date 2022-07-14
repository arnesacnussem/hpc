library ieee;
use ieee.std_logic_1164.all;
use work.consts.all;

entity encoder is
  port (
    msg : in bit_vector(MSG_LENGTH to 0);
    -- generator matrix
    g : in generator_matrix;
    encoded : out bit_vector(MSG_LENGTH to 0)
  );
end encoder;

architecture Encoder of encoder is
  component MatrixTransposer
    port (
      input : in code_matrix;
      output : out code_matrix_transpose
    );
  end component;
begin

end architecture;