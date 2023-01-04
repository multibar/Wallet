import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

public protocol PasscodeDelegate: AnyObject {
    func passcode(controller: PasscodeViewController,
                  got result: PasscodeViewController.Result,
                  for action: PasscodeViewController.Action)
}
public class PasscodeViewController: BaseViewController {
    private let action: Action
    private let passcode = Passcode(count: 4)
    private let progress = Progress(count: 4)
    private let keyboard = Keyboard.Numeric()
    private weak var delegate: PasscodeDelegate?
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return traits.pad ? .all : .portrait
    }
        
    public required init(_ action: Action, delegate: PasscodeDelegate) {
        self.action = action
        self.delegate = delegate
        super.init(route: .none)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    public required init?(coder: NSCoder) { nil }
    
    public override func setup() {
        super.setup()
        setupPasscode()
        setupProgress()
        setupKeyboard()
    }
    private func setupPasscode() {
        passcode.set(delegate: self)
        switch action {
        case .create:
            passcode.set(mode: .create)
        case .change:
            passcode.set(mode: .create)
        case .verify(let passcode):
            self.passcode.set(mode: .equals(to: passcode))
        }
    }
    private func setupProgress() {
        switch action {
        case .create:
            progress.set(stage: .create)
        case .verify, .change:
            progress.set(stage: .verify)
        }
        progress.auto = false
        view.add(progress)
        progress.top(to: view.safeTop, constant: 64)
        progress.left(to: view.safeLeft, constant: 16)
        progress.right(to: view.safeRight, constant: 16)
    }
    private func setupKeyboard() {
        keyboard.delegate = self
    }
}
extension PasscodeViewController {
    public enum Action {
        case create
        case change
        case verify(passcode: String)
    }
    public enum Result {
        case success
        case failure
    }
}
extension PasscodeViewController: KeyboardDelegate {
    public func pressed(key: Keyboard.Key) {
        Haptic.prepare()
        passcode.input(value: key.value)
    }
}
extension PasscodeViewController: PasscodeInputDelegate {
    fileprivate func success() {
        switch action {
        case .create, .change:
            break
        case .verify:
            Haptic.notification(.success).generate()
            delegate?.passcode(controller: self, got: .success, for: action)
        }
    }
    fileprivate func failure() {
        switch action {
        case .create, .change:
            break
        case .verify:
            Haptic.notification(.error).generate()
            delegate?.passcode(controller: self, got: .failure, for: action)
        }
    }
    fileprivate func biometry() {
        
    }
    fileprivate func progress(count: Int) {
        progress.set(status: .progress(count))
    }
}

fileprivate protocol PasscodeInputDelegate: AnyObject {
    func success()
    func failure()
    func biometry()
    func progress(count: Int)
}
extension PasscodeViewController {
    fileprivate class Passcode {
        private let count: Int
        private var input: String {
            didSet {
                delegate?.progress(count: input.count)
                guard input.count == count else {
                    if input.count > count { delegate?.failure() }
                    return
                }
                switch mode {
                case .create:
                    delegate?.success()
                case .equals(let passcode):
                    input == passcode ? delegate?.success() : delegate?.failure()
                }
            }
        }
        private var mode: Mode = .create
        private weak var delegate: PasscodeInputDelegate?
        
        public init(count: Int) {
            self.count = count
            self.input = ""
        }
        
        public func input(value: Keyboard.Key.Value) {
            switch value {
            case .number(let number):
                input.append("\(number)")
            case .character(let character):
                input.append(character)
            case .delete:
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
        
        public func set(stage: Stage) {
            var title: String?
            switch stage {
            case .create:
                title = "Create passcode"
            case .verify:
                title = "Enter passcode"
            case .ensure:
                title = "Re-enter passcode"
            }
            label.set(text: title,
                      attributes: .attributes(for: .title(size: .medium), color: .xFFFFFF, alignment: .center, lineBreak: .byTruncatingMiddle),
                      animated: true)
            dots.forEach({$0.set(status: .empty)})
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
    }
}
extension PasscodeViewController.Progress {
    fileprivate enum Stage {
        case create
        case verify
        case ensure
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
