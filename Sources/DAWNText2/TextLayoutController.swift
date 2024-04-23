import UIKit

final class TextLayoutController: NSObject, NSTextLayoutManagerDelegate {
    func textLayoutManager(
        _ textLayoutManager: NSTextLayoutManager,
        textLayoutFragmentFor location: any NSTextLocation,
        in textElement: NSTextElement
    ) -> NSTextLayoutFragment {
        NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
    }
}
