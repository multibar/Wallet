import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

public protocol PasscodeDelegate: AnyObject {
    func finished(with conclusion: PasscodeViewController.Conclusion, for action: PasscodeViewController.Action)
}
public class PasscodeViewController: BaseViewController {
    private let action: Action
    private weak var delegate: PasscodeDelegate?
    
    private init(_ action: Action, delegate: PasscodeDelegate) {
        self.action = action
        self.delegate = delegate
        super.init(route: .none)
    }
    public required init?(coder: NSCoder) { nil }

}
extension PasscodeViewController {
    public enum Action {
        case create
        case verify
    }
    public enum Conclusion {
        case created
        case verified
        case unverified
    }
}
