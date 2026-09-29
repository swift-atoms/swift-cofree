import Functor_Base_Macro
import Cofree_Macro
import Testing

@FunctorBase
@Cofree
private indirect enum Count {
    case zero
    case successor(Count)
}

private func annotations(_ value: Count.Cofree<Int>) -> [Int] {
    switch value {
    case let .cofree(number, .zero): [number]
    case let .cofree(number, .successor(child)): [number] + annotations(child)
    }
}

@Suite
struct `Cofree boundaries` {
    fileprivate let two = Count.Cofree<Int>.cofree(2, .successor(.cofree(1, .successor(.cofree(0, .zero)))))

    @Test
    func `extract returns the outermost annotation`() {
        #expect(two.extract == 2)
        #expect(Count.Cofree<Int>.cofree(7, .zero).extract == 7)
    }

    @Test
    func `map transforms the annotation of every layer`() {
        #expect(annotations(two.map { $0 * 10 }) == [20, 10, 0])
    }

    @Test
    func `extending with extract changes nothing`() {
        #expect(annotations(two.extend { $0.extract }) == [2, 1, 0])
    }

    @Test
    func `duplicate annotates each layer with its own subtree`() {
        #expect(annotations(two.duplicate().map { $0.extract }) == [2, 1, 0])
    }
}
