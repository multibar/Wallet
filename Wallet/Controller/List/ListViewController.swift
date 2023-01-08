import UIKit
import CoreKit
import NetworkKit
import InterfaceKit
import OrderedCollections

public class ListViewController: BaseViewController {
    public let header = Label()
    public private(set) lazy var list = List(with: self, in: content)
    public override var navBarItems: [NavigationController.Bar.Item] {
        let attributes = Attributes.navigation
        switch route.destination {
        case .add(let add):
            header.set(text: add.title, attributes: attributes)
            return [
                .view(header, attributes: attributes, position: .middle)
            ]
        case .wallets(let coin):
            header.alpha = 0.0
            header.set(text: coin.info.title, attributes: attributes)
            return [
                .view(header, attributes: attributes, position: .middle),
                .icon(.bar_profile, attributes: attributes, position: .right, width: 32, action: { [weak self] in
                    self?.tabViewController?.maximize()
                })
            ]
        default:
            return super.navBarItems
        }
    }
    public override var containerA: Container? {
        return list.containerA
    }
    public override var containerB: Container? {
        return list.containerB
    }
    public override var scroll: UIScrollView? {
        return list.scroll
    }
    public override var forcePresent: Bool {
        switch route.destination {
        case .add(let add):
            switch add {
            case .coins:
                return true
            case .coin, .store, .create, .import:
                return false
            }
        default:
            return false
        }
    }
    public override var multibar: Bool {
        switch route.destination {
        case .add:
            return false
        default:
            return true
        }
    }
    public override func receive(order: Store.Order, from store: Store) async {
        switch await order.status {
        case .accepted, .completed:
            switch order.operation {
            case .reload, .decrypt:
                list.set(sections: await order.sections, animated: !order.instantaneous)
            case .store, .rename, .delete:
                break
            }
            guard let failure = await order.failures.first else { break }
            show(error: failure, from: store, order: order, soft: true)
        case .failed:
            guard let failure = await order.failures.first else { break }
            show(error: failure, from: store, order: order, soft: false)
        default:
            break
        }
    }
    public override func update(traits: UITraitCollection) {
        super.update(traits: traits)
        list.update(traits: traits)
    }
    public override func prepare() {
        super.prepare()
        list.set(sections: store.preloaded, animated: false)
    }
    public override func rebuild() {
        super.rebuild()
        list.containerB = nil
    }
    public override func destroy() {
        super.destroy()
        list.destroy()
    }
    public func handle(content offset: CGPoint) {
        switch route.destination {
        case .add:
            break
        default:
            View.animate(duration: 0.125, animations: {
                self.header.alpha = offset.alpha
            })
        }
    }
}
extension ListViewController {
    @MainActor
    private func show(error: Error, from store: Store, order: Store.Order, soft: Bool) {
        switch error {
        case let failure as Network.Failure:
            switch failure {
            case .finished, .cancelled, .skip:
                break
            default:
                let alert = UIAlertController(title: "Error", message: failure.description, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                    store.retry(order)
                }))
                alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { _ in
                    UIPasteboard.general.string = failure.copy
                }))
                alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { [weak self] _ in
                    guard !soft else { return }
                    self?.list.source.snapshot.batch(updates: [.setSections([], items: {$0.items})], animation: nil)
                }))
                present(alert, animated: true)
            }
        default:
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                store.retry(order)
            }))
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { [weak self] _ in
                guard !soft else { return }
                self?.list.source.snapshot.batch(updates: [.setSections([], items: {$0.items})], animation: nil)
            }))
            present(alert, animated: true)
        }
    }
}
