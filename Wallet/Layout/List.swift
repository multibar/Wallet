import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit
import OrderedCollections

@MainActor
public class List: Composition.Manager<Store.Section, Store.Item> {
    public weak var controller: ViewController?
    public weak var containerA: Container?
    public weak var containerB: Container?
    
    public var folded: [Store.Section: Bool] = [:]
    
    public required init(with controller: BaseViewController, in content: UIView) {
        self.controller = controller
        super.init(in: content)
        scroll.showsVerticalScrollIndicator = controller.route.destination == .settings
        provide()
    }
    
    public func update(traits: UITraitCollection) {
        reinset()
        layout()
    }
    
    public override func selected(cell: LayoutKit.Cell, with item: Store.Item, in section: Store.Section, for indexPath: IndexPath) {
        deselect(item: item)
        containerB = (cell as? Transitionable)?.container
        switch item.template {
        case .quote, .keychain:
            break
        case .phrase:
            guard let phrase = cell as? Cell.Phrase else { break }
            phrase.begin()
        case .option:
            guard let option = cell as? Cell.Option else { break }
            option.action()
        case .button(let action):
            guard let button = cell as? Cell.Button, button.active else { break }
            switch action {
            case .process(let coin, let location):
                guard let processor = controller as? RecoveryPhraseProcessor else { break }
                processor.process(for: coin, at: location)
            case .route(let route):
                controller?.process(route: route)
            }
        default:
            guard let route = item.route else { break }
            controller?.process(route: route)
        }
    }
    public override func selected(header: Boundary, in section: Section, at index: Int) {
        switch section.header {
        default:
            break
        }
    }
    public override func highlightable(cell: LayoutKit.Cell, with item: Store.Item, in section: Store.Section, for indexPath: IndexPath) -> Bool {
        switch item.template {
        case .tab, .add, .wallet, .option, .button:
            return true
        default:
            return false
        }
    }
    public override func highlightable(header: Boundary, in section: Store.Section, at index: Int) -> Bool {
        return false
    }
    public override func highlightable(footer: Boundary, in section: Store.Section, at index: Int) -> Bool {
        switch section.footer {
        case .button:
            return true
        default:
            return false
        }
    }
    public override func selectable(cell: LayoutKit.Cell, with item: Store.Item, in section: Store.Section, for indexPath: IndexPath) -> Bool {
        switch item.template {
        case .tab:
            return !source.selected(item: item)
        case .add, .quote, .wallet, .phrase, .keychain, .option, .button:
            return true
        case .text, .footprint, .loader, .spacer:
            return false
        }
    }
    public override func selectable(header: Boundary, in section: Section, at index: Int) -> Bool {
        switch section.header {
        default:
            return false
        }
    }
    public override func deselectable(cell: LayoutKit.Cell, with item: Store.Item, in section: Store.Section, for indexPath: IndexPath) -> Bool {
        switch item.template {
        case .tab:
            return false
        default:
            return true
        }
    }
    public override func will(display cell: LayoutKit.Cell, with item: Store.Item, in section: Store.Section, for indexPath: IndexPath) {
        (cell as? Cell.Loader)?.set(loading: true)
    }
    public override func end(display cell: LayoutKit.Cell, with item: Store.Item, in section: Store.Section, for indexPath: IndexPath) {
        (cell as? Cell.Loader)?.set(loading: false)
    }
    public override func scrolled(section: Store.Section?, with offset: CGPoint) {
        let compensated = CGPoint(x: 0, y: offset.y + scroll.insets.top)
        (controller as? ListViewController)?.handle(content: compensated)
        controller?.navBar?.handle(content: compensated)
        controller?.tabViewController?.handle(descended: scroll.descended)
    }
    public override var insets: UIEdgeInsets {
        switch controller?.route.destination {
        case .multibar:
            return .zero
        default:
            let top: CGFloat = {
                var height = controller?.navBar?.frame.height ?? 0
                if height == 0 { height = controller?.navBarStyle.size.estimated ?? 0 }
                if height == 0 { height = 16 }
                height += 16
                height += (controller as? KeyboardHandler)?.keyboard ?? 0
                return height
            }()
            let bottom: CGFloat = {
                var height = controller?.tabViewController?.height ?? 0
                if height <= 0 { height = controller?.view.safeAreaInsets.bottom ?? 0 }
                height += 16
                if ((controller as? KeyboardHandler)?.keyboard) != 0 { height += 8 }
                return height
            }()
            return .insets(top: top, bottom: bottom)
        }
    }
    public override var cells: [LayoutKit.Cell.Type] {
        return [
            Cell.Button.self,
            Cell.Coin.Add.self,
            Cell.Loader.self,
            Cell.Tab.self,
            Cell.Tab.Coin.self,
            Cell.Tab.Action.self,
            Cell.Toggle.Location.self,
            Cell.Text.self,
            Cell.Quote.self,
            Cell.Wallet.self,
            Cell.Phrase.self,
            Cell.Option.self,
            Cell.Footprint.self
        ]
    }
    public override var boundaries: [Boundary.Type] {
        return [
            Header.Coin.self,
            Header.Title.self,
            Footer.Perks.self
        ]
    }
}
extension List {
    public func set(sections: OrderedSet<Store.Section>, animated: Bool = true) {
        folded.removeAll()
        source.snapshot.batch(updates: [.setSections(sections, items: {$0.items})], animation: animated ? .fade : nil)
    }
    public func reinset() {
        scroll.insets = insets
    }
}
extension List {
    public func destroy() {
        visibleCells.forEach({($0 as? Transitionable)?.destroy()})
    }
}
