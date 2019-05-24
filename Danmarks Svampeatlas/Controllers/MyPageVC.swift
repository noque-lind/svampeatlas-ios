//
//  MyPageVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 24/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MyPageVC: UIViewController, UIGestureRecognizerDelegate {

    private lazy var customNavigationBar: CustomNavigationBar = {
        let view = CustomNavigationBar()
        view.configureTitle(session.user.name)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: UIBarButtonItem.Style.plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu))
        return button
    }()
    
    private lazy var userView: UserView = {
       let view = UserView()
        view.translatesAutoresizingMaskIntoConstraints = false
         view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        view.configure(user: session.user)
        return view
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
            customNavigationBar.heightConstraint?.constant = navigationBarFrame.maxY
            scrollView.contentInset = UIEdgeInsets(top: (180 + 32) + view.safeAreaInsets.top, left: 0.0, bottom: view.safeAreaInsets.bottom, right: 0.0)
            scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 180 + 32, left: 0.0, bottom: 0, right: 0.0)
        }
        super.viewWillLayoutSubviews()
    }
    
    private func setupView() {
        let gradientView: GradientView = {
            let view = GradientView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        view.insertSubview(gradientView, at: 0)
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(userView)
        userView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        userView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(customNavigationBar)
        customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        customNavigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    deinit {
        print("MyPageVC Was deinited")
    }
}

extension MyPageVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let adjustedContentOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollView == self.scrollView {
            
            userView.transform = CGAffineTransform(translationX: 0, y: -adjustedContentOffset)
            customNavigationBar.changeAlpha((adjustedContentOffset - 80) / 100)
            }
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

