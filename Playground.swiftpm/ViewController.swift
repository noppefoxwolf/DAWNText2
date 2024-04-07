import UIKit
import DAWNText2

final class ViewController: UIViewController {
    let label = DAWNLabel()
    let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        func makeAttributedText() -> NSAttributedString {
            let attributedText = NSMutableAttributedString()
            attributedText.append(NSAttributedString(string: "Hello, World!", attributes: [.foregroundColor : UIColor.label]))
            attributedText.append(NSAttributedString(string: "🦊"))
            attributedText.append(NSAttributedString(attachment: NSTextAttachment(image: UIImage(systemName: "apple.logo")!.withRenderingMode(.alwaysTemplate))))
            attributedText.append(NSAttributedString(string: "Hello, World!", attributes: [.foregroundColor : UIColor.systemRed]))
            attributedText.append(NSAttributedString(attachment: ToggleTextAttachment()))
            attributedText.append(NSAttributedString(string: "Hello, World!", attributes: [.foregroundColor : UIColor.systemCyan]))
            attributedText.append(NSAttributedString(string: "Hello, World!Hello, World!Hello, World!", attributes: [.foregroundColor : UIColor.systemPink]))
            return attributedText
        }
        
        label.backgroundColor = .red
        label.attributedText = makeAttributedText()
        textView.attributedText = makeAttributedText()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            view.trailingAnchor.constraint(
                equalTo: stackView.safeAreaLayoutGuide.trailingAnchor,
                constant: 20
            ),
        ])
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            label.widthAnchor.constraint(equalToConstant: 353),
        ])
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: label.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            textView.widthAnchor.constraint(equalToConstant: 353),
            textView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}

class ToggleTextAttachment: NSTextAttachment {
    
    init() {
        super.init(data: nil, ofType: nil)
        allowsTextAttachmentView = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewProvider(for parentView: UIView?, location: any NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
        ToggleTextAttachmentViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer!.textLayoutManager,
            location: location
        )
    }
}

class ToggleTextAttachmentViewProvider: NSTextAttachmentViewProvider {
    
    override init(textAttachment: NSTextAttachment, parentView: UIView?, textLayoutManager: NSTextLayoutManager?, location: any NSTextLocation) {
        super.init(textAttachment: textAttachment, parentView: parentView, textLayoutManager: textLayoutManager, location: location)
        tracksTextAttachmentViewBounds = true
    }
    
    override func loadView() {
        view = UISwitch()
    }
}
