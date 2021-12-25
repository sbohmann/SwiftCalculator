import Foundation

struct Token {
    let value: Int64
}

struct TokenizerError: Error {
    let message: String
}

func tokenize(_ text: String) throws -> [Token] {
    var result = [Token]()
    var lines: [String]
    
    lines = text.components(separatedBy: .newlines)
    try readLines()
    
    func readLines() throws {
        var lineNUmber = 1
        for line in lines {
            try result.append(contentsOf: parseLine(line, lineNUmber))
            lineNUmber += 1
        }
    }
    
    return result
}

struct TokenParser {
    var consume: (_ c: Character, _ column: Int) throws -> ()
    var endOfLine: (_ column: Int) throws -> ()
}

func parseLine(_ line: String, _ lineNumber: Int) throws -> [Token] {
    var result = [Token]()
    var tokenParser: TokenParser!
    var startToken: TokenParser!
    var numberParser: (() -> TokenParser)!
    
    startToken = TokenParser(
        consume: { c, column in
            if c.isWhitespace {
                return
            } else if c.isNumber {
                tokenParser = numberParser()
                try tokenParser.consume(c, column)
            }
            else {
                throw TokenizerError(message: "Unexpected character [\(c)] at \(lineNumber):\(column)")
            }
        },
        endOfLine: { column in
            throw TokenizerError(message: "Unexpected end of line at \(lineNumber):\(column)")
        })
    
    numberParser = {
        var stringRepresentation = [Character]()
        
        func addToken(_ column: Int) throws {
            guard let value = Int64(String(stringRepresentation)) else {
                throw TokenizerError(message: "Illegal number literal [\(stringRepresentation)] at \(lineNumber):\(column)")
            }
            result.append(Token(value: value))
        }
        
        return TokenParser(
            consume: { c, column in
                if (c.isWhitespace) {
                    try addToken(column)
                    return
                }
                if !c.isNumber {
                    throw TokenizerError(message: "Unexpected character [\(c)] at \(lineNumber):\(column)")
                }
                stringRepresentation.append(c)
                
            },
            endOfLine: { column in
                try addToken(column)
            })
    }
    
    tokenParser = startToken
    
    var lastIndex: Int?
    for index in line.indices {
        let indexAsInt = index.utf16Offset(in: line)
        try tokenParser.consume(line[index], indexAsInt)
        lastIndex = indexAsInt + 1
    }
    if let lastIndex = lastIndex {
        try tokenParser.endOfLine(lastIndex)
    }
    return result
}
