import QuartzCore

open class ContentLayer: CALayer {
    open override class func defaultAction(forKey event: String) -> (any CAAction)? {
        NSNull()
    }
}
