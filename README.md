# swift-cofree

Use this package when every layer of a recursive enum needs an annotation of its own, for example to keep the result computed for each subtree. Attach `@Cofree` to the enum to get a nested `Cofree<Value>` that pairs a `Value` with one layer of the enum's `Base` functor whose recursive positions hold further `Cofree<Value>` nodes. For the dual, a structure built from layers of `Base` with pure values at the leaves, use `@Free` from swift-free instead.

## Laws

- The enum must also have a `Base` with a `map`, as `@FunctorBase` generates. The expansion refers to `Base` without checking that it exists.
- `extract` returns the outermost annotation only.
- `map` keeps the shape and transforms the annotation of every layer.
- `extend` annotates each layer with the transform applied to the subtree rooted at that layer. So `extend { $0.extract }` changes nothing, and `duplicate().map { $0.extract }` gives back the original annotations.
- `map`, `extend` and `duplicate` are eager and traverse the whole finite structure. Nothing is lazy or cached, and there is no productive infinite corecursion.
- The generated `Cofree<Value>` and its members get the enum's access level.
- Attaching `@Cofree` to anything other than an enum is a macro error. An enum whose cases are not polynomial in the enum itself expands to an `#error` that carries the derivation failure.
