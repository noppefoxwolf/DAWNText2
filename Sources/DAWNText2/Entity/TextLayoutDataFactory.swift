import UIKit

final class TextLayoutDataFactory {
    let textContainer = NSTextContainer()
    let textLayoutManager = NSTextLayoutManager()
    
    let textContentStorage = NSTextContentStorage()
    
    let textStorage = NSTextStorage()
    
    init() {
        textLayoutManager.textContainer = textContainer
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textContentStorage.textStorage = textStorage
    }
    
    @MainActor
    func make(for size: TextLayoutSize, storage: TextStorage) -> TextLayoutData {
        let storageCoordinator = NSTextContentStorageCoordinator(
            traitCollection: storage.traitCollection
        )
        textContentStorage.delegate = storageCoordinator
        textContentStorage.textStorage?.setAttributedString(storage.attributedText ?? NSAttributedString())
        
        textContainer.size = size.cgSize
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = storage.lineBreakMode
        textContainer.maximumNumberOfLines = storage.numberOfLines
        
        let managerCoordinator = NSTextLayoutManagerCoordinator(
            tintColor: UIColor.tintColor.resolvedColor(with: storage.traitCollection),
            buttonShapesEnabled: storage.buttonShapesEnabled
        )
        textLayoutManager.delegate = managerCoordinator
        // FIXME: textItemTagのtintColorが反映されない
        
        textLayoutManager.textViewportLayoutController.layoutViewport()
        
        var layoutWidth: Int = 0
        var layoutHeight: Int = 0
        var renderingWidth: Int = 0
        var renderingHeight: Int = 0
        var textLayoutFragments: [NSTextLayoutFragment] = []
        var textAttachmentViews: [(UIView, CGRect)] = []
        textLayoutManager.enumerateTextLayoutFragments(
            from: nil,
            options: [.ensuresLayout, .ensuresExtraLineFragment],
            using: { textLayoutFragment in
                for textAttachmentViewProvider in textLayoutFragment.textAttachmentViewProviders {
                    // Remove placeholder image
                    textAttachmentViewProvider.textAttachment?.image = UIImage()
                    
                    if let textAttachmentView = textAttachmentViewProvider.view {
                        let attachmentViewFrame = textLayoutFragment.frameForTextAttachment(
                            at: textAttachmentViewProvider.location
                        )
                        // 画面上に表示されない場合はsizeがzeroになる
                        if !attachmentViewFrame.isEmpty {
                            let frame = attachmentViewFrame.offsetBy(
                                dx: 0,
                                dy: textLayoutFragment.layoutFragmentFrame.minY
                            )
                            textAttachmentViews.append((textAttachmentView, frame))
                        }
                    }
                }
                layoutWidth = max(Int(textLayoutFragment.layoutFragmentFrame.width.rounded(.up)), layoutWidth)
                layoutHeight = max(Int(textLayoutFragment.layoutFragmentFrame.maxY.rounded(.up)), layoutHeight)
                renderingWidth = max(Int(textLayoutFragment.renderingSurfaceBounds.width.rounded(.up)), renderingWidth)
                renderingHeight += Int(textLayoutFragment.renderingSurfaceBounds.maxY.rounded(.up))
                textLayoutFragments.append(textLayoutFragment)
                return true
            }
        )
        let layoutSize = TextLayoutSize(width: layoutWidth, height: layoutHeight)
        let renderingSize = TextLayoutSize(width: renderingWidth, height: renderingHeight)
        
        let layer = LabelLayer()
        layer.contentsScale = storage.traitCollection.displayScale
        layer.rasterizationScale = storage.traitCollection.displayScale
        // FIXME: leading rendering inset
        layer.frame = CGRect(origin: .zero, size: renderingSize.cgSize)
        layer.textLayoutFragments = textLayoutFragments
        layer.setNeedsDisplay()
        
        let data = TextLayoutData(
            size: layoutSize,
            layer: layer,
            attachmentViews: textAttachmentViews,
            textLayoutManager: textLayoutManager
        )
        
        return data
    }
}

final class NSTextContentStorageCoordinator: NSObject, NSTextContentStorageDelegate {
    let traitCollection: UITraitCollection
    
    init(traitCollection: UITraitCollection) {
        self.traitCollection = traitCollection
    }
    
    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        var paragraphWithDisplayAttributes: NSTextParagraph? = nil
        let originalText = textContentStorage.textStorage!.attributedSubstring(from: range)
        
        paragraphWithDisplayAttributes = NSTextParagraph(
            attributedString: originalText.colorResolved(traitCollection)
        )
        return paragraphWithDisplayAttributes
    }
}

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

extension NSAttributedString {
    func colorResolved(_ traitCollection: UITraitCollection) -> NSAttributedString {
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
