import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

public protocol RecoveryPhraseProcessor: AnyObject {
    var done: Cell.Button? { get set }
    var inputs: [Int: Cell.Phrase] { get set }
    var phrases: [Int: String] { get set }
    var location: Keychain.Location? { get set }
    func scroll(to phrase: Int)
    func process(for coin: Coin, at location: Wallet.Location)
}
public class InputViewController: ListViewController, RecoveryPhraseProcessor, KeyboardHandler {
    public var done: Cell.Button?
    public var inputs: [Int: Cell.Phrase] = [:]
    public var phrases: [Int: String] = [:] { didSet { check() } }
    public var keyboard: CGFloat = 0.0
    public var location: Keychain.Location?
    private var input = 0
    private var compensating = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(_show), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_hide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public override func receive(order: Store.Order, from store: Store) async {
        switch order.operation {
        case .store(_, _, _, let key):
            guard let wallet = await order.package.wallet else {
                await super.receive(order: order, from: store)
                break
            }
            switch wallet.location {
            case .cloud:
                success(wallet: wallet)
            case .keychain(let location):
                success(wallet: wallet, key: location == .icloud ? key : nil)
            }
        default:
            await super.receive(order: order, from: store)
        }
        check()
    }
    public override func handle(content offset: CGPoint) {
        super.handle(content: offset)
        guard !compensating else { return }
        view.endEditing(true)
    }
    public func scroll(to input: Int) {
        self.input = input
        guard let coin,
              let tableView = scroll as? UITableView,
              let section = list.source.sections.firstIndex(where: {$0.items.count >= coin.words})
        else { return }
        compensating = true
        View.animate(duration: 0.5, spring: 1.0, velocity: 0.0) {
            tableView.scrollToRow(at: IndexPath(row: input-1, section: section), at: .middle, animated: false)
        } completion: { [weak self] _ in
            self?.compensating = false
        }
    }
    public func process(for coin: Coin, at location: Wallet.Location) {
        Haptic.prepare()
        let phrases: [String] = Array(phrases.values)
        guard phrases.count == coin.words else {
            Haptic.notification(.error).generate()
            return
        }
        let location: Wallet.Location = {
            switch location {
            case .cloud:
                return .cloud
            case .keychain:
                return .keychain(self.location ?? (location.synchronizable ? .icloud : .device))
            }
        }()
        store.order(.store(phrases: phrases, coin: coin, location: location, key: Key.generate()))
    }
    private func check() {
        guard let coin, let done else { return }
        done.set(active: phrases.values.count == coin.words)
    }
    
    @objc
    private func _show(_ notification: NSNotification) {
        guard let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboard = frame.height
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let curve = UIView.AnimationCurve(rawValue: curveValue),
              let coin,
              let tableView = scroll as? UITableView,
              let section = list.source.sections.firstIndex(where: {$0.items.count >= coin.words})
        else { return }
        list.reinset()
        let input = input
        let safeArea = view.safeAreaInsets
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            tableView.scrollToRow(at: IndexPath(row: input, section: section), at: .middle, animated: false)
            self.scroll?.transform = .move(y: -frame.height + safeArea.bottom + 16)
        }
        compensating = true
        animator.startAnimation()
        animator.addCompletion { [weak self] _ in
            self?.compensating = false
        }
    }
    @objc
    private func _hide(_ notification: NSNotification) {
        keyboard = 0.0
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
              let curve = UIView.AnimationCurve(rawValue: curveValue)
        else { return }
        list.reinset()
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            self.scroll?.transform = .identity
        }
        compensating = true
        animator.startAnimation()
        animator.addCompletion { [weak self] _ in
            self?.compensating = false
        }
    }
}
extension InputViewController {
    private var coin: Coin? {
        switch route.destination {
        case .add(let add):
            switch add {
            case .store(let store):
                switch store {
                case .recovery(let coin, _):
                    return coin
                default:
                    return nil
                }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    private func success(wallet: Wallet, key: String? = nil) {
        tabViewController?.present(SuccessViewController(wallet: wallet, key: key), animated: true)
    }
}
