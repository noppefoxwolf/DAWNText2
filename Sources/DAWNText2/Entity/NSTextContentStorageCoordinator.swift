import UIKit

final class NSTextContentStorageCoordinator: NSObject, NSTextContentStorageDelegate {
    let traitCollection: UITraitCollection
    
    init(traitCollection: UITraitCollection) {
        self.traitCollection = traitCollection
    }
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        let originalText = textContentStorage.textStorage?.attributedSubstring(from: range)
        guard let originalText else { return nil }
        
        return NSTextParagraph(
            attributedString: originalText.colorResolved(traitCollection)
        )
    }
}

extension NSAttributedString {
    fileprivate func colorResolved(_ traitCollection: UITraitCollection) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.enumerateAttributes(in: range) { attributes, range, _ in
            if let color = attributes[.foregroundColor] as? UIColor {
                attributedString.addAttribute(
                    .foregroundColor,
                    value: color.resolvedColor(with: traitCollection),
                    range: range
                )
            } else {
                // default text color
                attributedString.addAttribute(
                    .foregroundColor,
                    value: UIColor.label.resolvedColor(with: traitCollection),
                    range: range
                )
            }
        }
        return attributedString
    }
}
