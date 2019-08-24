//
//  OnboardingVC.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 29/04/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import ELKit

class OnboardingVC: UIViewController {

    private var actionLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onboard()
    }
    
    
    private func setupView() {
        let gradientView: GradientView = {
           let view = GradientView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        view.addSubview(gradientView)
        gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let contentStackview: UIStackView = {
           let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 20
            
            
            let spinnerStackview: UIStackView = {
               let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.alignment = .center
                
                let spinner: UIActivityIndicatorView = {
                    let view = UIActivityIndicatorView(style: .whiteLarge)
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.startAnimating()
                    return view
                }()
                
                stackView.addArrangedSubview(spinner)
                return stackView
            }()
            
            
            
            stackView.addArrangedSubview(actionLabel)
            stackView.addArrangedSubview(spinnerStackview)
            return stackView
        }()
        
        view.addSubview(contentStackview)
        contentStackview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        contentStackview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        contentStackview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func onboard() {
//        Session.resumeSession { (result) in
//            switch result {
//            case .Error:
//                DispatchQueue.main.async {
//                    self.actionLabel.text = "Fortsætter som gæst"
//                    self.pushVC(vc: UINavigationController(rootViewController: MushroomVC(session: nil)), session: nil)
//                }
//            case .Success(let session):
//                DispatchQueue.main.async {
//                    self.actionLabel.text = "Logger dig ind"
//                    self.pushVC(vc: UINavigationController(rootViewController: MyPageVC(session: session)), session: session)
//                }
//            }
//        }
    }
    
    private func pushVC(vc: UIViewController, session: Session?) {
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
//            let elReviewViewController = ELRevealViewController(mainVC: vc, revealVC: NavigationVC(session: session), revealVCPosition: .left, configuation: ELConfiguration.init(animationType: .flyerReveal, menuWidthPercentage: 0.7, menuThresholdPercentage: 0.3))
//            let delegate = UIApplication.shared.delegate as? AppDelegate
//            delegate?.elRevealViewController = elReviewViewController
//            UIApplication.shared.keyWindow?.rootViewController = elReviewViewController
//        }
    }
    
    deinit {
        print("OnboardingVC deinited")
    }
}
