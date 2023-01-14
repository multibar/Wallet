import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

public protocol PasscodeDelegate: AnyObject {
    @MainActor
    func passcode(controller: PasscodeViewController,
                  got result: PasscodeViewController.Result,
                  for action: PasscodeViewController.Action)
}
extension PasscodeDelegate where Self: UIViewController {
    public func passcode(action: PasscodeViewController.Action, animated: Bool = true) {
        let navigation = NavigationController(viewController: PasscodeViewController(action, delegate: self))
        navigation.modalTransitionStyle = .crossDissolve
        navigation.modalPresentationStyle = .overFullScreen
        present(navigation, animated: animated)
    }
}
public class PasscodeViewController: BaseViewController {
    private let action: Action
    private let keyboard = Keyboard.Numeric()
    private let progress = Progress(count: 4)
    private let passcode = Passcode(count: 4)
    private let notificator = Haptic.Notificator()
    private weak var delegate: PasscodeDelegate?
    
    private var banned: Bool {
        return Keychain.banned?.until.expired == false
    }
    private var failures = 0 {
        didSet {
            guard failures >= 3 else { return }
            switch action {
            case .change:
                delegate?.passcode(controller: self, got: .failure, for: action)
            case .verify:
                break
            default:
                return
            }
            let stage = (Keychain.banned?.stage ?? 0) + 1
            let until = Keychain.set(ban: stage)
            ban(stage: stage, until: until)
            failures = 0
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return traits.pad ? .all : .portrait
    }
    
    public override var navBarItems: [NavigationController.Bar.Item] {
        return action.cancellable ? [.back(direction: .left)] : []
    }
        
    public required init(_ action: Action, delegate: PasscodeDelegate) {
        self.action = action
        self.delegate = delegate
        super.init(route: .none)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    public required init?(coder: NSCoder) { nil }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkBan()
        guard Settings.App.biometry && !banned else { return }
        biometry()
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboard.selector.prepare()
        notificator.prepare()
    }
    
    public override func setup() {
        super.setup()
        setupKeyboard()
        setupProgress()
        setupPasscode()
    }
    private func setupPasscode() {
        passcode.set(delegate: self)
        switch action {
        case .create:
            passcode.set(mode: .create)
        case .verify, .change:
            guard let passcode = Keychain.passcode else {
                failure()
                return
            }
            self.passcode.set(mode: .equals(to: passcode))
        }
    }
    private func setupKeyboard() {
        switch action {
        case .create, .change:
            keyboard.set(biometry: false)
        case .verify:
            keyboard.set(biometry: true)
        }
        keyboard.delegate = self
        keyboard.auto = false
        view.add(keyboard)
        keyboard.left(to: view.safeLeft)
        keyboard.right(to: view.safeRight)
        keyboard.bottom(to: view.safeBottom, constant: 32)
    }
    private func setupProgress() {
        switch action {
        case .create:
            progress.set(stage: .create)
        case .change:
            progress.set(stage: .verify(change: true))
        case .verify:
            progress.set(stage: .verify(change: false))
        }
        progress.delegate = self
        progress.auto = false
        view.add(progress)
        progress.left(to: view.safeLeft, constant: 16)
        progress.right(to: view.safeRight, constant: 16)
        progress.bottom(to: keyboard.top, constant: 128)
    }
    private func ban(stage: Int, until: Time) {
        guard stage > 0 else { return }
        keyboard.set(enabled: false)
        progress.set(stage: .banned(until: until))
    }
    public func checkBan() {
        guard let banned = Keychain.banned, !banned.until.expired else {
            keyboard.set(enabled: true)
            switch action {
            case .create:
                progress.set(stage: .create)
            case .change:
                progress.set(stage: .verify(change: true))
            case .verify:
                progress.set(stage: .verify(change: false))
            }
            return
        }
        ban(stage: banned.stage, until: banned.until)
    }
    
    public override func app(state: System.App.State) {
        super.app(state: state)
        switch state {
        case .willEnterForeground:
            checkBan()
        default:
            break
        }
    }
}
extension PasscodeViewController {
    public enum Action {
        case create
        case change
        case verify(Verify)
        
        public var cancellable: Bool {
            switch self {
            case .create:
                return false
            case .change:
                return true
            case .verify(let verify):
                return verify.cancellable
            }
        }
        
        public enum Verify {
            case auth
            case delete
            case decrypt(with: String? = nil)
            
