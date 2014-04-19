import std.stdio;
import std.conv;
import std.string;
import std.array;
import std.string;
import grammarNode;
import grammarParser;

class GenParser
{
    this (ASTNode topNode)
    in
    {
        assert(cast(ASTNonTerminal)topNode !is null);
        assert((cast(ASTNonTerminal)topNode).name == "GRAMMAR");
    }
    body
    {
        this.topNode = topNode;
    }

    string generate()
    {
        genCode = "";
        if (!verifyIntegrity(topNode))
        {
            writeln("Broken");
            return "";
        }
        compile(topNode);
        return genCode;
    }

private:

    ASTNode topNode;
    string genCode;
    FunctionComponents curFunc;
    ParserDefinition parserDef;

    class ParserDefinition
    {
        string definition;
        FunctionComponents[] funcs;
        string header;
        string footer;

        void genHeaderFooter()
        {
            header = "";
            header ~= `import std.stdio;` ~ "\n";
            header ~= `import std.regex;` ~ "\n";
            header ~= `import std.string;` ~ "\n";
            header ~= `import std.array;` ~ "\n";
            header ~= `import std.algorithm;` ~ "\n";
            header ~= `import grammarNode;` ~ "\n";
            header ~= `class Parser` ~ "\n";
            header ~= `{` ~ "\n";
            header ~= `    this (string source)` ~ "\n";
            header ~= `    {` ~ "\n";
            header ~= `        this.source = source;` ~ "\n";
            header ~= `        this.index = 0;` ~ "\n";
            header ~= `        debug(TRACE) this.traceIndent = "";` ~ "\n";
            header ~= `    }` ~ "\n";
            header ~= `    ASTNode parse()` ~ "\n";
            header ~= `    {` ~ "\n";
            header ~= `        consumeWhitespace();` ~ "\n";
            header ~= `        ASTNode topNode = null;` ~ "\n";
            header ~= `        if (grammar())` ~ "\n";
            header ~= `        {` ~ "\n";
            header ~= `            topNode = stack[$-1];` ~ "\n";
            header ~= `        }` ~ "\n";
            header ~= `        index = 0;` ~ "\n";
            header ~= `        stack = [];` ~ "\n";
            header ~= `        return topNode;` ~ "\n";
            header ~= `    }` ~ "\n";
            header ~= `private:` ~ "\n";
            header ~= `    string source;` ~ "\n";
            header ~= `    uint index;` ~ "\n";
            header ~= `    ASTNode[] stack;` ~ "\n";
            header ~= `    struct ParenResult` ~ "\n";
            header ~= `    {` ~ "\n";
            header ~= `        uint collectedNodes;` ~ "\n";
            header ~= `        bool isSuccess;` ~ "\n";
            header ~= `        this (uint collectedNodes, bool isSuccess)` ~ "\n";
            header ~= `        {` ~ "\n";
            header ~= `            this.collectedNodes = collectedNodes;` ~ "\n";
            header ~= `            this.isSuccess = isSuccess;` ~ "\n";
            header ~= `        }` ~ "\n";
            header ~= `    }` ~ "\n";
            header ~= `    debug (TRACE)` ~ "\n";
            header ~= `    {` ~ "\n";
            header ~= `        string traceIndent;` ~ "\n";
            header ~= `        enum tracer =` ~ "\n";
            header ~= "            `" ~ "\n";
            header ~= `            string funcName = __FUNCTION__;` ~ "\n";
            header ~= `            funcName =` ~ "\n";
            header ~= `                funcName[__MODULE__.length + typeof(this).stringof.length + 2..$];` ~ "\n";
            header ~= `            writeln(traceIndent, "Entered: ", funcName, ", Index: ", index);` ~ "\n";
            header ~= `            traceIndent ~= "  ";` ~ "\n";
            header ~= `            scope(exit)` ~ "\n";
            header ~= `            {` ~ "\n";
            header ~= `                traceIndent = traceIndent[0..$-2];` ~ "\n";
            header ~= `                writeln(traceIndent, "Exiting: ", funcName, ", Index: ", index);` ~ "\n";
            header ~= `            }` ~ "\n";
            header ~= "            `;" ~ "\n";
            header ~= `    }` ~ "\n";

            footer = "";
            footer ~= `    void consumeWhitespace()` ~ "\n";
            footer ~= `    {` ~ "\n";
            footer ~= "        auto whitespaceRegex = ctRegex!(`^\\s*`);" ~ "\n";
            footer ~= `        auto whitespaceMatch = match(source[index..$], whitespaceRegex);` ~ "\n";
            footer ~= `        if (whitespaceMatch)` ~ "\n";
            footer ~= `        {` ~ "\n";
            footer ~= `            index += whitespaceMatch.captures[0].length;` ~ "\n";
            footer ~= `        }` ~ "\n";
            footer ~= `    }` ~ "\n";
            footer ~= `    void printStack(string indent = "")` ~ "\n";
            footer ~= `    {` ~ "\n";
            footer ~= `        foreach_reverse (x; stack)` ~ "\n";
            footer ~= `        {` ~ "\n";
            footer ~= `            if (cast(ASTNonTerminal)x !is null)` ~ "\n";
            footer ~= `            {` ~ "\n";
            footer ~= `                x.printTree(indent);` ~ "\n";
            footer ~= `            }` ~ "\n";
            footer ~= `            else if (cast(ASTTerminal)x !is null)` ~ "\n";
            footer ~= `            {` ~ "\n";
            footer ~= `                writeln("[", (cast(ASTTerminal)x).token, "]: ", (cast(ASTTerminal)x).index);` ~ "\n";
            footer ~= `            }` ~ "\n";
            footer ~= `        }` ~ "\n";
            footer ~= `    }` ~ "\n";
            footer ~= `}` ~ "\n";
        }

