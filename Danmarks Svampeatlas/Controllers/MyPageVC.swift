//
//  MyPageVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 24/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MyPageVC: UIViewController, UIGestureRecognizerDelegate {

    private lazy var elNavigationBar: ELNavigationBar = {
       let view = ELNavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle(title: session.user.name)
        
        let userView: UserView = {
            let view = UserView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(user: session.user)
            return view
        }()
        
        view.backgroundColor = UIColor.clear
        view.setContentView(view: userView, ignoreSafeAreaLayoutGuide: false, maxHeight: 180, topPadding: 30.0, bottomPadding: 30.0)
        return view
    }()

    
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: UIBarButtonItem.Style.plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu))
        return button
    }()
    
    private lazy var scrollView: MyPageScrollView = {
        let view = MyPageScrollView(session: session)
        view.delegate = self
        view.navigationDelegate = self
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let session: Session
    
    init(session: Session) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        setupView()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.setLeftBarButton(menuButton, animated: false)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        super.viewDidAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        if let navigationBarFrame = self.navigationController?.navigationBar.frame {
            additionalSafeAreaInsets = UIEdgeInsets(top: -navigationBarFrame.height, left: 0.0, bottom: 0.0, right: 0.0)
            elNavigationBar.minHeight = navigationBarFrame.maxY
            
            if scrollView.contentInset.top != elNavigationBar.maxHeight {
                scrollView.contentInset.top = elNavigationBar.maxHeight
                scrollView.scrollIndicatorInsets.top = elNavigationBar.maxHeight
                scrollView.contentInset.bottom = view.safeAreaInsets.bottom
                scrollView.scrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
            }
        }
        super.viewWillLayoutSubviews()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.appSecondaryColour()
        
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(elNavigationBar)
        elNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        elNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        elNavigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    deinit {
        print("MyPageVC Was deinited")
    }
}

extension MyPageVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let appBarAdjustedOffset = scrollView.contentOffset.y + elNavigationBar.maxHeight
        let percent = 1 - (appBarAdjustedOffset / elNavigationBar.maxHeight)
        elNavigationBar.setPercentExpanded(percent)
        }
    }

extension MyPageVC: NavigationDelegate {
    func presentVC(_ vc: UIViewController) {
        self.eLRevealViewController()?.pushNewViewController(viewController: vc)
    }
    
    func pushVC(_ vc: UIViewController) {
        DispatchQueue.main.async {
             self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

