/*
 * Tema LFA
 * Autor: Datcu Andrei Daniel 331CC
 * Data: 04.01.2014
 *
*/

%option stack
%option noyywrap
%option nodebug

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define UNPUTTYPE {int _i_;\
                  unput(' ');\
                  for (_i_ = strlen(typename) - 1; _i_ >= 0; --_i_)\
                  unput(typename[_i_]);}

char classname[50], funcname[50], typename[50];
int fbodybrackets, rtype, wasNormal, wasPointer;
//rtype imi spune daca analizez un tip din argumentele functiei
//  sau tipul intors de functie (folosit la afisare)

//wasNormal / wasPointer sunt folosite in VARLIST - vezi README

char* cleanUpFunctionName(char *input, char* dest){
    /*
     * Pentru ca numele functiei este citit pana se intalneste '('
     * aceasta functie elimina caracterele in plus
     *
     */
    strcpy(dest, strtok(input, " \n\t("));
    return dest;
}

char* cleanUpTypeName(char *input){
    /*
     * Daca este tip cu pointer intre numele tipului si * pot aparea spatii.
     * Aceasta functie le scoate.
    */

    if (typename[yyleng - 1] != '*' &&
        typename[yyleng - 1] != '&'){// daca nu e tip de pointer sau referinta
            wasNormal = 1;
            return input;
        } 

    int i;
    for (i = yyleng - 2;
        typename[i] == '\t' || typename[i] == '\n' ||
        typename[i] == ' '; --i);
    typename[i + 1] = typename[yyleng - 1];
    typename[i + 2] = 0;
    wasPointer = 1;
    return input;
}

%}

whitespace [" "\n\t]+
onelinecomment "//"[^\n]*\n
specifier "public"|"protected"|"private"
identifier [A-Za-z]+[A-Za-z0-9_]*
basictype "void"|"int"|"float"|"double"|"long"|"bool"|"short"|"char"
functionspecifier "inline"|"virtual"|"explicit"
memberspecifier "const"|"static"|"friend"
paramspecifier "unsigned"|"signed"|"long"|"short"
pointer "&"|"*"

%s CLASS COMMENT METHOD CLASSNAME INHERITANCE_LIST CLASSBODY VARLIST FUNC_OR_VAR FUNCDECL FUNCDEF
%x TYPENAME

%%
{whitespace} //eat up the whitespaces

{onelinecomment} //eat up one line comments
"/*" {yy_push_state(COMMENT);}


<INITIAL>"#"[^\n]*\n {}

<COMMENT>{
    "*/"      yy_pop_state();
    [^*]+   // eat comment in chunks
    "*"       // eat the lone star
}

<INITIAL>"class" BEGIN(CLASSNAME);

<CLASSNAME>{
    {identifier} {
        printf("Clasa %s:\n", yytext);
        strcpy(classname, yytext);
    }
    ":" BEGIN(INHERITANCE_LIST);
    "{" BEGIN (CLASSBODY);
}

<INHERITANCE_LIST>{
    {specifier} yy_push_state(TYPENAME);
    {identifier} {yy_push_state(TYPENAME); yyless(0);}
    "," //
    "{" BEGIN(CLASSBODY);
}

<TYPENAME>{
    ({paramspecifier}{whitespace}*)*{basictype}({whitespace}*{pointer})? yy_pop_state();
    {identifier}({whitespace}*{pointer})? {
        strcpy(typename, yytext);
        printf("\t %s", cleanUpTypeName(typename));
        switch(yy_top_state()){
            case INHERITANCE_LIST:
                printf(" (mostenire) \n");
                break;

            case FUNCDECL:
                if (rtype == 0)
                    printf(" (parametru functie %s)\n", funcname);
                else
                    printf(" (tip intors de functia %s)\n", funcname);
                break;

            case VARLIST:
                printf(" (membru)\n");
                break;
        }
        yy_pop_state();
    }
}

<CLASSBODY>{
    "};" BEGIN(INITIAL);
    {functionspecifier}|{memberspecifier} //eat up the specifiers;
    ({paramspecifier}{whitespace}*)*{pointer}? strcpy(typename, yytext);
    {specifier}{whitespace}*":" // public: private:
    "~"?{identifier}{whitespace}*"("|{identifier}({whitespace}*{pointer})? {
        char aux[50] = "~";
        static int noOfReads = 0;
        wasNormal = 0;
        wasPointer = 0;
        if (yytext[yyleng - 1] == '('){ //daca am citit functie
            noOfReads = 0;
            cleanUpFunctionName(yytext, funcname);
            if (strcmp(funcname, classname) == 0 || strcmp(funcname, strcat(aux, classname)) == 0){
                BEGIN(FUNCDECL);
            }
            else{
                BEGIN(FUNCDECL);
                rtype = 1;
                UNPUTTYPE;
                yy_push_state(TYPENAME);
            }
        }
        else{ //am citit identificator
            ++noOfReads;
            if (noOfReads < 2)
                strcpy(typename, yytext);
            else{
                noOfReads = 0;
                BEGIN(VARLIST);
                UNPUTTYPE;
                yy_push_state(TYPENAME);
            }
        }
    }
}

<FUNCDECL>{
    {memberspecifier} //eat up
    {identifier} {
        static int type = 0;
        rtype = 0;
        if (type == 0){//este tip
            yyless(0);
            yy_push_state(TYPENAME);
        }
        type = 1 - type;
    }
    "," //eat up
    ")" {
        BEGIN(FUNCDEF);
        fbodybrackets = 0;
    }
}

<VARLIST>{
    ({pointer}{whitespace}*)?{identifier} {
        if (yytext[0] == '*' && typename[strlen(typename) - 1] != '*'){
            //Daca este pointer
            strcat(typename, "*");
        }
        else
            if (yytext[0] != '*'&& typename[strlen(typename) - 1] == '*'){
                //Daca e tip normal
                typename[strlen(typename) - 1] = 0;
            }
            UNPUTTYPE;
            yy_push_state(TYPENAME);
    }
    "," //eat up
    ";" BEGIN(CLASSBODY);
}

<FUNCDEF>{
    ";" if (fbodybrackets == 0) BEGIN(CLASSBODY);
    "}"({whitespace}*";")? {
        fbodybrackets--;
        if (fbodybrackets == 0) BEGIN(CLASSBODY);
    }
    "{" fbodybrackets++;
    [^"{""}"";"]+ //eat up
}


%%

main( int argc, char **argv ) {

    yyin = fopen(argv[1], "r");

    if (!yyin){
        printf("!!!eroare!!!");
        exit(1);
    }

    yylex();
}
