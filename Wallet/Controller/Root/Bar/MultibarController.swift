import UIKit
import CoreKit
import NetworkKit
import InterfaceKit
import OrderedCollections

public protocol MultibarController: ViewController {
    var viewController: ViewController? { get }
    var viewControllers: [ViewController] { get set }
    func set(loading: Bool, animated: Bool, completion: (() -> Void)?)
}

public class Multibar: ListViewController {
    public weak var controller: MultibarController?
    
    public func set(selected route: Route) {
        guard let section = list.source.sections.first(where: {$0.template == .tabs}) else { return }
        section.items.forEach({
            if $0.route == route {
                list.select(item: $0, position: nil, animated: true)
            } else {
                list.deselect(item: $0, animated: true)
            }
        })
    }
    public override func receive(order: Store.Order, from store: Store) async {
        switch await order.status {
        case .created, .accepted:
            controller?.set(loading: true, animated: false, completion: nil)
        case .cancelled, .completed, .failed:
            controller?.set(loading: false, animated: true, completion: nil)
        }
        await super.receive(order: order, from: store)
        let sections = await order.sections.filter({$0.template == .tabs}).flatMap({$0.items})
        controller?.viewControllers = sections.compactMap({
            switch $0.template {
            case .tab(let tab):
                switch tab.route.destination {
                case .wallets:
                    return NavigationController(viewController: ListViewController(route: tab.route, load: false))
                default:
                    return nil
                }
            default:
                return nil
            }
        })
    }
    public override func process(route: Route) {
        controller?.process(route: route)
    }
}
extension Multibar {
    public func reset() {
        scroll?.offset(to: .zero)
    }
}
extension Multibar {
    public enum Position {
        case top
        case middle
        case bottom
        case headed
        case hidden
        
        public var descended: Bool {
            switch self {
            case .hidden, .headed, .bottom:
                return true
            default:
                return false
            }
        }
        public func values(for view: UIView, traits: UITraitCollection) -> (top: CGFloat, grab: CGFloat) {
            let safe = view.safeAreaInsets
            let compact = traits.vertical == .compact
            switch self {
            case .top:
                return (top: compact ? -view.frame.height : -view.frame.height + safe.top + 8, grab: 8)
            case .middle:
                return (top: -view.frame.height/2, grab: -8)
            case .bottom:
                return (top: minimal(for: view), grab: -8)
            case .headed:
                return (top: -56, grab: -8)
            case .hidden:
                return (top: 0, grab: 8)
            }
        }
        public func minimal(for view: UIView) -> CGFloat {
            switch self {
            case .hidden:
                return 0
            default:
                let safe = view.safeAreaInsets
                return -16 - (safe.bottom == 0 ? 20 : safe.bottom) - 64
            }
        }
    }
    public enum Preference {
        case none
        case soft
        case linear
        
        public var none: Bool {
            switch self {
            case .none:
                return true
            default:
                return false
            }
        }
        public var soft: Bool {
            switch self {
            case .soft:
                return true
            default:
                return false
            }
        }
        public var linear: Bool {
            switch self {
            case .linear:
                return true
            default:
                return false
            }
        }
    }
}
