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
                    self?.delete()
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
        case .completed:
            switch order.operation {
            case .rename:
                switch await order.package {
                case .wallet(let wallet):
                    store.set(route: Route(to: .wallet(wallet)), load: true)
                    (previous as? ListViewController)?.store.expire()
                default:
                    await super.receive(order: order, from: store)
                }
            case .delete:
                Haptic.prepare()
                Haptic.notification(.success).generate()
                tabViewController?.bar.store.order(.reload)
            default:
                await super.receive(order: order, from: store)
            }
        case .cancelled, .failed:
            await super.receive(order: order, from: store)
        default:
            await super.receive(order: order, from: store)
        }
    }

    private func edit() {
        guard let wallet else { return }
        let alert = UIAlertController(title: wallet.title, message: nil, preferredStyle: .alert)
        alert.view.tint = .x58ABF5
        alert.addTextField { textField in
            textField.font = Attributes.attributes(for: .text(size: .large)).typography.font
            textField.textColor = .xFFFFFF
            textField.tintColor = .x58ABF5
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.keyboardAppearance = .dark
            textField.autocapitalizationType = .sentences
            textField.enablesReturnKeyAutomatically = true
        }
        alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self, weak alert] _ in
            Haptic.prepare()
            guard let title = alert?.textFields?.first?.text,
                  !title.empty,
                  !title.replacingOccurrences(of: " ", with: "").empty
            else { return }
            Haptic.notification(.success).generate()
            self?.store.order(.rename(wallet: wallet, with: title))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    private func delete() {
        guard let wallet else { return }
        let alert = UIAlertController(title: "Delete wallet?", message: "Your key and encrypted phrase will be erased.", preferredStyle: .alert)
        alert.view.tint = .x58ABF5
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
            self?.store.order(.delete(wallet: wallet))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    private func unlock() {
        guard let wallet else { return }
        let alert = UIAlertController(title: "Private Key", message: "Enter your private key to decrypt secret phrase.", preferredStyle: .alert)
        alert.view.tint = .x58ABF5
        alert.addTextField { textField in
            textField.font = Attributes.attributes(for: .text(size: .large, family: .mono)).typography.font
            textField.textColor = .xFFFFFF
            textField.tintColor = .x58ABF5
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.textContentType = .password
            textField.keyboardAppearance = .dark
            textField.autocapitalizationType = .none
            textField.enablesReturnKeyAutomatically = true
        }
        alert.addAction(UIAlertAction(title: "Unlock", style: .default, handler: { [weak self] _ in
            Haptic.prepare()
            Haptic.notification(.success).generate()
            self?.store.order(.decrypt(wallet: wallet))
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
