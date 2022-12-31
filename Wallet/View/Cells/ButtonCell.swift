import UIKit
import CoreKit
import LayoutKit
import InterfaceKit

extension Cell {
    public class Button: Cell {
        public override class var identifier: String {
            return "buttonCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(top: 0, left: 32, right: 32, bottom: 0)
        }
        
        private let title = Label()
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            title.clear()
        }
        public func configure(with route: Route) {
            switch route.destination {
            case .add(let stage):
                switch stage {
                case .store:
                    title.set(text: "STORE", attributes: .attributes(for: .text(size: .medium, family: .mono), color: .xFFFFFF, alignment: .center))
                    content.color = .xFFFFFF_05
                case .create:
                    title.set(text: "CREATE", attributes: .attributes(for: .text(size: .medium, family: .mono), color: .xFFFFFF, alignment: .center))
                    content.color = .x58ABF5
                case .import:
                    title.set(text: "IMPORT", attributes: .attributes(for: .text(size: .medium, family: .mono), color: .xFFFFFF, alignment: .center))
                    content.color = .xFFFFFF_05
                default:
                    break
                }
            default:
                break
            }
        }
        
        public override func setup() {
            super.setup()
            content.corner(radius: 8)
            layout()
        }
        private func layout() {
            title.auto = false
            content.add(title)
            title.box(in: content)
        }
    }
}
