import UIKit
import CoreKit
import LayoutKit
import NetworkKit
import InterfaceKit

extension Cell {
    public class Quote: Cell, Observer {
        public typealias Value = CoreKit.Coin
        
        public override class var identifier: String {
            return "quoteCell"
        }
        public override var insets: UIEdgeInsets {
            return .insets(left: 16, right: 16)
        }
        
        private let icon = ImageView(format: .square)
        private let price = Label()
        private let arrow = UIImageView()
        private let change = Label()
        private let stack: Stack = {
            let stack = Stack()
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.distribution = .fill
            stack.spacing = 1
            return stack
        }()
        private let market = UIImageView(image: .icon_market)
        
        private weak var observable: Store.Observable<CoreKit.Coin>?
        private var coin: CoreKit.Coin? {
            return observable?.value
        }
        
        public override func prepareForReuse() {
            super.prepareForReuse()
            icon.clear()
            price.clear()
            change.clear()
            arrow.clear()
            stack.color = nil
            observable = nil
        }
        
        public func configure(with observable: Store.Observable<CoreKit.Coin>) {
            self.observable = observable
            observable.observer = self
            fetch()
        }
        public func fetch() {
            guard let coin, let quote = coin.quotes.preferred else { return }
            icon.load(from: coin.icons?.small?.url)
            price.set(text: quote.fiat.info.sign + quote.price,
                      attributes: .attributes(for: .text(size: .large, family: .mono), color: .xFFFFFF),
                      animated: true)
            change.set(text: quote.change.value,
                       attributes: .attributes(for: .text(size: .small, family: .mono), color: .xFFFFFF),
                       animated: true)
            arrow.image = quote.change.growth == .positive ? .arrow_up : .arrow_down
            View.animate(duration: 0.33, spring: 1.0, velocity: 1.0) {
                self.stack.color = quote.change.growth == .none ? .xFFFFFF_05 : quote.change.growth == .positive ? .x5CC489 : .xF36655
            }
        }
        
        public override func setup() {
            super.setup()
            market.interactive = true
            market.add(gesture: .tap(target: self, action: #selector(_market)))
            setupUI()
            layout()
        }
        private func setupUI() {
            icon.corner(radius: 16)
            stack.corner(radius: 4)
            content.corner(radius: 16)
            content.color = .xFFFFFF_05
        }
        private func layout() {
            let percent = Label(); percent.set(text: "%", attributes: .attributes(for: .custom(size: 11, weight: .heavy), color: .xFFFFFF))
            let right = View(); right.width(2)
            
            icon.auto = false
            price.auto = false
            stack.auto = false
            market.auto = false
            
            arrow.width(16)
            
            stack.append(arrow)
            stack.append(change)
            stack.append(percent)
            stack.append(right)
            
            content.add(icon)
            content.add(price)
            content.add(stack)
            content.add(market)
            
            icon.aspect(ratio: 40)
            icon.centerY(to: content.centerY)
            icon.left(to: content.left, constant: 16)
            
            price.top(to: icon.top)
            price.left(to: icon.right, constant: 16)
            price.right(to: market.left, constant: 16)
            
            stack.height(16)
            stack.left(to: icon.right, constant: 16)
            stack.bottom(to: icon.bottom)
            
            market.aspect(ratio: 32)
            market.centerY(to: content.centerY)
            market.right(to: content.right, constant: 16)
        }
        @objc
        private func _market() {
            guard let url = coin?.links.market.url else { return }
            list?.controller?.route(to: .unknown(.external(url: url)))
        }
    }
}
