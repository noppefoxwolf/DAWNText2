import UIKit
import SwiftUI

public struct TextView: UIViewRepresentable {
    public init(
        _ attributedString: AttributedString
    ) {
        self.attributedString = attributedString
    }

    let attributedString: AttributedString

    public func makeUIView(context: Context) -> DAWNTextView {
        DAWNTextView()
    }

    public func updateUIView(_ uiView: DAWNTextView, context: Context) {
        context.coordinator.openURLAction = context.environment.openURL
        uiView.numberOfLines = context.environment.lineLimit ?? 0
        
        
        switch context.environment.truncationMode {
        case .head:
            uiView.lineBreakMode = .byTruncatingHead
        case .middle:
            uiView.lineBreakMode = .byTruncatingMiddle
        case .tail:
            uiView.lineBreakMode = .byTruncatingTail
        @unknown default:
            uiView.lineBreakMode = .byTruncatingTail
        }
        var attributedString = attributedString

        // context.environment.font is only SwiftUI
        attributedString.font = context.environment.uiFont
        uiView.delegate = context.coordinator
        let attributedText = try! NSAttributedString(
            attributedString,
            including: \.uiKit
        )
        uiView.attributedText = attributedText
    }
    
    public static func dismantleUIView(_ uiView: DAWNTextView, coordinator: Coordinator) {
    }

    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: DAWNTextView, context: Context)
        -> CGSize?
    {
        let size = proposal.replacingUnspecifiedDimensions(by: .zero)
        return uiView.sizeThatFits(size)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public final class Coordinator: DAWNTextViewDelegate {
        var openURLAction: OpenURLAction?
        
        public func textView(
            _ textView: DAWNTextView,
            primaryActionFor textItem: DAWNTextItem,
            defaultAction: UIAction
        ) -> UIAction? {
            switch textItem.content {
            case .link(let url):
                return openURLAction.map({ action in
                    UIAction(handler: { _ in action(url) })
                })
            case .textAttachment:
                return nil
            case .tag:
                return nil
            default:
                return nil
            }
        }
    }
}

