
all: parserGenerator grammarParserMain.d parserGeneratorTrace

grammarParserMain.d: parserGenerator grammarMain.peg
	./parserGenerator < grammarMain.peg > grammarParserMain.d

parserGenerator: visitor.d parserGeneratorMain.d
	dmd -ofparserGenerator parserGeneratorMain.d visitor.d grammarParserMain.d

parserGeneratorTrace: visitor.d parserGeneratorMain.d
	dmd -ofparserGenerator parserGeneratorMain.d visitor.d grammarParserMain.d -debug=TRACE

