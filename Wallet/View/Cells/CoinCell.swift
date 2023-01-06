import UIKit
import CoreKit
import LayoutKit
import InterfaceKit

extension Cell {
    public struct Coin {}
}

extension Cell.Coin {
    public class Add: Cell {
        public override class var identifier: String {
            return "addCoinCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(left: 16, right: 16)
        }
        
        private let icon = Icon()
        private let title = Label(lines: 2)
        private let perks: Stack = {
            let stack = Stack()
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.distribution = .fill
            stack.spacing = 8
            return stack
        }()
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            icon.clear()
            title.clear()
            perks.clear()
        }
        
        public func configure(with coin: CoreKit.Coin) {
            icon.load(from: coin.icons?.small?.url)
            title.set(text: coin.info.title, attributes: .attributes(for: .text(size: .large), color: .xFFFFFF))
            perks.append(coin.perks.compactMap({
                let perk = UIImageView(image: $0.icon)
                perk.width(24)
                return perk
            }))
        }
        public override func set(highlighted: Bool, animated: Bool = true) {
            let icons = [icon, perks]
            View.animate(duration: 0.5,
                         spring: 1.0,
                         velocity: 0.5,
                         options: [.allowUserInteraction]) {
                icons.forEach({$0.transform = highlighted ? .scale(to: 1.1) : .identity})
                self.content.transform = highlighted ? .scale(to: 0.95) : .identity
            }
        }
        
        public override func setup() {
            super.setup()
            setupUI()
            layout()
        }
        private func setupUI() {
            icon.corner(radius: 16)
            icon.color = .xEEEFEF
            content.corner(radius: 16)
            content.color = .xFFFFFF_05
        }
        private func layout() {
            icon.auto = false
            title.auto = false
            perks.auto = false
            
            content.add(icon)
            content.add(title)
            content.add(perks)
                        
            icon.aspect(ratio: 56)
            icon.top(to: content.top, constant: 16)
            icon.left(to: content.left, constant: 16)
            
            title.centerY(to: icon.centerY)
            title.left(to: icon.right, constant: 16)
            
            perks.centerY(to: icon.centerY)
            perks.left(to: title.right, constant: 16)
            perks.right(to: content.right, constant: 16)
            perks.height(24)
        }
    }
}
