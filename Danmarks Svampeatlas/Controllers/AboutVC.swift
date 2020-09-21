//
//  AboutVC.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 13/09/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {

    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: UIBarButtonItem.Style.plain, target: self.eLRevealViewController(), action: #selector(self.eLRevealViewController()?.toggleSideMenu))
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.appConfiguration(translucent: false)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        title = NSLocalizedString("aboutVC_title", comment: "")
        view.backgroundColor = UIColor.appSecondaryColour()
        
         navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "Icons_MenuIcons_MenuButton"), style: .plain, target: eLRevealViewController(), action: #selector(eLRevealViewController()?.toggleSideMenu)), animated: false)
        
        let contentStackView: UIStackView = {
            func createImageViewWithImage(image: UIImage) -> UIImageView {
                let imageView = UIImageView(image: image)
                imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                imageView.contentMode = .scaleAspectFit
                return imageView
            }
            
            func createText(title: String, message: String) -> UIStackView {
                let header: SectionHeaderView = {
                    let view = SectionHeaderView()
                    view.configure(title: title)
                    return view
                }()
                
                let messageLabelStackView: UIStackView = {
                   let stackView = UIStackView()
                    stackView.isLayoutMarginsRelativeArrangement = true
                    stackView.layoutMargins = UIEdgeInsets(top: 0.0, left: 8, bottom: 0.0, right: 8)
                    let messageLabel: UILabel = {
                        let view = UILabel()
                        view.font = UIFont.appPrimary()
                        view.textColor = UIColor.appWhite()
                        view.backgroundColor = UIColor.clear
                        view.numberOfLines = 0
                        view.text = message
                        return view
                        }()
                    
                    stackView.addArrangedSubview(messageLabel)
                    return stackView
                }()
                
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 4
                stackView.addArrangedSubview(header)
                stackView.addArrangedSubview(messageLabelStackView)
                return stackView
                }
        
    
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 32
            stackView.distribution = .fill
            stackView.alignment = .fill
            
            stackView.addArrangedSubview(createImageViewWithImage(image: #imageLiteral(resourceName: "Images_Sponsors_KU")))
            stackView.addArrangedSubview(createImageViewWithImage(image: #imageLiteral(resourceName: "Images_Sponsors_Aage V. Jensen")))
            stackView.addArrangedSubview(createImageViewWithImage(image: #imageLiteral(resourceName: "Images_Sponsors_Svampekundskabens fremme")))
            stackView.addArrangedSubview(createImageViewWithImage(image: #imageLiteral(resourceName: "Images_Sponsors_fifteenJune")))
            stackView.addArrangedSubview(createText(title: NSLocalizedString("aboutVC_recognition_title", comment: ""), message: NSLocalizedString("aboutVC_recognition_message", comment: "")
))
            
            stackView.addArrangedSubview(createText(title: NSLocalizedString("aboutVC_general_title", comment: ""), message: NSLocalizedString("aboutVC_general_message", comment: "")))
            
            stackView.addArrangedSubview(createText(title: NSLocalizedString("aboutVC_generalTerms_title", comment: ""), message: NSLocalizedString("aboutVC_generalTerms_message", comment: "")))
            
            stackView.addArrangedSubview(createText(title: NSLocalizedString("aboutVC_qualityAssurance_title", comment: "  "), message: NSLocalizedString("aboutVC_qualityAssurance_message", comment: "")))
            
            stackView.addArrangedSubview(createText(title: NSLocalizedString("aboutVC_guidelines_title", comment: ""), message: NSLocalizedString("aboutVC_guidelines_message", comment: "")))
            return stackView
        }()
        
        
        let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(contentStackView)
            scrollView.contentInset = UIEdgeInsets(top: 16, left: 0.0, bottom: 16, right: 0.0)
            
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            return scrollView
        }()
        
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}
