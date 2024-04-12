import UIKit
import CoreGraphics
import os

@MainActor
fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

final class TextLayoutFragmentLayer: CALayer {
    let layoutFragment: NSTextLayoutFragment
    
    override class func defaultAction(forKey: String) -> CAAction? { NSNull() }

    init(layoutFragment: NSTextLayoutFragment) {
        self.layoutFragment = layoutFragment
        super.init()
        updateGeometry()
        setNeedsDisplay()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateGeometry() {
        bounds = layoutFragment.renderingSurfaceBounds
        anchorPoint = CGPoint(
            x: -bounds.origin.x / bounds.size.width,
            y: -bounds.origin.y / bounds.size.height
        )
        position = layoutFragment.layoutFragmentFrame.origin
    }
    
    override func draw(in ctx: CGContext) {
        layoutFragment.textLineFragments.forEach { lineFragment in
            // https://speakerdeck.com/niw/iosdc-japan-2023?slide=33
            let point = lineFragment.typographicBounds.insetBy(
                dx: -layoutFragment.layoutFragmentFrame.minX,
                dy: 0
            ).origin
            lineFragment.draw(at: point, in: ctx)
        }
    }
}
