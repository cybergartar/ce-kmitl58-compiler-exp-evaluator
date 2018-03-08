%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <ctype.h>

  typedef struct node {
    int val;
    struct node *next;
  } NODE;

  extern int yylex (void);
  extern int yyparse (void);
  void yyerror (char const *s);
  int getRegVal(int index);
  void setRegVal(int index, int value);
  void setAcc(int value);
  NODE* createNode(int val);
  void push(int val);
  void pop();
  int getTop();
  int getStackSize();

%}

/* Bison declarations.  */
%define api.value.type {int}
%token NUM REG TOP
%token TK_PLUS TK_MINUS TK_MOD TK_MULTIPLY TK_DIVIDE TK_AND TK_OR TK_NOT
%token TK_LPAREN TK_RPAREN
%token TK_SHOW TK_LOAD TK_PUSH SIZE TK_POP;
%token TK_NEWLINE
%left  TK_PLUS TK_MINUS 
%left  TK_MULTIPLY TK_DIVIDE TK_MOD
%left  TK_AND TK_OR TK_NOT
%token TK_END

%precedence NEG   /* negation--unary minus */

%start input

%% /* The grammar follows.  */

input:
| input line                     
;

line:
  TK_NEWLINE
| exp TK_NEWLINE                   { printf ("= %d\n", $1); }
| REG TK_NEWLINE                   { yyerror("USE \"SHOW $r[A-Z]\""); }
| TOP TK_NEWLINE                   { yyerror("USE \"SHOW $top\""); }
| SIZE TK_NEWLINE                  { yyerror("USE \"SHOW $size\""); }
| TK_SHOW show TK_NEWLINE          { printf("= %d\n", $2); }
| TK_LOAD srcreg dstreg TK_NEWLINE { setRegVal($3, $2); }
| TK_PUSH srcreg TK_NEWLINE        { push($2); }
| TK_POP dstreg TK_NEWLINE         { if(getStackSize() != 0) {setRegVal($2, getTop()); pop(); } else { yyerror("STACK EMPTY"); } }
;

exp:
  NUM                      { $$ = $1; }
| REG                      { $$ = getRegVal($1); }
| TOP                      { if(getStackSize() != 0) { $$ = getTop(); } else { yyerror("STACK EMPTY");  YYERROR; } }
| exp TK_PLUS exp          { $$ = $1 + $3; setAcc($$); }
| exp TK_MINUS exp         { $$ = $1 - $3; setAcc($$); }
| exp TK_MULTIPLY exp      { $$ = $1 * $3; setAcc($$); }
| exp TK_DIVIDE exp        { if($3 == 0) { yyerror("DIVIDE BY ZERO"); YYERROR; } else { $$ = $1 / $3; setAcc($$); } }
| exp TK_MOD exp           { $$ = $1 % $3; setAcc($$); }
| exp TK_AND exp           { $$ = $1 & $3; setAcc($$); }
| exp TK_OR exp            { $$ = $1 | $3; setAcc($$); }
| TK_NOT exp               { $$ = ~$2; setAcc($$); }
| TK_MINUS exp %prec NEG   { $$ = -$2; }
| TK_LPAREN exp TK_RPAREN  { $$ = $2; }
| TK_END                   { exit(0); }
;

show: /* returns values of register and variable */
  REG         { $$ = getRegVal($1); }
| TOP         { if(getStackSize() != 0) { $$ = getTop(); } else {  yyerror("STACK EMPTY"); YYERROR; } }
| SIZE        { $$ = getStackSize(); }
;

srcreg: /* returns values of register and variable */
  REG         { $$ = getRegVal($1); }
| TOP         { if(getStackSize() != 0) { $$ = getTop(); } else { yyerror("STACK EMPTY"); YYERROR; }  }
| SIZE        { yyerror("$size IS NOT A REGISTER!"); YYERROR; }
;

dstreg: /* returns register index */
  REG         { if($1 == 26) { yyerror("CANNOT WRITE TO ACC"); YYERROR; } else { $$ = $1; } }
| TOP         { yyerror("$top IS READONLY!"); YYERROR; }
| SIZE        { yyerror("$size IS NOT A REGISTER!"); YYERROR; }
;

%%

NODE *head, *top;
int stack_size = 0;

NODE* createNode(int val) {
  NODE* temp = malloc(sizeof(NODE));
  temp -> val = val;
  temp -> next = NULL;
  return temp;
}

void push(int val) {
  NODE* temp = createNode(val);
  temp -> next = top;
  top = temp;
  stack_size++;
}

void pop() {
    NODE* tmp = top;
    top = top -> next;
    free(tmp);
    stack_size--;
}

int r_reg[27]; // $rA-$rZ = 26, $acc = 1

void main() {
  memset(r_reg, 0, sizeof(r_reg));
  head = createNode(0);
  top = head;
  while(1) {
    yyparse();
  }
}

int getRegVal(int index) {
  return r_reg[index];
}

void setRegVal(int index, int value) {
  r_reg[index] = value;
}

void setAcc(int value) {
  r_reg[26] = value;
}

int getTop() {
  return top->val;
}

int getStackSize() {
  return stack_size;
}

void yyerror (char const *s) {
  fprintf (stderr, "! ERROR: %s\n", s);
}
