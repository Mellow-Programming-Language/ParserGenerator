import std.stdio;
import std.regex;
import std.string;
import std.array;
import std.algorithm;
import grammarNode;
class Parser
{
    this (string source)
    {
        this.source = source;
        this.index = 0;
        debug(TRACE) this.traceIndent = "";
    }
    ASTNode parse()
    {
        consumeWhitespace();
        ASTNode topNode = null;
        if (grammar())
        {
            topNode = stack[$-1];
        }
        index = 0;
        stack = [];
        return topNode;
    }
private:
    string source;
    uint index;
    ASTNode[] stack;
    struct ParenResult
    {
        uint collectedNodes;
        bool isSuccess;
        this (uint collectedNodes, bool isSuccess)
        {
            this.collectedNodes = collectedNodes;
            this.isSuccess = isSuccess;
        }
    }
    debug (TRACE)
    {
        string traceIndent;
        enum tracer =
            `
            string funcName = __FUNCTION__;
            funcName =
                funcName[__MODULE__.length + typeof(this).stringof.length + 2..$];
            writeln(traceIndent, "Entered: ", funcName, ", Index: ", index);
            traceIndent ~= "  ";
            scope(exit)
            {
                traceIndent = traceIndent[0..$-2];
                writeln(traceIndent, "Exiting: ", funcName, ", Index: ", index);
            }
            `;
    }
    bool grammar()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (rule())
        {
            collectedNodes++;
            while (rule())
            {
                collectedNodes++;
            }
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("GRAMMAR");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool rule()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool ruleLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^::`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                index += mat.captures[0].length;
                consumeWhitespace();
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        bool ruleLiteral_2()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^;`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                index += mat.captures[0].length;
                consumeWhitespace();
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        uint collectedNodes = 0;
        if (ruleName())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (ruleLiteral_1())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (prunedElevatedNormal())
        {
            collectedNodes++;
            while (prunedElevatedNormal())
            {
                collectedNodes++;
            }
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (ruleLiteral_2())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("RULE");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool prunedElevatedNormal()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (pruned())
        {
            collectedNodes++;
        }
        else if (elevated())
        {
            collectedNodes++;
        }
        else if (normal())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("PRUNEDELEVATEDNORMAL");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool pruned()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool prunedLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^#`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                index += mat.captures[0].length;
                consumeWhitespace();
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        uint collectedNodes = 0;
        if (prunedLiteral_1())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (orChain())
        {
            collectedNodes++;
        }
        else if (ruleSegment())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("PRUNED");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool elevated()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool elevatedLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^\^`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                index += mat.captures[0].length;
                consumeWhitespace();
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        uint collectedNodes = 0;
        if (elevatedLiteral_1())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (orChain())
        {
            collectedNodes++;
        }
        else if (ruleSegment())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("ELEVATED");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool normal()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (orChain())
        {
            collectedNodes++;
        }
        else if (ruleSegment())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("NORMAL");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool ruleSegment()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (ruleNameWithOp())
        {
            collectedNodes++;
        }
        else if (terminalWithOp())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("RULESEGMENT");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool ruleNameWithOp()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (ruleName())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (unaryOperator())
        {
            collectedNodes++;
        }
        auto nonTerminal = new ASTNonTerminal("RULENAMEWITHOP");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool terminalWithOp()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (terminal())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (unaryOperator())
        {
            collectedNodes++;
        }
        auto nonTerminal = new ASTNonTerminal("TERMINALWITHOP");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool orChain()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool orChainLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^\|`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                index += mat.captures[0].length;
                consumeWhitespace();
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        uint collectedNodes = 0;
        if (ruleSegment())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (orChainLiteral_1())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (ruleSegment())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        while (orChainExtra())
        {
            collectedNodes++;
        }
        auto nonTerminal = new ASTNonTerminal("ORCHAIN");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool orChainExtra()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool orChainExtraLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^\|`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                index += mat.captures[0].length;
                consumeWhitespace();
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        uint collectedNodes = 0;
        if (orChainExtraLiteral_1())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (ruleSegment())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("ORCHAINEXTRA");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool unaryOperator()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool unaryOperatorLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^\*`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                index += mat.captures[0].length;
                consumeWhitespace();
                stack ~= terminal;
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        bool unaryOperatorLiteral_2()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^\+`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                index += mat.captures[0].length;
                consumeWhitespace();
                stack ~= terminal;
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        bool unaryOperatorLiteral_3()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^\?`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                index += mat.captures[0].length;
                consumeWhitespace();
                stack ~= terminal;
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        uint collectedNodes = 0;
        if (unaryOperatorLiteral_1())
        {
            collectedNodes++;
        }
        else if (unaryOperatorLiteral_2())
        {
            collectedNodes++;
        }
        else if (unaryOperatorLiteral_3())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("UNARYOPERATOR");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool terminal()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (terminalLiteral())
        {
            collectedNodes++;
        }
        else if (terminalRegex())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("TERMINAL");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool terminalLiteral()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool terminalLiteralLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^"(?:\\.|[^"\\])*"`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                index += mat.captures[0].length;
                consumeWhitespace();
                stack ~= terminal;
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        uint collectedNodes = 0;
        if (terminalLiteralLiteral_1())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("TERMINALLITERAL");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool terminalRegex()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool terminalRegexLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^\/(?:\\.|[^\/\\])*\/`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                index += mat.captures[0].length;
                consumeWhitespace();
                stack ~= terminal;
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        uint collectedNodes = 0;
        if (terminalRegexLiteral_1())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("TERMINALREGEX");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool ruleName()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool ruleNameLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^[a-zA-Z_][a-zA-Z0-9_]*`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                index += mat.captures[0].length;
                consumeWhitespace();
                stack ~= terminal;
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }
        uint collectedNodes = 0;
        if (ruleNameLiteral_1())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("RULENAME");
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    void consumeWhitespace()
    {
        auto whitespaceRegex = ctRegex!(`^\s*`);
        auto whitespaceMatch = match(source[index..$], whitespaceRegex);
        if (whitespaceMatch)
        {
            index += whitespaceMatch.captures[0].length;
        }
    }
    void printStack(string indent = "")
    {
        foreach_reverse (x; stack)
        {
            if (cast(ASTNonTerminal)x !is null)
            {
                x.printTree(indent);
            }
            else if (cast(ASTTerminal)x !is null)
            {
                writeln("[", (cast(ASTTerminal)x).token, "]: ", (cast(ASTTerminal)x).index);
            }
        }
    }
    unittest
    {
        auto parser = new Parser(
            `
            grammar :: rule + ;
            rule :: ruleName "::" prunedElevatedNormal + ";" ;
            prunedElevatedNormal :: pruned | elevated | normal;
            pruned :: "#" orChain | ruleSegment ;
            elevated :: "\^" orChain | ruleSegment ;
            normal :: orChain | ruleSegment ;
            ruleSegment :: ruleNameWithOp
                         | terminalWithOp
                         ;
            ruleNameWithOp :: ruleName unaryOperator ?;
            terminalWithOp :: terminal unaryOperator ?;
            orChain :: ruleSegment "\|" ruleSegment orChainExtra* ;
            orChainExtra :: "\|" ruleSegment;
            unaryOperator :: "\*"
                           | "\+"
                           | "\?";
            terminal :: terminalLiteral | terminalRegex ;
            terminalLiteral :: /"(?:\\.|[^"\\])*"/ ;
            terminalRegex :: /\/(?:\\.|[^\/\\])*\// ;
            ruleName :: /[a-zA-Z_][a-zA-Z0-9_]*/ ;
            `
            );
        auto topNode = parser.parse();
        if (topNode is null)
        {
            writeln("Null I guess!");
        }
        else
        {
            writeln("Not null!");
            topNode.printTree();
        }
    }
}

