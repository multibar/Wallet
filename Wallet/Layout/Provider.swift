/// About containers.
/// When pushing a new ViewController to Navigation Stack,
/// the just created instance of ViewController calls store
/// for pre-loaded sections that contains "container" section,
/// which is empty section that serves as a container for
/// upcoming cargo. After cargo is received, a new portion
/// of data from server / cache should be ready and
/// ViewController receives and displays it.
/// That way, we only need the very first Transitionable cell.

import UIKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension List {
    //MARK: Entry
    internal func provide() {
        layoutProvider()
        sourceProvider()
        behaviourProvider()
    }
    
    //MARK: Layout
    fileprivate func layoutProvider() {
        set(layout: Layout.Provider(style: { section, frame in
            switch section.template {
            case .tabs:
                return .grid(insets: .insets(top: 16, left: 16, right: 16, bottom: 16),
                             mode: .automatic(minSpacing: 16, indent: .absolute(16)),
                             size: { _ in
                    return CGSize(w: 56, h: 56)
                })
            case .auto:
                return .vertical(height: { item in
                    switch item.template {
                    case .tab:
                        return .absolute(56)
                    case .coin:
                        return .absolute(88)
                    case .quote:
                        return .absolute(64)
                    case .text:
                        return .automatic
                    case .button:
                        return .absolute(56)
                    case .loader:
                        return .absolute(56)
                    case .spacer(let height):
                        return .absolute(height)
                    }
                }, separator: .spacer(8))
            }
        }, header: { section, frame in
            switch section.header {
            case .coin:
                return .absolute(56)
            case .title:
                return .automatic
            case .spacer(let height):
                return .absolute(height)
            case .none:
                return nil
            }
        }, footer: { section, frame in
            switch section.footer {
            case .perks:
                return .absolute(24)
            case .spacer(let height):
                return .absolute(height)
            case .button:
                return nil
            case .none:
                return nil
            }
        }), animated: false)
    }
    
    //MARK: Source
    fileprivate func sourceProvider() {
        set(source: Source.Provider(cell: { [weak self] indexPath, item, section in
            guard let self else { return nil }
            var cell: Cell?
            switch item.template {
            case .tab(let item):
                let _cell = self.dequeue(cell: Cell.Tab.self, for: indexPath)
                _cell?.configure(with: item)
                cell = _cell
            case .coin(let item):
                let _cell = self.dequeue(cell: Cell.Coin.Listed.self, for: indexPath)
                _cell?.configure(with: item)
                cell = _cell
            case .quote(let coin):
                let _cell = self.dequeue(cell: Cell.Quote.self, for: indexPath)
                _cell?.configure(with: coin)
                cell = _cell
            case .text(let text):
                let _cell = self.dequeue(cell: Cell.Text.self, for: indexPath)
                _cell?.configure(with: text)
                cell = _cell
            case .button(let route):
                let _cell = self.dequeue(cell: Cell.Button.self, for: indexPath)
                _cell?.configure(with: route)
                cell = _cell
            case .loader:
                cell = self.dequeue(cell: Cell.Loader.self, for: indexPath)
            case .spacer:
                cell = self.dequeue(cell: Cell.self, for: indexPath)
            }
            cell?.list = self
            if let cell = cell as? Transitionable, let container = cell.container, self.containerA == nil {
                self.containerA = container
            }
            return cell
        }, header: { [weak self] index, section in
            guard let self else { return nil }
            var header: Header?
            switch section.header {
            case .coin(let coin):
                let boundary = Header.Coin()
                boundary.configure(with: coin)
                header = boundary
            case .title(let title, _):
                let boundary = Header.Title()
                boundary.configure(with: title.text, size: title.size)
                header = boundary
            case .spacer:
                header = Header()
            case .none:
                return nil
            }
            header?.list = self
            if let header = header as? Transitionable, let container = header.container, self.containerA == nil {
                self.containerA = container
            }
            return header
        }, footer: { [weak self] index, section in
            guard let self else { return nil }
            var footer: Footer?
            switch section.footer {
            case .perks(let coin):
                let boundary = Footer.Perks()
                boundary.configure(with: coin)
                return boundary
            case .spacer:
                footer = Footer()
            case .button:
                return nil
            case .none:
                return nil
            }
            footer?.list = self
            if let footer = footer as? Transitionable, let container = footer.container, self.containerA == nil {
                self.containerA = container
            }
            return footer
        }), animated: false)
    }
    
    //MARK: Behaviour
    fileprivate func behaviourProvider() {
        set(behaviour: Behaviour.Provider(multiselection: { _ in return true }))
    }
}
