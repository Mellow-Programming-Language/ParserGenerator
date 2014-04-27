import std.stdio;
import grammarParser4;

interface Visitor
{
    void visit(grammarNode node);
    void visit(ruleNode node);
    void visit(prunedElevatedNormalNode node);
    void visit(prunedNode node);
    void visit(elevatedNode node);
    void visit(normalNode node);
    void visit(ruleSegmentNode node);
    void visit(ruleNameWithOpNode node);
    void visit(terminalWithOpNode node);
    void visit(orChainNode node);
    void visit(orChainExtraNode node);
    void visit(unaryOperatorNode node);
    void visit(terminalNode node);
    void visit(terminalLiteralNode node);
    void visit(terminalRegexNode node);
    void visit(ruleNameNode node);
    void visit(ASTTerminal node);
}

class PrintVisitor : Visitor
{
    string indent;
    this ()
    {
        indent = "";
    }
    void visit(grammarNode node)
    {
        writeln(indent, "GRAMMARNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(ruleNode node)
    {
        writeln(indent, "RULENODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(prunedElevatedNormalNode node)
    {
        writeln(indent, "PRUNEDELEVATEDNORMALNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(prunedNode node)
    {
        writeln(indent, "PRUNEDNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(elevatedNode node)
    {
        writeln(indent, "ELEVATEDNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(normalNode node)
    {
        writeln(indent, "NORMALNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(ruleSegmentNode node)
    {
        writeln(indent, "RULESEGMENTNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(ruleNameWithOpNode node)
    {
        writeln(indent, "RULENAMEWITHOPNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(terminalWithOpNode node)
    {
        writeln(indent, "TERMINALWITHOPNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(orChainNode node)
    {
        writeln(indent, "ORCHAINNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(orChainExtraNode node)
    {
        writeln(indent, "ORCHAINEXTRANODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(unaryOperatorNode node)
    {
        writeln(indent, "UNARYOPERATORNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(terminalNode node)
    {
        writeln(indent, "TERMINALNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(terminalLiteralNode node)
    {
        writeln(indent, "TERMINALLITERALNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(terminalRegexNode node)
    {
        writeln(indent, "TERMINALREGEXNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(ruleNameNode node)
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
