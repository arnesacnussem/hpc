import { gencfg } from "./generator_cfg.js";
import { writeFile, comment } from "./generator_common.js";

export default ({ h, g, n, k }) => {
  const pkgName = "types";
  const vhdl = `-- generated from ${process.argv[1]}
LIBRARY ieee;
PACKAGE ${pkgName} IS
    ${comment(
      "The message should be a matrix of k*k, which is " +
        k * k +
        "-bits, for ideal, the message should be serially input"
    )}

    ${comment("MSG_LENGTH(k) = " + k)}
    CONSTANT MSG_LENGTH      : INTEGER := ${k - 1};

    ${comment("CODEWORD_LENGTH(n) = " + k)}
    CONSTANT CODEWORD_LENGTH : INTEGER := ${n - 1};

    ${comment("CHECK_BITS = " + gencfg.check_bits)}
    CONSTANT CHEKC_BITS      : INTEGER := ${gencfg.check_bits - 1};

    TYPE GEN_MAT IS ARRAY (0 TO MSG_LENGTH, 0 TO CODEWORD_LENGTH) OF BIT;
    TYPE CHK_MAT IS ARRAY (0 TO CHEKC_BITS, 0 TO CODEWORD_LENGTH) OF BIT;

    TYPE MSG_LINE IS ARRAY (0 TO MSG_LENGTH) OF BIT;
    TYPE MSG_MAT IS ARRAY (0 TO MSG_LENGTH) OF MSG_LINE;
    TYPE MSG_SERIAL IS ARRAY (0 TO ${k * k - 1}) OF BIT;
    
    TYPE CODEWORD_LINE IS ARRAY (0 TO CODEWORD_LENGTH) OF BIT;
    TYPE CODEWORD_MAT IS ARRAY(0 TO CODEWORD_LENGTH) OF CODEWORD_LINE;
    TYPE CODEWORD_SERIAL IS ARRAY (0 TO ${n * n - 1}) OF BIT;
END PACKAGE ${pkgName};
`;

  writeFile(pkgName, vhdl);
};
