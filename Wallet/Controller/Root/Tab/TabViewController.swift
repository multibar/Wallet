import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

public class TabViewController: TabController, MultibarController {
    public let bar = Multibar(route: Route(to: .multibar), load: false)
    
    private let dim = UIView()
    private let blur = Blur()
    private let border = UIView()
    private let grabber = UIView()
    private let loader = LoaderView()
    
    private lazy var top = bar.view.top(to: view.bottom)
    private lazy var grab = grabber.centerY(to: bar.view.top)
    
    private var cooler: Timer?
    private var constant = 0.0
    private var grabbing = false
    private var descended = false
    private var positioning = false
    private var previous: Multibar.Position = .hidden
    public private(set) var position: Multibar.Position = .hidden {
        didSet {
            let position = position
            let dragging = grabbing
            View.animate(duration: 0.33,
                         spring: 1.0,
                         velocity: 0.5,
                         options: [.allowUserInteraction, .curveLinear],
                         animations: {
                self.bar.list.scroll.enabled = (position == .top && !dragging)
            })
        }
    }
    public lazy private(set) var height = abs(position.minimal(for: view))
    
    public override var viewController: ViewController? {
        didSet {
            guard let route = (viewController as? NavigationController)?.rootViewController.route ?? viewController?.route else { return }
            bar.set(selected: route)
        }
    }
    
    public override var prefersHomeIndicatorAutoHidden: Bool {
        return position == .headed || traits.landscape ? true : super.prefersHomeIndicatorAutoHidden
    }
    
    private var loading = false
    public func set(loading: Bool,
                    animated: Bool = true,
                    completion: (() -> Void)? = nil) {
        guard self.loading != loading else { return }
        self.loading = loading
        if loading {
            loader.set(loading: true)
            loader.auto = false
            view.add(loader)
            loader.box(in: view)
            loader.layer.zPosition = .leastNormalMagnitude
        }
        burst(duration: 0.33)
        View.animate(duration: animated ? 0.33 : 0.0,
                     delay: loading ? 0.0 : 0.33,
                     spring: 1.0,
                     velocity: 1.0,
                     options: loading ? [.curveLinear] : [.allowUserInteraction, .curveLinear]) {
            self.loader.alpha = loading ? 1.0 : 0.0
        } completion: { _ in
            guard !loading && loading == self.loading else { completion?(); return }
            self.loader.set(loading: false)
            self.loader.removeFromSuperview()
            completion?()
        }
    }
    
