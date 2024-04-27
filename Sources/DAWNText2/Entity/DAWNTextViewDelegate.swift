import UIKit

public protocol DAWNTextViewDelegate: AnyObject {
    @MainActor
    func textView(
        _ textView: DAWNTextView,
        primaryActionFor textItem: DAWNTextItem,
        defaultAction: UIAction
    ) -> UIAction?
}
