//
//  TermsController.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 12/09/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class TermsController: UIViewController {

    private let header: SectionHeaderView = {
       let view = SectionHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let textView: UILabel = {
       let view = UILabel()
        view.font = UIFont.appPrimary()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor.appWhite()
        view.backgroundColor = UIColor.clear
        view.numberOfLines = 0
        return view
    }()
    
    private let acceptButton: UIButton = {
       let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Forstået", for: [])
        view.heightAnchor.constraint(equalToConstant: 70).isActive = true
        view.backgroundColor = UIColor.appGreen()
        view.addTarget(self, action: #selector(acceptButtonPressed), for: .touchUpInside)
        return view
    }()
    
    private let imageView: UIImageView = {
       let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowOpacity = Float.shadowOpacity()
        view.layer.shadowOffset = CGSize.shadowOffset()
        return view
    }()
        
    enum Terms {
        case mlPredict
        case localityHelper
    }
    
    private var heightAnchor = NSLayoutConstraint()
    private let terms: Terms
     var wasDismissed: (() -> ())?
    
    init(terms: Terms) {
        self.terms = terms
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configure()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        
        let contentStackView: UIStackView = {
           let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 16
            stackView.distribution = .fill
            stackView.alignment = .fill
            
            let headerViewContainer: UIView = {
               let view = UIView()
                view.backgroundColor = UIColor.clear
                view.addSubview(header)
                header.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
                header.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                header.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                header.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                return view
            }()
            
            let textViewContainer: UIView = {
               let view = UIView()
                view.backgroundColor = UIColor.clear
                view.addSubview(textView)
                textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
                textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
                textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
                textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                return view
            }()
            
            stackView.addArrangedSubview(headerViewContainer)
            stackView.addArrangedSubview(textViewContainer)
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(acceptButton)
            return stackView
        }()
        
        let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.backgroundColor = UIColor.appSecondaryColour()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(contentStackView)
            scrollView.layer.cornerRadius = 16
            
            contentStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            return scrollView
        }()
        
        view.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        scrollView.heightAnchor.constraint(lessThanOrEqualToConstant: (UIScreen.main.bounds.height) / 4 * 3).isActive = true
    }
    
    private func configure() {
        switch terms {
        case .mlPredict:
            header.configure(text: "Automatisk billedgenkendelse - du skal acceptere vores betingelser.")
            
            textView.text = """
            Brug af automatisk billedegenkendelse kan aldrig være helt præcis, og det er derfor vigtigt at systemet bruges med endnu mere kritisk sans end din svampebog. Spis aldrig svampe uden at søge hjælp fra svampekyndige mennesker. Danmarks Svampeatlas og Noque ApS frasiger sig ethvert ansvar for eventuelle forgiftninger eller andre sundhedsskadelige forhold.

            Systemet er udviklet af Milan Šulc og Professor Jiri Matas fra det Tjekkiske Tekniske Universitet (CTU) i Prag, Lukáš Picek fra University of West Bohemia (UWB) i Tjekkiet og Danmarks Svampeatlas. Systemet er baseret på kunstig intelligens og er trænet med alle de fotos I har biddraget med til Svampeatlasset. Jo mere du bidrager med observationer og gode billeder, jo bedre vil vi kunne udvikle teknologien i fremtiden.
            
            Dette system er stadig i udviklingsfase og vi vil meget gerne have jeres feedback så det kan laves endnu bedre i fremtiden. Start en tråd på vores Facebook gruppe, eller send en mail til app@noque.dk
            """
        case .localityHelper:
            header.configure(text: "Sådan justerer du dit funds lokation")
            imageView.loadGif(name: "LocalityHelper")
        }
    }
    
    @objc private func acceptButtonPressed() {
        UserDefaultsHelper.setHasAcceptedImagePredictionTerms(true)
        wasDismissed?()
        dismiss(animated: true, completion: nil)
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
