import UIKit
import CoreKit
import NetworkKit
import InterfaceKit

public class TabViewController: TabController, MultibarController {
    public let bar: Multibar
    public let container: NavigationController
    
    private let dim = UIView()
    private let blur = Blur()
    private let border = UIView()
    private let grabber = UIView()
    private let loader = LoaderView()
    private let impact = Haptic.Impactor(style: .soft)
    
    private var presence: Time = .minutes(5)
    
    private lazy var top = container.view.top(to: view.bottom)
    private lazy var grab = grabber.centerY(to: container.view.top)
    
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
                self.container.scroll?.enabled = (position == .top && !dragging)
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
        bar.reset(for: position)
        container.update(traits: traits)
        viewController?.update(traits: traits)
        Task { set(position: position) }
    }
    
    public required init() {
        let bar = Multibar(route: Route(to: .multibar), load: false)
        let container = NavigationController(viewController: bar)
        self.bar = bar
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }
    public required init?(coder: NSCoder) { nil }
    
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
        container.view.color = .clear
        container.view.corner(radius: 16)
        
        container.view.add(gesture: pan)
        container.view.frame = CGRect(x: 0, y: view.frame.height, w: view.frame.width, h: view.frame.height)
        container.view.auto = false
        
        container.view.insert(blur, at: 0)
        container.view.insert(border, above: container.view)
        view.add(container.view)
        
        top.constant = 0
        container.view.left(to: view.left)
        container.view.right(to: view.right)
        container.view.height(to: view.height)
        
        blur.box(in: container.view)
        
        border.top(to: container.view.top)
        border.left(to: container.view.left, constant: -0.66)
        border.right(to: container.view.right, constant: -0.66)
        border.bottom(to: container.view.bottomAnchor)
    }
    private func setupDim() {
        dim.alpha = 0
        dim.backgroundColor = .x000000
        dim.interactive = false
        dim.auto = false
        view.insert(dim, below: container.view)
        dim.box(in: view)
    }
    private func setupGrabber() {
        let helper = UIView()
        helper.color = .clear
        helper.interactive = true
        helper.add(gesture: .pan(target: self, delegate: self, action: #selector(pan(recognizer:))))
        grabber.color = .xFFFFFF_20
        grabber.corner(radius: 3, curve: .circular)
        grabber.add(gesture: .pan(target: self, delegate: self, action: #selector(pan(recognizer:))))
        grabber.auto = false
        helper.auto = false
        view.insert(grabber, above: container.view)
        view.insert(helper, below: container.view)
        grab.constant = 12
        grabber.centerX(to: container.view.centerX)
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
        switch state {
        case .willEnterForeground:
            guard presence.expired else { return }
            lock()
        case .willResignActive:
            presence = .minutes(5)
        default:
            break
        }
        presented?.app(state: state)
        viewControllers.forEach({$0.app(state: state)})
    }
}
extension TabViewController: UIGestureRecognizerDelegate {
    @objc
    private func pan(recognizer: UIPanGestureRecognizer) {
        impact.prepare()
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
            guard container.view.frame.origin.y >= view.safeAreaInsets.top && container.view.frame.origin.y <= view.frame.height else {
                recognizer.isEnabled = false
                recognizer.isEnabled = true
                impact.generate()
                return
            }
            let value = container.view.frame.origin.y + (recognizer.velocity(in: view).y/5)
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
                impact.generate()
                return
            }
            top.constant = constant + recognizer.translation(in: view).y
            View.animate(duration: 0.1, options: [.allowUserInteraction, .curveLinear]) {
                self.relayout()
            }
            View.animate(duration: 0.33, options: [.allowUserInteraction, .curveLinear]) {
                self.border.alpha = 1.0
                self.grabber.alpha = 1.0
            }
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
            self.content.transform = compact ? .identity : position == .top ? .scale(to: values.scale).moved(y: values.y) : .identity
            self.content.corner(radius: position == .top ? 16 : 0)
            self.blur.colorTintAlpha = 0.95
            self.grabber.alpha = position == .top ? 0.33 : (position.descended && descended) ? 0.0 : 1.0
            self.border.alpha = (position.descended && descended || position == .top || empty) ? 0.0 : 1.0
            self.dim.alpha = position == .top ? 0.33 : 0.0
            self.bar.reset(for: position)
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
        View.animate(duration: 0.125, animations: {
            self.border.alpha = descended ? 0.0 : 1.0
            self.grabber.alpha = descended ? 0.0 : 1.0
        })
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let scroll = container.scroll, (scroll.offset.y + scroll.insets.top) <= 64 else { return false }
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
        guard let scroll = container.scroll else { return false }
        return position == .top && (scroll.offset.y + scroll.insets.top) <= 64
    }
}
extension TabViewController {
    public func maximize() {
        set(position: .top, preference: position.descended || position == .middle ? .soft : .none)
    }
    public func minimize() {
        set(position: .bottom, preference: .soft)
    }
}
extension TabViewController: PasscodeDelegate {
    private func lock() {
        Keychain.passcode == nil ? passcode(action: .create) : passcode(action: .verify(.auth))
    }
    public func passcode(controller: PasscodeViewController,
                         got result: PasscodeViewController.Result,
                         for action: PasscodeViewController.Action) {
        switch action {
        case .create:
            bar.store.order(.reload)
        case .change:
            switch result {
            case .success:
                controller.dismiss(animated: true) {
                    self.passcode(action: .create)
                }
            case .failure:
                // access denied notification
                break
            }
        case .verify(let verify):
            switch verify {
            case .auth:
                switch result {
                case .success:
                    bar.store.order(.reload)
                case .failure:
                    // access denied notification
                    break
                }
            default:
                break
            }
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
    public var tabViewController: TabViewController? {
        return tabController as? TabViewController
    }
}
