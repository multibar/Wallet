import UIKit
import Lottie
import LayoutKit
import InterfaceKit

public class Loader: View {
    private let loader: LottieAnimationView = {
        let loader = LottieAnimationView(name: "loader")
        loader.loopMode = .loop
        return loader
    }()
    public var currentFrame: AnimationFrameTime {
        get { loader.currentFrame }
        set { loader.currentFrame = newValue }
    }
    public var loading = false
    
    public func set(loading: Bool) {
        self.loading = loading
        if loading {
            loader.currentFrame = 0
            loader.animationSpeed = 1
            loader.loopMode = .loop
            loader.play()
            View.animate(duration: 0.5,
                         spring: 0.8,
                         velocity: 0.2,
                         options: [.curveEaseInOut],
                         animations: {
                self.transform = .identity
                self.alpha = 1
            })
        } else {
            loader.animationSpeed = 5
            loader.play(toFrame: 60, loopMode: .playOnce)
            View.animate(duration: 0.33,
                         options: [.curveEaseInOut],
                         animations: {
                self.transform = .scale(to: 0.5)
                self.alpha = 0
            }, completion: { [weak self] (bool) in
                guard self?.alpha == 0 else { return }
                self?.loader.stop()
            })
        }
    }
    
    public override func setup() {
        super.setup()
        layout()
    }
    
    private func layout() {
        loader.auto = false
        add(loader)
        loader.box(in: self)
    }
}
public class LoaderView: View {
    private let loader = Loader()
    
    public func set(loading: Bool) {
        loader.set(loading: loading)
    }
    
    public override func setup() {
        super.setup()
        color = .x151A26
        layout()
    }
    private func layout() {
        loader.auto = false
        add(loader)
        loader.center(in: self, ratio: 56)
    }
}
