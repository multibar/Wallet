import UIKit
import Lottie
import CoreKit
import NetworkKit
import InterfaceKit

public class SuccessViewController: BaseViewController {
    private let success = LottieAnimationView(name: "success")
    private let copied = LottieAnimationView(name: "copy")
    private let container = View()
    private let wallet: Wallet
    private let key: String?
    
    public override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    public required init(wallet: Wallet, key: String? = nil) {
        self.wallet = wallet
        self.key = key
        super.init(route: .none)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    public required init(route: Route, query: Store.Query = .none, load: Bool = true) {
        self.wallet = .init(coin: "", phrase: "", location: .keychain(.device))
        self.key = nil
        super.init(route: route, query: query, load: load)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        dismiss(animated: false)
    }
    public required init?(coder: NSCoder) { nil }
    
    public override func setup() {
        super.setup()
        display(fps: .maximum)
        Haptic.prepare()
        setupSuccess()
        setupContainer()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        success.play()
        let y = view.frame.height / 4
        container.transform = .move(y: container.frame.height + view.safeAreaInsets.bottom)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.66) { [weak self] in
            self?.success.play(fromFrame: 60, toFrame: 0, loopMode: .playOnce)
            View.animate(duration: 0.5, delay: 1.33, spring: 1.0, velocity: 1.0) { [weak self] in
                self?.success.alpha = 0
                self?.success.transform = .move(y: -y)
                self?.container.alpha = 1.0
                self?.container.transform = .identity
            }
        }
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Haptic.notification(.success).generate()
        display(fps: .default)
        (presentingViewController as? TabViewController)?.bar.store.order(.reload)
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        display(fps: .maximum)
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        display(fps: .default)
    }
    
    private func setupSuccess() {
        success.auto = false
        content.add(success)
        success.center(in: content, ratio: 128)
    }
    private func setupContainer() {
        let title = Label()
        let hints = Label(lines: 0)
        let secret = Label(lines: 0)
        let button = Label()
                
        container.alpha = 0.0
        container.color = .x8B93A1_20
        container.corner(radius: 16)
        
        switch wallet.location {
        case .cloud:
            title.set(text: "You're all set!",
                      attributes: .attributes(for: .title(size: .large), color: .xFFFFFF, alignment: .center))
            hints.set(text: "Your private key is saved in your iCloud Keychain, if enabled. Otherwise, it's saved locally in your device's Keychain",
                      attributes: .attributes(for: .text(size: .medium), color: .x8B93A1, alignment: .center))
            secret.set(text: "Your encrypted phrase is saved in cloud.",
                       attributes: .attributes(for: .text(size: .medium), color: .x8B93A1, alignment: .center))
            button.set(text: "DONE",
                       attributes: .attributes(for: .text(size: .medium, family: .mono), color: .xFFFFFF, alignment: .center))
        case .keychain(let location):
            switch location {
            case .device:
                title.set(text: "You're all set!",
                          attributes: .attributes(for: .title(size: .large), color: .xFFFFFF, alignment: .center))
                hints.set(text: "Your private key and encrypted secret phrase are saved locally in your device's Keychain.",
                          attributes: .attributes(for: .text(size: .medium), color: .x8B93A1, alignment: .center))
                secret.set(text: "Neither the key nor the secret phrase will leave your device.",
                           attributes: .attributes(for: .text(size: .large), color: .x8B93A1, alignment: .center))
                button.set(text: "DONE",
                           attributes: .attributes(for: .text(size: .medium, family: .mono), color: .xFFFFFF, alignment: .center))
            case .icloud:
                title.set(text: "Private Key",
                          attributes: .attributes(for: .title(size: .large), color: .xFFFFFF, alignment: .center))
                hints.set(text: "Keep your private key in secret. It's the only way to decrypt your recovery phrases.",
                          attributes: .attributes(for: .text(size: .medium), color: .x8B93A1, alignment: .center))
                secret.set(text: key,
                           attributes: .attributes(for: .text(size: .large, family: .mono), color: .x8B93A1, alignment: .center))
                button.set(text: "DONE",
                           attributes: .attributes(for: .text(size: .medium, family: .mono), color: .xFFFFFF, alignment: .center))
            }
        }

        button.color = .x58ABF5
        button.corner(radius: 8)
        button.interactive = true
        button.add(gesture: .tap(target: self, action: #selector(_done)))
        secret.interactive = true
        secret.add(gesture: .tap(target: self, action: #selector(_copy)))
        
        copied.alpha = 0.0
        copied.loopMode = .playOnce

        container.auto = false
        title.auto = false
        hints.auto = false
        secret.auto = false
        button.auto = false
        copied.auto = false
        
        content.add(container)
        container.add(title)
        container.add(hints)
        container.add(secret)
        container.add(button)
        container.add(copied)
        
        container.left(to: content.left, constant: 16)
        container.right(to: content.right, constant: 16)
        container.bottom(to: content.safeBottom, constant: 16)
        
        title.base(line: .first, to: container.top, constant: 48)
        title.left(to: container.left, constant: 16)
        title.right(to: container.right, constant: 16)
        
        hints.base(line: .first, to: title.line(.last), constant: 20)
        hints.left(to: title.left)
        hints.right(to: title.right)
        
        secret.base(line: .first, to: hints.line(.last), constant: 40)
        secret.left(to: hints.left)
        secret.right(to: hints.right)
        
        button.height(56)
        button.top(to: secret.line(.last), constant: 40)
        button.left(to: container.left, constant: 16)
        button.right(to: container.right, constant: 16)
        button.bottom(to: container.bottom, constant: 16)

        copied.aspect(ratio: 56)
        copied.top(to: container.top)
        copied.right(to: container.right)
    }
    
    @objc
    private func _copy() {
        guard let key else { return }
        Haptic.prepare()
        copied.currentFrame = 0
        Haptic.notification(.success).generate()
        UIPasteboard.general.string = key
        View.animate(duration: 0.33, spring: 1.0, velocity: 1.0) { [weak self] in
            self?.copied.alpha = 1.0
        } completion: { [weak self] _ in
            self?.copied.play(completion: { [weak self] _ in
                View.animate(duration: 0.33, delay: 0.5, spring: 1.0, velocity: 1.0) { [weak self] in
                    self?.copied.alpha = 0.0
                }
            })
        }
    }
    @objc
    private func _done() {
        Haptic.prepare()
        Haptic.selection.generate()
        let y = container.frame.height + view.safeAreaInsets.bottom
        View.animate(duration: 0.5, spring: 1.0, velocity: 1.0) { [weak self] in
            self?.container.transform = .move(y: y)
        } completion: { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
}
