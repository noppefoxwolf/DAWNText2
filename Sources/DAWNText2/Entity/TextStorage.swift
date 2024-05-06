import UIKit

final class TextStorage {
    var attributedText: NSAttributedString? = nil
    var numberOfLines: Int = 0
    var lineBreakMode: NSLineBreakMode = .byTruncatingTail
    var traitCollection: UITraitCollection = .current
    var buttonShapesEnabled: Bool = UIAccessibility.buttonShapesEnabled
}
