import std.stdio;
// Filename of parser also generated by this program. Default 'parser'
import parser;
interface Visitor
{
    void visit(GrammarNode node);
    void visit(RuleNode node);
    void visit(PrunedElevatedNormalNode node);
    void visit(ParenNode node);
    void visit(PrunedNode node);
    void visit(ElevatedNode node);
    void visit(NormalNode node);
    void visit(PrunedPlainNode node);
    void visit(ElevatedPlainNode node);
    void visit(OrChainNormalNode node);
    void visit(TerminalOrRulenameNode node);
    void visit(PrunedElevatedForChainNode node);
    void visit(RuleSegmentNode node);
    void visit(RuleNameWithOpNode node);
    void visit(TerminalWithOpNode node);
    void visit(ParenWithOpNode node);
    void visit(OrChainNode node);
    void visit(UnaryOperatorNode node);
    void visit(TerminalNode node);
    void visit(TerminalLiteralNode node);
    void visit(TerminalLiteralNoConsumeNode node);
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
    void visit(ParenNode node)
    {
        writeln(indent, "PARENNODE");
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
    void visit(PrunedPlainNode node)
    {
        writeln(indent, "PRUNEDPLAINNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(ElevatedPlainNode node)
    {
        writeln(indent, "ELEVATEDPLAINNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(OrChainNormalNode node)
    {
        writeln(indent, "ORCHAINNORMALNODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(TerminalOrRulenameNode node)
    {
        writeln(indent, "TERMINALORRULENAMENODE");
        indent ~= "  ";
        foreach (child; node.children)
        {
            child.accept(this);
        }
        indent = indent[0..$-2];
    }
    void visit(PrunedElevatedForChainNode node)
    {
        writeln(indent, "PRUNEDELEVATEDFORCHAINNODE");
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
    void visit(ParenWithOpNode node)
    {
        writeln(indent, "PARENWITHOPNODE");
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
    void visit(TerminalLiteralNoConsumeNode node)
    {
        writeln(indent, "TERMINALLITERALNOCONSUMENODE");
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
        writeln(indent, "[", node.token, "]: Line: [", node.data["LINE"].get!uint, "] Col: [", node.data["COLUMN"].get!uint, "]");
    }
}
