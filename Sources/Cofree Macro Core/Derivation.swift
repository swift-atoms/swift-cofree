import Functor_Base_Macro_Core
public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    public static func expansion(of declaration: EnumDeclSyntax) -> [DeclSyntax] {
        Functor_Base_Macro_Core.Derivation.base(of: declaration)
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
