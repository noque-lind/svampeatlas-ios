//
//  AppDelegate.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 17/02/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import CoreData
import ELKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private lazy var navigationVC: NavigationVC = {
        return NavigationVC(session: nil)
    }()
    
    lazy var elRevealViewController: ELRevealViewController = {
        return ELRevealViewController(mainVC: OnboardingVC(), revealVC: navigationVC, revealVCPosition: .left, configuation: ELConfiguration.init(animationType: .flyerReveal, menuWidthPercentage: 0.7, menuThresholdPercentage: 0.3))
    }()
    
    var window: UIWindow?
    var session: Session? {
        didSet {
            navigationVC.session = session
            
            if let session = session {
                elRevealViewController.pushNewViewController(viewController: UINavigationController(rootViewController: MyPageVC(session: session)))
//                if !UserDefaultsHelper.hasSeenWhatsNew {
//                    elRevealViewController.currentViewController.present(TermsVC(terms: .whatsNew), animated: true, completion: nil)
//                    UserDefaultsHelper.hasSeenWhatsNew = true
//                }
               
            } else {
                elRevealViewController.pushNewViewController(viewController: UINavigationController(rootViewController: MushroomVC(session: session)))
            }
            
            if let awaitingController = awaitingController { present(vc: awaitingController) }
            onboarding = false
        }
    }
    
    private var onboarding = true
    private var awaitingController: UIViewController?
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard let url = userActivity.webpageURL else {return false}
        
        if url.host != "svampe.databasen.org" {
            // THE url is not correct and therefore we want safari to handle it
            application.open(url, options: [:], completionHandler: nil)
            return true
        } else {
            if url.pathComponents.contains("taxon") {
                guard let taxonID = Int(url.lastPathComponent) else {return false}
                let detailsViewController = DetailsViewController(detailsContent: .mushroomWithID(taxonID: Int(taxonID)), session: session)
                
                if onboarding {
                    awaitingController = detailsViewController
                } else {
                    present(vc: detailsViewController)
                }
            }
            return true
        }
    }
    
    private func present(vc: UIViewController) {
        if let navigationController = elRevealViewController.currentViewController as? UINavigationController {
            navigationController.pushViewController(vc, animated: false)
            if elRevealViewController.sideMenuShowing { elRevealViewController.toggleSideMenu() }
        } else {
            elRevealViewController.pushNewViewController(viewController: vc)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        // Short-circuit starting app if running unit tests
        let isUnitTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
        guard !isUnitTesting else {
            return true
        }
        #endif
        
        window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = elRevealViewController
        self.window?.makeKeyAndVisible()
        
        Database.instance.setup {
            Session.resumeSession { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let session):
                        self.session = session
                    case .failure:
                        self.session = nil
                    }
                }
            }
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //        self.saveContext()
    }
}
