import { writeFile, comment } from "./generator_common.js";
import { exported_data } from "./generator.d.js";

export default ({ ht, g, n, k, table, syndt }: exported_data) => {
  const pkgName = "config";
  const tab = table as string[];
  const synd = syndt as string[];
  const vhdl = `-- generated from ${process.argv[1]}
library ieee;
USE work.types.ALL;
PACKAGE ${pkgName} IS
    CONSTANT CHANNEL_ERROR_RATE : INTEGER := 3;
    ${comment("MSG_LENGTH(k) = " + k)}
    CONSTANT MSG_LENGTH : INTEGER := ${k - 1};

    ${comment("CODEWORD_LENGTH(n) = " + k)}
    CONSTANT CODEWORD_LENGTH : INTEGER := ${n - 1};

    ${comment("CHECK_LENGTH = " + ht[0].length)}
    CONSTANT CHECK_LENGTH    : INTEGER := ${ht[0].length - 1};
    CONSTANT GENERATE_MATRIX : GEN_MAT := (
        ${g
          .map((l, i) => i.toString().concat(' => "').concat(l).concat('"'))
          .join(",\n\t\t")}
    );
    CONSTANT CHECK_MATRIX_T : CHK_MAT := (
        ${ht
          .map((l, i) => i.toString().concat(' => "').concat(l).concat('"'))
          .join(",\n\t\t")}
    );

    CONSTANT REF_TABLE : REF_TABLE_ARR := (
        ${tab.join(", ")}
    );

    CONSTANT SYNDTABLE : MXIO(0 TO ${synd.length - 1})(0 TO ${
    synd[0].length - 1
  }) := (
      ${synd
        .map((l, i) => i.toString().concat(' => "').concat(l).concat('"'))
        .join(",\n\t\t")}
  );
END PACKAGE ${pkgName};
`;
  writeFile(pkgName, vhdl);
};
