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
    private weak var delegate: PasscodeDelegate?
    
    private let label = Label()
    
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
        label.color = .x58ABF5
        label.corner(radius: 12)
        label.set(text: "VERIFY", attributes: .attributes(for: .text(size: .medium, family: .mono), color: .xFFFFFF, alignment: .center))
        label.add(gesture: .tap(target: self, action: #selector(verify)))
        label.interactive = true
        label.auto = false
        content.add(label)
        label.center(in: content, with: .size(w: 128, h: 56))
    }
    @objc
    private func verify() {
        Haptic.notification(.success).generate()
        View.animate(duration: 0.33, spring: 1.0, velocity: 1.0) {
            self.label.color = .x5CC489
        }
        delegate?.passcode(controller: self, got: .success, for: action)
    }
}
extension PasscodeViewController {
    public enum Action {
        case create
        case verify
    }
    public enum Result {
        case success
        case failure
    }
}
