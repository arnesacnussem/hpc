import { gencfg } from "./generator_cfg.js";
import { writeFile, comment } from "./generator_common.js";

export default ({ h, g, n, k }) => {
  const pkgName = "types";
  const vhdl = `-- generated from ${process.argv[1]}
LIBRARY ieee;
PACKAGE ${pkgName} IS
    TYPE GEN_MAT IS ARRAY (0 TO ${k - 1}, 0 TO ${n - 1}) OF BIT;
    TYPE CHK_MAT IS ARRAY (0 TO ${gencfg.check_bits - 1}, 0 TO ${n - 1}) OF BIT;

    TYPE MSG_LINE IS ARRAY (0 TO ${k - 1}) OF BIT;
    TYPE MSG_MAT IS ARRAY (0 TO ${k - 1}) OF MSG_LINE;
    TYPE MSG_SERIAL IS ARRAY (0 TO ${k * k - 1}) OF BIT;
    
    TYPE CODEWORD_LINE IS ARRAY (0 TO ${n - 1}) OF BIT;
    TYPE CODEWORD_MAT IS ARRAY(0 TO ${n - 1}) OF CODEWORD_LINE;
    TYPE CODEWORD_SERIAL IS ARRAY (0 TO ${n * n - 1}) OF BIT;
END PACKAGE ${pkgName};
`;

  writeFile(pkgName, vhdl);
};
