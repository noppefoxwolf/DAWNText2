import UIKit

@MainActor
extension DAWNLabel {
    
    public var textContainer: NSTextContainer {
        controller.textContainer
    }
    
    public var numberOfLines: Int {
        get { textContainer.maximumNumberOfLines }
        set { textContainer.maximumNumberOfLines = newValue }
    }

    public var lineBreakMode: NSLineBreakMode {
        get { textContainer.lineBreakMode }
        set { textContainer.lineBreakMode = newValue }
    }
    
    public var attributedText: NSAttributedString? {
        get { controller.textContentStorage.attributedString }
        set { controller.setAttributedString(newValue) }
    }

    public var text: String? {
        get { attributedText?.string }
        set { attributedText = newValue.map(NSAttributedString.init(string:)) }
    }
}

extension DAWNLabel {
    func url(at location: CGPoint) -> URL? {
        let attributes = attributes(at: location)
        let link = attributes[.link]
        return link as? URL
    }

    func attachment(at location: CGPoint) -> NSTextAttachment? {
        let attributes = attributes(at: location)
        let link = attributes[.attachment]
        return link as? NSTextAttachment
    }

    func attributes(at location: CGPoint) -> [NSAttributedString.Key: Any] {
        guard let textLayoutFragment = controller.textLayoutManager.textLayoutFragment(for: location) else {
            return [:]
        }
        let location = CGPoint(
            x: location.x - textLayoutFragment.layoutFragmentFrame.minX,
            y: location.y - textLayoutFragment.layoutFragmentFrame.minY
        )
        let textLineFragment = textLayoutFragment.textLineFragments.first(
            where: { $0.typographicBounds.contains(location) }
        )
        guard let textLineFragment else { return [:] }
        let index = textLineFragment.characterIndex(for: location)
        let attributes = textLineFragment.attributedString.attributes(
            at: index,
            effectiveRange: nil
        )
        return attributes
    }
}
