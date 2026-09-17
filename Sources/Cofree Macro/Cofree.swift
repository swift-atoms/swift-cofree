@attached(member, names: arbitrary)
public macro Cofree() = #externalMacro(
    module: "Cofree_Macro_Plugin",
    type: "Macro"
)
