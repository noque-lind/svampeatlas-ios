//
//  TestController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 22/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class TestController: UIViewController {

    private var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return button
    }()
    
    private var button2: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.blue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped2), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 100).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100).isActive = true
        
        view.addSubview(button2)
        button2.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        button2.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
    
        
        
        
    }
    
    
    @objc private func buttonTapped() {
        let view = ELNotificationView(style: .success, primaryText: Date().convert(into: DateFormatter.Style.medium), secondaryText: nil)
        view.show(animationType: ELNotificationView.AnimationType.fromBottom)
        
    }
    
    @objc private func buttonTapped2() {
        let view = ELNotificationView(style: .error, primaryText: Date().convert(into: DateFormatter.Style.medium), secondaryText: nil)
        view.show(animationType: ELNotificationView.AnimationType.fromBottom, queuePosition: .front)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
