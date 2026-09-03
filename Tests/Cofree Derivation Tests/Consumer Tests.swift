import Cofree_Derivation
import Testing

@Cofree
private indirect enum Natural {
    case zero
    case successor(Natural)
}

@Test
func `cofree carrier pairs annotation with a recursive layer`() {
    let tail = Natural.Cofree<Int>.cofree(0, .zero)
    let value = Natural.Cofree<Int>.cofree(1, .successor(tail))
    guard case let .cofree(number, .successor(.cofree(child, .zero))) = value else {
        Issue.record("Expected annotated successor")
        return
    }
    #expect(number == 1)
    #expect(child == 0)
}
