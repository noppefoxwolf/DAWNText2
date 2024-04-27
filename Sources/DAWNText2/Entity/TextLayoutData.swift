import Foundation
import UIKit

final class TextLayoutData {
    let size: TextLayoutSize
    let layer: CALayer
    let attachmentViews: [UIView]
    let textLayoutManager: NSTextLayoutManager
    
    init(size: TextLayoutSize, layer: CALayer, attachmentViews: [UIView], textLayoutManager: NSTextLayoutManager) {
        self.size = size
        self.layer = layer
        self.attachmentViews = attachmentViews
        self.textLayoutManager = textLayoutManager
    }
}

