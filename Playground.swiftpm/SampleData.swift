import SwiftUI

extension AttributedString {
    static var sample: AttributedString {
        var attributedString = AttributedString()
        
        let markdown = """
        Lorem ipsum dolor sit amet. [Aut harum quod et galisum quia ad eligendi illo.](https://apple.com) Ut voluptas dolor aut reiciendis veniam qui numquam aliquam ut amet assumenda eos ratione dignissimos ut beatae commodi. **Et vero numquam** ut nisi asperiores qui accusamus blanditiis qui soluta voluptatibus sed omnis nesciunt.
        """
        let markdownAttr = try! AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
        attributedString.append(markdownAttr)
        
        let attachment = UISwitchAttachment()
        let attachmentAttr = AttributedString(NSAttributedString(attachment: attachment))
        attributedString.append(attachmentAttr)
        
        var foregroundColorAttr = AttributedString("Est molestias voluptas aut distinctio expedita ut omnis nostrum et sequi quas?")
        foregroundColorAttr.foregroundColor = UIColor.red
        attributedString.append(foregroundColorAttr)
        
        var textTagAttr = AttributedString("Read More")
        textTagAttr.foregroundColor = UIColor.tintColor
        textTagAttr.textItemTag = "dev.noppe.dawn-text.text-item-tag"
        attributedString.append(textTagAttr)
        
        return attributedString
    }
}

final class UISwitchAttachment: NSTextAttachment {
    override init(data contentData: Data?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
        allowsTextAttachmentView = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewProvider(for parentView: UIView?, location: any NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
        UISwitchAttachmentViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
    }
}

final class UISwitchAttachmentViewProvider: NSTextAttachmentViewProvider {
    
    override init(textAttachment: NSTextAttachment, parentView: UIView?, textLayoutManager: NSTextLayoutManager?, location: any NSTextLocation) {
        super.init(textAttachment: textAttachment, parentView: parentView, textLayoutManager: textLayoutManager, location: location)
        tracksTextAttachmentViewBounds = true
    }
    
    override func loadView() {
        view = UISwitch()
    }
}

extension UIColor {
    static let custom: UIColor = UIColor(dynamicProvider: { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor.systemGreen
        case .light:
            return UIColor.systemOrange
        default:
            return UIColor.white
        }
    })
}
