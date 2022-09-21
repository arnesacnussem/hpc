export type exported_data = {
  n: number;
  k: number;
  h: string[];
  g: string[];
  [keys: string]: string[][] | string[] | number;
};

export type vhdl = {
  pkg: string;
  vhdl: string;
};
