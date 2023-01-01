import UIKit
import CoreKit
import InterfaceKit

public class RecoveryViewController: ListViewController {
    
    public override func handle(content offset: CGPoint) {
        super.handle(content: offset)
        view.endEditing(true)
    }
}

extension RecoveryViewController: RecoveryPhraseProcessor {
    public func process(phrases: [String], for coin: Coin, at location: Wallet.Location) {
        store.order(.store(phrases: phrases, coin: coin, location: location))
    }
}
