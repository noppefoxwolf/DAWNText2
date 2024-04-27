import Foundation

struct TextLayoutSize: Sendable {
    let width: Int
    let height: Int
    
    static let zero: Self = Self(width: 0, height: 0)
}

extension TextLayoutSize {
    init(_ cgSize: CGSize) {
        var size = cgSize
        if size.width <= 0 || !size.width.isNormal {
            size.width = 10000000
        }
        size.height = 0
        self = TextLayoutSize(width: Int(size.width), height: Int(size.height))
    }
    
    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }
}

