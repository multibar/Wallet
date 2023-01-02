import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

public class WalletViewController: ListViewController {
    public override var navBarItems: [NavigationController.Bar.Item] {
        let attributes: Attributes = .attributes(for: .title(size: .medium), color: .xFFFFFF, lineBreak: .byTruncatingMiddle)
        switch route.destination {
        case .wallet(let wallet):
            header.alpha = 0.0
            header.set(text: wallet.title, attributes: attributes)
            return [
                .view(header, attributes: attributes, position: .middle),
                .icon(.bar_edit, attributes: attributes, position: .right, width: 24, action: { [weak self] in
                    self?.edit()
                }),
                .icon(.bar_trash, attributes: attributes, position: .right, width: 24, action: { [weak self] in
                    self?.store.order(.delete(wallet: wallet))
                })
            ]
        default:
            return super.navBarItems
        }
    }
    public override var multibar: Bool {
        return false
    }
    public override var forcePresent: Bool {
        return true
    }

    public override func receive(order: Store.Order, from store: Store) async {
        switch await order.status {
        case .accepted, .completed:
            switch order.operation {
            case .rename:
                switch await order.package {
                case .wallet(let wallet):
                    store.set(route: Route(to: .wallet(wallet)), load: true)
                    (previous as? ListViewController)?.store.expire()
                default:
                    await super.receive(order: order, from: store)
                }
            default:
                await super.receive(order: order, from: store)
            }
        default:
            await super.receive(order: order, from: store)
        }
    }

    private func edit() {
        guard let wallet else { return }
        let alert = UIAlertController(title: wallet.title, message: nil, preferredStyle: .alert)
        alert.view.tint = .x58ABF5
        alert.addTextField { textField in
            print()
        }
        alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self, weak alert] _ in
            guard let title = alert?.textFields?.first?.text,
                  !title.empty,
                  !title.replacingOccurrences(of: " ", with: "").empty
            else { return }
            self?.store.order(.rename(wallet: wallet, with: title))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

}

extension WalletViewController {
    private var wallet: Wallet? {
        switch route.destination {
        case .wallet(let wallet):
            return wallet
        default:
            return nil
        }
    }
}
