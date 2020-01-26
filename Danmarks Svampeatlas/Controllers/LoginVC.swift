//
//  LoginVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 20/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit
import SafariServices

class LoginVC: UIViewController {
    
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: UIBarButtonItem.Style.plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu))
        return button
    }()
    
    private var upperStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        

        let upperStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 0
            
    
            let upperLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimaryHightlighed()
                label.textColor = UIColor.appWhite()
                label.text = NSLocalizedString("loginVC_upperLabel", comment: "")
                return label
            }()
            
            let lowerLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appTitle()
                label.textColor = UIColor.appWhite()
                label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
                label.text = NSLocalizedString("loginVC_lowerLabel",  comment: "")
                return label
            }()
            
            stackView.addArrangedSubview(upperLabel)
            stackView.addArrangedSubview(lowerLabel)
            return stackView
        }()
        
        let detailsLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.appPrimary()
            label.textColor = UIColor.appWhite()
            label.numberOfLines = 0
            label.text = NSLocalizedString("loginVC_detailsLabel",  comment: "")
            return label
        }()
        
        stackView.addArrangedSubview(upperStackView)
        stackView.addArrangedSubview(detailsLabel)
        return stackView
    }()
    
    private var initialsTextField: ELTextField = {
        let textField = ELTextField()
        textField.font = UIFont.appPrimaryHightlighed()
        textField.textColor = UIColor.appWhite()
        textField.autocapitalizationType = .none
        textField.placeholder = NSLocalizedString("loginVC_initialsTextField_placeholder",  comment: "")
        textField.backgroundColor = UIColor.appSecondaryColour()
        textField.textContentType = .username
        textField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        textField.icon = #imageLiteral(resourceName: "Glyphs_Profile")
        return textField
    }()
    
    private var passwordTextField: ELTextField = {
        let textField = ELTextField()
        textField.font = UIFont.appPrimaryHightlighed()
        textField.textColor = UIColor.appWhite()
        textField.placeholder = NSLocalizedString("loginVC_passwordTextField_placeholder",  comment: "")
        textField.textContentType = .password
        textField.backgroundColor = UIColor.appSecondaryColour()
        textField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        textField.isSecureTextEntry = true
        textField.icon = #imageLiteral(resourceName: "Glyphs_Lock")
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.appGreen()
        button.setTitle(NSLocalizedString("loginVC_loginButton",  comment: ""), for: [])
        button.layer.cornerRadius = CGFloat.cornerRadius()
        button.layer.shadowOpacity = Float.shadowOpacity()
        button.layer.shadowOffset = CGSize.shadowOffset()
        button.titleLabel?.font = UIFont.appTitle()
        button.setTitleColor(UIColor.appWhite(), for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .highlighted)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(logInButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var createNewAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("loginVC_createNewAccountButton",  comment: ""), for: [])
        button.setTitleColor(UIColor.appWhite(), for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .highlighted)
        button.titleLabel?.font = UIFont.appPrimary()
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(createAccountPressed), for: .touchUpInside)
        return button
    }()
    
    @objc private func createAccountPressed() {
        let svc = SFSafariViewController(url: URL(string: "https://svampe.databasen.org/signup")!)
        present(svc, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = menuButton
        super.viewWillAppear(animated)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.upperStackView.transform = CGAffineTransform.identity
                self.upperStackView.alpha = 1
            }, completion: nil)
    }
    
    
    
    private func setupView() {
        view.backgroundColor = UIColor.appPrimaryColour()
    
        let gradientImageView: GradientImageView = {
            let view = GradientImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            
            view.setImage(image: #imageLiteral(resourceName: "Images_MushroomBackground"), fade: true)
            return view
        }()
        
        view.addSubview(gradientImageView)
        gradientImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        view.addConstraint(NSLayoutConstraint(item: gradientImageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 0.8, constant: 0.0))
        
        
        let textFieldStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 20
            stackView.addArrangedSubview(initialsTextField)
            stackView.addArrangedSubview(passwordTextField)
            stackView.addArrangedSubview(loginButton)
            stackView.addArrangedSubview(createNewAccountButton)
            return stackView
        }()
        
        view.addSubview(textFieldStackView)
        textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        textFieldStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        
        view.addSubview(upperStackView)
        upperStackView.leadingAnchor.constraint(equalTo: textFieldStackView.leadingAnchor).isActive = true
        upperStackView.trailingAnchor.constraint(equalTo: textFieldStackView.trailingAnchor).isActive = true
        upperStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -((view.frame.height / 2) / 2)).isActive = true
        upperStackView.alpha = 0
        upperStackView.transform = CGAffineTransform(translationX: 0.0, y: -50)
        
        
        ELKeyboardHelper.instance.registerObject(view: passwordTextField)
    }
    
    @objc private func logInButtonPressed() {
        guard let initials = initialsTextField.text, initials != "" else {initialsTextField.showError(message: NSLocalizedString("loginVC_initialsTextField_error", comment: "")); return}
        
        
        guard let password = passwordTextField.text, password != "" else {passwordTextField.showError(message: NSLocalizedString("loginVC_passwordTextField_error", comment: "")); return}
        view.endEditing(true)
        Spinner.start(onView: view)
        
        Session.login(initials: initials, password: password) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let session):
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                    appDelegate.session = session
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        Spinner.stop()
                        ELNotificationView.appNotification(style: .error(actions: nil), primaryText: error.errorTitle, secondaryText: error.errorDescription, location: .top)
                            .show(animationType: .fromTop)
                    }
                }
            }
        }
    }
}