            public var cancellable: Bool {
                switch self {
                case .auth:
                    return false
                case .delete, .decrypt:
                    return true
                }
            }
        }
    }
    public enum Result {
        case success
        case failure
    }
}
extension PasscodeViewController: KeyboardDelegate {
    public func pressed(key: Keyboard.Key) {
        passcode.input(value: key.value)
    }
}
extension PasscodeViewController: ProgressDelegate {}
extension PasscodeViewController: PasscodeInputDelegate {
    fileprivate func success(result: Passcode.Result) {
        Keychain.set(ban: 0)
        switch action {
        case .create:
            keyboard.set(enabled: false)
            Task.delayed(by: 0.2) {
                await self.progress.set(status: .success)
                switch result {
                case .created(let passcode):
                    Task.delayed(by: 0.5) {
                        await self.passcode.set(mode: .equals(to: passcode))
                        await self.progress.set(stage: .ensure)
                        await self.keyboard.set(enabled: true)
                    }
                case .verified(let passcode):
                    try? Keychain.set(passcode)
                    Task.delayed(by: 0.125) {
                        await self.delegate?.passcode(controller: self, got: .success, for: self.action)
                        Task.delayed(by: 0.33) {
                            await MainActor.run {
                                self.dismiss(animated: true)
                            }
                        }
                    }
                }
            }
        case .change, .verify:
            keyboard.set(enabled: false)
            Task.delayed(by: 0.2) {
                await self.notificator.generate(.success)
                await self.progress.set(status: .success)
                Task.delayed(by: 0.125) {
                    await self.delegate?.passcode(controller: self, got: .success, for: self.action)
                    Task.delayed(by: 0.33) {
                        await MainActor.run {
                            self.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    }
    fileprivate func failure(biometric: Bool = false) {
        switch action {
        case .create:
            keyboard.set(enabled: false)
            Task.delayed(by: 0.2) {
                await self.notificator.generate(.error)
                await self.progress.set(status: .failure)
                Task.delayed(by: 0.5) {
                    await self.passcode.set(mode: .create)
                    await self.progress.set(stage: .create)
                    await self.keyboard.set(enabled: true)
                }
            }
        case .change, .verify:
            if !biometric { failures += 1 }
            keyboard.set(enabled: false)
            Task.delayed(by: 0.2) {
                await self.notificator.generate(.error)
                await self.progress.set(status: .failure)
                Task.delayed(by: 0.33) {
                    await self.delegate?.passcode(controller: self, got: .failure, for: self.action)
                    await self.passcode.clear()
                    await self.progress.set(status: .progress(0))
                    await self.keyboard.set(enabled: await !self.banned)
                }
            }
        }
    }
    fileprivate func biometry() {
        switch action {
        case .create, .change:
            break
        case .verify:
            Task {
                do {
                    guard let passcode = Keychain.passcode else {
                        failure()
                        return
                    }
                    try await System.Device.authenticate()
                    Settings.App.biometry = true
                    success(result: .verified(passcode: passcode))
                } catch {
                    failure(biometric: true)
                }
            }
        }
    }
    fileprivate func progress(count: Int) {
        progress.set(status: .progress(count))
    }
}

fileprivate protocol PasscodeInputDelegate: AnyObject {
    func success(result: PasscodeViewController.Passcode.Result)
    func failure(biometric: Bool)
    func biometry()
    func progress(count: Int)
}
extension PasscodeViewController {
    @MainActor
    fileprivate class Passcode {
        private let count: Int
        private var input: String {
            didSet {
                delegate?.progress(count: input.count)
                guard input.count == count else {
                    if input.count > count { delegate?.failure(biometric: false) }
                    return
                }
                switch mode {
                case .create:
                    delegate?.success(result: .created(passcode: input))
                case .equals(let comparable):
                    input == comparable ? delegate?.success(result: .verified(passcode: input)) : delegate?.failure(biometric: false)
                }
            }
        }
        public private(set) var mode: Mode = .create
        private weak var delegate: PasscodeInputDelegate?
        
        public init(count: Int) {
            self.count = count
            self.input = ""
        }
        
        public func input(value: Keyboard.Key.Value) {
            switch value {
            case .number(let number):
                guard input.count < count else { return }
                input.append("\(number)")
            case .character(let character):
                guard input.count < count else { return }
                input.append(character)
            case .delete:
                guard !input.empty else { return }
                input.removeLast()
            case .biometry:
                delegate?.biometry()
            }
        }
        public func set(mode: Mode) {
            self.clear()
            self.mode = mode
        }
        public func set(delegate: PasscodeInputDelegate) {
            self.clear()
            self.delegate = delegate
        }
        public func clear() {
            self.input = ""
        }
    }
}
extension PasscodeViewController.Passcode {
    fileprivate enum Mode {
        case create
        case equals(to: String)
    }
    fileprivate enum Result {
        case created(passcode: String)
        case verified(passcode: String)
    }
}

fileprivate protocol ProgressDelegate: AnyObject {
    func checkBan()
}
extension PasscodeViewController {
    fileprivate class Progress: View {
        private let count: Int
        private let label = Label()
        private let stack: Stack = {
            let stack = Stack()
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.distribution = .fill
            stack.spacing = 8
            return stack
        }()
        private var dots: [Dot] = []
        private var timer: Timer?
        
        public weak var delegate: ProgressDelegate?
        
        public func set(stage: Stage) {
            timer?.invalidate()
            timer = nil
            var title: String?
            switch stage {
            case .create:
                title = "Create passcode"
            case .verify(let change):
                title = change ? "Current passcode" : "Enter passcode"
            case .ensure:
                title = "Re-enter passcode"
            case .banned(let ban):
                title = "\(ban.seconds(to: .now).time)"
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                    let timeleft = ban.seconds(to: .now)
                    self?.set(title: "\(timeleft.time)")
                    guard timeleft == 0 else { return }
                    self?.delegate?.checkBan()
                })
            }
            jump()
            set(title: title)
            Task.delayed(by: 0.125) { await MainActor.run {
                self.dots.forEach({$0.set(status: .empty)})
            }}
        }
        public func set(status: Status) {
            switch status {
            case .progress(let progress):
                guard dots.count >= progress else { return }
                dots.enumerated().forEach { number, dot in
                    guard progress > 0 else {
                        dot.set(status: .empty)
                        return
                    }
                    (number + 1) <= progress ? dot.set(status: .filled) : dot.set(status: .empty)
                }
            case .success:
                dots.forEach { $0.set(status: .success) }
            case .failure:
                dots.forEach { $0.set(status: .failure) }
            }
        }
        
        public required init(count: Int) {
            self.count = count
            super.init(frame: .zero)
        }
        public required init?(coder: NSCoder) { nil }
        
        public override func setup() {
            super.setup()
            layout()
        }
        private func layout() {
            label.auto = false
            stack.auto = false
            
            add(label)
            add(stack)
            
            label.top(to: top)
            label.left(to: left)
            label.right(to: right)
            
            stack.height(10)
            stack.top(to: label.bottom, constant: 16)
            stack.centerX(to: centerX)
            stack.bottom(to: bottom)
            
            for _ in 0..<count {
                let dot = Dot()
                dots.append(dot)
                stack.append(dot)
            }
        }
        private func set(title: String?) {
            label.set(text: title,
                      attributes: .attributes(for: .title(size: .medium), color: .xFFFFFF, alignment: .center, lineBreak: .byTruncatingMiddle),
                      animated: true)
        }
        private func jump() {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.toValue = 1.2
            animation.fromValue = 1.0
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isAdditive = false
            animation.isRemovedOnCompletion = true
            animation.autoreverses = true
            label.layer.add(animation, forKey: "scale")
        }
    }
}
extension PasscodeViewController.Progress {
    fileprivate enum Stage {
        case create
        case verify(change: Bool)
        case ensure
        case banned(until: Time)
    }
    fileprivate enum Status {
        case progress(Int)
        case success
        case failure
    }
}
extension PasscodeViewController.Progress {
    fileprivate class Dot: View {
        private let ratio: CGFloat
        private var status: Status = .empty
        private let dot = View()
        
        public func set(status: Status) {
            let previous = self.status
            self.status = status
            View.animate(duration: 0.2, spring: 1.0, velocity: 1.0) {
                switch status {
                case .empty:
                    self.dot.color = .xFFFFFF_20
                case .filled:
                    self.dot.color = .x58ABF5
                case .success:
                    self.dot.color = .x5CC489
                case .failure:
                    self.dot.color = .xF36655
                }
            }
            guard status != .empty && previous != status else { return }
            jump()
        }
        
        public required init(ratio: CGFloat = 10) {
            self.ratio = ratio
            super.init(frame: .zero)
        }
        public required init?(coder: NSCoder) { nil }
        
        public override func setup() {
            super.setup()
            setupUI()
            layout()
        }
        private func setupUI() {
            clips = false
            dot.color = .xFFFFFF_20
            dot.corner(radius: ratio/2, curve: .circular)
        }
        private func layout() {
            auto = false
            dot.auto = false
            add(dot)
            dot.repeat(self)
            aspect(ratio: ratio)
        }
        private func jump() {
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.toValue = 1.2
            animation.fromValue = 1.0
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.fillMode = .forwards
            animation.isAdditive = false
            animation.isRemovedOnCompletion = true
            animation.autoreverses = true
            layer.add(animation, forKey: "scale")
        }
    }
}
extension PasscodeViewController.Progress.Dot {
    fileprivate enum Status {
        case empty
        case filled
        case success
        case failure
    }
}
