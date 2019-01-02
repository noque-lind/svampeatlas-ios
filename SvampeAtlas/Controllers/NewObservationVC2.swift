//
//  NewObservationVC2.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 06/12/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

fileprivate enum CreateObservationCategory: String, CaseIterable {
    case Species = "Art"
    case Details = "Detajler"
    case Location = "Lokalitet"
}

class NewObservationVC2: UIViewController {
    
    private var observationImagesView: ObservationImagesView = {
        let view = ObservationImagesView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 200).isActive = true
        return view
    }()
    
    
    private var newCategoryView: NewCategoryView<CreateObservationCategory> = {
        let items = CreateObservationCategory.allCases.compactMap({GenericRow<CreateObservationCategory>(type: $0, title: $0.rawValue)})
        
       let view = NewCategoryView<CreateObservationCategory>(withItems: items)
        return view
    }()
    
    private var categoryView: CategoryView = {
        let view = CategoryView(dynamicCellWidth: false, categories: [Category.init(title: "Art"), Category.init(title: "Detajler"), Category.init(title: "Lokalitet")], firstIndex: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
       let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.delegate = self
        view.dataSource = self
        view.register(ObservationDetailsCell.self, forCellWithReuseIdentifier: "observationDetailsCell")
        view.register(ObservationLocationCell.self, forCellWithReuseIdentifier: "observationLocationCell")
        view.register(ObservationSpecieCell.self, forCellWithReuseIdentifier: "observationSpecieCell")
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private var details = CreateObservationCategory.allCases
    
    
    var date = Date()
    var substrate: Substrate?
    var vegetationType: VegetationType?
    var notes: String?
    var ecologyNotes: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        observationImagesView.configure(images: [#imageLiteral(resourceName: "agaricus-arvensis1")])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        self.eLRevealViewController()?.delegate = self
        self.title = "Nyt fund"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.tintColor = UIColor.appWhite()
        self.navigationController?.navigationBar.barTintColor = UIColor.appPrimaryColour()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appWhite(), NSAttributedString.Key.font: UIFont.appHeader()]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        super.viewWillAppear(animated)
    }
    
    
    private func setupView() {
        view.backgroundColor = UIColor.appSecondaryColour()
        
        view.addSubview(observationImagesView)
        observationImagesView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        observationImagesView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        observationImagesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        view.addSubview(categoryView)
        categoryView.topAnchor.constraint(equalTo: observationImagesView.bottomAnchor).isActive = true
        categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: categoryView.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension NewObservationVC2: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return details.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch details[indexPath.row] {
        case .Species:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "observationSpecieCell", for: indexPath) as? ObservationSpecieCell else {fatalError()}
            return cell
        case .Location:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "observationLocationCell", for: indexPath) as? ObservationLocationCell else {fatalError()}
            return cell
        case .Details:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "observationDetailsCell", for: indexPath) as? ObservationDetailsCell else {fatalError()}
            cell.configure(date: date, substrate: substrate, vegetationType: vegetationType, notes: notes, ecologyNotes: ecologyNotes)
            return cell
        }
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}



class SelectorCell: UITableViewCell {
    
    private var iconImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 14).isActive = true
        view.widthAnchor.constraint(equalToConstant: 14).isActive = true
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appPrimaryHightlighed()
        label.textAlignment = .right
        label.textColor = UIColor.appWhite()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        contentLabel.textColor = selected ? UIColor.appThirdColour(): UIColor.appWhite()
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        heightAnchor.constraint(equalToConstant: 45).isActive = true
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.addSubview(iconImageView)
        iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        let stackView: UIStackView = {
            let view = UIStackView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.addArrangedSubview(descriptionLabel)
            view.addArrangedSubview(contentLabel)
            return view
        }()
        
        contentView.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func configureCell(icon: UIImage, description: String, content: String) {
        iconImageView.image = icon
        descriptionLabel.text = description
        contentLabel.text = content
    }
}
