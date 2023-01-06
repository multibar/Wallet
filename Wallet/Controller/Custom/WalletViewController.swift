import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

public class WalletViewController: ListViewController {
    private let notificator = Haptic.Notificator()
    public override var navBarItems: [NavigationController.Bar.Item] {
        let attributes: Attributes = .attributes(for: .title(size: .medium), color: .xFFFFFF, lineBreak: .byTruncatingMiddle)
        switch route.destination {
        case .wallet(let wallet):
            header.alpha = 0.0
            header.set(text: wallet.title, attributes: attributes)
            return [
                .view(header, attributes: attributes, position: .middle),
                .icon(.bar_edit, attributes: attributes, position: .right, width: 32, action: { [weak self] in
                    self?.edit()
                }),
                .icon(.bar_trash, attributes: attributes, position: .right, width: 32, action: { [weak self] in
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
                notificator.prepare()
                notificator.generate(.success)
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
            self?.notificator.prepare()
            guard let title = alert?.textFields?.first?.text,
                  !title.empty,
                  !title.replacingOccurrences(of: " ", with: "").empty
            else { return }
            self?.notificator.generate(.success)
            self?.store.order(.rename(wallet: wallet, with: title))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    private func delete() {
        let alert = UIAlertController(title: "Delete wallet?", message: "Your key and encrypted phrase will be erased.", preferredStyle: .alert)
        alert.view.tint = .x58ABF5
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak self] _ in
            self?.passcode(action: .verify(.delete))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    private func unlock() {
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
            self?.passcode(action: .verify(.decrypt))
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
extension WalletViewController: PasscodeDelegate {
    public func passcode(controller: PasscodeViewController,
                         got result: PasscodeViewController.Result,
                         for action: PasscodeViewController.Action) {
        guard let wallet else { return }
        switch action {
        case .verify(let verify):
            switch verify{
            case .delete:
                store.order(.delete(wallet: wallet))
            case .decrypt:
                store.order(.decrypt(wallet: wallet))
            default:
                break
            }
        default:
            break
        }
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
