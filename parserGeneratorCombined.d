import std.stdio;
import std.conv;
import std.string;
import std.array;
import std.string;
import grammarParser4;
import visitor;

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
        auto visitor = new PrintVisitor();
        visitor.visit(cast(GrammarNode)topNode);
    }
    else
    {
        writeln("Failed to parse!");
    }
    return 0;
}
