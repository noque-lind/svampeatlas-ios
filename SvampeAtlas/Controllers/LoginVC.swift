//
//  LoginVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 20/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    private var gradientImageView: GradientImageView = {
        let view = GradientImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var initialsTextField: ELTextField = {
       let textField = ELTextField()
        textField.font = UIFont.appPrimaryHightlighed()
        textField.textColor = UIColor.appWhite()
        textField.autocapitalizationType = .none
        textField.placeholder = "Initialer"
        textField.textContentType = .username
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.icon = #imageLiteral(resourceName: "Profile")
        return textField
    }()
    
    private var passwordTextField: ELTextField = {
       let textField = ELTextField()
        textField.font = UIFont.appPrimaryHightlighed()
        textField.textColor = UIColor.appWhite()
        textField.placeholder = "Kodeord"
        textField.textContentType = .password
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.isSecureTextEntry = true
        textField.icon = #imageLiteral(resourceName: "Glyphs_Lock")
        ELKeyboardHelper.instance.registerObject(view: textField)
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.appGreen()
        button.setTitle("Log ind", for: [])
        button.titleLabel?.font = UIFont.appHeader()
        button.setTitleColor(UIColor.appWhite(), for: [])
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(logInButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.appPrimaryColour()
        
        view.addSubview(gradientImageView)
        gradientImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        view.addConstraint(NSLayoutConstraint(item: gradientImageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 0.5, constant: 0.0))
        
        let textFieldStackView: UIStackView = {
           let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 20
            stackView.addArrangedSubview(initialsTextField)
            stackView.addArrangedSubview(passwordTextField)
            stackView.addArrangedSubview(loginButton)
            return stackView
        }()
        
        view.addSubview(textFieldStackView)
        textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        textFieldStackView.topAnchor.constraint(equalTo: gradientImageView.bottomAnchor, constant: -30).isActive = true
        
        
        
        gradientImageView.setImage(image: #imageLiteral(resourceName: "agaricus-arvensis1"), fade: true)
    }
    
    @objc private func logInButtonPressed() {
        guard let initials = initialsTextField.text, let password = passwordTextField.text else {return}
        
        view.controlActivityIndicator(wantRunning: true)
        UserService.instance.login(initials: initials, password: password) { (appError) in
            
            if let appError = appError {
                DispatchQueue.main.async {
                    self.view.controlActivityIndicator(wantRunning: false)
                     self.present(UIAlertController(title: appError.title, message: appError.message), animated: true, completion: nil)
                }
               
            } else {
                DispatchQueue.main.async {
                    self.eLRevealViewController()?.pushNewViewController(viewController: UIViewController())
                }
            }
            }
    }

}

