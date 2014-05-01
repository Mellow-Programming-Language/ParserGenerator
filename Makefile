
all: parserGenerator grammarParserMain.d

grammarParserMain.d: parserGenerator grammarMain.peg
	./parserGenerator < grammarMain.peg > grammarParserMain.d

parserGenerator: visitor.d parserGeneratorMain.d
	dmd -ofparserGenerator parserGeneratorMain.d visitor.d grammarParserMain.d

