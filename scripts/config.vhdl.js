import { gencfg } from "./generator_cfg.js";
import { writeFile, comment } from "./generator_common.js";

export default ({ h, g, n, k }) => {
  const pkgName = "config";
  const vhdl = `-- generated from ${process.argv[1]}
library ieee;
USE work.types.ALL;
PACKAGE ${pkgName} IS
    ${comment("MSG_LENGTH(k) = " + k)}
    CONSTANT MSG_LENGTH      : INTEGER := ${k - 1};

    ${comment("CODEWORD_LENGTH(n) = " + k)}
    CONSTANT CODEWORD_LENGTH : INTEGER := ${n - 1};

    ${comment("CHECK_BITS = " + gencfg.check_bits)}
    CONSTANT CHEKC_BITS      : INTEGER := ${gencfg.check_bits - 1};
    CONSTANT GENERATE_MATRIX : GEN_MAT := (
        ${g
          .map((l, i) => i.toString().concat(' => "').concat(l).concat('"'))
          .join(",\n\t\t")}
    );
    CONSTANT CHECK_MATRIX : CHK_MAT := (
        ${h
          .map((l, i) => i.toString().concat(' => "').concat(l).concat('"'))
          .join(",\n\t\t")}
    );
END PACKAGE ${pkgName};
`;
  writeFile(pkgName, vhdl);
};
