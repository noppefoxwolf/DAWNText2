import UIKit
import Combine

public final class DAWNTextView: UIView {
    let storage = TextStorage()
    var primaryAction: UIAction? = nil
    let output: any ViewOutput
    public weak var delegate: (any DAWNTextViewDelegate)? = nil
    // workaround: can not add sublayer and subview directly.
    let contentLayer = ContentLayer()
    var cancellables: Set<AnyCancellable> = []
    
    public override init(frame: CGRect) {
        let presenter = Presenter()
        output = presenter
        super.init(frame: frame)
        presenter.view = self
        
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        storage.buttonShapesEnabled = UIAccessibility.buttonShapesEnabled
        storage.tintColor = tintColor
        storage.scale = traitCollection.displayScale
        addTapGestureRecognizer()
        register()
        
        layer.addSublayer(contentLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override class var layerClass: AnyClass { ContentLayer.self }
    
    func addTapGestureRecognizer() {
        let tapGestureRecognizer = DAWNTextViewGestureRecognizer(output: output, storage: storage)
        tapGestureRecognizer.addTarget(self, action: #selector(onTap))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func onTap(_ gestureRecognizer: DAWNTextViewGestureRecognizer) {
        guard gestureRecognizer.state == .ended else { return }
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        output.onTap(at: location, size: TextLayoutSize(bounds.size), storage: storage)
    }
    
    func register() {
        registerForTraitChanges([UITraitDisplayScale.self]) { (traitEnvironment: Self, previousTraitCollection) in
            traitEnvironment.storage.scale = traitEnvironment.traitCollection.displayScale
            traitEnvironment.output.onChangedStorage()
        }
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (traitEnvironment: Self, previousTraitCollection) in
            traitEnvironment.output.onChangedStorage()
        }
        NotificationCenter.default
            .publisher(for: UIAccessibility.buttonShapesEnabledStatusDidChangeNotification)
            .sink { [unowned self] _ in
            storage.buttonShapesEnabled = UIAccessibility.buttonShapesEnabled
            output.onChangedStorage()
            setNeedsLayout()
        }.store(in: &cancellables)
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        output.layoutSubLayers(TextLayoutSize(bounds.size), storage: storage)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        output.layoutSubviews(TextLayoutSize(bounds.size), storage: storage)
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        storage.tintColor = tintColor
        output.onChangedStorage()
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        output.sizeThatFits(TextLayoutSize(size), storage: storage).cgSize
    }
}

extension DAWNTextView: ViewInput {
    func setLayer(_ textLayer: CALayer) {
        contentLayer.sublayers = nil
        contentLayer.addSublayer(textLayer)
    }
    
    func setAttachmentViews(_ views: [UIView]) {
        subviews.forEach({ $0.removeFromSuperview() })
        views.forEach({ addSubview($0) })
    }
    
    func openURL(_ url: URL) {
        let defaultAction = UIAction { _ in }
        let action = delegate?.textView(
            self,
            primaryActionFor: DAWNTextItem(.link(url)),
            defaultAction: defaultAction
        ) ?? defaultAction
        action.performWithSender(nil, target: nil)
    }
}

extension DAWNTextView {
    public var attributedText: NSAttributedString? {
        get { storage.attributedText }
        set {
            if storage.attributedText != newValue {
                storage.attributedText = newValue
                output.onChangedStorage()
            }
        }
    }
    
    public var numberOfLines: Int {
        get { storage.numberOfLines }
        set {
            if storage.numberOfLines != newValue {
                storage.numberOfLines = newValue
                output.onChangedStorage()
            }
        }
    }
    
    public var lineBreakMode: NSLineBreakMode {
        get { storage.lineBreakMode }
        set {
            if storage.lineBreakMode != newValue {
                storage.lineBreakMode = newValue
                output.onChangedStorage()
            }
        }
    }
}

@MainActor
protocol ViewInput: AnyObject {
    func setNeedsDisplay()
    func setNeedsLayout()
    func setLayer(_ layer: CALayer)
    func setAttachmentViews(_ views: [UIView])
    func openURL(_ url: URL)
}

@MainActor
protocol ViewOutput {
    func onTap(at location: CGPoint, size: TextLayoutSize, storage: TextStorage)
    func onChangedStorage()
    func otherGestureShouldCancel(at location: CGPoint, size: TextLayoutSize, storage: TextStorage) -> Bool
    func layoutSubLayers(_ size: TextLayoutSize, storage: TextStorage)
    func layoutSubviews(_ size: TextLayoutSize, storage: TextStorage)
    func sizeThatFits(_ size: TextLayoutSize, storage: TextStorage) -> TextLayoutSize
}

final class Presenter: ViewOutput {
    weak var view: (any ViewInput)?
    let keyFactory = KeyFactory()
    let textLayoutDataCache = TextLayoutDataCache()
    
    func otherGestureShouldCancel(at location: CGPoint, size: TextLayoutSize, storage: TextStorage) -> Bool {
        let data = retrieveTextLayoutData(for: size, storage: storage)
        let attributes = data.textLayoutManager.attributes(for: location)
        let url = attributes[.link] as? URL
        return url != nil
    }
    
    func onTap(at location: CGPoint, size: TextLayoutSize, storage: TextStorage) {
        let data = retrieveTextLayoutData(for: size, storage: storage)
        let attributes = data.textLayoutManager.attributes(for: location)
        if let url = attributes[.link] as? URL {
            view?.openURL(url)
        }
    }
    
    func layoutSubLayers(_ size: TextLayoutSize, storage: TextStorage) {
        let data = retrieveTextLayoutData(for: size, storage: storage)
        view?.setLayer(data.layer)
    }
    
    func layoutSubviews(_ size: TextLayoutSize, storage: TextStorage) {
        let data = retrieveTextLayoutData(for: size, storage: storage)
        view?.setAttachmentViews(data.attachmentViews)
    }
    
    func onChangedStorage() {
        textLayoutDataCache.removeAll()
        view?.setNeedsLayout()
    }
    
    func sizeThatFits(_ size: TextLayoutSize, storage: TextStorage) -> TextLayoutSize {
        retrieveTextLayoutData(for: size, storage: storage).size
    }
    
    private func retrieveTextLayoutData(for size: TextLayoutSize, storage: TextStorage) -> TextLayoutData {
        let key = keyFactory.make(for: size)
        if let data = textLayoutDataCache.data(for: key) {
            return data
        } else {
            let data = TextLayoutDataFactory().make(for: size, storage: storage)
            textLayoutDataCache.store(data, for: key)
            return data
        }
    }
}

