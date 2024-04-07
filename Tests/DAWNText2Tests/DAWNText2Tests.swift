import XCTest
@testable import DAWNText2

@MainActor
final class DAWNText2Tests: XCTestCase {
    func testExample() async throws {
        let label = UILabel()
        XCTAssertEqual(label.contentHuggingPriority(for: .horizontal), .defaultLow)
        XCTAssertEqual(label.contentHuggingPriority(for: .vertical), .defaultLow)
        XCTAssertEqual(label.contentCompressionResistancePriority(for: .horizontal), .defaultHigh)
        XCTAssertEqual(label.contentCompressionResistancePriority(for: .vertical), .defaultHigh)
        
    }
    
    func testTextView() async throws {
        let textView = UITextView()
        // print(textView.perform(Selector("_methodDescription")))
    }
    
    func testDAWNLabel() async throws {
        let label = DAWNLabel()
        _ = label.textContainer
        _ = label.textLayoutManager
        _ = label.textStorage
        _ = label.text
        _ = label.attributedText
    }
}
