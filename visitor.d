import std.stdio;
import grammarParser4;

interface Visitor
{
    void visit(GrammarNode node);
    void visit(RuleNode node);
    void visit(PrunedElevatedNormalNode node);
    void visit(PrunedNode node);
    void visit(ElevatedNode node);
    void visit(NormalNode node);
    void visit(RuleSegmentNode node);
    void visit(RuleNameWithOpNode node);
    void visit(TerminalWithOpNode node);
    void visit(OrChainNode node);
    void visit(OrChainExtraNode node);
    void visit(UnaryOperatorNode node);
    void visit(TerminalNode node);
    void visit(TerminalLiteralNode node);
    void visit(TerminalRegexNode node);
    void visit(RuleNameNode node);
    void visit(ASTTerminal node);
}

class PrintVisitor : Visitor
{
    string indent;
    this ()
    {
        indent = "";
    }
    void visit(GrammarNode node)
    {
        writeln(indent, "GRAMMARNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(RuleNode node)
    {
        writeln(indent, "RULENODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(PrunedElevatedNormalNode node)
    {
        writeln(indent, "PRUNEDELEVATEDNORMALNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(PrunedNode node)
    {
        writeln(indent, "PRUNEDNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(ElevatedNode node)
    {
        writeln(indent, "ELEVATEDNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(NormalNode node)
    {
        writeln(indent, "NORMALNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(RuleSegmentNode node)
    {
        writeln(indent, "RULESEGMENTNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(RuleNameWithOpNode node)
    {
        writeln(indent, "RULENAMEWITHOPNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(TerminalWithOpNode node)
    {
        writeln(indent, "TERMINALWITHOPNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(OrChainNode node)
    {
        writeln(indent, "ORCHAINNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(OrChainExtraNode node)
    {
        writeln(indent, "ORCHAINEXTRANODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(UnaryOperatorNode node)
    {
        writeln(indent, "UNARYOPERATORNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(TerminalNode node)
    {
        writeln(indent, "TERMINALNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(TerminalLiteralNode node)
    {
        writeln(indent, "TERMINALLITERALNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(TerminalRegexNode node)
    {
        writeln(indent, "TERMINALREGEXNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(RuleNameNode node)
    {
        writeln(indent, "RULENAMENODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(ASTTerminal node)
    {
        writeln(indent, "[", node.token, "]: ", node.index);
    }
}
