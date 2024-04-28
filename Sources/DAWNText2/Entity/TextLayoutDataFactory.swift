import UIKit

final class TextLayoutDataFactory: NSObject, NSTextLayoutManagerDelegate {
    let textContainer = NSTextContainer()
    let textLayoutManager = NSTextLayoutManager()
    
    let textContentStorage = NSTextContentStorage()
    
    let textStorage = NSTextStorage()
    
    override init() {
        textLayoutManager.textContainer = textContainer
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textContentStorage.textStorage = textStorage
        super.init()
    }
    
    @MainActor
    func make(for size: TextLayoutSize, storage: TextStorage) -> TextLayoutData {
        textContainer.size = size.cgSize
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = storage.lineBreakMode
        textContainer.maximumNumberOfLines = storage.numberOfLines
        
        textContentStorage.attributedString = storage.attributedText
        
        let coordinator = NSTextLayoutManagerCoordinator(
            tintColor: storage.tintColor,
            buttonShapesEnabled: storage.buttonShapesEnabled
        )
        textLayoutManager.delegate = coordinator
        
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
        layer.contentsScale = storage.scale
        layer.rasterizationScale = storage.scale
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
