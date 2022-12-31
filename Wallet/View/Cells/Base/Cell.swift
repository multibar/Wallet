import UIKit
import CoreKit
import LayoutKit
import InterfaceKit

public protocol Transitionable: AnyObject {
    var container: Container? { get }
    func destroy()
}
public class Cell: LayoutKit.Cell {
    public weak var list: List?
    
    public override func set(highlighted: Bool, animated: Bool = true) {
        View.animate(duration: 0.5,
                     spring: 1.0,
                     velocity: 0.5,
                     options: [.allowUserInteraction]) { [weak self] in
            self?.content.transform = highlighted ? .scale(to: 0.95) : .identity
        }
    }
}
