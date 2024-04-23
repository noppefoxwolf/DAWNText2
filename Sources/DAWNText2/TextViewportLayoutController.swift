import UIKit

final class TextViewportLayoutController: NSObject, NSTextViewportLayoutControllerDelegate {
    nonisolated public func viewportBounds(
        for textViewportLayoutController: NSTextViewportLayoutController
    ) -> CGRect {
        CGRect(origin: .zero, size: textViewportLayoutController.textLayoutManager?.textContainer?.size ?? .zero)
    }
    
    nonisolated public func textViewportLayoutController(
        _ textViewportLayoutController: NSTextViewportLayoutController,
        configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment
    ) {
        
    }
}
