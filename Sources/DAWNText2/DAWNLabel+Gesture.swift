import UIKit

extension DAWNLabel: UIGestureRecognizerDelegate {
    func addPrimaryActionGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(onTapAction))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        let attributes = attributes(at: location)
        let isSwiftUIGestureRecognizer = type(of: otherGestureRecognizer).description() == "SwiftUI.UIKitGestureRecognizer"
        if isSwiftUIGestureRecognizer, attributes.keys.contains(.link) || attributes.keys.contains(.attachment) {
            // workaround: SwiftUI.UIKitGestureRecognizer can't fail by other gestures.
            otherGestureRecognizer.state = .failed
            return true
        }
        return false
    }
    
    @objc func onTapAction(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else { return }
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        let attributes = attributes(at: location)
        if let url = attributes[.link] as? URL {
            openURLAction(url)
        }
    }

    func attributes(at location: CGPoint) -> [NSAttributedString.Key: Any] {
        guard let textLayoutFragment = controller.textLayoutManager.textLayoutFragment(for: location) else {
            return [:]
        }
        let location = CGPoint(
            x: location.x - textLayoutFragment.layoutFragmentFrame.minX,
            y: location.y - textLayoutFragment.layoutFragmentFrame.minY
        )
        let textLineFragment = textLayoutFragment.textLineFragments.first(
            where: { $0.typographicBounds.contains(location) }
        )
        guard let textLineFragment else { return [:] }
        let index = textLineFragment.characterIndex(for: location)
        let attributes = textLineFragment.attributedString.attributes(
            at: index,
            effectiveRange: nil
        )
        return attributes
    }
}

