-- generated from /workspaces/hpc/scripts/generator.ts
LIBRARY ieee;
PACKAGE types IS
    TYPE GEN_MAT IS ARRAY (0 TO 10, 0 TO 14) OF BIT;
    TYPE CHK_MAT IS ARRAY (0 TO 3, 0 TO 14) OF BIT;

    TYPE MSG_LINE IS ARRAY (0 TO 10) OF BIT;
    TYPE MSG_MAT IS ARRAY (0 TO 10) OF MSG_LINE;
    TYPE MSG_SERIAL IS ARRAY (0 TO 120) OF BIT;
    
    TYPE CODEWORD_LINE IS ARRAY (0 TO 14) OF BIT;
    TYPE CODEWORD_MAT IS ARRAY(0 TO 14) OF CODEWORD_LINE;
    TYPE CODEWORD_SERIAL IS ARRAY (0 TO 224) OF BIT;
END PACKAGE types;
