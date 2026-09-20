import Type_Algebra_Syntax
public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public static func expansion(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        do { return try derive(declaration) }
        catch { return [DeclSyntax(stringLiteral: "#error(\(String(reflecting: String(describing: error))))")] }
    }

    private static func derive(_ declaration: EnumDeclSyntax) throws -> [DeclSyntax] {
        let variable = Type.Variable("Recursion")
        let layer = try Type.Syntax.Recursion.polynomial(of: declaration, variable: variable)
        let carrier = try Type.Recursion.cofree(layer: layer.expression, variable: variable, observing: .atom(.init("Value")))

        let representation = Type.Syntax.Interpretation(
            atoms: [.init("Value"): TypeSyntax(stringLiteral: "Value")],
            representations: [layer.expression: TypeSyntax(stringLiteral: "Base<Cofree<Value>>")])
        let access = Type.Syntax.Recursion.access(of: declaration)

        return ["""
            \(raw: access)indirect enum Cofree<Value> {
                case cofree\(try representation.type(carrier.body))

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
