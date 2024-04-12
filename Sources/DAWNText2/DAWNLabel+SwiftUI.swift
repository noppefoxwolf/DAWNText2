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
        uiView.backgroundColor = .tertiarySystemBackground
        uiView.numberOfLines = context.environment.lineLimit ?? 0
        uiView.attributedText = try! NSAttributedString(
            attributedString,
            including: \.uiKit
        )
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: DAWNLabel, context: Context) -> CGSize? {
        let width = proposal.width ?? 0
        let height = proposal.height ?? 0
        return uiView.sizeThatFits(CGSize(width: width, height: height))
    }
}
