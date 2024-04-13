import UIKit
import os

@MainActor
fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

final class TextLayoutManager: NSTextLayoutManager {
    var foregroundColor: UIColor = .tintColor
    
    override func renderingAttributes(
        forLink link: Any,
        at location: any NSTextLocation
    ) -> [NSAttributedString.Key : Any] {
        [.foregroundColor : foregroundColor]
    }
}

public final class DAWNLabel: UIView, NSTextViewportLayoutControllerDelegate {
    private var contentLayer: CALayer { layer as! LabelLayer }
    public override class var layerClass: AnyClass { LabelLayer.self }
    
    var preferredContentSize: CGSize = .zero
    var contentSize: CGSize = .zero
    
    public let textContainer = NSTextContainer()
    public let textLayoutManager: NSTextLayoutManager = TextLayoutManager()
    let layoutController = LayoutController()
    
    private let textContentStorage = NSTextContentStorage()
    public var textStorage: NSTextStorage { textContentStorage.textStorage! }
    
    public var numberOfLines: Int {
        get { textContainer.maximumNumberOfLines }
        set { textContainer.maximumNumberOfLines = newValue }
    }
    
    public var lineBreakMode: NSLineBreakMode {
        get { textContainer.lineBreakMode }
        set { textContainer.lineBreakMode = newValue }
    }
    
    public var attributedText: NSAttributedString = NSAttributedString() {
        didSet {
            setAttributedString(attributedText)
        }
    }
    /// set and resolve AttributedString
    /// - Parameter attributedString: NSAttributedString
    func setAttributedString(_ attributedString: NSAttributedString) {
        cachedSize = [:]
        let textStorage = textContentStorage.textStorage!
        textStorage.setAttributedString(attributedText)
        updateContentSizeIfNeeded()
    }
    
    public var text: String? {
        get { attributedText.string }
        set { attributedText = newValue.map(NSAttributedString.init(string:)) ?? NSAttributedString() }
    }
    
    private let fragmentLayerMap: NSMapTable<NSTextLayoutFragment, CALayer> = .weakToWeakObjects()
    private var cachedSize: [Double : CGSize] = [:]
    
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
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(onTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        if let url = url(at: location) {
            UIApplication.shared.open(url)
        }
    }
    
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
    
    func attributes(at location: CGPoint) -> [NSAttributedString.Key : Any] {
        guard let textLayoutFragment = textLayoutManager.textLayoutFragment(for: location) else { return [:] }
        let location = CGPoint(
            x: location.x - textLayoutFragment.layoutFragmentFrame.minX,
            y: location.y - textLayoutFragment.layoutFragmentFrame.minY
        )
        let textLineFragment = textLayoutFragment.textLineFragments.first(
            where: { $0.typographicBounds.contains(location) }
        )
        guard let textLineFragment else { return [:] }
        let index = textLineFragment.characterIndex(for: location)
        let attributes = textLineFragment.attributedString.attributes(at: index, effectiveRange: nil)
        return attributes
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
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        setAttributedString(attributedText)
    }
    
    // MARK: - NSTextViewportLayoutControllerDelegate
    
    public func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
        CGRect(origin: .zero, size: preferredContentSize)
    }

    public func textViewportLayoutControllerWillLayout(_ controller: NSTextViewportLayoutController) {
        CATransaction.begin()
        subviews.forEach({ $0.removeFromSuperview() })
        contentLayer.sublayers = nil
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
                    
                    let attachmentViewFrame = textLayoutFragment.frameForTextAttachment(
                        at: textAttachmentViewProvider.location
                    )
                    attachmentView.frame = attachmentViewFrame
                        .offsetBy(
                            dx: textLayoutFragment.layoutFragmentFrame.minX,
                            dy: textLayoutFragment.layoutFragmentFrame.minY
                        )
                    addSubview(attachmentView)
                }
            }
            
            return true
        }
        
        CATransaction.commit()
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
//        // 雑に計算回数を減らす
//        if size.width == 0 {
//            return .zero
//        }
//        if let size = cachedSize[size.width] {
//            return size
//        }
//        print(#function, size)
        preferredContentSize = CGSize(width: size.width, height: 0)
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
        let newSize = CGSize(width: width.rounded(.up), height: height.rounded(.up))
        cachedSize[size.width] = newSize
        return newSize
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        url(at: point) != nil || attachment(at: point) != nil
    }
}
