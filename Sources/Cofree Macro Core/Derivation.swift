public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public static func expansion(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        let access = declaration.modifiers.contains {
            $0.name.tokenKind == .keyword(.public)
        } ? "public " : ""

        return ["""
            \(raw: access)indirect enum Cofree<Value> {
                case cofree(Value, Base<Cofree<Value>>)

                \(raw: access)var extract: Value {
                    switch self { case .cofree(let value, _): return value }
                }
                \(raw: access)func map<Mapped>(_ transform: (Value) -> Mapped) -> Cofree<Mapped> {
                    switch self {
                    case .cofree(let value, let layer): return .cofree(transform(value), layer.map { $0.map(transform) })
                    }
                }
                /// Finite eager extension; this does not promise productive infinite corecursion.
                \(raw: access)func extend<Mapped>(_ transform: (Cofree<Value>) -> Mapped) -> Cofree<Mapped> {
                    switch self {
                    case .cofree(_, let layer): return .cofree(transform(self), layer.map { $0.extend(transform) })
                    }
                }
                \(raw: access)func duplicate() -> Cofree<Cofree<Value>> { extend { $0 } }
            }
            """]
    }
}
