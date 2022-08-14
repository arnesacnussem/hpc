import { writeFile, comment } from "./generator_common.js";
import { matrix } from "./generator.d.js";

export default ({ h, g, n, k, table }: matrix) => {
  const pkgName = "config";
  const vhdl = `-- generated from ${process.argv[1]}
library ieee;
USE work.types.ALL;
PACKAGE ${pkgName} IS
    CONSTANT CHANNEL_ERROR_RATE : INTEGER := 3;
    ${comment("MSG_LENGTH(k) = " + k)}
    CONSTANT MSG_LENGTH : INTEGER := ${k - 1};

    ${comment("CODEWORD_LENGTH(n) = " + k)}
    CONSTANT CODEWORD_LENGTH : INTEGER := ${n - 1};

    ${comment("CHECK_LENGTH = " + h[0].length)}
    CONSTANT CHECK_LENGTH    : INTEGER := ${h[0].length - 1};
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

    CONSTANT REF_TABLE : REF_TABLE_ARR := (
        ${(table as unknown as string[]).join(", ")}
    );
END PACKAGE ${pkgName};
`;
  writeFile(pkgName, vhdl);
};