        void compileDefinition()
        {
            genHeaderFooter();
            definition = "";
            definition ~= header;
            foreach (func; funcs)
            {
                func.compileFunction();
                definition ~= func.func;
            }
            definition ~= footer;
        }
    }

    class FunctionComponents
    {
        string func;
        string ruleName;
        string header;
        string footer;
        string[] parenInFuncs;
        string[] termInFuncs;
        string[] sequences;

        this (string ruleName)
        {
            this.ruleName = ruleName;
        }

        void genHeaderFooter()
        {
            header = "";
            header ~= `    bool ` ~ ruleName ~ "()\n";
            header ~= `    {` ~ "\n";
            header ~= `        debug (TRACE) mixin(tracer);` ~ "\n";
            header ~= `        uint saveIndex = index;` ~ "\n";

            footer ~= `        auto nonTerminal = new ASTNonTerminal("` ~ ruleName.toUpper ~ `");` ~ "\n";
            footer ~= `        foreach (node; stack[$-collectedNodes..$])` ~ "\n";
            footer ~= `        {` ~ "\n";
            footer ~= `            nonTerminal.addChild(node);` ~ "\n";
            footer ~= `        }` ~ "\n";
            footer ~= `        stack = stack[0..$-collectedNodes];` ~ "\n";
            footer ~= `        stack ~= nonTerminal;` ~ "\n";
            footer ~= `        return true;` ~ "\n";
            footer ~= `    }` ~ "\n";
        }

        void compileFunction()
        {
            genHeaderFooter();
            func = "";
            func ~= header;
            foreach (terminalFunc; termInFuncs)
            {
                func ~= terminalFunc;
            }
            foreach (parenFunc; parenInFuncs)
            {
                func ~= parenFunc;
            }
            if (parenInFuncs.length > 0)
            {
                func ~= `        ParenResult* result;` ~ "\n";
            }
            func ~= `        uint collectedNodes = 0;` ~ "\n";
            foreach (seq; sequences)
            {
                func ~= seq;
            }
            func ~= footer;
        }
    }

