import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Footer {
    public class Perks: Footer {
        public override class var identifier: String {
            return "perksFooter"
        }
        
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
            perks.clear()
        }
        
        public func configure(with coin: Coin) {
            perks.append(coin.perks.compactMap({
                let perk = UIImageView(image: $0.icon)
                perk.width(24)
                return perk
            }))
        }
        
        public override func setup() {
            super.setup()
            layout()
        }
        
        private func layout() {
            perks.auto = false
            content.add(perks)
            perks.top(to: content.top)
            perks.centerX(to: content.centerX)
            perks.bottom(to: content.bottom)
        }
    }
}
