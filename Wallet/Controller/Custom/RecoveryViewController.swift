import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

public class RecoveryViewController: ListViewController {
    public override func receive(order: Store.Order, from store: Store) async {
        switch order.operation {
        case .reload:
            await super.receive(order: order, from: store)
        case .store(let phrases, let coin, let location, let password):
            switch location {
            case .cloud:
                // success, leave
                break
            case .keychain:
                // show user the password to keep
                break
            }
        }
    }
    public override func handle(content offset: CGPoint) {
        super.handle(content: offset)
        view.endEditing(true)
    }
}

extension RecoveryViewController: RecoveryPhraseProcessor {
    public func process(phrases: [String], for coin: Coin, at location: Wallet.Location) {
        store.order(.store(phrases: phrases, coin: coin, location: location, password: UUID().password))
    }
}
