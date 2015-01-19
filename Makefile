
all: parserGenerator

parser.d: grammarMain.peg
	./parser < grammarMain.peg > parser.d

parserGenerator: visitor.d parserGeneratorMain.d parser.d
	dmd -ofparserGenerator parserGeneratorMain.d visitor.d parser.d
