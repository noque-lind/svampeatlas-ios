//
//  NewObservationVC.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 18/06/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class NewObservationVC: UIViewController {
    
    private var backgroundView: GradientView = {
       let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var menuButton: UIButton = {
      let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "MenuButton"), for: [])
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 31).isActive = true
        button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appWhite()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        return view
    }()
    
    private lazy var containerStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createView(image: #imageLiteral(resourceName: "Camera"), text: "Få hjælp til at finde ud af hvilken art det er, ved at bruge kameraet", tag: 0))
        stackView.addArrangedSubview(createView(image: #imageLiteral(resourceName: "PaperAndPen"), text: "Du er hardcore, og kender allerede navnet på arten du har fundet.", tag: 1))
        return stackView
    }()
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dividerView.layer.cornerRadius = dividerView.frame.height / 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.eLRevealViewController()?.edgePan.delegate = self
    }
    
    
    
    private func setupView() {
        view.backgroundColor = UIColor.appPrimaryColour()
        
        view.addSubview(backgroundView)
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(containerStackView)
        containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerStackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(menuButton)
        menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        
        
        view.addSubview(dividerView)
        dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        dividerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func createView(image: UIImage, text: String, tag: Int) -> UIView {
        let containerView: UIView = {
           let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.clear
            view.tag = tag
            
            let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(viewWasHeld(sender:)))
            longPressGestureRecognizer.minimumPressDuration = 0.0
            longPressGestureRecognizer.allowableMovement = 5
            longPressGestureRecognizer.delegate = self        
            view.addGestureRecognizer(longPressGestureRecognizer)
            
            return view
        }()
        
        let contentStackView: UIStackView = {
           let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.alignment = .center
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView: UIImageView = {
               let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                imageView.image = image
                return imageView
            }()
            
            let label: UILabel = {
               let label = UILabel()
                label.font = UIFont.appPrimaryHightlighed()
                label.textColor = UIColor.appWhite()
                label.text = text
                label.textAlignment = .center
                label.numberOfLines = 0
                return label
            }()
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(label)
            return stackView
        }()
        
        containerView.addSubview(contentStackView)
        contentStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        contentStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        contentStackView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        return containerView
    }

    @objc private func menuButtonTapped() {
        self.eLRevealViewController()?.toggleSideMenu()
    }
    
    @objc private func viewWasHeld(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            sender.view?.backgroundColor = UIColor.appWhite().withAlphaComponent(0.2)
        case .ended:
            sender.view?.backgroundColor = UIColor.clear
            if (sender.location(in: sender.view).y > (sender.view?.bounds.maxY)!) || (sender.location(in: sender.view).y < (sender.view?.bounds.minY)!) {
                print("Cancelled")
            } else {
                switch sender.view!.tag {
                case 0:
                    self.eLRevealViewController()?.pushNewViewController(viewController: UINavigationController(rootViewController: RecognizeVC(isObservation: true)))
                case 1:
                    self.eLRevealViewController()?.pushNewViewController(viewController: UINavigationController(rootViewController: NewObservationVC2()))
                default: return
                }
            }
        default:
            return
        }
    }
}

extension NewObservationVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


