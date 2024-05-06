import UIKit
import SwiftUI
import DAWNText2

enum Section: Int {
    case items
}

struct Item: Hashable {
    let id: UUID = UUID()
    let attributedString: AttributedString
    let usesDAWNText: Bool
}

final class ViewController: UITableViewController {
    lazy var dataSource = UITableViewDiffableDataSource<Section, Item>(
        tableView: tableView,
        cellProvider: { [unowned self] (tableView, indexPath, item) in
            if item.usesDAWNText {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DAWNTextCell", for: indexPath)
                cell.contentConfiguration = UIHostingConfiguration(content: {
                    DAWNText2.TextView(item.attributedString)
                })
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwiftUITextCell", for: indexPath)
                cell.contentConfiguration = UIHostingConfiguration(content: {
                    SwiftUI.Text(item.attributedString)
                })
                return cell
            }
        }
    )
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    
    var usesDAWNText: Bool = true {
        didSet {
            snapshot.deleteAllItems()
            snapshot.appendSections([.items])
            snapshot.appendItems((0..<10).map({ _ in
                return Item(attributedString: .sample, usesDAWNText: usesDAWNText)
            }), toSection: .items)
            
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DAWNTextCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SwiftUITextCell")
        _ = dataSource
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIHostingController(rootView: DAWNText2.TextView("hello"))
        navigationController?.pushViewController(vc, animated: true)
    }
}

