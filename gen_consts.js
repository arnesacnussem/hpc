import { writeFileSync } from "fs";
import { resolve } from "path";
import { exec } from "child_process";
const commentPrefix = "--\t";
const comment = (m) => commentPrefix + m;
const chk_bits = process.argv.length === 2 ? 3 : parseInt(process.argv[2]);
console.log(`Generating constants for ${chk_bits}-bit parity check.`);
exec(
  `octave-cli -q --eval '
  pkg load communications;
  [h,g,n,k]=hammgen(${chk_bits});
  printf("h=%s\\n",mat2str(h));
  printf("g=%s\\n",mat2str(g));
  printf("n=%d\\n",n);
  printf("k=%d\\n",k);
  '`,
  (_, stdout, __) => {
    // console.log(stdout);

    // split matrixs

    const matrixs = { h: [], g: [], n: "", k: "" };
    stdout
      .trim()
      .split("\n")
      .forEach((line) => {
        if (line.trim() === "") return;
        const current = line.at(0).trim();
        switch (current) {
          case "h":
          case "g":
            matrixs[current] = line
              .slice(3, line.length - 1)
              .split(";")
              .map((v) => v.split(" ").join(""));
            break;
          case "n":
          case "k":
            matrixs[current] = parseInt(
              line.split("=").map((l) => l.trim())[1]
            );
        }
      });

    console.log(matrixs);

    const vhdl = `
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
PACKAGE consts IS
    CONSTANT MSG_LENGTH : INTEGER := ${matrixs.k - 1}; ${comment(
      "msg len = " + matrixs.k
    )}
    CONSTANT CODEWORD_LENGTH : INTEGER := ${matrixs.n - 1}; ${comment(
      "codeword len = " + matrixs.n
    )}
    CONSTANT CHK_LENGTH : INTEGER := ${chk_bits - 1}; ${comment(
      "check bits = " + chk_bits
    )}
    TYPE GEN_MAT IS ARRAY (0 TO MSG_LENGTH, 0 TO CODEWORD_LENGTH) OF BIT;
    TYPE CHK_MAT IS ARRAY (0 TO CHK_LENGTH, 0 TO CODEWORD_LENGTH) OF BIT;
    TYPE MSG_ENC IS ARRAY(0 TO CODEWORD_LENGTH) OF BIT;
    TYPE MESSAGE IS ARRAY (0 TO MSG_LENGTH) OF BIT;
    CONSTANT GENERATE_MATRIX : GEN_MAT := (
        ${matrixs.g
          .map((l, i) => i.toString().concat(' => "').concat(l).concat('"'))
          .join(",\n\t\t")}
    );
    CONSTANT CHECK_MATRIX : CHK_MAT := (
        ${matrixs.h
          .map((l, i) => i.toString().concat(' => "').concat(l).concat('"'))
          .join(",\n\t\t")}
    );
END PACKAGE consts;
`;
    writeFileSync(resolve("vhdl/consts.vhdl"), vhdl);
    console.log(`Generated constants for ${chk_bits}-bit parity check.`);
  }
);
