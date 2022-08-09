import { mkdirSync, writeFileSync } from "fs";
import { resolve } from "path";
import { gencfg } from "./generator_cfg.js";

export const comment = (c: string) => `-- ${c}`.toString();
export const writeFile = (pkgName: string, vhdl: string) => {
  mkdirSync(resolve(gencfg.output), { recursive: true });
  const file = resolve(gencfg.output, pkgName + ".vhdl");
  writeFileSync(file, vhdl);
  console.log(`Done write file ${file}`);
};
