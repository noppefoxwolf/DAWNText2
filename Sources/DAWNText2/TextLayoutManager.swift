import UIKit

final class TextLayoutManager: NSTextLayoutManager {
    var foregroundColor: UIColor = .tintColor

    override func renderingAttributes(
        forLink link: Any,
        at location: any NSTextLocation
    ) -> [NSAttributedString.Key: Any] {
        [.foregroundColor: foregroundColor]
    }
}
