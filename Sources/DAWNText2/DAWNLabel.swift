import UIKit
import os

@MainActor
fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public final class DAWNLabel: UIView, NSTextViewportLayoutControllerDelegate {
    private var contentLayer: CALayer { layer as! LabelLayer }
    public override class var layerClass: AnyClass { LabelLayer.self }
    
    var preferredContentSize: CGSize = .zero
    var contentSize: CGSize = .zero
    
    public let textContainer = NSTextContainer()
    public let textLayoutManager = NSTextLayoutManager()
    let layoutController = LayoutController()
    
    private let textContentStorage = NSTextContentStorage()
    public var textStorage: NSTextStorage { textContentStorage.textStorage! }
    
    public var numberOfLines: Int {
        get { textContainer.maximumNumberOfLines }
        set { textContainer.maximumNumberOfLines = newValue }
    }
    
    public var attributedText: NSAttributedString = NSAttributedString() {
        didSet {
            setAttributedString(attributedText)
        }
    }
    /// set and resolve AttributedString
    /// - Parameter attributedString: NSAttributedString
    func setAttributedString(_ attributedString: NSAttributedString) {
        let textStorage = textContentStorage.textStorage!
        textStorage.setAttributedString(attributedText)
        updateContentSizeIfNeeded()
    }
    
    public var text: String? {
        get { attributedText.string }
        set { attributedText = newValue.map(NSAttributedString.init(string:)) ?? NSAttributedString() }
    }
    
    private let fragmentLayerMap: NSMapTable<NSTextLayoutFragment, CALayer> = .weakToWeakObjects()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        traitObservationInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func commonInit() {
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        layer.backgroundColor = UIColor.clear.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        
        textContainer.lineBreakMode = .byTruncatingTail
        textLayoutManager.textContainer = textContainer
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.delegate = layoutController
        textLayoutManager.textViewportLayoutController.delegate = self
    }
    
    private func traitObservationInit() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self, UITraitPreferredContentSizeCategory.self]) { (self: Self, _) in
            self.setAttributedString(self.attributedText)
        }
        registerForTraitChanges([UITraitDisplayScale.self]) { (self: Self, _) in
            for key in self.fragmentLayerMap.keyEnumerator() {
                self.fragmentLayerMap.object(forKey: key as? NSTextLayoutFragment)?.contentsScale = self.traitCollection.displayScale
            }
        }
    }
    
    // MARK: - NSTextViewportLayoutControllerDelegate
    
    public func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
        CGRect(origin: .zero, size: preferredContentSize)
    }

    public func textViewportLayoutControllerWillLayout(_ controller: NSTextViewportLayoutController) {
        subviews.forEach({ $0.removeFromSuperview() })
        contentLayer.sublayers = nil
        CATransaction.begin()
    }
    
    private func findOrCreateLayer(_ textLayoutFragment: NSTextLayoutFragment) -> (TextLayoutFragmentLayer, Bool) {
        if let layer = fragmentLayerMap.object(forKey: textLayoutFragment) as? TextLayoutFragmentLayer {
            return (layer, false)
        } else {
            let layer = TextLayoutFragmentLayer(layoutFragment: textLayoutFragment)
            layer.contentsScale = traitCollection.displayScale
            fragmentLayerMap.setObject(layer, forKey: textLayoutFragment)
            return (layer, true)
        }
    }
    
    public func textViewportLayoutController(
        _ textViewportLayoutController: NSTextViewportLayoutController,
        configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment
    ) {}
    
    public func textViewportLayoutControllerDidLayout(_ controller: NSTextViewportLayoutController) {
        
        textLayoutManager.enumerateTextLayoutFragments(
            from: nil,
            options: [.ensuresLayout]
        ) { textLayoutFragment in
            
            let (textLayoutFragmentLayer, didCreate) = findOrCreateLayer(textLayoutFragment)
            if !didCreate {
                let oldPosition = textLayoutFragmentLayer.position
                let oldBounds = textLayoutFragmentLayer.bounds
                textLayoutFragmentLayer.updateGeometry()
                if oldBounds != textLayoutFragmentLayer.bounds {
                    textLayoutFragmentLayer.setNeedsDisplay()
                }
            }
            
            contentLayer.addSublayer(textLayoutFragmentLayer)
            
            guard textLayoutFragment.state == .layoutAvailable else { return true }
            for textAttachmentViewProvider in textLayoutFragment.textAttachmentViewProviders {
                if let attachmentView = textAttachmentViewProvider.view {
                    // Remove placeholder image
                    textAttachmentViewProvider.textAttachment?.image = UIImage()
                    
                    let attachmentViewFrame = textLayoutFragment.frameForTextAttachment(at: textAttachmentViewProvider.location)
                    attachmentView.frame = attachmentViewFrame
                    addSubview(attachmentView)
                }
            }
            
            return true
        }
        
        CATransaction.commit()
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        assert(layer == self.layer)
    }
    
    public func updateContentSizeIfNeeded() {
        let newSize = sizeThatFits(preferredContentSize)
        if abs(bounds.height - newSize.height) > 1e-10 {
            self.contentSize = newSize
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize { contentSize }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        preferredContentSize = CGSize(width: size.width, height: size.height)
        textContainer.size = preferredContentSize

        textLayoutManager.textViewportLayoutController.layoutViewport()
        var width: Double = 0
        var height: CGFloat = 0
        textLayoutManager.enumerateTextLayoutFragments(
            from: nil,
            options: [.ensuresLayout]
        ) { layoutFragment in
            width = max(layoutFragment.layoutFragmentFrame.width, width)
            height = max(layoutFragment.layoutFragmentFrame.maxY, height)
            
            return true
        }
        let newSize = CGSize(width: width, height: height)
        return newSize
    }
}
