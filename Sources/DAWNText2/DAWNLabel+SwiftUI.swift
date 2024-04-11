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
        uiView.numberOfLines = 1
        var attributedString = attributedString
        attributedString.font = .body
        uiView.attributedText = try! NSAttributedString(
            attributedString,
            including: \.uiKit
        )
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: DAWNLabel, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        guard let height = proposal.height else { return nil }
        return uiView.sizeThatFits(CGSize(width: width, height: height))
    }
}
