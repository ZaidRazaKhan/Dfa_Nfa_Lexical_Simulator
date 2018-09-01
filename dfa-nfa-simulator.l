%{
#include<stdio.h>
#include<stdlib.h>
#include<bits/stdc++.h>
#include<fstream>
#include<string>
using namespace std ;

// Declerations of variabes that are going to be used in the code
int is_dfa_nfa;

int numberOfStates ;
int numberOfFinalStates ;
int numberOfSymbols ;

bool ETransitions; // indicates the presence or absence of E-transitions

map<char,int> alphabetMap ; // To make traversing in transition table easier

vector<int> states ;
vector<int> finalStates ;

vector<vector<int> > DFATransitionTable ;
vector<vector<string> > NFATransitionTable ;


//Reading NFA and DFA from the specification.txt
void readDFA();
void readNFA();


// Checking whether the given state is final or not
bool isFinalInDFA(int state);
bool isFinalInNFA(vector<int> Fstates);

// Moving NFA and DFA by one step
int moveDFA(int state , char inputCharacter);
vector<int> moveNFA(vector<int> state , char inputCharacter);


// Finding e-closure for NFA
vector<int> Eclosure(vector<int> setOfStates);


// For printing whehter the input string is accepted by the given NFA or DFA
void DFA(string);
void NFA(string);

// Convert string to const char*
char* toChar(string);


// Definitions of the above functions

bool isFinalInDFA(int state){
// Checks whether input state is final state or not
    for(int i = 0 ; i < numberOfFinalStates ; i ++){
        if(state == finalStates[i])return true;
    }
    return false;
}

bool isFinalInNFA ( vector<int> Fstates){
// Checks whether input state set belongs to final state or not
    for(int i = 0 ; i < Fstates.size() ; i++){
        if(isFinalInDFA(Fstates[i]))return true; // Simply isFinalInDFA function is used for ease
    }
    return false;
}

vector <int> Eclosure (vector <int> setOfStates){
    // It takes vector of states and return a vector of states containing e-closure
    // Find its absolute e-neighbour
    // Iterate recursively on the absolute e-neighbours and add it to the Eclosure
    vector <int> Etrans;
    for (int i = 0; i < setOfStates.size (); i++){
        Etrans.push_back(setOfStates[i]);
    }
    if(!ETransitions){
        return Etrans;
    }
    while (setOfStates.size () != 0){
        int state = setOfStates[setOfStates.size () - 1];
        setOfStates.pop_back ();
        vector <int> stateVector;
        stateVector.push_back (state);
        vector <int> Eneighbours = moveNFA (stateVector, '$');
        while (Eneighbours.size () != 0){
            int current = Eneighbours[Eneighbours.size () - 1];
            Eneighbours.pop_back ();
            vector < int >::iterator it;
            it = find (setOfStates.begin (), setOfStates.end (), current);
            if (it == setOfStates.end ()){
                setOfStates.push_back (current);
                Etrans.push_back (current);
            }
        }
    }
    return Etrans;
}


char* toChar(string str){
    // Takes a string and convert it into char*  
    char *cstr = new char[str.length() + 1];
    strcpy(cstr, str.c_str());
    return cstr;
}


int moveDFA(int state , char inputCharacter){
    // It tells the next state on passing through a single character input
    return DFATransitionTable[state][alphabetMap[inputCharacter]];
}


vector <int> moveNFA (vector <int> state, char inputChar){
    // It tells the next set of states on passing through a single input character
    vector <int> transitionStates;
    vector <int>::iterator it;
    for (int i = 0; i < state.size (); i++){
        string entry = NFATransitionTable[state[i]][alphabetMap[inputChar]];
        if(entry=="^")
            continue;
        char *token;
        if (entry.length()==1){
            transitionStates.push_back(stoi(entry)); 
        }
        else {
            token=strtok (toChar(entry), ",");
            while (token != NULL){
                it = find (transitionStates.begin (), transitionStates.end (), stoi (token));
                if (it == transitionStates.end ()){
                    transitionStates.push_back (stoi (token));
                    token = strtok (NULL, ",");
                }
            }
        }
    }
    return transitionStates;
}

void readDFA(){
    // It will read DFA as everything is global so we can take it from above
    ifstream myFile;
    myFile.open("specification.txt");
    vector<string> linesInSpecification;
    while(!myFile.eof()){
        string s;
        getline(myFile,s);
        linesInSpecification.push_back(s);
    }
    myFile.close();

    char cstr[linesInSpecification[0].length()+1];
    strcpy(cstr,linesInSpecification[0].c_str());
    char* tokenForStates = strtok(cstr, " ");
    while (tokenForStates != NULL) {
        states.push_back(stoi(tokenForStates));
        tokenForStates = strtok(NULL, " ");
    }
    char cstr1[linesInSpecification[1].length()+1];
    strcpy(cstr1,linesInSpecification[1].c_str());
    char* tokenForFinalStates = strtok(cstr1, " ");
    while (tokenForFinalStates != NULL) {
        finalStates.push_back(stoi(tokenForFinalStates));
        tokenForFinalStates = strtok(NULL, " ");
    }
    int counter = 0 ;
    char cstr2[linesInSpecification[2].length()+1];
    strcpy(cstr2,linesInSpecification[2].c_str());
    char* tokenForAlphabetSymbols = strtok(cstr2, " ");
    while (tokenForAlphabetSymbols != NULL) {
        alphabetMap.insert ( pair<char,int>(tokenForAlphabetSymbols[0],counter) );
        counter++;
        tokenForAlphabetSymbols = strtok(NULL, " ");
    }
    for(int i = 3 ; i < linesInSpecification.size() ; i++){
        vector<int> column;
        char cstr3[linesInSpecification[i].length()+1];
        strcpy(cstr3,linesInSpecification[i].c_str());
        char* tokenForRowsInTable = strtok(cstr3, " ");
        while (tokenForRowsInTable != NULL) {
            column.push_back(stoi(tokenForRowsInTable));
            tokenForRowsInTable = strtok(NULL, " ");
        }   
        DFATransitionTable.push_back(column);
    }
}

void readNFA (){
    //It will read NFA from the specification.txt and it takes no argument and return void as everything is globally changed
    ifstream file;
    file.open ("specification.txt");
    vector <string> linesOfSpecs;
    while (!file.eof ()){
        string line;
        getline (file, line);
        linesOfSpecs.push_back (line);
    }
    file.close ();
    char* token = strtok (toChar(linesOfSpecs[0]), " ");
    while (token != NULL){
        states.push_back (stoi (string (token)));
        token = strtok (NULL, " ");
    }
    token = strtok (toChar(linesOfSpecs[1]), " ");
    while (token != NULL){
        finalStates.push_back (stoi (string (token)));
        token = strtok (NULL, " ");
    }
    token = strtok (toChar(linesOfSpecs[2]), " ");
    int counter = 0;
    while (token != NULL){
        alphabetMap.insert(pair <char,int> (token[0],counter));
        token = strtok (NULL, " ");
        counter++;
    }
    alphabetMap.insert(pair <char,int> ('$',counter));
    for (int i = 3; i < linesOfSpecs.size(); i++){
        token = strtok (toChar(linesOfSpecs[i]), " ");
        counter = 0;
        vector<string> col;
        while (token != NULL){
            col.push_back(string(token));
        //NFATransitionTable[i - 3][counter] = string (token);
            token = strtok (NULL, " ");
            counter++;
        }
        NFATransitionTable.push_back(col);
    }
    if(counter==numberOfSymbols)
    {
      ETransitions=false;
    }
    else 
      ETransitions=true;
}


void DFA(string str){
    int state=0;
    for(int i=0;i<str.length();i++){
        state=moveDFA(state,str.at(i));
    }
    cout<<state<<endl;
    if(isFinalInDFA(state)){
        cout<<"MATCHED\n";
    }
        
    else
        cout<<"ERROR\n";
}

void NFA (string str){
    vector <int> start;
    start.push_back (0);
    vector <int> state = Eclosure (start);
    int i=0; 
    for (; i < str.length (); i++){
        if (alphabetMap.find(str.at(i))==alphabetMap.end()){
            cout<<"ERROR";
            break;
        }
        state = Eclosure (moveNFA (state, str.at (i)));
    }
    if (isFinalInNFA (state) && i==str.length())
      cout << "MATCHED";
    if (!isFinalInNFA (state) && i==str.length())
      cout << "ERROR";
}


%}




%%

.* {if (is_dfa_nfa == 1)
    {
     DFA (yytext);
    }
    else
    {
     NFA (yytext);
    }
   } 


%%



int main(int argc, char *argv[]){
    // For taking input from the file input.txt
    extern FILE *yyin;
    yyin = fopen("input.txt","r");

    is_dfa_nfa = stoi(argv[1]);
    numberOfStates = stoi (argv[2]);
    numberOfFinalStates = stoi (argv[3]);
    numberOfSymbols = stoi (argv[4]);
    
    if (is_dfa_nfa == 1){
        readDFA ();
    }
    else{
        readNFA ();
    }
    yylex ();
    return 0;

    
}
