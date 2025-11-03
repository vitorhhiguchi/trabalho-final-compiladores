// Define o nome da gramática
grammar CSubset;

// Define o opção para gerar o código do parser/lexer em Dart
options {
  language = Dart;
}

/*------------------------------------------------------------------
 * REGRAS DE PARSER (SINTAXE)
 * Começam com letra minúscula.
 *------------------------------------------------------------------*/

// A regra inicial. Um programa é composto por zero ou mais declarações.
program: (topLevelDeclaration)* EOF;

// Uma declaração de topo pode ser uma diretiva ou uma definição de função
topLevelDeclaration
    : preprocessorDirective
    | functionDefinition
    ;

// Requisito 8: Diretivas do Pré-processador
preprocessorDirective
    : HASH INCLUDE INCLUDE_PATH
    | HASH DEFINE ID (INT_LITERAL | FLOAT_LITERAL | STRING_LITERAL)
    ;

// Requisito 6: Funções
// Por enquanto, vamos focar na estrutura 'int main(void)'
functionDefinition
    : type ID LPAREN (type | VOID_TYPE)? RPAREN LBRACE (statement)* RBRACE
    ;

// Um 'statement' (instrução) por enquanto é só uma declaração de variável
statement
    : variableDeclarationStatement
    ;

// Requisito 1: Declaração e Inicialização de Variáveis
variableDeclarationStatement
    : type variableDeclaration (',' variableDeclaration)* SEMI
    ;

variableDeclaration
    : ID (ASSIGN expression)? // Suporta 'int x;' e 'int x = 10;'
    ;

// Por enquanto, uma expressão é apenas um valor literal
expression
    : INT_LITERAL
    | FLOAT_LITERAL
    | CHAR_LITERAL
    | STRING_LITERAL
    ;

// Define os tipos base da nossa linguagem
type
    : INT_TYPE
    | FLOAT_TYPE
    | CHAR_TYPE
    ;


/*------------------------------------------------------------------
 * REGRAS DE LEXER (VOCABULÁRIO)
 * Começam com letra MAIÚSCULA.
 * A ordem importa! As regras mais específicas vêm antes.
 *------------------------------------------------------------------*/

// -- Palavras-chave e Tipos --
INT_TYPE: 'int';
FLOAT_TYPE: 'float';
CHAR_TYPE: 'char';
VOID_TYPE: 'void'; //

// -- Diretivas de Pré-processador --
HASH: '#';
INCLUDE: 'include';
DEFINE: 'define';
INCLUDE_PATH: '<' [a-zA-Z_.]+ '>'; // Simplificado para <stdio.h>

// -- Identificadores --
ID: [a-zA-Z_] [a-zA-Z_0-9]*; // Nomes de variáveis e funções

// -- Literais --
INT_LITERAL: [0-9]+;
FLOAT_LITERAL: [0-9]+ '.' [0-9]+;
CHAR_LITERAL: '\'' . '\''; // 'a'

// ***** CORREÇÃO ESTÁ AQUI *****
// Define uma string literal, permitindo caracteres escapados (ex: \n, \")
// ou qualquer caractere que não seja uma aspa dupla ou barra invertida.
STRING_LITERAL: '"' ( '\\' . | ~[\\"] )* '"';

// -- Símbolos e Operadores --
LPAREN: '(';
RPAREN: ')';
LBRACE: '{';
RBRACE: '}';
SEMI: ';';
ASSIGN: '=';
LT: '<';
GT: '>';
COMMA: ',';

// -- Comentários e Espaços em Branco (Ignorados) --

// Requisito 9: Comentários
LINE_COMMENT: '//' ~[\r\n]* -> skip;
BLOCK_COMMENT: '/*' .*? '*/' -> skip;

// Ignora espaços em branco, tabs e novas linhas
WS: [ \t\r\n]+ -> skip;