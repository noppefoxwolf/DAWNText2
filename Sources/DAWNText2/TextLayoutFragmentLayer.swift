import UIKit
import CoreGraphics

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
        anchorPoint = CGPoint(x: -bounds.origin.x / bounds.size.width, y: -bounds.origin.y / bounds.size.height)
        position = layoutFragment.layoutFragmentFrame.origin
    }
    
    override func draw(in ctx: CGContext) {
        layoutFragment.draw(at: .zero, in: ctx)
    }
}
