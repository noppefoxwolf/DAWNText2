import SwiftUI
import UIKit
import os

@MainActor
fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public final class DAWNLabel: UIControl {
    private var contentLayer: LabelLayer { layer as! LabelLayer }
    public override class var layerClass: AnyClass { LabelLayer.self }
    
    let controller = LayoutController()
    
    public var openURLAction: OpenURLAction = OpenURLAction(handler: { _ in .systemAction })
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        traitObservationInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        controller.delegate = self
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(onTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        if let url = url(at: location) {
            openURLAction(url)
        }
    }
    
    private func traitObservationInit() {
        registerForTraitChanges([
            UITraitUserInterfaceStyle.self,
            UITraitPreferredContentSizeCategory.self,
        ]) { (self: Self, _) in
            self.controller.setAttributedString(self.attributedText)
        }
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        controller.resolveTintColor()
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        var textLayoutFragments: [NSTextLayoutFragment] = []
        controller.enumerateTextLayoutFragments { textLayoutFragment in
            textLayoutFragments.append(textLayoutFragment)
        }
        
        contentLayer.backgroundColor = backgroundColor!.cgColor
        contentLayer.contentsScale = traitCollection.displayScale
        contentLayer.rasterizationScale = traitCollection.displayScale
        contentLayer.textLayoutFragments = textLayoutFragments
        
        contentLayer.displayIfNeeded()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        subviews.forEach({ $0.removeFromSuperview() })
        
        controller.layoutIfNeeded(CGSize(width: Int(bounds.size.width), height: 0))
        
        controller.enumerateTextLayoutFragments { textLayoutFragment in
            
            guard textLayoutFragment.state == .layoutAvailable else { return }
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
                        addSubview(attachmentView)
                    }
                }
            }
        }
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        controller.makeSize(that: size)
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        url(at: point) != nil || attachment(at: point) != nil
    }
}

extension DAWNLabel: LayoutControllerDelegate {
    nonisolated func layoutController(_ layoutController: LayoutController, onUpdated attributedText: NSAttributedString?) {
//        MainActor.assumeIsolated {
//            setNeedsLayout()
//        }
    }
}
