import UIKit

final class NSTextLayoutManagerCoordinator: NSObject, NSTextLayoutManagerDelegate {
    let tintColor: UIColor
    let buttonShapesEnabled: Bool
    
    init(tintColor: UIColor, buttonShapesEnabled: Bool) {
        self.tintColor = tintColor
        self.buttonShapesEnabled = buttonShapesEnabled
    }
    
    func textLayoutManager(
        _ textLayoutManager: NSTextLayoutManager,
        renderingAttributesForLink link: Any,
        at location: any NSTextLocation,
        defaultAttributes renderingAttributes: [NSAttributedString.Key : Any] = [:]
    ) -> [NSAttributedString.Key : Any]? {
        var defaultAttributes = renderingAttributes
        defaultAttributes[.foregroundColor] = tintColor
        defaultAttributes[.underlineStyle] = buttonShapesEnabled ? NSUnderlineStyle.single.rawValue : nil
        return defaultAttributes
    }
}
