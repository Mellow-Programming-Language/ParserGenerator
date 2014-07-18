import std.stdio;
import std.regex;
import std.string;
import std.array;
import std.algorithm;
import std.variant;
import visitor;
void printTree(ASTNode node, string indent = "")
{
    if (cast(ASTNonTerminal)node) {
        writeln(indent, (cast(ASTNonTerminal)node).name);
        foreach (x; (cast(ASTNonTerminal)node).children) {
            printTree(x, indent ~ "  ");
        }
    }
    else if (cast(ASTTerminal)node) {
        writeln(indent, "[", (cast(ASTTerminal)node).token, "]: ",
            (cast(ASTTerminal)node).index);
    }
}
abstract class ASTNode
{
    Variant[string] data;
    void accept(Visitor v);
}
abstract class ASTNonTerminal : ASTNode
{
    ASTNode[] children;
    string name;
    void addChild(ASTNode node) {
        children ~= node;
    }
    Tag getTag() {
        return Tag.ASTNONTERMINAL;
    }
}
class ASTTerminal : ASTNode
{
    const string token;
    const uint index;
    this (string token, uint index) {
        this.token = token;
        this.index = index;
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
}
class GrammarNode : ASTNonTerminal
{
    this () {
        this.name = "GRAMMAR";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.GRAMMAR;
    }
}
class RuleNode : ASTNonTerminal
{
    this () {
        this.name = "RULE";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.RULE;
    }
}
class PrunedElevatedNormalNode : ASTNonTerminal
{
    this () {
        this.name = "PRUNEDELEVATEDNORMAL";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.PRUNEDELEVATEDNORMAL;
    }
}
class ParenNode : ASTNonTerminal
{
    this () {
        this.name = "PAREN";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.PAREN;
    }
}
class PrunedNode : ASTNonTerminal
{
    this () {
        this.name = "PRUNED";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.PRUNED;
    }
}
class ElevatedNode : ASTNonTerminal
{
    this () {
        this.name = "ELEVATED";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.ELEVATED;
    }
}
class NormalNode : ASTNonTerminal
{
    this () {
        this.name = "NORMAL";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.NORMAL;
    }
}
class PrunedPlainNode : ASTNonTerminal
{
    this () {
        this.name = "PRUNEDPLAIN";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.PRUNEDPLAIN;
    }
}
class ElevatedPlainNode : ASTNonTerminal
{
    this () {
        this.name = "ELEVATEDPLAIN";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.ELEVATEDPLAIN;
    }
}
class OrChainNormalNode : ASTNonTerminal
{
    this () {
        this.name = "ORCHAINNORMAL";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.ORCHAINNORMAL;
    }
}
class TerminalOrRulenameNode : ASTNonTerminal
{
    this () {
        this.name = "TERMINALORRULENAME";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.TERMINALORRULENAME;
    }
}
class PrunedElevatedForChainNode : ASTNonTerminal
{
    this () {
        this.name = "PRUNEDELEVATEDFORCHAIN";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.PRUNEDELEVATEDFORCHAIN;
    }
}
class RuleSegmentNode : ASTNonTerminal
{
    this () {
        this.name = "RULESEGMENT";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.RULESEGMENT;
    }
}
class RuleNameWithOpNode : ASTNonTerminal
{
    this () {
        this.name = "RULENAMEWITHOP";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.RULENAMEWITHOP;
    }
}
class TerminalWithOpNode : ASTNonTerminal
{
    this () {
        this.name = "TERMINALWITHOP";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.TERMINALWITHOP;
    }
}
class ParenWithOpNode : ASTNonTerminal
{
    this () {
        this.name = "PARENWITHOP";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.PARENWITHOP;
    }
}
class OrChainNode : ASTNonTerminal
{
    this () {
        this.name = "ORCHAIN";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.ORCHAIN;
    }
}
class UnaryOperatorNode : ASTNonTerminal
{
    this () {
        this.name = "UNARYOPERATOR";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.UNARYOPERATOR;
    }
}
class TerminalNode : ASTNonTerminal
{
    this () {
        this.name = "TERMINAL";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.TERMINAL;
    }
}
class TerminalLiteralNode : ASTNonTerminal
{
    this () {
        this.name = "TERMINALLITERAL";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.TERMINALLITERAL;
    }
}
class TerminalLiteralNoConsumeNode : ASTNonTerminal
{
    this () {
        this.name = "TERMINALLITERALNOCONSUME";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.TERMINALLITERALNOCONSUME;
    }
}
class TerminalRegexNode : ASTNonTerminal
{
    this () {
        this.name = "TERMINALREGEX";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.TERMINALREGEX;
    }
}
class RuleNameNode : ASTNonTerminal
{
    this () {
        this.name = "RULENAME";
    }
    override void accept(Visitor v) {
        v.visit(this);
    }
    override Tag getTag() {
        return Tag.RULENAME;
    }
}
enum Tag {
    GRAMMAR,
    RULE,
    PRUNEDELEVATEDNORMAL,
    PAREN,
    PRUNED,
    ELEVATED,
    NORMAL,
    PRUNEDPLAIN,
    ELEVATEDPLAIN,
    ORCHAINNORMAL,
    TERMINALORRULENAME,
    PRUNEDELEVATEDFORCHAIN,
    RULESEGMENT,
    RULENAMEWITHOP,
    TERMINALWITHOP,
    PARENWITHOP,
    ORCHAIN,
    UNARYOPERATOR,
    TERMINAL,
    TERMINALLITERAL,
    TERMINALLITERALNOCONSUME,
    TERMINALREGEX,
    RULENAME,
    ASTNONTERMINAL
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
    private uint getLineNumber(const uint index) pure
    {
        uint line = 1;
        for (auto i = 0; i < source[0..index].length; i++)
        {
            if (source[i] == '\n')
            {
                line++;
            }
        }
        return line;
    }
    private uint getColumnNumber(const uint index) pure
    {
        return cast(uint)(index - source[0..index].lastIndexOf('\n'));
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
        uint collectedNodes = 0;
        bool ruleLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:::)`);
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
            auto reg = ctRegex!(`^(?:;)`);
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
        if (normal())
        {
            collectedNodes++;
        }
        else if (parenWithOp())
        {
            collectedNodes++;
        }
        else if (pruned())
        {
            collectedNodes++;
        }
        else if (elevated())
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
    bool paren()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        bool parenLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:\()`);
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
        bool parenLiteral_2()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:\))`);
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
        if (parenLiteral_1())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        while (prunedElevatedNormal())
        {
            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);
            stack = stack[0..$-1];
            foreach (child; tempNode.children)
            {
                stack ~= child;
            }
            collectedNodes += tempNode.children.length;
        }
        if (parenLiteral_2())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ParenNode();
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
        uint collectedNodes = 0;
        bool prunedLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:#)`);
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
        if (prunedLiteral_1())
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
        uint collectedNodes = 0;
        bool elevatedLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:\^)`);
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
        if (elevatedLiteral_1())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (ruleNameWithOp())
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
    bool prunedPlain()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        bool prunedPlainLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:#)`);
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
        if (prunedPlainLiteral_1())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (terminalOrRulename())
        {
            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);
            stack = stack[0..$-1];
            foreach (child; tempNode.children)
            {
                stack ~= child;
            }
            collectedNodes += tempNode.children.length;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new PrunedPlainNode();
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool elevatedPlain()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        bool elevatedPlainLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:\^)`);
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
        if (elevatedPlainLiteral_1())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
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
        auto nonTerminal = new ElevatedPlainNode();
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool orChainNormal()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (ruleName())
        {
            collectedNodes++;
        }
        else if (terminal())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new OrChainNormalNode();
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool terminalOrRulename()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (terminal())
        {
            collectedNodes++;
        }
        else if (ruleName())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new TerminalOrRulenameNode();
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        stack = stack[0..$-collectedNodes];
        stack ~= nonTerminal;
        return true;
    }
    bool prunedElevatedForChain()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (prunedPlain())
        {
            collectedNodes++;
        }
        else if (elevatedPlain())
        {
            collectedNodes++;
        }
        else if (orChainNormal())
        {
            collectedNodes++;
        }
        else if (paren())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new PrunedElevatedForChainNode();
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
        if (parenWithOp())
        {
            collectedNodes++;
        }
        else if (ruleNameWithOp())
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
    bool parenWithOp()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        if (paren())
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
        auto nonTerminal = new ParenWithOpNode();
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
        uint collectedNodes = 0;
        bool orChainLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:\|)`);
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
        bool orChainParen_1()
        {
            debug (TRACE) mixin(tracer);
            uint saveIndex = index;
            bool orChainParen_1Literal_1()
            {
                debug (TRACE) mixin(tracer);
                auto reg = ctRegex!(`^(?:\|)`);
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
            uint innerCollectedNodes = 0;
            if (orChainParen_1Literal_1())
            {
            }
            else
            {
                stack = stack[0..$-innerCollectedNodes];
                index = saveIndex;
                return false;
            }
            if (prunedElevatedForChain())
            {
                auto tempNode = cast(ASTNonTerminal)(stack[$-1]);
                stack = stack[0..$-1];
                foreach (child; tempNode.children)
                {
                    stack ~= child;
                }
                innerCollectedNodes += tempNode.children.length;
            }
            else
            {
                stack = stack[0..$-innerCollectedNodes];
                index = saveIndex;
                return false;
            }
            collectedNodes += innerCollectedNodes;
            return true;
        }
        if (prunedElevatedForChain())
        {
            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);
            stack = stack[0..$-1];
            foreach (child; tempNode.children)
            {
                stack ~= child;
            }
            collectedNodes += tempNode.children.length;
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
        if (prunedElevatedForChain())
        {
            auto tempNode = cast(ASTNonTerminal)(stack[$-1]);
            stack = stack[0..$-1];
            foreach (child; tempNode.children)
            {
                stack ~= child;
            }
            collectedNodes += tempNode.children.length;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        while (orChainParen_1())
        {
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
    bool unaryOperator()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        bool unaryOperatorLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:\*)`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                terminal.data["TOK_BEGIN"] = index;
                terminal.data["TOK_END"] = index + mat.captures[0].length;
                terminal.data["LINE"] = getLineNumber(index);
                terminal.data["COLUMN"] = getColumnNumber(index);
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
            auto reg = ctRegex!(`^(?:\+)`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                terminal.data["TOK_BEGIN"] = index;
                terminal.data["TOK_END"] = index + mat.captures[0].length;
                terminal.data["LINE"] = getLineNumber(index);
                terminal.data["COLUMN"] = getColumnNumber(index);
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
            auto reg = ctRegex!(`^(?:\?)`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                terminal.data["TOK_BEGIN"] = index;
                terminal.data["TOK_END"] = index + mat.captures[0].length;
                terminal.data["LINE"] = getLineNumber(index);
                terminal.data["COLUMN"] = getColumnNumber(index);
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
        else if (terminalLiteralNoConsume())
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
        uint collectedNodes = 0;
        bool terminalLiteralLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:"(?:\\.|[^"\\])*")`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                terminal.data["TOK_BEGIN"] = index;
                terminal.data["TOK_END"] = index + mat.captures[0].length;
                terminal.data["LINE"] = getLineNumber(index);
                terminal.data["COLUMN"] = getColumnNumber(index);
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
    bool terminalLiteralNoConsume()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        uint collectedNodes = 0;
        bool terminalLiteralNoConsumeLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:'(?:\\.|[^'\\])*')`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                terminal.data["TOK_BEGIN"] = index;
                terminal.data["TOK_END"] = index + mat.captures[0].length;
                terminal.data["LINE"] = getLineNumber(index);
                terminal.data["COLUMN"] = getColumnNumber(index);
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
        if (terminalLiteralNoConsumeLiteral_1())
        {
            collectedNodes++;
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new TerminalLiteralNoConsumeNode();
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
        uint collectedNodes = 0;
        bool terminalRegexLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:\/(?:\\.|[^\/\\])*\/)`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                terminal.data["TOK_BEGIN"] = index;
                terminal.data["TOK_END"] = index + mat.captures[0].length;
                terminal.data["LINE"] = getLineNumber(index);
                terminal.data["COLUMN"] = getColumnNumber(index);
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
        uint collectedNodes = 0;
        bool ruleNameLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto reg = ctRegex!(`^(?:[a-zA-Z_][a-zA-Z0-9_]*)`);
            auto mat = match(source[index..$], reg);
            if (mat)
            {
                debug (TRACE) writeln(traceIndent, "  Match: [", mat.captures[0], "]");
                auto terminal = new ASTTerminal(mat.captures[0], index);
                terminal.data["TOK_BEGIN"] = index;
                terminal.data["TOK_END"] = index + mat.captures[0].length;
                terminal.data["LINE"] = getLineNumber(index);
                terminal.data["COLUMN"] = getColumnNumber(index);
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

