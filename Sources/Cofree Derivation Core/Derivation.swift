import Base_Functor_Derivation_Core
public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public static func expansion(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        Base_Functor_Derivation_Core.Derivation.base(of: declaration)
            + carrier(of: declaration)
    }

    public static func carrier(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        let access = declaration.modifiers.contains {
            $0.name.tokenKind == .keyword(.public)
        } ? "public " : ""

        return ["""
            \(raw: access)indirect enum Cofree<Value> {
                case cofree(Value, Base<Cofree<Value>>)
            }
            """]
    }
}