    void compile(ASTNode execNode)
    in
    {
        // We should never be passed in a null node
        assert(execNode !is null);
        // We should always receive a nonterminal
        assert(cast(ASTNonTerminal)execNode !is null);
    }
    body
    {
        // Cast the general ASTNode to a non-terminal node to actually work
        // with
        auto node = cast(ASTNonTerminal)execNode;
        // Final switch says we're positive we've covered all possiblities
        switch (node.name)
        {
        case "GRAMMAR":
            parserDef = new ParserDefinition();
            foreach (child; node.children)
            {
                compile(child);
            }
            parserDef.compileDefinition();
            genCode = parserDef.definition;
            break;
        case "RULE":
            auto ruleNameNode = cast(ASTNonTerminal)node.children[0];
            auto ruleName = (cast(ASTTerminal)(ruleNameNode.children[0])).token;
            curFunc = new FunctionComponents(ruleName);
            foreach (child; node.children[1..$])
            {
                compile(child);
            }
            parserDef.funcs ~= [curFunc];
            break;
        case "RULESEGMENT":
            auto segmentNode = cast(ASTNonTerminal)node.children[0];
            auto segmentType = segmentNode.name;
            if (segmentType != "RULENAME")
            {
                compile(node.children[0]);
            }
            string sequence = "";
            if (node.children.length > 1)
            {
                auto operatorNode = cast(ASTNonTerminal)node.children[1];
                auto op = (cast(ASTTerminal)(operatorNode.children[0])).token;
                final switch (op)
                {
                case "*":
                    switch (segmentType)
                    {
                    case "TERMINAL":
                        sequence ~= `        while (` ~ curFunc.ruleName ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            collectedNodes++;` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        break;
                    case "PARENSEGMENT":
                        sequence ~= `        while (result = ` ~ curFunc.ruleName ~ `Paren_` ~ curFunc.parenInFuncs.length.to!string ~ `(), result.isSuccess)` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            collectedNodes += result.collectedNodes;` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        break;
                    case "RULENAME":
                        auto ruleName = (cast(ASTTerminal)(segmentNode.children[0])).token;
                        sequence ~= `        while (` ~ ruleName ~ `())` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            collectedNodes++;` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        break;
                    default:
                        writeln("Can't handle ", segmentType);
                    }
                    break;
                case "+":
                    switch (segmentType)
                    {
                    case "TERMINAL":
                        sequence ~= `        if (` ~ curFunc.ruleName ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            collectedNodes++;` ~ "\n";
                        sequence ~= `            while (` ~ curFunc.ruleName ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                        sequence ~= `            {` ~ "\n";
                        sequence ~= `                collectedNodes++;` ~ "\n";
                        sequence ~= `            }` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        sequence ~= `        else` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
                        sequence ~= `            index = saveIndex;` ~ "\n";
                        sequence ~= `            return false;` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        break;
                    case "PARENSEGMENT":
                        sequence ~= `        if (result = ` ~ curFunc.ruleName ~ `Paren_` ~ curFunc.parenInFuncs.length.to!string ~ `(), result.isSuccess)` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            collectedNodes += result.collectedNodes;` ~ "\n";
                        sequence ~= `            while (result = ` ~ curFunc.ruleName ~ `Paren_` ~ curFunc.parenInFuncs.length.to!string ~ `(), result.isSuccess)` ~ "\n";
                        sequence ~= `            {` ~ "\n";
                        sequence ~= `                collectedNodes += result.collectedNodes;` ~ "\n";
                        sequence ~= `            }` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        sequence ~= `        else` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
                        sequence ~= `            index = saveIndex;` ~ "\n";
                        sequence ~= `            return false;` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        break;
                    case "RULENAME":
                        auto ruleName = (cast(ASTTerminal)(segmentNode.children[0])).token;
                        sequence ~= `        if (` ~ ruleName ~ `())` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            collectedNodes++;` ~ "\n";
                        sequence ~= `            while (` ~ ruleName ~ `())` ~ "\n";
                        sequence ~= `            {` ~ "\n";
                        sequence ~= `                collectedNodes++;` ~ "\n";
                        sequence ~= `            }` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        sequence ~= `        else` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
                        sequence ~= `            index = saveIndex;` ~ "\n";
                        sequence ~= `            return false;` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        break;
                    default:
                        writeln("Can't handle ", segmentType);
                    }
                    break;
                case "?":
                    switch (segmentType)
                    {
                    case "TERMINAL":
                        sequence ~= `        if (` ~ curFunc.ruleName ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            collectedNodes++;` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        break;
                    case "PARENSEGMENT":
                        sequence ~= `        if (result = ` ~ curFunc.ruleName ~ `Paren_` ~ curFunc.parenInFuncs.length.to!string ~ `(), result.isSuccess)` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            collectedNodes += result.collectedNodes;` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        break;
                    case "RULENAME":
                        auto ruleName = (cast(ASTTerminal)(segmentNode.children[0])).token;
                        sequence ~= `        if (` ~ ruleName ~ `())` ~ "\n";
                        sequence ~= `        {` ~ "\n";
                        sequence ~= `            collectedNodes++;` ~ "\n";
                        sequence ~= `        }` ~ "\n";
                        break;
                    default:
                        writeln("Can't handle ", segmentType);
                    }
                    break;
                }
            }
            else
            {
                switch (segmentType)
                {
                case "TERMINAL":
                    sequence ~= `        if (` ~ curFunc.ruleName ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                    sequence ~= `        {` ~ "\n";
                    sequence ~= `            collectedNodes++;` ~ "\n";
                    sequence ~= `        }` ~ "\n";
                    sequence ~= `        else` ~ "\n";
                    sequence ~= `        {` ~ "\n";
                    sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
                    sequence ~= `            index = saveIndex;` ~ "\n";
                    sequence ~= `            return false;` ~ "\n";
                    sequence ~= `        }` ~ "\n";
                    break;
                case "PARENSEGMENT":
                    sequence ~= `        if (result = ` ~ curFunc.ruleName ~ `Paren_` ~ curFunc.parenInFuncs.length.to!string ~ `(), result.isSuccess)` ~ "\n";
                    sequence ~= `        {` ~ "\n";
                    sequence ~= `            collectedNodes += result.collectedNodes;` ~ "\n";
                    sequence ~= `        }` ~ "\n";
                    sequence ~= `        else` ~ "\n";
                    sequence ~= `        {` ~ "\n";
                    sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
                    sequence ~= `            index = saveIndex;` ~ "\n";
                    sequence ~= `            return false;` ~ "\n";
                    sequence ~= `        }` ~ "\n";
                    break;
                case "RULENAME":
                    auto ruleName = (cast(ASTTerminal)(segmentNode.children[0])).token;
                    sequence ~= `        if (` ~ ruleName ~ `())` ~ "\n";
                    sequence ~= `        {` ~ "\n";
                    sequence ~= `            collectedNodes++;` ~ "\n";
                    sequence ~= `        }` ~ "\n";
                    sequence ~= `        else` ~ "\n";
                    sequence ~= `        {` ~ "\n";
                    sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
                    sequence ~= `            index = saveIndex;` ~ "\n";
                    sequence ~= `            return false;` ~ "\n";
                    sequence ~= `        }` ~ "\n";
                    break;
                default:
                    writeln("Can't handle ", segmentType);
                }
            }
            curFunc.sequences ~= [sequence];
            break;
        case "TERMINAL":
            auto terminalTypeNode = cast(ASTNonTerminal)node.children[0];
            auto terminal = (cast(ASTTerminal)(terminalTypeNode.children[0])).token;
            string terminalFunc = "";
            terminalFunc ~= `        bool ` ~ curFunc.ruleName ~ `Literal_` ~ (curFunc.termInFuncs.length + 1).to!string ~ `()` ~ "\n";
            terminalFunc ~= `        {` ~ "\n";
            terminalFunc ~= `            debug (TRACE) mixin(tracer);` ~ "\n";
            terminalFunc ~= "            auto reg = ctRegex!(`^" ~ terminal[1..$-1] ~ "`);" ~ "\n";
            terminalFunc ~= `            auto mat = match(source[index..$], reg);` ~ "\n";
            terminalFunc ~= `            if (mat)` ~ "\n";
            terminalFunc ~= `            {` ~ "\n";
            terminalFunc ~= `                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");` ~ "\n";
            terminalFunc ~= `                auto terminal = new ASTTerminal(mat.captures[0], index);` ~ "\n";
            terminalFunc ~= `                index += mat.captures[0].length;` ~ "\n";
            terminalFunc ~= `                consumeWhitespace();` ~ "\n";
            terminalFunc ~= `                stack ~= terminal;` ~ "\n";
            terminalFunc ~= `            }` ~ "\n";
            terminalFunc ~= `            else` ~ "\n";
            terminalFunc ~= `            {` ~ "\n";
            terminalFunc ~= `                debug (TRACE) writeln(traceIndent, "  No match.");` ~ "\n";
            terminalFunc ~= `                return false;` ~ "\n";
            terminalFunc ~= `            }` ~ "\n";
            terminalFunc ~= `            return true;` ~ "\n";
            terminalFunc ~= `        }` ~ "\n";
            curFunc.termInFuncs ~= [terminalFunc];
            break;
        case "ORCHAIN":
            string elseIf = "";
            string sequence = "";
            foreach (child; node.children)
            {
                auto nonTermNode = cast(ASTNonTerminal)child;
                auto segmentNode = cast(ASTNonTerminal)nonTermNode.children[0];
                auto segmentType = segmentNode.name;
                if (segmentType != "RULENAME")
                {
                    compile(nonTermNode.children[0]);
                }
                switch (segmentType)
                {
                case "TERMINAL":
                    sequence ~= `        ` ~ elseIf ~ `if (` ~ curFunc.ruleName ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                    sequence ~= `        {` ~ "\n";
                    sequence ~= `            collectedNodes++;` ~ "\n";
                    sequence ~= `        }` ~ "\n";
                    break;
                case "PARENSEGMENT":
                    sequence ~= `        ` ~ elseIf ~ `if (result = ` ~ curFunc.ruleName ~ `Paren_` ~ curFunc.parenInFuncs.length.to!string ~ `(), result.isSuccess)` ~ "\n";
                    sequence ~= `        {` ~ "\n";
                    sequence ~= `            collectedNodes += result.collectedNodes;` ~ "\n";
                    sequence ~= `        }` ~ "\n";
                    break;
                case "RULENAME":
                    auto ruleName = (cast(ASTTerminal)(segmentNode.children[0])).token;
                    sequence ~= `        ` ~ elseIf ~ `if (` ~ ruleName ~ `())` ~ "\n";
                    sequence ~= `        {` ~ "\n";
                    sequence ~= `            collectedNodes++;` ~ "\n";
                    sequence ~= `        }` ~ "\n";
                    break;
                default:
                    writeln("Can't handle ", segmentType);
                }
                elseIf = "else ";
            }
            sequence ~= `        else` ~ "\n";
            sequence ~= `        {` ~ "\n";
            sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
            sequence ~= `            index = saveIndex;` ~ "\n";
            sequence ~= `            return false;` ~ "\n";
            sequence ~= `        }` ~ "\n";
            curFunc.sequences ~= [sequence];
            break;
            break;
        default:
            writeln("No handler for ", node.name);
        }
    }

    bool verifyIntegrity(ASTNode execNode)
    {
        bool[string] ruleNames;
        uint[string] calledRules;

        void gatherRuleNames(ASTNode execNode)
        {
            auto node = cast(ASTNonTerminal)execNode;
            foreach (child; node.children)
            {
                auto childNonTerminal = cast(ASTNonTerminal)child;
                auto ruleNameNode = cast(ASTNonTerminal)childNonTerminal.children[0];
                auto ruleName =
                    (cast(ASTTerminal)(ruleNameNode.children[0])).token;
                ruleNames[ruleName] = true;
            }
        }

        void gatherCalledRules(ASTNode execNode)
        {
            auto node = cast(ASTNonTerminal)execNode;
            if (node is null)
            {
                return;
            }
            switch (node.name)
            {
            case "RULENAME":
                auto nameToken = (cast(ASTTerminal)node.children[0]).token;
                auto index = (cast(ASTTerminal)node.children[0]).index;
                calledRules[nameToken] = index;
                break;
            default:
                foreach (child; node.children)
                {
                    gatherCalledRules(child);
                }
                break;
            }
        }

        gatherRuleNames(execNode);
        gatherCalledRules(execNode);
        foreach (key; calledRules.byKey())
        {
            if (key !in ruleNames)
            {
                writefln("Undefined rule [%s] called at index: %d", key, calledRules[key]);
                return false;
            }
        }
        return true;
    }
}

int main(string[] argv)
{
    // Version with parenthised sections
    //auto parser = new Parser(
    //    `
    //    grammar :: rule + ;
    //    rule :: ruleName "::" (orChain | ruleSegment) + ";" ;
    //    ruleSegment :: (ruleName unaryOperator ?)
    //                 | (parenSegment unaryOperator ?)
    //                 | (terminal unaryOperator ?)
    //                 ;
    //    parenSegment :: "(" ruleSegment + ")" ;
    //    orChain :: ruleSegment "|" ruleSegment ("|" ruleSegment)* ;
    //    unaryOperator :: "*"
    //                   | "+"
    //                   | "?";
    //    terminal :: terminalLiteral | terminalRegex ;
    //    terminalLiteral :: /"(?:\\.|[^\"\\])*"/ ;
    //    terminalRegex :: /\/(?:\\.|[^\/\\])*\// ;
    //    ruleName :: /[a-zA-Z_][a-zA-Z0-9_]*/ ;
    //    `
    //    );
    // Version without parentheses
    //auto parser = new Parser(
    //    `
    //    grammar :: rule + ;
    //    rule :: ruleName "::" orChainOrRuleSegment + ";" ;
    //    orChainOrRuleSegment :: orChain | ruleSegment;
    //    ruleSegment :: ruleNameWithOp
    //                 | terminalWithOp
    //                 ;
    //    ruleNameWithOp :: ruleName unaryOperator ?;
    //    terminalWithOp :: terminal unaryOperator ?;
    //    orChain :: ruleSegment "\|" ruleSegment orChainExtra* ;
    //    orChainExtra :: "\|" ruleSegment;
    //    unaryOperator :: "\*"
    //                   | "\+"
    //                   | "\?";
    //    terminal :: terminalLiteral | terminalRegex ;
    //    terminalLiteral :: /"(?:\\.|[^"\\])*"/ ;
    //    terminalRegex :: /\/(?:\\.|[^\/\\])*\// ;
    //    ruleName :: /[a-zA-Z_][a-zA-Z0-9_]*/ ;
    //    `
    //    );
    //auto parser = new Parser(
    //    `
    //    program :: block ;
    //    block :: "begin" statement* "end" ;
    //    statement :: assignment
    //               | ifblock
    //               | whileblock
    //               | pass
    //               | block
    //               | print ;
    //    assignment :: identifier ":=" expression terminator ;
    //    pass :: "pass" terminator ;
    //    ifblock :: "if" logicExpr statement "else" statement ;
    //    whileblock :: "while" logicExpr statement ;

    //    print :: "print" identifier terminator ;

    //    expression :: sum ;
    //    sum :: product sumOpProduct* ;
    //    sumOpProduct :: sumOp product ;
    //    product :: value mulOpValue* ;
    //    mulOpValue :: mulOp value ;
    //    value :: num
    //           | parenExpr
    //           | identifier ;
    //    parenExpr :: "(" expression ")" ;

    //    terminator :: ";" ;
    //    sumOp :: /[+-]/ ;
    //    mulOp :: /[*\/%]/ ;
    //    num :: /[1-9][0-9]*(?:\.[0-9]*)?/ ;
    //    identifier :: /[a-zA-Z_][a-zA-Z0-9_]*/ ;


    //    logicExpr :: logicRelationship logicOpLogicRelationship* ;
    //    logicOpLogicRelationship :: logicOp logicRelationship;
    //    logicRelationship :: expression relationOpExpression ? ;
    //    relationOpExpression :: relationOp expression;
    //    logicOp :: "&&"
    //             | "||" ;
    //    relationOp :: "<"
    //                | ">"
    //                | "<="
    //                | ">="
    //                | "=="
    //                | "!=" ;
    //    `
    //    );
    string line = "";
    string source = "";
    while ((line = stdin.readln) !is null)
    {
        source ~= line;
    }
    auto parser = new Parser(source);
    auto topNode = parser.parse();
    if (topNode !is null)
    {
        auto context = new GenParser(topNode);
        auto code = context.generate();
        writeln(code);
    }
    else
    {
        writeln("Failed to parse!");
    }
    return 0;
}
