export type matrix = {
  n: number;
  k: number;
  h: string[];
  g: string[];
  [keys: string]: string[] | number;
};

export type vhdl = {
  pkg: string;
  vhdl: string;
};
