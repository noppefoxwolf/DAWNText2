import UIKit
import os

@MainActor
fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

protocol LayoutControllerDelegate: AnyObject {
    func layoutController(_ layoutController: LayoutController, onUpdated attributedText: NSAttributedString?)
}

final class LayoutController {
    let textContainer = NSTextContainer()
    let textLayoutManager: NSTextLayoutManager = TextLayoutManager()
    let textLayoutController = TextLayoutController()
    let textViewportLayoutController = TextViewportLayoutController()
    let textContentStorage = NSTextContentStorage()
    let textStorage = NSTextStorage()
    weak var delegate: (any LayoutControllerDelegate)? = nil
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
            delegate?.layoutController(self, onUpdated: attributedString)
        }
    }
    
    func resolveTintColor() {
        
    }
    
    func makeSize(that fitSize: CGSize) -> CGSize {
        guard textContentStorage.attributedString != nil else { return .zero }
        // 雑に計算回数を減らす
        var size = fitSize
        if size.width <= 0 || size.width == .infinity {
            size.width = 10000000
        }
        let cacheKey = SizeCache.Key(width: Int(size.width))
        if let size = cache.value(for: cacheKey) {
            return CGSize(width: size.width, height: size.height)
        }
        layout(size: CGSize(width: Int(size.width), height: 0))
        
        let newSize = makeTextLayoutSize()
        cache.store(SizeCache.Value(width: Int(newSize.width), height: Int(newSize.height)), key: cacheKey)
        layoutedSize = newSize
        return newSize
    }
    
    func layoutIfNeeded(_ size: CGSize) {
        if layoutedSize.width != size.width {
            layout(size: size)
        }
    }
    
    func layout(size: CGSize) {
        textContainer.size = size
        textLayoutManager.textViewportLayoutController.layoutViewport()
    }
    
    func makeTextLayoutSize() -> CGSize {
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
        return CGSize(width: width.rounded(.up), height: height.rounded(.up))
    }
}


