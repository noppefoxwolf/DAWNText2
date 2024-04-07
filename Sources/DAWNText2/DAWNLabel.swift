import UIKit

public final class DAWNLabel: UIView, NSTextViewportLayoutControllerDelegate {
    private var contentLayer: CALayer { layer as! LabelLayer }
    public override class var layerClass: AnyClass { LabelLayer.self }
    
    var contentSize: CGSize = .zero
    var contentOffset: CGPoint = .zero
    
    public let textContainer = NSTextContainer()
    public let textLayoutManager = NSTextLayoutManager()
    let layoutController = LayoutController()
    
    private let textContentStorage = NSTextContentStorage()
    public var textStorage: NSTextStorage { textContentStorage.textStorage! }
    
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
        
        textLayoutManager.textContainer = textContainer
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.delegate = layoutController
        textLayoutManager.textViewportLayoutController.delegate = self
        updateContentSizeIfNeeded()
        updateTextContainerSize()
    }
    
    private func traitObservationInit() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
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
        CGRect(origin: contentOffset, size: contentSize)
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
    
    public func textViewportLayoutController(_ textViewportLayoutController: NSTextViewportLayoutController,
                                      configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment) {

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
        
        guard textLayoutFragment.state == .layoutAvailable else { return }
        for textAttachmentViewProvider in textLayoutFragment.textAttachmentViewProviders {
            if let attachmentView = textAttachmentViewProvider.view {
                // Remove placeholder image
                textAttachmentViewProvider.textAttachment?.image = UIImage()
                
                let attachmentViewFrame = textLayoutFragment.frameForTextAttachment(at: textAttachmentViewProvider.location)
                // https://speakerdeck.com/niw/iosdc-japan-2023?slide=33
                attachmentView.frame = attachmentViewFrame.offsetBy(
                    dx: textLayoutFragment.layoutFragmentFrame.minX,
                    dy: 0
                )
                addSubview(attachmentView)
            }
        }
    }
    
    public func textViewportLayoutControllerDidLayout(_ controller: NSTextViewportLayoutController) {
        CATransaction.commit()
        updateContentSizeIfNeeded()
        adjustViewportOffsetIfNeeded()
    }
    
    private func adjustViewportOffsetIfNeeded() {
        let viewportLayoutController = textLayoutManager.textViewportLayoutController
        let contentOffset = bounds.minY
        
        let compareResult = viewportLayoutController.viewportRange!.location.compare(
            textLayoutManager.documentRange.location
        )
        if contentOffset < bounds.height && compareResult == .orderedDescending {
            // Nearing top, see if we need to adjust and make room above.
            adjustViewportOffset()
        } else if compareResult == .orderedSame {
            // At top, see if we need to adjust and reduce space above.
            adjustViewportOffset()
        }
    }
    
    private func adjustViewportOffset() {
        let viewportLayoutController = textLayoutManager.textViewportLayoutController
        var layoutYPoint: CGFloat = 0
        textLayoutManager.enumerateTextLayoutFragments(from: viewportLayoutController.viewportRange!.location,
                                                        options: [.reverse, .ensuresLayout]) { layoutFragment in
            layoutYPoint = layoutFragment.layoutFragmentFrame.origin.y
            return true
        }
        if layoutYPoint != 0 {
            let adjustmentDelta = bounds.minY - layoutYPoint
            viewportLayoutController.adjustViewport(byVerticalOffset: adjustmentDelta)
            let point = CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + adjustmentDelta)
            contentOffset = point
        }
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        assert(layer == self.layer)
        textLayoutManager.textViewportLayoutController.layoutViewport()
        updateTextContainerSize()
        updateContentSizeIfNeeded()
    }
    
    private func updateTextContainerSize() {
        let textContainer = textLayoutManager.textContainer
        if let textContainer, textContainer.size.width != bounds.width {
            textContainer.size = CGSize(width: bounds.width, height: 0)
            layer.setNeedsLayout()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        contentSize
    }
    
    public func updateContentSizeIfNeeded() {
        let currentWidth = bounds.width
        let currentHeight = bounds.height
        var height: CGFloat = 0
        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.endLocation,
            options: [.reverse, .ensuresLayout]
        ) { layoutFragment in
            height = layoutFragment.layoutFragmentFrame.maxY
            return false // stop
        }
        height = max(height, contentSize.height)
        if abs(currentHeight - height) > 1e-10 {
            let contentSize = CGSize(width: bounds.width, height: height)
            self.contentSize = contentSize
            invalidateIntrinsicContentSize()
        }
    }
}
