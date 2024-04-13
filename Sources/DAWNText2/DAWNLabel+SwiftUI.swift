import SwiftUI
import os

@MainActor
fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public struct Label: UIViewRepresentable {
    public init(
        attributedString: AttributedString
    ) {
        self.attributedString = attributedString
    }

    let attributedString: AttributedString
    
    public func makeUIView(context: Context) -> UIViewType {
        DAWNLabel()
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.numberOfLines = context.environment.lineLimit ?? 0
        uiView.openURLAction = context.environment.openURL
        var attributedString = attributedString
        attributedString.font = context.environment.font
        uiView.attributedText = try! NSAttributedString(
            attributedString,
            including: \.uiKit
        )
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: DAWNLabel, context: Context) -> CGSize? {
        let size = proposal.replacingUnspecifiedDimensions(by: .zero)
        let roundedSize = CGSize(width: size.width.rounded(.down), height: size.height.rounded(.up))
        return uiView.sizeThatFits(roundedSize)
    }
}
