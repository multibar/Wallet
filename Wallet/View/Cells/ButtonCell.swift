import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Cell {
    public class Button: Cell {
        public override class var identifier: String {
            return "buttonCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(top: 0, left: 32, right: 32, bottom: 0)
        }
        
        private let lock = UIImageView(image: .icon_lock)
        private let title = Label()
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            lock.hidden = true
            title.clear()
        }
        public func configure(with route: Route) {
            var title: String?
            var color: UIColor?
            switch route.destination {
            case .add(let stage):
                switch stage {
                case .store(let store):
                    switch store {
                    case .location:
                        title = "STORE"
                        color = .xFFFFFF_05
                    case .recovery(_, let location):
                        switch location {
                        case .cloud:
                            let authorized = Network.Manager.shared.state == .authorized
                            title = "CLOUD"
                            color = authorized ? .x58ABF5 : .xFFFFFF_05
                            alpha = authorized ? 1.0 : 0.33
                            lock.hidden = authorized
                        case .keychain:
                            title = "KEYCHAIN"
                            color = .xFFFFFF_05
                        }
                    }
                case .create:
                    title = "CREATE"
                    color = .x58ABF5
                case .import:
                    title = "IMPORT"
                    color = .xFFFFFF_05
                default:
                    break
                }
            default:
                break
            }
            self.title.set(text: title, attributes: .attributes(for: .text(size: .medium, family: .mono), color: .xFFFFFF, alignment: .center))
            self.content.color = color
        }
        
        public override func setup() {
            super.setup()
            lock.hidden = true
            content.corner(radius: 8)
            layout()
        }
        private func layout() {
            lock.auto = false
            title.auto = false
            
            content.add(lock)
            content.add(title)
            
            lock.aspect(ratio: 24)
            lock.centerY(to: content.centerY)
            lock.right(to: content.right, constant: 16)
            title.box(in: content)
        }
    }
}
