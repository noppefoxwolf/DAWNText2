import QuartzCore
import UIKit

final class LabelLayer: ContentLayer {
    
    var textLayoutFragments: [NSTextLayoutFragment] = []
    
    override init() {
        super.init()
        // FIXME: isOpaque = trueにしたい
        isOpaque = false
        backgroundColor = CGColor(gray: 0, alpha: 0)
        shouldRasterize = true
        drawsAsynchronously = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        for textLayoutFragment in textLayoutFragments {
            textLayoutFragment.textLineFragments.forEach { textLineFragment in
                let textLineFragmentOrigin = CGPoint(
                    x: 0,
                    y: textLayoutFragment.layoutFragmentFrame.origin.y + textLineFragment.typographicBounds.origin.y
                )
                textLineFragment.draw(
                    at: textLineFragmentOrigin,
                    in: ctx
                )
            }
        }
    }
}
