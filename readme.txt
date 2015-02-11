README Tema LFA

Autor: Datcu Andrei Daniel
Grupa: 331CC
Data: 04.01.2014

Arhiva contine 3 teste:
    example.cpp (in principiu este exemplul din enunt putin modificat)
    example2.cpp (contine multe spatii \n si Lista de declaratii cu pointeri si fara)
    example3.cpp (nu contine niciun spatiu in plus, mostenire multipla, const in parametrii si la tipul intors)
    
Utilizare:

      make #genereaza executabilul tema
      ./tema nume_fisier_intrare #outputul va fi la stdout


Descriere pe scurt a solutiei:
    Practic, cu ajutorul flexului am modelat problema ca pe un automat cu stiva (folosind %option stack voi avea o stiva
        a startilor).

Indifirent de stare, consum tot inseamna whitespace (spatiu, tab, enter)

Indiferent de stare, daca intalnesc "/*" intru in starea COMMENT. Prin yy_pop_state() ma intorc la starea anterioara

Starea initiala inseamna ca nu am intalnit inca keyword-ul "class".

O data intalnit, voi intra in starea CLASSNAME. Aici citesc un identificator care va reprezenta numele clasei.
Daca intalnesc { inseamna ca voi intra in corpul clasei (starea CLASSBODY). Daca intalnesc : inseamna ca va urma
o lista de mostenire (INHERITANCE_LIST).
Daca intalnesc un specificator (public, privat, protected) inseamna ca urmeaza un identificator de tip. Orice identificator
de tip va fi citit in starea TYPENAME. Daca uneori citesc un identificator pentru a-mi da seama daca e tip sau nu, daca va fi tip
voi face unset la toate caracterele sale (vezi macroul UNPUTTYPE). Din INHERITCENCE_LIST voi iesi doar cu "{" care va duce catre
CLASSBODY.

In CLASSBODY voi citi intotdeauna 2 identificatori (unul poate sa fie urmat de ( - asta inseamna ca e nume de functie)
Daca al 2-lea identificator e urmat de paranteza voi sari la FUNCDECL altfel inseamna ca am o lista de membri si sar la
VARLIST

In FUNCDECL, citesc un identificator. Daca am citit un numar impar(type == 0) atunci inseamna ca am ctit un tip si-l voi procesa
ca atare. Trec peste ',' si la ) trec la starea in care functia deste definita - FUNCDEF.

In FUNCDEF, daca intalnesc ; si toate parantezele au fost inchise (fbodybrackets==0) inseamna ca am terminat cu definirea si voi
intra iar in CLASSBODY.  La intalnirea unei paranteze ajustez corespunzator fbodybrackets, iar orice alt caracter este ignorat.

In VARLIST citesc practic nume de identificatori. Practic, stiu deja tipul din CLASSBODY (este memorat in typename). Insa fiind
citit doar o data, fie este un tip cu pointer fie este fara. Asadar, cand intalnesc un pointer vad daca in aceasta lista a mai
existat unul. Daca nu, tiparesc tipul cu pointer. Analog pentru tipul fara pointer.


Alte chestii ciudate:

UNPUTTYPE este macro fiindca foloseste functia unput(). Daca ar fi fost functie globala, atunci ar fi dat o eroare de nume, functia
unput fiind definita mai jos de codul initial in lex.yy.c.



