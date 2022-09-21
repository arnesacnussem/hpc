export type exported_data = {
  n: number;
  k: number;
  ht: string[];
  g: string[];
  [keys: string]: string[][] | string[] | number;
};

export type vhdl = {
  pkg: string;
  vhdl: string;
};
