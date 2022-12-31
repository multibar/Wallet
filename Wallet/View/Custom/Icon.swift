import UIKit
import InterfaceKit

public class Icon: View {
    private let icon = ImageView(format: .square)
    
    public func set(image: UIImage?) {
        icon.image = image
    }
    public func load(from source: URL?) {
        icon.load(from: source)
    }
    public func clear() {
        icon.clear()
        color = nil
    }
    public override func setup() {
        super.setup()
        layout()
    }
    private func layout() {
        icon.auto = false
        add(icon)
        icon.box(in: self, insets: .insets(top: 8, left: 8, right: 8, bottom: 8))
    }
}
