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
    
    public func update(trait collection: UITraitCollection) {
        reinset()
    }
    
    public override func selected(cell: LayoutKit.Cell, with item: Store.Item, in section: Store.Section, for indexPath: IndexPath) {
        deselect(item: item)
        containerB = (cell as? Transitionable)?.container
        switch item.template {
        case .quote:
            break
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
        case .tab, .coin, .button:
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
        case .coin:
            return true
        case .quote:
            return true
        case .button:
            return true
        case .text, .loader, .spacer:
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
                return height
            }()
            return .insets(top: top,
                           left: 0,
                           right: 0,
                           bottom: (controller?.tabViewController?.height ?? 0) + 16)
        }
    }
    public override var cells: [LayoutKit.Cell.Type] {
        return [
            Cell.Button.self,
            Cell.Coin.Listed.self,
            Cell.Loader.self,
            Cell.Tab.self,
            Cell.Text.self,
            Cell.Quote.self
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