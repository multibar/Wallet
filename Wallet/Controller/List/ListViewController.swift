import UIKit
import CoreKit
import NetworkKit
import InterfaceKit
import OrderedCollections

public class ListViewController: BaseViewController {
    public let header = Label()
    public private(set) lazy var list = List(with: self, in: content)
    public override var navBarItems: [NavigationController.Bar.Item] {
        let attributes: Attributes = .attributes(for: .title(size: .medium), color: .xFFFFFF, lineBreak: .byTruncatingMiddle)
        switch route.destination {
        case .add(let stage):
            header.set(text: stage.title, attributes: attributes)
            var items: [NavigationController.Bar.Item] = [.view(header, attributes: attributes, position: .middle)]
            switch stage {
            case .coins:
                items.append(.icon(.bar_scan, attributes: attributes, position: .right, width: 24))
            default:
                break
            }
            return items
        case .wallets(let coin):
            header.alpha = 0.0
            header.set(text: coin.info.title, attributes: attributes)
            return [
                .view(header, attributes: attributes, position: .middle),
                .icon(.bar_scan, attributes: attributes, position: .right, width: 24)
            ]
        default:
            return super.navBarItems
        }
    }
    public override var navBarStyle: NavigationController.Bar.Style {
        switch route.destination {
        default:
            return NavigationController.Bar.Style(background: .blur(.x151A26),
                                                  attributes: .attributes(for: .title(size: .small), color: .xFFFFFF),
                                                  separator: .color(.x8B93A1_20),
                                                  insets: .insets(top: 0, left: 16, right: 16, bottom: 0),
                                                  spacing: NavigationController.Bar.Style.Spacing(left: 16, right: 16))
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
        case .add(let stage):
            switch stage {
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
            case .reload:
                list.set(sections: await order.sections, animated: await !order.instantaneous)
            case .store, .rename, .delete, .decrypt:
                break
            }
            guard let failure = await order.failures.first else { break }
            show(failure: failure, from: store, soft: true)
        case .failed:
            guard let failure = await order.failures.first else { break }
            show(failure: failure, from: store, soft: false)
        default:
            break
        }
    }
    public override func update(trait collection: UITraitCollection) {
        super.update(trait: collection)
        list.update(trait: collection)
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
            View.animate(duration: 0.125,
                         options: [.allowUserInteraction],
                         animations: {
                self.header.alpha = offset.alpha
            })
        }
    }
}
extension ListViewController {
    @MainActor
    private func show(failure: Network.Failure, from store: Store, soft: Bool) {
        switch failure {
        case .finished, .cancelled, .skip:
            break
        default:
            let alert = UIAlertController(title: "Error", message: failure.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                store.order(.reload)
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
    }
}
