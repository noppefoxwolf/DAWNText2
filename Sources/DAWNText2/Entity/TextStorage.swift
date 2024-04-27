import UIKit

final class TextStorage {
    var attributedText: NSAttributedString? = nil
    var numberOfLines: Int = 0
    var lineBreakMode: NSLineBreakMode = .byTruncatingTail
    var scale: Double = 1
    var tintColor: UIColor = .tintColor
    var buttonShapesEnabled: Bool = false
}
