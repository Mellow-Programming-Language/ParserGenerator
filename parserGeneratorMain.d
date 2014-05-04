import std.stdio;
import std.conv;
import std.string;
import std.array;
import std.string;
import visitor;
import grammarParserMain;

string camel(string name)
{
    return name[0..1].toLower ~ name[1..$];
}

class GenParser : Visitor
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
        visit(cast(GrammarNode)topNode);
        return genCode;
    }

    void visit(GrammarNode node)
    {
        parserDef = new ParserDefinition();
        foreach (child; node.children)
        {
            child.accept(this);
        }
        parserDef.compileDefinition();
        parserDef.generateVisitorBoilerplate();
        genCode = parserDef.definition;
    }

    void visit(RuleNode node)
    {
        auto ruleNameNode = cast(ASTNonTerminal)node.children[0];
        auto ruleName = (cast(ASTTerminal)(ruleNameNode.children[0])).token;
        if (firstRule)
        {
            firstRule = false;
            parserDef.startRule = ruleName;
        }
        curFunc = new FunctionComponents(ruleName);
        foreach (child; node.children[1..$])
        {
            child.accept(this);
        }
        parserDef.funcs ~= [curFunc];
    }

    void visit(NormalNode node)
    {
        status = NodeStatus.NORMAL;
        node.children[0].accept(this);
    }

    void visit(PrunedNode node)
    {
        status = NodeStatus.PRUNED;
        node.children[0].accept(this);
    }

    void visit(ElevatedNode node)
    {
        status = NodeStatus.ELEVATED;
        node.children[0].accept(this);
    }

    void visit(RuleNameWithOpNode node)
    {
        auto ruleNameNode = cast(ASTNonTerminal)node.children[0];
        auto ruleName = (cast(ASTTerminal)(ruleNameNode.children[0])).token;
        string sequence = "";
        if (node.children.length > 1)
        {
            auto operatorNode = cast(ASTNonTerminal)node.children[1];
            auto op = (cast(ASTTerminal)(operatorNode.children[0])).token;
            final switch (op)
            {
            case "*":
                sequence ~= `        while (` ~ ruleName.camel ~ `())` ~ "\n";
                sequence ~= `        {` ~ "\n";
                if (status == NodeStatus.PRUNED)
                {
                sequence ~= `            stack = stack[0..$-1];` ~ "\n";
                }
                else if (status == NodeStatus.ELEVATED)
                {
                sequence ~= `            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);` ~ "\n";
                sequence ~= `            stack = stack[0..$-1];` ~ "\n";
                sequence ~= `            foreach (child; tempNode.children)` ~ "\n";
                sequence ~= `            {` ~ "\n";
                sequence ~= `                stack ~= child;` ~ "\n";
                sequence ~= `            }` ~ "\n";
                sequence ~= `            collectedNodes += tempNode.children.length;` ~ "\n";
                }
                else
                {
                sequence ~= `            collectedNodes++;` ~ "\n";
                }
                sequence ~= `        }` ~ "\n";
                break;
            case "+":
                sequence ~= `        if (` ~ ruleName.camel ~ `())` ~ "\n";
                sequence ~= `        {` ~ "\n";
                if (status == NodeStatus.PRUNED)
                {
                sequence ~= `            stack = stack[0..$-1];` ~ "\n";
                }
                else if (status == NodeStatus.ELEVATED)
                {
                sequence ~= `            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);` ~ "\n";
                sequence ~= `            stack = stack[0..$-1];` ~ "\n";
                sequence ~= `            foreach (child; tempNode.children)` ~ "\n";
                sequence ~= `            {` ~ "\n";
                sequence ~= `                stack ~= child;` ~ "\n";
                sequence ~= `            }` ~ "\n";
                sequence ~= `            collectedNodes += tempNode.children.length;` ~ "\n";
                }
                else
                {
                sequence ~= `            collectedNodes++;` ~ "\n";
                }
                sequence ~= `            while (` ~ ruleName.camel ~ `())` ~ "\n";
                sequence ~= `            {` ~ "\n";
                if (status == NodeStatus.PRUNED)
                {
                sequence ~= `                stack = stack[0..$-1];` ~ "\n";
                }
                else if (status == NodeStatus.ELEVATED)
                {
                sequence ~= `                tempNode = cast(ASTNonTerminal)(stack[$-1]);` ~ "\n";
                sequence ~= `                stack = stack[0..$-1];` ~ "\n";
                sequence ~= `                foreach (child; tempNode.children)` ~ "\n";
                sequence ~= `                {` ~ "\n";
                sequence ~= `                    stack ~= child;` ~ "\n";
                sequence ~= `                }` ~ "\n";
                sequence ~= `                collectedNodes += tempNode.children.length;` ~ "\n";
                }
                else
                {
                sequence ~= `                collectedNodes++;` ~ "\n";
                }
                sequence ~= `            }` ~ "\n";
                sequence ~= `        }` ~ "\n";
                sequence ~= `        else` ~ "\n";
                sequence ~= `        {` ~ "\n";
                sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
                sequence ~= `            index = saveIndex;` ~ "\n";
                sequence ~= `            return false;` ~ "\n";
                sequence ~= `        }` ~ "\n";
                break;
            case "?":
                sequence ~= `        if (` ~ ruleName.camel ~ `())` ~ "\n";
                sequence ~= `        {` ~ "\n";
                if (status == NodeStatus.PRUNED)
                {
                sequence ~= `            stack = stack[0..$-1];` ~ "\n";
                }
                else if (status == NodeStatus.ELEVATED)
                {
                sequence ~= `            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);` ~ "\n";
                sequence ~= `            stack = stack[0..$-1];` ~ "\n";
                sequence ~= `            foreach (child; tempNode.children)` ~ "\n";
                sequence ~= `            {` ~ "\n";
                sequence ~= `                stack ~= child;` ~ "\n";
                sequence ~= `            }` ~ "\n";
                sequence ~= `            collectedNodes += tempNode.children.length;` ~ "\n";
                }
                else
                {
                sequence ~= `            collectedNodes++;` ~ "\n";
                }
                sequence ~= `        }` ~ "\n";
                break;
            }
        }
        else
        {
            sequence ~= `        if (` ~ ruleName.camel ~ `())` ~ "\n";
            sequence ~= `        {` ~ "\n";
            if (status == NodeStatus.PRUNED)
            {
            sequence ~= `            stack = stack[0..$-1];` ~ "\n";
            }
            else if (status == NodeStatus.ELEVATED)
            {
            sequence ~= `            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);` ~ "\n";
            sequence ~= `            stack = stack[0..$-1];` ~ "\n";
            sequence ~= `            foreach (child; tempNode.children)` ~ "\n";
            sequence ~= `            {` ~ "\n";
            sequence ~= `                stack ~= child;` ~ "\n";
            sequence ~= `            }` ~ "\n";
            sequence ~= `            collectedNodes += tempNode.children.length;` ~ "\n";
            }
            else
            {
            sequence ~= `            collectedNodes++;` ~ "\n";
            }
            sequence ~= `        }` ~ "\n";
            sequence ~= `        else` ~ "\n";
            sequence ~= `        {` ~ "\n";
            sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
            sequence ~= `            index = saveIndex;` ~ "\n";
            sequence ~= `            return false;` ~ "\n";
            sequence ~= `        }` ~ "\n";
        }
        curFunc.sequences ~= [sequence];
    }

    void visit(TerminalWithOpNode node)
    {
        node.children[0].accept(this);
        if (inOrChain)
        {
            return;
        }
        string sequence = "";
        if (node.children.length > 1)
        {
            auto operatorNode = cast(ASTNonTerminal)node.children[1];
            auto op = (cast(ASTTerminal)(operatorNode.children[0])).token;
            final switch (op)
            {
            case "*":
                sequence ~= `        while (` ~ curFunc.ruleName.camel ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                sequence ~= `        {` ~ "\n";
                if (status != NodeStatus.PRUNED)
                {
                sequence ~= `            collectedNodes++;` ~ "\n";
                }
                sequence ~= `        }` ~ "\n";
                break;
            case "+":
                sequence ~= `        if (` ~ curFunc.ruleName.camel ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                sequence ~= `        {` ~ "\n";
                if (status != NodeStatus.PRUNED)
                {
                sequence ~= `            collectedNodes++;` ~ "\n";
                }
                sequence ~= `            while (` ~ curFunc.ruleName.camel ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                sequence ~= `            {` ~ "\n";
                if (status != NodeStatus.PRUNED)
                {
                sequence ~= `                collectedNodes++;` ~ "\n";
                }
                sequence ~= `            }` ~ "\n";
                sequence ~= `        }` ~ "\n";
                sequence ~= `        else` ~ "\n";
                sequence ~= `        {` ~ "\n";
                sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
                sequence ~= `            index = saveIndex;` ~ "\n";
                sequence ~= `            return false;` ~ "\n";
                sequence ~= `        }` ~ "\n";
                break;
            case "?":
                sequence ~= `        if (` ~ curFunc.ruleName.camel ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                sequence ~= `        {` ~ "\n";
                if (status != NodeStatus.PRUNED)
                {
                sequence ~= `            collectedNodes++;` ~ "\n";
                }
                sequence ~= `        }` ~ "\n";
                break;
            }
        }
        else
        {
            sequence ~= `        if (` ~ curFunc.ruleName.camel ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
            sequence ~= `        {` ~ "\n";
            if (status != NodeStatus.PRUNED)
            {
            sequence ~= `            collectedNodes++;` ~ "\n";
            }
            sequence ~= `        }` ~ "\n";
            sequence ~= `        else` ~ "\n";
            sequence ~= `        {` ~ "\n";
            sequence ~= `            stack = stack[0..$-collectedNodes];` ~ "\n";
            sequence ~= `            index = saveIndex;` ~ "\n";
            sequence ~= `            return false;` ~ "\n";
            sequence ~= `        }` ~ "\n";
        }
        curFunc.sequences ~= [sequence];
    }

    void visit(RuleSegmentNode node)
    {
        node.children[0].accept(this);
    }

    void visit(TerminalNode node)
    {
        auto terminalTypeNode = cast(ASTNonTerminal)node.children[0];
        auto terminal = (cast(ASTTerminal)(terminalTypeNode.children[0])).token;
        string terminalFunc = "";
        terminalFunc ~= `        bool ` ~ curFunc.ruleName.camel ~ `Literal_` ~ (curFunc.termInFuncs.length + 1).to!string ~ `()` ~ "\n";
        terminalFunc ~= `        {` ~ "\n";
        terminalFunc ~= `            debug (TRACE) mixin(tracer);` ~ "\n";
        terminalFunc ~= "            auto reg = ctRegex!(`^" ~ terminal[1..$-1] ~ "`);" ~ "\n";
        terminalFunc ~= `            auto mat = match(source[index..$], reg);` ~ "\n";
        terminalFunc ~= `            if (mat)` ~ "\n";
        terminalFunc ~= `            {` ~ "\n";
        terminalFunc ~= `                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");` ~ "\n";
        if (status != NodeStatus.PRUNED)
        {
        terminalFunc ~= `                auto terminal = new ASTTerminal(mat.captures[0], index);` ~ "\n";
        }
        terminalFunc ~= `                index += mat.captures[0].length;` ~ "\n";
        terminalFunc ~= `                consumeWhitespace();` ~ "\n";
        if (status != NodeStatus.PRUNED)
        {
        terminalFunc ~= `                stack ~= terminal;` ~ "\n";
        }
        terminalFunc ~= `            }` ~ "\n";
        terminalFunc ~= `            else` ~ "\n";
        terminalFunc ~= `            {` ~ "\n";
        terminalFunc ~= `                debug (TRACE) writeln(traceIndent, "  No match.");` ~ "\n";
        terminalFunc ~= `                return false;` ~ "\n";
        terminalFunc ~= `            }` ~ "\n";
        terminalFunc ~= `            return true;` ~ "\n";
        terminalFunc ~= `        }` ~ "\n";
        curFunc.termInFuncs ~= [terminalFunc];
    }

    void visit(OrChainNode node)
    {
        inOrChain = true;
        string elseIf = "";
        string sequence = "";
        foreach (child; node.children)
        {
            // RULESEGMENT
            auto nonTermNode = cast(ASTNonTerminal)child;
            // ruleNameWithOp or terminalWithOp
            auto segmentNode = cast(ASTNonTerminal)nonTermNode.children[0];
            auto segmentType = segmentNode.name;
            // ruleName or terminal
            auto typeNode = cast(ASTNonTerminal)segmentNode.children[0];
            auto typeName = typeNode.name;
            if (segmentType != "RULENAMEWITHOP")
            {
                segmentNode.accept(this);
            }
            switch (typeName)
            {
            case "TERMINAL":
                sequence ~= `        ` ~ elseIf ~ `if (` ~ curFunc.ruleName.camel ~ `Literal_` ~ curFunc.termInFuncs.length.to!string ~ `())` ~ "\n";
                sequence ~= `        {` ~ "\n";
                if (status != NodeStatus.PRUNED)
                {
                sequence ~= `            collectedNodes++;` ~ "\n";
                }
                sequence ~= `        }` ~ "\n";
                break;
            case "RULENAME":
                auto ruleName = (cast(ASTTerminal)(typeNode.children[0])).token;
                sequence ~= `        ` ~ elseIf ~ `if (` ~ ruleName.camel ~ `())` ~ "\n";
                sequence ~= `        {` ~ "\n";
                if (status == NodeStatus.PRUNED)
                {
                sequence ~= `            stack = stack[0..$-1];` ~ "\n";
                }
                else if (status == NodeStatus.ELEVATED)
                {
                sequence ~= `            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);` ~ "\n";
                sequence ~= `            stack = stack[0..$-1];` ~ "\n";
                sequence ~= `            foreach (child; tempNode.children)` ~ "\n";
                sequence ~= `            {` ~ "\n";
                sequence ~= `                stack ~= child;` ~ "\n";
                sequence ~= `            }` ~ "\n";
                sequence ~= `            collectedNodes += tempNode.children.length;` ~ "\n";
                }
                else
                {
                sequence ~= `            collectedNodes++;` ~ "\n";
                }
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
        inOrChain = false;
    }

    void visit(PrunedElevatedNormalNode node) {}
    void visit(OrChainExtraNode node) {}
    void visit(UnaryOperatorNode node) {}
    void visit(TerminalRegexNode node) {}
    void visit(RuleNameNode node) {}
    void visit(TerminalLiteralNode node) {}
    void visit(ASTTerminal node) {}

private:

    ASTNode topNode;
    string genCode;
    FunctionComponents curFunc;
    ParserDefinition parserDef;

    enum NodeStatus {PRUNED, ELEVATED, NORMAL}
    static NodeStatus status = NodeStatus.NORMAL;
    static inOrChain = false;
    static firstRule = true;

    class ParserDefinition
    {
        string definition;
        string nodeClassDefinitions;
        FunctionComponents[] funcs;
        string imports;
        string header;
        string footer;
        string startRule;

        void genHeaderFooter()
        {
            imports = "";
            imports ~= `import std.stdio;` ~ "\n";
            imports ~= `import std.regex;` ~ "\n";
            imports ~= `import std.string;` ~ "\n";
            imports ~= `import std.array;` ~ "\n";
            imports ~= `import std.algorithm;` ~ "\n";
            imports ~= `import visitor;` ~ "\n";
            header = "";
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
            header ~= `        if (` ~ startRule.camel ~ `())` ~ "\n";
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
            genASTNodes();
            definition = "";
            definition ~= imports;
            definition ~= nodeClassDefinitions;
            definition ~= header;
            foreach (func; funcs)
            {
                func.compileFunction();
                definition ~= func.func;
            }
            definition ~= footer;
        }

        void genASTNodes()
        {
            nodeClassDefinitions = "";

            nodeClassDefinitions ~= `void printTree(ASTNode node, string indent = "")` ~ "\n";
            nodeClassDefinitions ~= `{` ~ "\n";
            nodeClassDefinitions ~= `    if (cast(ASTNonTerminal)node)` ~ "\n";
            nodeClassDefinitions ~= `    {` ~ "\n";
            nodeClassDefinitions ~= `        writeln(indent, (cast(ASTNonTerminal)node).name);` ~ "\n";
            nodeClassDefinitions ~= `        foreach (x; (cast(ASTNonTerminal)node).children)` ~ "\n";
            nodeClassDefinitions ~= `        {` ~ "\n";
            nodeClassDefinitions ~= `            printTree(x, indent ~ "  ");` ~ "\n";
            nodeClassDefinitions ~= `        }` ~ "\n";
            nodeClassDefinitions ~= `    }` ~ "\n";
            nodeClassDefinitions ~= `    else if (cast(ASTTerminal)node)` ~ "\n";
            nodeClassDefinitions ~= `    {` ~ "\n";
            nodeClassDefinitions ~= `        writeln(indent, "[", (cast(ASTTerminal)node).token, "]: ",` ~ "\n";
            nodeClassDefinitions ~= `            (cast(ASTTerminal)node).index);` ~ "\n";
            nodeClassDefinitions ~= `    }` ~ "\n";
            nodeClassDefinitions ~= `}` ~ "\n";
            nodeClassDefinitions ~= `abstract class ASTNode` ~ "\n";
            nodeClassDefinitions ~= `{` ~ "\n";
            nodeClassDefinitions ~= `    string[string] properties;` ~ "\n";
            nodeClassDefinitions ~= `    void accept(Visitor v);` ~ "\n";
            nodeClassDefinitions ~= `}` ~ "\n";
            nodeClassDefinitions ~= `abstract class ASTNonTerminal : ASTNode` ~ "\n";
            nodeClassDefinitions ~= `{` ~ "\n";
            nodeClassDefinitions ~= `    ASTNode[] children;` ~ "\n";
            nodeClassDefinitions ~= `    string name;` ~ "\n";
            nodeClassDefinitions ~= `    void addChild(ASTNode node)` ~ "\n";
            nodeClassDefinitions ~= `    {` ~ "\n";
            nodeClassDefinitions ~= `        children ~= node;` ~ "\n";
            nodeClassDefinitions ~= `    }` ~ "\n";
            nodeClassDefinitions ~= `}` ~ "\n";
            nodeClassDefinitions ~= `class ASTTerminal : ASTNode` ~ "\n";
            nodeClassDefinitions ~= `{` ~ "\n";
            nodeClassDefinitions ~= `    const string token;` ~ "\n";
            nodeClassDefinitions ~= `    const uint index;` ~ "\n";
            nodeClassDefinitions ~= `    this (string token, uint index)` ~ "\n";
            nodeClassDefinitions ~= `    {` ~ "\n";
            nodeClassDefinitions ~= `        this.token = token;` ~ "\n";
            nodeClassDefinitions ~= `        this.index = index;` ~ "\n";
            nodeClassDefinitions ~= `    }` ~ "\n";
            nodeClassDefinitions ~= `    override void accept(Visitor v)` ~ "\n";
            nodeClassDefinitions ~= `    {` ~ "\n";
            nodeClassDefinitions ~= `        v.visit(this);` ~ "\n";
            nodeClassDefinitions ~= `    }` ~ "\n";
            nodeClassDefinitions ~= `}` ~ "\n";
            foreach (func; funcs)
            {
                string curDef = "";
                curDef ~= `class ` ~ func.ruleName ~ `Node : ASTNonTerminal` ~ "\n";
                curDef ~= `{` ~ "\n";
                curDef ~= `    this ()` ~ "\n";
                curDef ~= `    {` ~ "\n";
                curDef ~= `        this.name = "` ~ func.ruleName.toUpper ~ `";` ~ "\n";
                curDef ~= `    }` ~ "\n";
                curDef ~= `    override void accept(Visitor v)` ~ "\n";
                curDef ~= `    {` ~ "\n";
                curDef ~= `        v.visit(this);` ~ "\n";
                curDef ~= `    }` ~ "\n";
                curDef ~= `}` ~ "\n";
                nodeClassDefinitions ~= curDef;
            }
        }

        void generateVisitorBoilerplate()
        {
            string visitBoiler = "";
            string visitInterfaceFunc = "";
            string visitPrintFunc = "";
            foreach (func; funcs)
            {
                visitInterfaceFunc ~= `    void visit(` ~ func.ruleName ~ `Node node);` ~ "\n";
                visitPrintFunc ~= `    void visit(` ~ func.ruleName ~ `Node node)` ~ "\n";
                visitPrintFunc ~= `    {` ~ "\n";
                visitPrintFunc ~= `        writeln(indent, "` ~ func.ruleName.toUpper ~ `NODE");` ~ "\n";
                visitPrintFunc ~= `        indent ~= "  ";` ~ "\n";
                visitPrintFunc ~= `        foreach (child; node.children)` ~ "\n";
                visitPrintFunc ~= `        {` ~ "\n";
                visitPrintFunc ~= `            child.accept(this);` ~ "\n";
                visitPrintFunc ~= `        }` ~ "\n";
                visitPrintFunc ~= `        indent = indent[0..$-2];` ~ "\n";
                visitPrintFunc ~= `    }` ~ "\n";
            }
            visitInterfaceFunc ~= `    void visit(ASTTerminal node);` ~ "\n";
            visitBoiler ~= `import std.stdio;` ~ "\n";
            visitBoiler ~= `// Filename of parser also generated by this program` ~ "\n";
            visitBoiler ~= `import ;` ~ "\n";
            visitBoiler ~= `interface Visitor` ~ "\n";
            visitBoiler ~= `{` ~ "\n";
            foreach (interfaceFunc; visitInterfaceFunc)
            {
                visitBoiler ~= interfaceFunc;
            }
            visitBoiler ~= `}` ~ "\n\n";
            visitBoiler ~= `class PrintVisitor : Visitor` ~ "\n";
            visitBoiler ~= `{` ~ "\n";
            visitBoiler ~= `    string indent;` ~ "\n";
            visitBoiler ~= `    this ()` ~ "\n";
            visitBoiler ~= `    {` ~ "\n";
            visitBoiler ~= `        indent = "";` ~ "\n";
            visitBoiler ~= `    }` ~ "\n";
            foreach (printFunc; visitPrintFunc)
            {
                visitBoiler ~= printFunc;
            }
            visitBoiler ~= `    void visit(ASTTerminal node)` ~ "\n";
            visitBoiler ~= `    {` ~ "\n";
            visitBoiler ~= `        writeln(indent, "[", node.token, "]: ", node.index);` ~ "\n";
            visitBoiler ~= `    }` ~ "\n";
            visitBoiler ~= `}` ~ "\n";
            import std.file;
            auto file = new File("visitorAUTO.d", "w");
            scope (exit) file.close();
            if (file.isOpen())
            {
                file.write(visitBoiler);
            }
            else
            {
                // Failed to write out visitorAUTO.d
            }
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
            header ~= `    bool ` ~ ruleName.camel ~ "()\n";
            header ~= `    {` ~ "\n";
            header ~= `        debug (TRACE) mixin(tracer);` ~ "\n";
            header ~= `        uint saveIndex = index;` ~ "\n";

            footer ~= `        auto nonTerminal = new ` ~ ruleName ~ `Node();` ~ "\n";
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
        return 1;
    }
    return 0;
}
