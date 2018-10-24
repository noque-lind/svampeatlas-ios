//
//  MyPageVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 24/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class MyPageVC: UIViewController {

    private var gradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var userView: UserView = {
       let view = UserView()
        view.translatesAutoresizingMaskIntoConstraints = false
        UserService.instance.getUser(completion: { (user) in
            DispatchQueue.main.async {
                if let user = user {
                    view.configure(user: user)
                }
            }
           
        })
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.insertSubview(gradientView, at: 0)
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(userView)
        userView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        userView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        let button = UIButton()
        
        view.addSubview(button)
        button.setTitle("Log Out button", for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(logOutButtonPressed), for: .touchUpInside)
    }
    
    @objc private func logOutButtonPressed() {
        UserService.instance.logOut()
        self.eLRevealViewController()?.pushNewViewController(viewController: LoginVC())
    }
}
