//
//  HomeViewController.swift
//  AuvergneWebcams
//
//  Created by Drusy on 16/02/2018.
//

import UIKit

class HomeViewController: AbstractRealmViewController {

    fileprivate enum TransitionDirection {
        case left
        case right
        case top
        case bottom
    }
    
    @IBOutlet weak var tabbar: UITabBar! {
        didSet {
            tabbar.delegate = self
        }
    }
    @IBOutlet weak var listTabbarItem: UITabBarItem!
    @IBOutlet weak var mapTabbarItem: UITabBarItem!
    @IBOutlet weak var containerView: UIView!
    
    fileprivate(set) weak var currentViewController: UIViewController?
    fileprivate weak var currentTabbarItem: UITabBarItem?
    fileprivate var isAnimatingController: Bool = false
    
    lazy var listViewController: WebcamCarouselViewController = {
        let controller = WebcamCarouselViewController()
        controller.delegate = self
        return controller
    }()
    lazy var mapViewController: MapViewController = {
        return MapViewController(webcams: WebcamManager.shared.webcams())
    }()
    
    lazy var listViewNavitationController: NavigationController = {
        return NavigationController(rootViewController: listViewController)
    }()
    lazy var mapViewNavigationController: NavigationController = {
        return NavigationController(rootViewController: mapViewController)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showList(with: .left, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: -
    
    fileprivate func showList(with direction: TransitionDirection, animated: Bool = true) {
        currentTabbarItem = listTabbarItem
        tabbar.selectedItem = listTabbarItem
        _ = setup(viewController: listViewNavitationController,
                  direction: direction,
                  animated: animated)
    }
    
    fileprivate func showMap(with direction: TransitionDirection, animated: Bool = true) {
        currentTabbarItem = mapTabbarItem
        tabbar.selectedItem = mapTabbarItem
        _ = setup(viewController: mapViewNavigationController,
                  direction: direction,
                  animated: animated)
    }
    
    fileprivate func setup(viewController controller: UIViewController?, direction: TransitionDirection, animated: Bool = true, duration: Double = 0.25) -> Bool {
        if controller != nil && currentViewController != controller && !isAnimatingController {
            isAnimatingController = true
            currentViewController?.view.endEditing(true)
            
            if let controller = controller {
                // Initial state
                var xOffset = containerView.frame.width * 0.15
                switch direction {
                case .left: xOffset *= -1
                case .right: break
                case .top: break
                case .bottom: break
                }
                
                controller.view.frame = containerView.bounds.offsetBy(dx: xOffset, dy: 0)
                controller.view.alpha = 0
                
                addChildViewController(controller)
                containerView.addSubview(controller.view)
                controller.willMove(toParentViewController: self)
                
                // Transition blocks
                let animationBlock = { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    controller.view.translatesAutoresizingMaskIntoConstraints = true
                    controller.view.frame = strongSelf.containerView.bounds
                    controller.view.alpha = 1
                }
                
                let completionBlock: ((Bool) -> Void) = { [weak self] (finished: Bool) -> Void in
                    guard let strongSelf = self else { return }
                    
                    // Remove previous view
                    strongSelf.currentViewController?.removeFromParentViewController()
                    strongSelf.currentViewController?.view.removeFromSuperview()
                    
                    // Apply new constraints
                    controller.didMove(toParentViewController: strongSelf)
                    strongSelf.containerView.fit(toSubview: controller.view)
                    strongSelf.currentViewController = controller
                    strongSelf.isAnimatingController = false
                }
                
                if animated {
                    UIView.transition(with: containerView,
                                      duration: duration,
                                      options: .curveEaseOut,
                                      animations: animationBlock,
                                      completion: completionBlock)
                } else {
                    animationBlock()
                    completionBlock(true)
                }
            }
            
            return true
        }
        
        return false
    }
}

// MARK: - UITabBarDelegate

extension HomeViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        var controller: UIViewController?
        var direction: TransitionDirection = .left
        
        // Controller
        if item == listTabbarItem {
            controller = listViewNavitationController
        } else if item == mapTabbarItem {
            controller = mapViewNavigationController
        }
        
        // Direction
        if let currentTabbarItem = currentTabbarItem {
            if item.tag >= currentTabbarItem.tag {
                direction = .right
            } else {
                direction = .left
            }
        }
        
        // Setup
        if let controller = controller {
            if setup(viewController: controller, direction: direction) {
                currentTabbarItem = item
            } else {
                if let navController = controller as? NavigationController {
                    navController.popToRootViewController(animated: true)
                }
                tabbar.selectedItem = currentTabbarItem
            }
        }
    }
}

// MARK: - WebcamCarouselViewControllerDelegate

extension HomeViewController: WebcamCarouselViewControllerDelegate {
    func webcamCarouselDidTriggerSettings(viewController: WebcamCarouselViewController) {
        let settingsVC = SettingsViewController()
        let navigationVC = NavigationController(rootViewController: settingsVC)
        
        navigationVC.modalPresentationStyle = .overCurrentContext
        
        present(navigationVC, animated: true, completion: nil)
        AnalyticsManager.logEvent(button: "settings")
    }
}

