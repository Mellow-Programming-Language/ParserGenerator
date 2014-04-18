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
        // Initialize source and index
        this.source = source;
        this.index = 0;
        debug(TRACE) this.traceIndent = "";
    }

    ASTNode parse()
    {
        // Consume leading whitespace
        consumeWhitespace();
        // Declare top of tree
        ASTNode topNode = null;
        // Attempt to parse the source. If successful, the only node on the
        // stack will be a grammar node
        if (grammar())
        {
            topNode = stack[$-1];
        }
        // Reset index and node stack in case parse is called again
        index = 0;
        stack = [];
        // Return the AST of the source
        return topNode;
    }

private:

    // Contains the source code to be parsed
    string source;
    // Index within the source where we are currently looking
    uint index;
    // Stack of AST nodes for use with building the AST tree
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
        // Add indentation with recursive calls, to pretty print the
        // call sequence for grammar rules
        string traceIndent;
        // Use mixin() to compile this code verbatim at the point of mixin.
        // __FUNCTION__ evaluates to name of the function currently being
        // compiled, and __MODULE__ evaluates to the file name by default.
        // tHe fully qualified function name from __FUNCTION__ includes the
        // module name and class name, so strip those off the front of the
        // function name to reduce noise. The complete tracer code simply
        // prints out the function name just entered, increases the amount
        // of indentation used for printing (on every recursive call),
        // and sets up the exit code, where on exit the indentation is reduced
        // and the fact that we're leaving the current function is printed.
        // By mixing in this string at the top of every function definition,
        // we suddenly have concise, complete tracer code for the whole parser
        // Simple!
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
            // If parsing fails, then remove all nodes generated between now
            // and the beginning of the rule
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        // Generate a non-terminal to represent the grammar node
        auto nonTerminal = new ASTNonTerminal("GRAMMAR");
        // Add all the nodes added to the stack for this rule as children to
        // the GRAMMAR node
        foreach (node; stack[$-collectedNodes..$])
        {
            nonTerminal.addChild(node);
        }
        // Remove the child nodes off the stack
        stack = stack[0..$-collectedNodes];
        // Add the nonterminal to the stack
        stack ~= nonTerminal;
        // Return successfully
        return true;
    }

    bool rule()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool ruleLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto regex_1 = ctRegex!(`^::`);
            auto match_1 = match(source[index..$], regex_1);
            if (match_1)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_1.captures[0], "]");
                index += match_1.captures[0].length;
                consumeWhitespace();
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }

        ParenResult* ruleParen_1()
        {
            auto result = new ParenResult(0, false);
            if (orChain())
            {
                result.collectedNodes++;
            }
            else if (ruleSegment())
            {
                result.collectedNodes++;
            }
            else
            {
                stack = stack[0..$-result.collectedNodes];
                result.collectedNodes = 0;
                result.isSuccess = false;
                return result;
            }
            result.isSuccess = true;
            return result;
        }

        bool ruleLiteral_2()
        {
            debug (TRACE) mixin(tracer);
            auto regex_2 = ctRegex!(`^;`);
            auto match_2 = match(source[index..$], regex_2);
            if (match_2)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_2.captures[0], "]");
                index += match_2.captures[0].length;
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
        ParenResult* result;
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
        if (result = ruleParen_1(), result.isSuccess)
        {
            collectedNodes += result.collectedNodes;
            while (result = ruleParen_1(), result.isSuccess)
            {
                collectedNodes += result.collectedNodes;
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

    bool ruleSegment()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        ParenResult* ruleSegmentParen_1()
        {
            auto result = new ParenResult(0, false);
            if (ruleName())
            {
                result.collectedNodes++;
            }
            else
            {
                stack = stack[0..$-result.collectedNodes];
                result.collectedNodes = 0;
                result.isSuccess = false;
                return result;
            }
            if (unaryOperator())
            {
                result.collectedNodes++;
            }
            result.isSuccess = true;
            return result;
        }

        ParenResult* ruleSegmentParen_2()
        {
            auto result = new ParenResult(0, false);
            if (parenSegment())
            {
                result.collectedNodes++;
            }
            else
            {
                stack = stack[0..$-result.collectedNodes];
                result.collectedNodes = 0;
                result.isSuccess = false;
                return result;
            }
            if (unaryOperator())
            {
                result.collectedNodes++;
            }
            result.isSuccess = true;
            return result;
        }

        ParenResult* ruleSegmentParen_3()
        {
            auto result = new ParenResult(0, false);
            if (terminal())
            {
                result.collectedNodes++;
            }
            else
            {
                stack = stack[0..$-result.collectedNodes];
                result.collectedNodes = 0;
                result.isSuccess = false;
                return result;
            }
            if (unaryOperator())
            {
                result.collectedNodes++;
            }
            result.isSuccess = true;
            return result;
        }

        uint collectedNodes = 0;
        ParenResult* result;
        if (result = ruleSegmentParen_1(), result.isSuccess)
        {
            collectedNodes += result.collectedNodes;
        }
        else if (result = ruleSegmentParen_2(), result.isSuccess)
        {
            collectedNodes += result.collectedNodes;
        }
        else if (result = ruleSegmentParen_3(), result.isSuccess)
        {
            collectedNodes += result.collectedNodes;
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

    bool parenSegment()
    {
        debug (TRACE) mixin(tracer);
        uint saveIndex = index;
        bool parenSegmentLiteral_1()
        {
            debug (TRACE) mixin(tracer);
            auto regex_1 = ctRegex!(`^\(`);
            auto match_1 = match(source[index..$], regex_1);
            if (match_1)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_1.captures[0], "]");
                index += match_1.captures[0].length;
                consumeWhitespace();
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }

        ParenResult* parenSegmentParen_1()
        {
            auto result = new ParenResult(0, false);
            if (orChain())
            {
                result.collectedNodes++;
            }
            else if (ruleSegment)
            {
                result.collectedNodes++;
            }
            else
            {
                stack = stack[0..$-result.collectedNodes];
                result.collectedNodes = 0;
                result.isSuccess = false;
                return result;
            }
            result.isSuccess = true;
            return result;
        }

        bool parenSegmentLiteral_2()
        {
            debug (TRACE) mixin(tracer);
            auto regex_2 = ctRegex!(`^\)`);
            auto match_2 = match(source[index..$], regex_2);
            if (match_2)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_2.captures[0], "]");
                index += match_2.captures[0].length;
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
        ParenResult* result;
        if (parenSegmentLiteral_1())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (result = parenSegmentParen_1(), result.isSuccess)
        {
            collectedNodes += result.collectedNodes;
            while (result = parenSegmentParen_1(), result.isSuccess)
            {
                collectedNodes += result.collectedNodes;
            }
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        if (parenSegmentLiteral_2())
        {
        }
        else
        {
            stack = stack[0..$-collectedNodes];
            index = saveIndex;
            return false;
        }
        auto nonTerminal = new ASTNonTerminal("PARENSEGMENT");
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
            auto regex_1 = ctRegex!(`^\|`);
            auto match_1 = match(source[index..$], regex_1);
            if (match_1)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_1.captures[0], "]");
                index += match_1.captures[0].length;
                consumeWhitespace();
            }
            else
            {
                debug (TRACE) writeln(traceIndent, "  No match.");
                return false;
            }
            return true;
        }

        ParenResult* orChainParen_1()
        {
            bool orChainParen_1Literal_1()
            {
                debug (TRACE) mixin(tracer);
                auto regex_1 = ctRegex!(`^\|`);
                auto match_1 = match(source[index..$], regex_1);
                if (match_1)
                {
                    debug (TRACE) writeln(
                        traceIndent, "  Match: [", match_1.captures[0], "]");
                    index += match_1.captures[0].length;
                    consumeWhitespace();
                }
                else
                {
                    debug (TRACE) writeln(traceIndent, "  No match.");
                    return false;
                }
                return true;
            }
            auto result = new ParenResult(0, false);
            if (orChainParen_1Literal_1())
            {
            }
            else
            {
                stack = stack[0..$-result.collectedNodes];
                result.collectedNodes = 0;
                result.isSuccess = false;
                return result;
            }
            if (ruleSegment())
            {
                result.collectedNodes++;
            }
            else
            {
                stack = stack[0..$-result.collectedNodes];
                result.collectedNodes = 0;
                result.isSuccess = false;
                return result;
            }
            result.isSuccess = true;
            return result;
        }

        uint collectedNodes = 0;
        ParenResult* result;
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
        do
        {
            result = orChainParen_1();
            collectedNodes += result.collectedNodes;
        } while (result.isSuccess);
        auto nonTerminal = new ASTNonTerminal("ORCHAIN");
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
            auto regex_1 = ctRegex!(`^\*`);
            auto match_1 = match(source[index..$], regex_1);
            if (match_1)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_1.captures[0], "]");
                auto terminal = new ASTTerminal(match_1.captures[0], index);
                index += match_1.captures[0].length;
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
            auto regex_2 = ctRegex!(`^\+`);
            auto match_2 = match(source[index..$], regex_2);
            if (match_2)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_2.captures[0], "]");
                auto terminal = new ASTTerminal(match_2.captures[0], index);
                index += match_2.captures[0].length;
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
            auto regex_3 = ctRegex!(`^\?`);
            auto match_3 = match(source[index..$], regex_3);
            if (match_3)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_3.captures[0], "]");
                auto terminal = new ASTTerminal(match_3.captures[0], index);
                index += match_3.captures[0].length;
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
            auto regex_1 = ctRegex!(`^"(?:\\.|[^"\\])*"`);
            auto match_1 = match(source[index..$], regex_1);
            if (match_1)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_1.captures[0], "]");
                auto terminal = new ASTTerminal(match_1.captures[0], index);
                index += match_1.captures[0].length;
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
            auto regex_1 = ctRegex!(`^/(?:\\.|[^/\\])*/`);
            auto match_1 = match(source[index..$], regex_1);
            if (match_1)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_1.captures[0], "]");
                auto terminal = new ASTTerminal(match_1.captures[0], index);
                index += match_1.captures[0].length;
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
            auto regex_1 = ctRegex!(`^[a-zA-Z_][a-zA-Z0-9_]*`);
            auto match_1 = match(source[index..$], regex_1);
            if (match_1)
            {
                debug (TRACE) writeln(
                    traceIndent, "  Match: [", match_1.captures[0], "]");
                auto terminal = new ASTTerminal(match_1.captures[0], index);
                index += match_1.captures[0].length;
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
            rule :: ruleName "::" (orChain | ruleSegment) + ";" ;
            ruleSegment :: (ruleName unaryOperator ?)
                         | (parenSegment unaryOperator ?)
                         | (terminal unaryOperator ?)
                         ;
            parenSegment :: "(" ruleSegment + ")" ;
            orChain :: ruleSegment "|" ruleSegment ("|" ruleSegment)* ;
            unaryOperator :: "*"
                           | "+"
                           | "?";
            terminal :: terminalLiteral | terminalRegex ;
            terminalLiteral :: /"(?:\\.|[^\"\\])*"/ ;
            terminalRegex :: /\/(?:\\.|[^\/\\])*\// ;
            ruleName :: /[a-zA-Z_][a-zA-Z0-9_]*/ ;
            `
            );
        auto topNode = parser.parse();
        topNode.printTree();
    }
}