    public override func update(traits: UITraitCollection) {
        super.update(traits: traits)
        height = abs(position.minimal(for: view))
        bar.update(traits: traits)
        viewController?.update(traits: traits)
        Task { set(position: position) }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lock()
    }
    private func setup() {
        setupBar()
        setupDim()
        setupGrabber()
        relayout()
    }
    private func setupBar() {
        let pan: UIPanGestureRecognizer = .pan(target: self, delegate: self, action: #selector(pan(recognizer:)))
        
        blur.colorTint = .x151A26
        blur.colorTintAlpha = 0.95
        blur.blurRadius = 8
        blur.auto = false
        
        border.color = .clear
        border.corner(radius: 20)
        border.border(width: 0.33)
        border.border(color: .x8B93A1_20)
        border.interactive = false
        border.auto = false
        
        bar.controller = self
        bar.view.color = .clear
        bar.view.corner(radius: 16)
        
        bar.view.add(gesture: pan)
        bar.view.frame = CGRect(x: 0, y: view.frame.height, w: view.frame.width, h: view.frame.height)
        bar.view.auto = false
        
        bar.view.insert(blur, below: bar.content)
        bar.view.insert(border, above: blur)
        view.add(bar.view)
        
        top.constant = 0
        bar.view.left(to: view.left)
        bar.view.right(to: view.right)
        bar.view.height(to: view.height)
        
        blur.box(in: bar.view)
        
        border.top(to: bar.view.top)
        border.left(to: bar.view.left, constant: -0.66)
        border.right(to: bar.view.right, constant: -0.66)
        border.bottom(to: bar.view.bottomAnchor)
    }
    private func setupDim() {
        dim.alpha = 0
        dim.backgroundColor = .x000000
        dim.interactive = false
        dim.auto = false
        view.insert(dim, below: bar.view)
        dim.box(in: view)
    }
    private func setupGrabber() {
        let pan: UIPanGestureRecognizer = .pan(target: self, delegate: self, action: #selector(pan(recognizer:)))
        let helper = UIView()
        helper.color = .clear
        helper.interactive = true
        helper.add(gesture: pan)
        grabber.color = .xFFFFFF_20
        grabber.corner(radius: 3, curve: .circular)
        grabber.auto = false
        helper.auto = false
        view.insert(grabber, above: bar.view)
        view.insert(helper, below: bar.view)
        grab.constant = 12
        grabber.centerX(to: bar.view.centerX)
        grabber.size(width: 40, height: 6)
        helper.centerX(to: grabber.centerX)
        helper.centerY(to: grabber.centerY)
        helper.width(to: grabber.width, multiplier: 2)
        helper.height(to: grabber.height, multiplier: 4)
    }
    
    public override func animate(with viewController: ViewController, coordinator: UIViewControllerTransitionCoordinator? = nil) {
        super.animate(with: viewController, coordinator: coordinator)
        let old: Multibar.Position = position
        let new: Multibar.Position = viewController.multibar ? old != .bottom ? .bottom : old : .hidden
        guard let coordinator else {
            Task { set(position: new) }
            return
        }
        coordinator.animate { context in
            let position = context.isCancelled ? old : viewController.multibar ? new : .hidden
            self.set(position: position, preference: .linear)
        } completion: { context in
            let position = context.isCancelled ? old : viewController.multibar ? new : .hidden
            guard !self.grabbing, !self.positioning, self.position != position else { return }
            self.set(position: position, preference: .linear)
        }
    }
    public override func app(state: System.App.State) {
        super.app(state: state)
        viewControllers.forEach({$0.app(state: state)})
    }
}
extension TabViewController: UIGestureRecognizerDelegate {
    @objc
    private func pan(recognizer: UIPanGestureRecognizer) {
        Haptic.prepare()
        switch recognizer.state {
        case .began:
            grabbing = true
            display(fps: .maximum)
            constant = top.constant
            previous = position
            View.animate(duration: 0.2,
                         options: [.allowUserInteraction, .curveLinear],
                         animations: {
                self.grabber.transform = .scale(x: 1.25, y: 1.025)
            })
        case .changed:
            guard bar.view.frame.origin.y >= view.safeAreaInsets.top && bar.view.frame.origin.y <= view.frame.height else {
                recognizer.isEnabled = false
                recognizer.isEnabled = true
                Haptic.impact(.soft).generate()
                return
            }
            let value = bar.view.frame.origin.y + (recognizer.velocity(in: view).y/5)
            switch value {
            case -.infinity ..< view.frame.height/3:
                position = .top
            case view.frame.height/3 ..< view.frame.height - view.frame.height/3:
                position = .middle
            case view.frame.height - view.frame.height/3 ..< .infinity:
                position = .bottom
            default:
                recognizer.isEnabled = false
                recognizer.isEnabled = true
                Haptic.impact(.soft).generate()
                return
            }
            top.constant = constant + recognizer.translation(in: view).y
            View.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
                self.relayout()
            }, completion: nil)
            View.animate(withDuration: 0.33, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
                self.border.alpha = 1.0
                self.grabber.alpha = 1.0
            }, completion: nil)
        case .ended, .cancelled, .failed:
            grabbing = false
            set(position: position)
            View.animate(duration: 0.2,
                         options: [.allowUserInteraction, .curveLinear],
                         animations: {
                self.grabber.transform = .identity
            })
        default:
            break
        }
    }
    private func set(position: Multibar.Position, preference: Multibar.Preference = .none) {
        self.position = position
        self.positioning = true
        let traits = traits
        let empty = viewControllers.empty
        let descended = descended
        let compact = traits.vertical == .compact
        let values = position.values(for: view, traits: traits)
        height = abs(position.minimal(for: view))
        top.constant = values.top
        grab.constant = values.grab
        burst(duration: 0.66)
        View.animate(duration: previous == .top ? 0.50 : 0.66,
                     spring: 1.0,
                     velocity: 0.5,
                     interactive: preference.linear,
                     options: [.allowUserInteraction, .curveLinear],
                     animations: {
            self.content.transform = compact ? .identity : position == .top ? .scale(x: 0.925, y: 0.925).moved(y: 24) : .identity
            self.content.corner(radius: position == .top ? 16 : 0)
            self.blur.colorTintAlpha = 0.95
            self.grabber.alpha = position == .top ? 0.33 : (position.descended && descended) ? 0.0 : 1.0
            self.border.alpha = (position.descended && descended || position == .top || empty) ? 0.0 : 1.0
            self.dim.alpha = position == .top ? 0.33 : 0.0
            self.bar.reset()
        }, completion: { _ in
            self.positioning = false
        })
        View.animate(duration: 0.50,
                     spring: preference.soft ? 1.0 : 0.75,
                     velocity: 0.5,
                     interactive: preference.linear,
                     options: [.allowUserInteraction, .curveLinear],
                     animations: {
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsStatusBarAppearanceUpdate()
            self.relayout()
        }, completion: nil)
    }
    private func burst(duration: Double) {
        display(fps: .maximum)
        cooler?.invalidate()
        cooler = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(cooldown), userInfo: nil, repeats: false)
    }
    @objc
    private func cooldown() {
        guard !grabbing else { return }
        display(fps: .default)
    }
    public func handle(descended: Bool) {
        guard viewController?.multibar == true, position.descended, !positioning, !grabbing else { return }
        self.descended = descended
        View.animate(duration: 0.125,
                     options: [.allowUserInteraction],
                     animations: {
            self.border.alpha = descended ? 0.0 : 1.0
            self.grabber.alpha = descended ? 0.0 : 1.0
        })
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard bar.list.scroll.offset.y <= 64 else { return false }
        guard let recognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = recognizer.velocity(in: recognizer.view)
        if position == .top && velocity.y < 0 {
            return false
        }
        return abs(velocity.y) > abs(velocity.x)
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return position != .top
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return position == .top && bar.list.scroll.offset.y <= 64
    }
}
extension TabViewController {
    public func maximize() {
        set(position: .top, preference: position.descended ? .soft : .none)
    }
}
extension TabViewController: PasscodeDelegate {
    private func lock() {
        Keychain.passcode == nil ? passcode(action: .create) : passcode(action: .verify(.auth))
    }
    public func passcode(controller: PasscodeViewController,
                         got result: PasscodeViewController.Result,
                         for action: PasscodeViewController.Action) {
        try? Keychain.deletePasscode()
        switch action {
        case .verify(let verify):
            switch verify {
            case .auth:
                switch result {
                case .success:
                    bar.store.order(.reload)
                case .failure:
                    break
                }
            default:
                break
            }
        default:
            break
        }
    }
}
extension TabViewController {
    public func logs() async {
        guard let log = await Core.shared.log() else { return }
        let activity = UIActivityViewController(activityItems: [log], applicationActivities: nil)
        if let popoverController = activity.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = view.bounds
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        present(activity, animated: true, completion: nil)
    }
}
extension ViewController {
    public var bar: Multibar? {
        return tabViewController?.bar
    }
    public var tabViewController: TabViewController? {
        return tabController as? TabViewController
    }
}
