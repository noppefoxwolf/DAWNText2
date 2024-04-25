import UIKit
import os

@MainActor
fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

final class LayoutController {
    let textContainer = NSTextContainer()
    let textLayoutManager: NSTextLayoutManager = TextLayoutManager()
    let textLayoutController = TextLayoutController()
    let textViewportLayoutController = TextViewportLayoutController()
    let textContentStorage = NSTextContentStorage()
    let textStorage = NSTextStorage()
    let fragmentLayerMap: NSMapTable<NSTextLayoutFragment, CALayer> = .weakToWeakObjects()
    var layoutedSize: CGSize = .zero
    let cache = SizeCache()
    
    init() {
        textContainer.lineBreakMode = .byTruncatingTail
        textLayoutManager.textContainer = textContainer
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textContentStorage.textStorage = textStorage
        textLayoutManager.delegate = textLayoutController
        textLayoutManager.textViewportLayoutController.delegate = textViewportLayoutController
    }
    
    func enumerateTextLayoutFragments(using: (NSTextLayoutFragment) -> Void) {
        textLayoutManager.enumerateTextLayoutFragments(
            from: nil,
            options: [.ensuresLayout, .ensuresExtraLineFragment],
            using: {
                using($0)
                return true
            }
        )
    }
    
    /// set and resolve AttributedString
    /// - Parameter attributedString: NSAttributedString
    func setAttributedString(_ attributedString: NSAttributedString?) {
        let isChanged = textContentStorage.attributedString.hashValue != attributedString.hashValue
        textContentStorage.attributedString = attributedString
        if isChanged {
            cache.removeAll()
            layoutedSize = .zero
            textContainer.size = .zero
        }
    }
    
    func makeSize(that fitSize: CGSize) -> CGSize {
        guard textContentStorage.attributedString != nil else { return .zero }
        // 雑に計算回数を減らす
        var size = fitSize
        if size.width <= 0 || size.width == .infinity {
            size.width = 10000000
        }
        let width = Int(size.width.rounded(.down))
        let cacheKey = SizeCache.Key(width: width)
        if let size = cache.value(for: cacheKey) {
            return CGSize(width: size.width, height: size.height)
        }
        layout(width: width)
        
        let newSize = makeTextLayoutSize()
        let cacheValue = SizeCache.Value(
            width: newSize.width,
            height: newSize.height
        )
        cache.store(cacheValue, key: cacheKey)
        layoutedSize = CGSize(width: newSize.width, height: newSize.height)
        return layoutedSize
    }
    
    func layoutIfNeeded(width: Int) {
        if Int(layoutedSize.width) != width {
            layout(width: width)
        }
    }
    
    func layout(width: Int) {
        textContainer.size = CGSize(width: width, height: 0)
        textLayoutManager.textViewportLayoutController.layoutViewport()
    }
    
    func makeTextLayoutSize() -> (width: Int, height: Int) {
        var width: Double = 0
        var height: CGFloat = 0
        textLayoutManager.enumerateTextLayoutFragments(
            from: nil,
            options: [.ensuresLayout, .ensuresExtraLineFragment]
        ) { textLayoutFragment in
            width = max(textLayoutFragment.layoutFragmentFrame.width, width)
            height = max(textLayoutFragment.layoutFragmentFrame.maxY, height)
            return true
        }
        return (
            width: Int(width.rounded(.up)),
            height: Int(height.rounded(.up)) + 1 // workaround: +1
        )
    }
}


