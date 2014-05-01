import std.stdio;
import std.regex;
import std.string;
import std.array;
import std.algorithm;
import visitor;
void printTree(ASTNode node, string indent = "")
{
    if (cast(ASTNonTerminal)node)
    {
        writeln(indent, (cast(ASTNonTerminal)node).name);
        foreach (x; (cast(ASTNonTerminal)node).children)
        {
            printTree(x, indent ~ "  ");
        }
    }
    else if (cast(ASTTerminal)node)
    {
        writeln(indent, "[", (cast(ASTTerminal)node).token, "]: ",
            (cast(ASTTerminal)node).index);
    }
}
interface ASTNode
{
    void accept(Visitor v);
}
abstract class ASTNonTerminal : ASTNode
{
    ASTNode[] children;
    string name;
    void addChild(ASTNode node)
    {
        children ~= node;
    }
}
class ASTTerminal : ASTNode
{
    const string token;
    const uint index;
    this (string token, uint index)
    {
        this.token = token;
        this.index = index;
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class GrammarNode : ASTNonTerminal
{
    this ()
    {
        this.name = "GRAMMAR";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class RuleNode : ASTNonTerminal
{
    this ()
    {
        this.name = "RULE";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class PrunedElevatedNormalNode : ASTNonTerminal
{
    this ()
    {
        this.name = "PRUNEDELEVATEDNORMAL";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class PrunedNode : ASTNonTerminal
{
    this ()
    {
        this.name = "PRUNED";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class ElevatedNode : ASTNonTerminal
{
    this ()
    {
        this.name = "ELEVATED";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class NormalNode : ASTNonTerminal
{
    this ()
    {
        this.name = "NORMAL";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class RuleSegmentNode : ASTNonTerminal
{
    this ()
    {
        this.name = "RULESEGMENT";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class RuleNameWithOpNode : ASTNonTerminal
{
    this ()
    {
        this.name = "RULENAMEWITHOP";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class TerminalWithOpNode : ASTNonTerminal
{
    this ()
    {
        this.name = "TERMINALWITHOP";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class OrChainNode : ASTNonTerminal
{
    this ()
    {
        this.name = "ORCHAIN";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class OrChainExtraNode : ASTNonTerminal
{
    this ()
    {
        this.name = "ORCHAINEXTRA";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class UnaryOperatorNode : ASTNonTerminal
{
    this ()
    {
        this.name = "UNARYOPERATOR";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class TerminalNode : ASTNonTerminal
{
    this ()
    {
        this.name = "TERMINAL";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class TerminalLiteralNode : ASTNonTerminal
{
    this ()
    {
        this.name = "TERMINALLITERAL";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class TerminalRegexNode : ASTNonTerminal
{
    this ()
    {
        this.name = "TERMINALREGEX";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
class RuleNameNode : ASTNonTerminal
{
    this ()
    {
        this.name = "RULENAME";
    }
    void accept(Visitor v)
    {
        v.visit(this);
    }
}
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
        auto nonTerminal = new GrammarNode();
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
            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);
            stack = stack[0..$-1];
            foreach (child; tempNode.children)
            {
                stack ~= child;
            }
            collectedNodes += tempNode.children.length;
            while (prunedElevatedNormal())
            {
                tempNode = cast(ASTNonTerminal)(stack[$-1]);
                stack = stack[0..$-1];
                foreach (child; tempNode.children)
                {
                    stack ~= child;
                }
                collectedNodes += tempNode.children.length;
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
        auto nonTerminal = new RuleNode();
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
        auto nonTerminal = new PrunedElevatedNormalNode();
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
        auto nonTerminal = new PrunedNode();
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
        auto nonTerminal = new ElevatedNode();
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
        auto nonTerminal = new NormalNode();
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
        auto nonTerminal = new RuleSegmentNode();
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
        auto nonTerminal = new RuleNameWithOpNode();
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
        auto nonTerminal = new TerminalWithOpNode();
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
            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);
            stack = stack[0..$-1];
            foreach (child; tempNode.children)
            {
                stack ~= child;
            }
            collectedNodes += tempNode.children.length;
        }
        auto nonTerminal = new OrChainNode();
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
        auto nonTerminal = new OrChainExtraNode();
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
        auto nonTerminal = new UnaryOperatorNode();
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
        auto nonTerminal = new TerminalNode();
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
        auto nonTerminal = new TerminalLiteralNode();
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
        auto nonTerminal = new TerminalRegexNode();
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
        auto nonTerminal = new RuleNameNode();
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
}

