import UIKit

final class LayoutController: NSObject, NSTextLayoutManagerDelegate {
    func textLayoutManager(_ textLayoutManager: NSTextLayoutManager,
                           textLayoutFragmentFor location: NSTextLocation,
                           in textElement: NSTextElement) -> NSTextLayoutFragment {
        NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
    }
}
