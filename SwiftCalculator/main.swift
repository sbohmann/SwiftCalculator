import Foundation

let source = try String(contentsOf: URL(fileURLWithPath: "source.calc"), encoding: .utf8)

let tokens = try tokenize(source)

print(tokens)
