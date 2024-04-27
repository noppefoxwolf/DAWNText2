import XCTest
@testable import DAWNText2

final class KeyFactoryTests: XCTestCase {
    let factory = KeyFactory()
    
    func testKey() async throws {
        let key1 = factory.make(for: TextLayoutSize(width: 100, height: 0))
        let key2 = factory.make(for: TextLayoutSize(width: 100, height: 100))
        XCTAssertEqual(key1, key2)
    }
}

final class TextLayoutSizeTests: XCTestCase {
    func testSize1() async throws {
        let cgSize = CGSize(width: 100, height: 0)
        let size = TextLayoutSize(cgSize)
        XCTAssertEqual(size.width, 100)
    }
    
    func testSize2() async throws {
        let cgSize = CGSize(width: .infinity, height: 0.0)
        let size = TextLayoutSize(cgSize)
        XCTAssertEqual(size.width, 10000000)
    }
    
    func testSize3() async throws {
        let cgSize = CGSize(width: 0.0, height: 0.0)
        let size = TextLayoutSize(cgSize)
        XCTAssertEqual(size.width, 10000000)
    }
    
    func testSize4() async throws {
        let cgSize = CGSize(width: -1, height: 0.0)
        let size = TextLayoutSize(cgSize)
        XCTAssertEqual(size.width, 10000000)
    }
    
    func testSize5() async throws {
        let cgSize = CGSize(width: .nan, height: 0.0)
        let size = TextLayoutSize(cgSize)
        XCTAssertEqual(size.width, 10000000)
    }
    
    func testSize6() async throws {
        let cgSize = CGSize(width: 100.1, height: 0.0)
        let size = TextLayoutSize(cgSize)
        XCTAssertEqual(size.width, 100)
    }
    
    func testSize7() async throws {
        let cgSize = CGSize(width: 100.5, height: 0.0)
        let size = TextLayoutSize(cgSize)
        XCTAssertEqual(size.width, 100)
    }
    
    func testSize8() async throws {
        let cgSize = CGSize(width: 100.9, height: 0.0)
        let size = TextLayoutSize(cgSize)
        XCTAssertEqual(size.width, 100)
    }
    
    func testCGSize1() async throws {
        let size = TextLayoutSize(width: 100, height: 200)
        XCTAssertEqual(size.cgSize.width, 100)
        XCTAssertEqual(size.cgSize.height, 200)
    }
}

