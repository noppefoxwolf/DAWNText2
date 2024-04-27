import UIKit

final class DAWNTextViewGestureRecognizer: UITapGestureRecognizer {
    let output: any ViewOutput
    let storage: TextStorage
    
    init(output: any ViewOutput, storage: TextStorage) {
        self.output = output
        self.storage = storage
        super.init(target: nil, action: nil)
    }
    
    override func shouldBeRequiredToFail(by otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view else { return false }
        
        let location = location(in: view)
        let shouldCancel = output.otherGestureShouldCancel(
            at: location,
            size: TextLayoutSize(view.bounds.size),
            storage: storage
        )
        
        let isSwiftUIGestureRecognizer = type(of: otherGestureRecognizer).description() == "SwiftUI.UIKitGestureRecognizer"
        if isSwiftUIGestureRecognizer && shouldCancel {
            // workaround: SwiftUI.UIKitGestureRecognizer can't fail by other gestures.
            otherGestureRecognizer.state = .cancelled
            return true
        }
        return false
    }
}
