// file: astNode.d
// author: Collin Reeser
// description: Simple AST class hierarchy, with terminals and nonterminals

import std.stdio;

// Simple tree-printing function
void printTree(ASTNode node, string indent = "")
{
    // If a nonterminal, descend over every child
    if (cast(ASTNonTerminal)node)
    {
        // Write out the current indent amount, then the node name
        writeln(indent, (cast(ASTNonTerminal)node).name);
        // Recurse on children
        foreach (x; (cast(ASTNonTerminal)node).children)
        {
            printTree(x, indent ~ "  ");
        }
    }
    // Write out terminal information
    else if (cast(ASTTerminal)node)
    {
        // Includes token and source index of token
        writeln(indent, "[", (cast(ASTTerminal)node).token, "]: ",
            (cast(ASTTerminal)node).index);
    }
}

abstract class ASTNode
{
}

class ASTNonTerminal : ASTNode
{
    // Children of nonterminal, can be terminals or other nonterminals
    ASTNode[] children;
    // Name of nonterminal
    const string name;

    this (string name)
    {
        this.name = name;
    }

    void addChild(ASTNode node)
    {
        // Append new child to child array
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
}
