import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

public class RecoveryViewController: ListViewController {
    private var compensating = false
    public override func receive(order: Store.Order, from store: Store) async {
        switch order.operation {
        case .reload:
            await super.receive(order: order, from: store)
        case .store(_, _, let location, let password):
            switch location {
            case .cloud:
                success()
            case .keychain:
                success(password: password)
            }
        }
    }
    public override func handle(content offset: CGPoint) {
        super.handle(content: offset)
        print(offset)
        guard !compensating else { return }
        view.endEditing(true)
    }
}
extension RecoveryViewController {
    private func success(password: String? = nil) {
        tabViewController?.present(SuccessViewController(password: password), animated: true)
    }
}
extension RecoveryViewController: RecoveryPhraseProcessor {
    public func scroll(to input: UIView) {
        let y = input.convert(input.frame).origin.y - list.scroll.offset.y - list.scroll.insets.top
        print(y)
        compensating = true
        View.animate(duration: 0.5, spring: 1.0, velocity: 1.0) {
            self.list.scroll.offset = .point(x: 0, y: y < 0 ? 0 : y)
        } completion: { [weak self] _ in
            self?.compensating = false
        }
    }
    public func process(phrases: [String], for coin: Coin, at location: Wallet.Location) {
        store.order(.store(phrases: phrases, coin: coin, location: location, password: UUID().password))
    }
}
