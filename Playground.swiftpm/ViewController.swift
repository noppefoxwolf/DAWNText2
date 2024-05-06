import UIKit
import SwiftUI
import DAWNText2

enum Section: Int {
    case items
}

struct Item: Hashable {
    let id: UUID = UUID()
    let attributedString: AttributedString
}

final class ViewController: UITableViewController {
    lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(
        tableView: tableView,
        cellProvider: { [unowned self] (tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.contentConfiguration = UIHostingConfiguration(content: {
                DAWNText2.TextView(item.attributedString)
            })
            return cell
        }
    )
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        _ = dataSource
        
        snapshot.appendSections([.items])
        //snapshot.appendItems((0..<100).map({ _ in
        snapshot.appendItems((0..<10).map({ _ in
//            let tokenCount = (1...30).randomElement()!
//            var attr = AttributedString()
//            for _ in 0..<tokenCount {
//                attr += AttributedString("Hello, World!!")
//            }
            /// めんどそうが表示されない
            let markdown = """
            家から申請できないんだ…

            めんどそう
            """
            /// 気がしてきたが途切れる
            let markdown2 = """
            *ハンバーガー食べれば食べるほどポテトそんなに要らない気がしてきた*
            """
            
            let markdown3 = """
            [#きつねかわいい](https://google.com) [#DAWN](https://apple.com) 個人的にはプロフに飛んだらプロフ＋ポストが最初から見れた方が好き（固定ポストだけでもOK）
            あとプロフ編集が画像1枚目みたいに充実すると嬉しい
            [#mastodon](https://mstdn.jp)
            あ！あとALT書くとこもうちょい広い方（もしくは書いた分だけ広がる）が書きやすいかも
            画像2枚目、検索する時この[二つ](https://seconds.jp)どう違うのか分からないので一言説明つけて欲しい（未だにどう違うのかよく分からない）
            あぁ〜あと下書き一覧から消す時スワイプで消すやり方もあった方が一件だけ消す時楽だと思う
            今気になるのはこのくらいかなぁ
            ストリーミングも楽しみに待ってる🦊
            """
            
            let markdown4 = "user_1"
            
            let markdown5 = "See also [Here](https://apple.com)"
            
            let attachmentAttr = AttributedString(NSAttributedString(attachment: UISwitchAttachment()))
            
            var attr = try! AttributedString(
//                markdown: [markdown2].randomElement()!,
//                markdown: [markdown3].randomElement()!,
//                markdown: markdown4,
//                markdown: markdown5,
                markdown: [markdown, markdown2, markdown3, markdown4, markdown5].randomElement()!,
                including: \.uiKit,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            ) + attachmentAttr
            attr.foregroundColor = UIColor.label
            
            return Item(attributedString: attr)
        }), toSection: .items)
        
        dataSource.apply(snapshot)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.window!.tintColor = .red
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIHostingController(rootView: Text("hello"))
        navigationController?.pushViewController(vc, animated: true)
    }
}

final class UISwitchAttachment: NSTextAttachment {
    override init(data contentData: Data?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
        allowsTextAttachmentView = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewProvider(for parentView: UIView?, location: any NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
        UISwitchAttachmentViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
    }
}

final class UISwitchAttachmentViewProvider: NSTextAttachmentViewProvider {
    
    override init(textAttachment: NSTextAttachment, parentView: UIView?, textLayoutManager: NSTextLayoutManager?, location: any NSTextLocation) {
        super.init(textAttachment: textAttachment, parentView: parentView, textLayoutManager: textLayoutManager, location: location)
        tracksTextAttachmentViewBounds = true
    }
    
    override func loadView() {
        view = UISwitch()
    }
}

struct TextView: UIViewRepresentable {
    let attributedText: AttributedString
    
    func makeUIView(context: Context) -> UITextView {
        UITextView()
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.isEditable = false
        uiView.attributedText = NSAttributedString(attributedText)
    }
}
