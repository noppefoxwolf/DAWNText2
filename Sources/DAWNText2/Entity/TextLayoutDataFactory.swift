import UIKit

final class TextLayoutDataFactory {
    let textContainer = NSTextContainer()
    let textLayoutManager = TextLayoutManager()
    
    let textContentStorage = NSTextContentStorage()
    
    let textStorage = NSTextStorage()
    
    init() {
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = .byTruncatingTail
        textLayoutManager.textContainer = textContainer
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textContentStorage.textStorage = textStorage
    }
    
    @MainActor
    func make(for size: TextLayoutSize, storage: TextStorage) -> TextLayoutData {
        textContentStorage.attributedString = storage.attributedText
        textContainer.lineBreakMode = storage.lineBreakMode
        textContainer.maximumNumberOfLines = storage.numberOfLines
        textContainer.size = size.cgSize
        textLayoutManager.foregroundColor = storage.tintColor
        textLayoutManager.buttonShapesEnabled = storage.buttonShapesEnabled
        textLayoutManager.textViewportLayoutController.layoutViewport()
        
        var layoutWidth: Int = 0
        var layoutHeight: Int = 0
        var renderingWidth: Int = 0
        var renderingHeight: Int = 0
        var textLayoutFragments: [NSTextLayoutFragment] = []
        textLayoutManager.enumerateTextLayoutFragments(
            from: nil,
            options: [.ensuresLayout, .ensuresExtraLineFragment],
            using: { textLayoutFragment in
                for textAttachmentViewProvider in textLayoutFragment.textAttachmentViewProviders {
                    if let attachmentView = textAttachmentViewProvider.view {
                        // Remove placeholder image
                        textAttachmentViewProvider.textAttachment?.image = UIImage()
                        
                        let attachmentViewFrame = textLayoutFragment.frameForTextAttachment(
                            at: textAttachmentViewProvider.location
                        )
                        // 画面上に表示されない場合はsizeがzeroになる
                        if !attachmentViewFrame.isEmpty {
                            attachmentView.frame = attachmentViewFrame.offsetBy(
                                dx: 0,
                                dy: textLayoutFragment.layoutFragmentFrame.minY
                            )
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
            attachmentViews: textLayoutFragments.map(\.textAttachmentViewProviders).flatMap{ $0 }.compactMap(\.view),
            textLayoutManager: textLayoutManager
        )
        
        return data
    }
}

