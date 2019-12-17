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
}
