//
//  MyPageVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 24/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MyPageVC: UIViewController, UIGestureRecognizerDelegate {

    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "MenuButton"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(menuButtonPressed))
        return button
    }()
    
    private var gradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var userView: UserView = {
       let view = UserView()
        view.translatesAutoresizingMaskIntoConstraints = false
         view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        UserService.instance.getUser(completion: { (user) in
            DispatchQueue.main.async {
                if let user = user {
                    view.configure(user: user)
                    self.customNavigationBar.configureTitle(user.name)
                    self.scrollView.configure(user: user)
                }
            }
        })
        return view
    }()
    
    private lazy var scrollView: MyPageScrollView = {
        let view = MyPageScrollView()
        view.delegate = self
        view.customDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var customNavigationBar: CustomNavigationBar = {
        let view = CustomNavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var hasBeenSetup = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.setLeftBarButton(menuButton, animated: false)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if !hasBeenSetup {
            setupView()
            hasBeenSetup = true
        }
//        self.eLRevealViewController()?.delegate = self
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        super.viewDidAppear(animated)
    }

    
    override func viewDidLayoutSubviews() {
        customNavigationBar.heightAnchor.constraint(equalToConstant: (self.navigationController?.navigationBar.frame.maxY)!).isActive = true
        customNavigationBar.navigationBarOffset = self.navigationController?.navigationBar.frame.origin.y
        
        scrollView.contentInset = UIEdgeInsets(top: view.safeAreaInsets.top + 180 + 16 + 16, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView.contentInset = UIEdgeInsets.init(top: scrollView.contentInset.top, left: 0.0, bottom: view.safeAreaInsets.bottom, right: 0.0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: scrollView.contentInset.top, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
    }
    
    private func setupView() {
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
        
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        view.addSubview(customNavigationBar)
        customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        customNavigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        print(self.navigationController?.navigationBar.frame.maxY)
        
        scrollView.delegate = self
    }
    
    @objc private func menuButtonPressed() {
        self.eLRevealViewController()?.toggleSideMenu()
    }
}

extension MyPageVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let adjustedContentOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollView == self.scrollView {
            
            userView.transform = CGAffineTransform(translationX: 0, y: -adjustedContentOffset)
            customNavigationBar.changeAlpha((adjustedContentOffset - 100) / 100)
            
            
//            let minValue = (max(adjustedContentOffset, 0))
//            print(minValue)
            print(adjustedContentOffset)
//            imagesCollectionView.configureTransform(deltaValue: minValue)
//            if minValue <= 0 {
//                imagesCollectionView.configureHeightConstraint(deltaValue: adjustedContentOffset)
            }
        }
    }

extension MyPageVC: NavigationDelegate {
    func presentVC(_ vc: UIViewController) {
        
    }
    
    func pushVC(_ vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

