import { mkdirSync, writeFileSync } from "fs";
import { resolve } from "path";
import { gencfg } from "./generator_cfg.js";

export const comment = (c: string) => `-- ${c}`.toString();
export const writeFile = (pkgName: string, vhdl: string) => {
  mkdirSync(resolve(gencfg.output), { recursive: true });
  writeFileSync(resolve(gencfg.output, pkgName + ".vhdl"), vhdl);
  console.log(`Done write file ${pkgName}.vhdl`);
};
