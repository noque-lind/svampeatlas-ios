//
//  TestController.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 22/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class TestController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        let textView = ELTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.appSecondaryColour()
        textView.textColor = UIColor.appWhite()
        textView.descriptionTextColor = UIColor.appWhite()
        view.addSubview(textView)
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        textView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        // Do any additional setup after loading the view.
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
