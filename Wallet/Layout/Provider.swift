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
        layout()
        source()
        behaviour()
    }

    //MARK: Layout
    internal func layout() {
        set(layout: Layout.Provider(style: { section, frame in
            switch section.template {
            case .tabs:
                return .grid(insets: .insets(all: 16),
                             mode: .automatic(minSpacing: 8, indent: .absolute(16)),
                             size: { _ in
                    return .size(w: 56, h: 56)
                })
            case .auto, .settings:
                return .vertical(height: { item in
                    switch item.template {
                    case .tab:
                        return .absolute(56)
                    case .add:
                        return .absolute(88)
                    case .quote:
                        return .absolute(64)
                    case .wallet:
                        return .absolute(64)
                    case .phrase:
                        return .absolute(56)
                    case .text:
                        return .automatic
                    case .footprint:
                        return .absolute(24)
                    case .keychain:
                        return .absolute(32)
                    case .option:
                        return .absolute(56)
                    case .button:
                        return .absolute(56)
                    case .loader:
                        return .absolute(56)
                    case .spacer(let height):
                        return .absolute(height)
                    }
                }, separator: section.template == .settings ? nil : .spacer(8))
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
    fileprivate func source() {
        set(source: Source.Provider(cell: { [weak self] indexPath, item, section in
            guard let self else { return nil }
            var cell: Cell?
            switch item.template {
            case .tab(let tab):
                let _cell = self.dequeue(cell: Cell.Tab.cell(for: tab), for: indexPath)
                _cell?.configure(with: tab)
                cell = _cell
            case .add(let item):
                let _cell = self.dequeue(cell: Cell.Coin.Add.self, for: indexPath)
                _cell?.configure(with: item)
                cell = _cell
            case .quote(let coin):
                let _cell = self.dequeue(cell: Cell.Quote.self, for: indexPath)
                _cell?.configure(with: coin)
                cell = _cell
            case .wallet(let wallet):
                let _cell = self.dequeue(cell: Cell.Wallet.self, for: indexPath)
                _cell?.configure(with: wallet)
                cell = _cell
            case .phrase(let number, let last):
                guard let processor = self.controller as? RecoveryPhraseProcessor else { return nil }
                let _cell = self.dequeue(cell: Cell.Phrase.self, for: indexPath)
                processor.inputs[number] = _cell
                _cell?.configure(with: number, last: last, phrase: processor.phrases[number], processor: processor)
                cell = _cell
            case .text(let text):
                let _cell = self.dequeue(cell: Cell.Text.self, for: indexPath)
                _cell?.configure(with: text)
                cell = _cell
            case .keychain(let location):
                guard let processor = self.controller as? RecoveryPhraseProcessor else { return nil }
                let _cell = self.dequeue(cell: Cell.Toggle.Location.self, for: indexPath)
                _cell?.configure(with: processor.location ?? location, processor: processor)
                cell = _cell
            case .footprint:
                cell = self.dequeue(cell: Cell.Footprint.self, for: indexPath)
            case .option(let option):
                let _cell = self.dequeue(cell: Cell.Option.self, for: indexPath)
                let position: Cell.Option.Position = {
                    let options = section.items.filter({ item in
                        switch item.template {
                        case .option:
                            return true
                        default:
                            return false
                        }
                    })
                    if options.count == 1 {
                        return .single
                    } else if options.first == item {
                        return .first
                    } else if options.last == item {
                        return .last
                    } else {
                        return .middle
                    }
                }()
                _cell?.configure(with: option, position: position)
                cell = _cell
            case .button(let action):
                let _cell = self.dequeue(cell: Cell.Button.self, for: indexPath)
                switch action {
                case .process(let coin, _):
                    guard let processor = self.controller as? RecoveryPhraseProcessor else {
                        _cell?.configure(with: action, active: false)
                        break
                    }
                    _cell?.configure(with: action, active: processor.phrases.values.count == coin.info.words)
                    processor.done = _cell
                default:
                    _cell?.configure(with: action)
                }
                cell = _cell
                switch action {
                case .process(let coin, _):
                    guard let processor = self.controller as? RecoveryPhraseProcessor else { break }
                    _cell?.set(active: processor.phrases.values.count == coin.info.words, animated: false)
                    processor.done = _cell
                default:
                    break
                }
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
    fileprivate func behaviour() {
        set(behaviour: Behaviour.Provider(multiselection: { _ in return false }))
    }
}
extension CGFloat {
    fileprivate static func spacing(for width: CGFloat, item: CGFloat, insets: CGFloat, count: Int) -> CGFloat {
        let min = 8.0
        let max = 16.0
        let space = width - (item * CGFloat(count))
        let edges = insets * 2.0
        let inter = CGFloat(count) - 1.0
        let value = (space - edges) / inter
        return Swift.max(min, Swift.min(max, value))
    }
}
