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
                VStack {
                    DAWNText2.TextView(item.attributedString)
                    SwiftUI.Text(item.attributedString)
                }
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
        snapshot.appendItems((0..<10).map({ _ in
            return Item(attributedString: .sample)
        }), toSection: .items)
        
        dataSource.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIHostingController(rootView: DAWNText2.TextView("hello"))
        navigationController?.pushViewController(vc, animated: true)
    }
}

