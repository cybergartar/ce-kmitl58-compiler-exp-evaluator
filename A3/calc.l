%option noyywrap

L     [A-Z]

%{
  #include "calc.tab.h"
  #include <stdio.h>
  #include <stdlib.h>
  #include <math.h>
  #include <ctype.h>
  #include <string.h>
  int strToHex(char* s);
  int getRegIndex(char* s);
%}

%%
[ \t]             {  }
[0-9]+            { yylval = atoi(yytext); return (NUM); }
[0-9a-fA-F]+[hH]  { yylval = strToHex(yytext); return (NUM);}
"$r"{L}           { yylval = getRegIndex(yytext); return (REG); }
"$acc"            { yylval = getRegIndex("$r["); return(REG); }
\n                { return (TK_NEWLINE); }
"AND"             { return (TK_AND); }
"OR"              { return (TK_OR); }
"NOT"             { return (TK_NOT); }
"SHOW"            { return (TK_SHOW); }
"LOAD"            { return (TK_LOAD); }
"PUSH"            { return (TK_PUSH); }
"POP"             { return (TK_POP); }
"END"             { return (TK_END); }
"$top"            { return (TOP); }
"$size"           { return (SIZE); }
"+"               { return (TK_PLUS); }
"-"               { return (TK_MINUS); }
"*"               { return (TK_MULTIPLY); }
"/"               { return (TK_DIVIDE); }
"\\"              { return (TK_MOD); }
"("               { return (TK_LPAREN); }
")"               { return (TK_RPAREN); }
%%

int strToHex(char* s) {
  int len = strlen(s);
  s[len-1] = 0;
  return (int)( strtol(s, NULL, 16) );
}

int getRegIndex(char* s) {
  return (s[2] - 'A');
}



