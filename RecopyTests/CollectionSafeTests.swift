import Testing
@testable import Recopy

@Suite("Collection Safe Subscript Tests")
struct CollectionSafeTests {

    @Test("Safe subscript returns element at valid index")
    func validIndex() {
        let array = ["a", "b", "c"]
        #expect(array[safe: 0] == "a")
        #expect(array[safe: 1] == "b")
        #expect(array[safe: 2] == "c")
    }

    @Test("Safe subscript returns nil for negative index")
    func negativeIndex() {
        let array = ["a", "b"]
        #expect(array[safe: -1] == nil)
    }

    @Test("Safe subscript returns nil for out-of-bounds index")
    func outOfBounds() {
        let array = ["a", "b"]
        #expect(array[safe: 2] == nil)
        #expect(array[safe: 100] == nil)
    }

    @Test("Safe subscript returns nil for empty collection")
    func emptyCollection() {
        let array: [String] = []
        #expect(array[safe: 0] == nil)
    }

    @Test("Safe subscript works with single element")
    func singleElement() {
        let array = [42]
        #expect(array[safe: 0] == 42)
        #expect(array[safe: 1] == nil)
    }
}
