import UIKit

final class TextLayoutManager: NSTextLayoutManager {
    var foregroundColor: UIColor = .tintColor
    var buttonShapesEnabled: Bool = false
    
    override func renderingAttributes(
        forLink link: Any,
        at location: any NSTextLocation
    ) -> [NSAttributedString.Key: Any] {
        var defaultAttributes = super.renderingAttributes(forLink: link, at: location)
        defaultAttributes[.foregroundColor] = foregroundColor
        defaultAttributes[.underlineStyle] = buttonShapesEnabled ? NSUnderlineStyle.single.rawValue : nil
        return defaultAttributes
    }
}
