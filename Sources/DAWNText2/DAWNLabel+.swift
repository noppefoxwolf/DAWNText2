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

