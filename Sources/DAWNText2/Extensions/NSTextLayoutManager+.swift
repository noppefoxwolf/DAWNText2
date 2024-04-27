import UIKit

extension NSTextLayoutManager {
    func attributes(for location: CGPoint) -> [NSAttributedString.Key : Any] {
        guard let textLayoutFragment = textLayoutFragment(for: location) else {
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

