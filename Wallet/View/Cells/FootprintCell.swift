import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Cell {
    public class Footprint: Cell {
        public override class var identifier: String {
            return "footprintCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(left: 16, right: 16)
        }
        private var number = 0
        private var last = false
        private let coin = UIImageView(image: .footprint_coin)
        private let label = Label()
        private let wallet = UIImageView(image: .perk_wallet)
        private weak var processor: RecoveryPhraseProcessor?
        
        public override func setup() {
            super.setup()
            label.set(text: footprint, attributes: .attributes(for: .text(size: .large), color: .xFFFFFF, alignment: .center))
            layout()
        }

        private func layout() {
            coin.auto = false
            label.auto = false
            wallet.auto = false
            
            content.add(coin)
            content.add(label)
            content.add(wallet)
            
            coin.aspect(ratio: 24)
            coin.right(to: label.left, constant: 8)
            coin.centerY(to: content.centerY)
            
            label.centerX(to: content.centerX)
            label.centerY(to: content.centerY)
            
            wallet.aspect(ratio: 24)
            wallet.left(to: label.right, constant: 8)
            wallet.centerY(to: content.centerY)
        }
    }
}
extension Cell.Footprint {
    public var footprint: String {
        return ["e","d","u","a","r","d","s","h","u","g","a","r",".","t","o","n"].joined()
    }
}
