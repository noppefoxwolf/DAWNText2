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
                DAWNText2.Label(attributedString: item.attributedString)
                //Text(item.attributedString)
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
        snapshot.appendItems((0..<100).map({ _ in
            let tokenCount = (1...30).randomElement()!
            var attr = AttributedString()
            for _ in 0..<tokenCount {
                attr += AttributedString("Hello, World!!")
            }
            return Item(attributedString: attr)
        }), toSection: .items)
        
        dataSource.apply(snapshot)
    }
}
