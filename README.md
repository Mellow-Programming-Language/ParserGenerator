To build the parser generator, exucute `make` in the toplevel project directory.
A good example of the syntax used for grammar files is in the file
`grammarMain.peg`, used to generate the parser generated and used by the parser
generator to parse grammar files to generate parser generators. A better example
can be seen in `lang.peg` of the project https://github.com/Mellow-Programming-Language/Mellow .
`./parserGenerator < lang.peg > parser.d` will produce a parser file `parser.d`,
as well as a definitions file for the AST class hierarchy in `visitor.d`.

In a D project, your new parser can be constructed with `new Parser(source)`,
where `source` is the string that you want to parse. The result will either be
a null pointer, indicating failure to parse, or the top node of the generated
AST.

An XVisitor class, inheriting from the Visitor class in `visitor.d`, will
be used to implement the behavior desired from the generated AST, using the
visitor pattern.

All AST nodes have access to a type generic
(http://dlang.org/phobos/std_variant.html) hashmap `data`. Using string keys
and the Variant `get!(...)` function, any data can be stashed in `data` for
further processing, such as if multiple visitors are implemented as passes
on the AST.

`ASTTerminal` nodes, which contain the actual string tokens captured by the
parser, contain the token in the member `.token`, and the starting index
of the token in the source input in the member `.index`.

String literals in double quotes implicitely consume and ignore any following
whitespace. Single quotes do not consume any following whitespace. Any rule
preceeded by a `#` will be trimmed from the generated AST. Any rule
preceeded by a `^` will be replaced with the 0 or more AST nodes that that rule
itself contained as children, effectively "promoting" those child nodes to the
position of their parent.

The OR operator `|` has a high precedence, and therefore binds more tightly
than sequence semantics. That is, `ruleOne | ruleTwo ruleThree` is a choice
between `ruleOne` and `ruleTwo`, following sequentially by `ruleThree`. Use
parenthesis where necessary.
