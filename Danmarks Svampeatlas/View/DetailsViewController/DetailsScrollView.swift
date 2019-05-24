//
//  CustomScrollView.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 29/05/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
import MapKit
class AppScrollView: UIScrollView {
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = UIStackView.Distribution.fill
        stackView.spacing = 24
        return stackView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        return view
    }()
    
    weak var customDelegate: NavigationDelegate?
    
    init() {
        super.init(frame: CGRect.zero)
        contentInsetAdjustmentBehavior = .never
        setupView()
    }
    
    deinit {
        print("AppScrollView deinited")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    func addContent(title: String, content: UIView) -> UIStackView {
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 2
            
            let dividerLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appDivider()
                label.textColor = UIColor.appWhite()
                label.text = title
                return label
            }()
            
            stackView.addArrangedSubview(dividerLabel)
    if content is UIScrollView {
    
    }
            stackView.addArrangedSubview(content)
            return stackView
    }()
        contentStackView.addArrangedSubview(stackView)
        return stackView
        
    }
    
    func configureHeader(title: String, subtitle: String?, user: String?) {
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 4
            
            let titleLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appHeader()
                label.textColor = UIColor.appWhite()
                label.textAlignment = .center
                label.text = title
                return label
            }()
            
            stackView.addArrangedSubview(titleLabel)
            
            if let subtitle = subtitle, subtitle != "" {
                let subtitleLabel: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.appPrimaryHightlighed()
                    label.textColor = UIColor.appWhite()
                    label.textAlignment = .center
                    label.text = subtitle
                    return label
                }()
                
                stackView.addArrangedSubview(subtitleLabel)
            }
            
            if let user = user, user != "" {
                let userStackView: UIStackView = {
                    let stackView = UIStackView()
                    stackView.axis = .horizontal
                    stackView.spacing = 4
                    
                    let iconView: UIImageView = {
                        let view = UIImageView()
                        view.translatesAutoresizingMaskIntoConstraints = false
                        view.image = #imageLiteral(resourceName: "Profile")
                        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                        return view
                    }()
                    
                    let userLabel: UILabel = {
                        let label = UILabel()
                        label.font = UIFont.appPrimaryHightlighed()
                        label.textColor = UIColor.appWhite()
                        label.textAlignment = .center
                        label.text = user
                        return label
                    }()
                    
                    stackView.addArrangedSubview(iconView)
                    stackView.addArrangedSubview(userLabel)
                    return stackView
                }()
                stackView.addArrangedSubview(userStackView)
            }
            return stackView
        }()
        contentStackView.addArrangedSubview(stackView)
    }
    
    func configureHeader(title: NSAttributedString, subtitle: NSAttributedString?, user: String?) {
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 4
            
            let titleLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appHeader()
                label.textColor = UIColor.appWhite()
                label.textAlignment = .center
                label.attributedText = title
                return label
            }()
            
            stackView.addArrangedSubview(titleLabel)
            
            if let subtitle = subtitle, subtitle.string != "" {
                let subtitleLabel: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.appPrimaryHightlighed()
                    label.textColor = UIColor.appWhite()
                    label.textAlignment = .center
                    label.attributedText = subtitle
                    return label
                }()
                
                stackView.addArrangedSubview(subtitleLabel)
            }
            
            if let user = user, user != "" {
                let userStackView: UIStackView = {
                    let stackView = UIStackView()
                    stackView.axis = .horizontal
                    stackView.spacing = 4
                    
                    let iconView: UIImageView = {
                        let view = UIImageView()
                        view.translatesAutoresizingMaskIntoConstraints = false
                        view.image = #imageLiteral(resourceName: "Profile")
                        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
                        return view
                    }()
                    
                    let userLabel: UILabel = {
                        let label = UILabel()
                        label.font = UIFont.appPrimaryHightlighed()
                        label.textColor = UIColor.appWhite()
                        label.textAlignment = .center
                        label.text = user
                        return label
                    }()
                    
                    stackView.addArrangedSubview(iconView)
                    stackView.addArrangedSubview(userLabel)
                    return stackView
                }()
                stackView.addArrangedSubview(userStackView)
            }
            return stackView
        }()
        contentStackView.addArrangedSubview(stackView)
    }

    
    func configureText(title: String, text: String?) {
        guard let text = text, text != "" else {return}
        
        let textLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.appPrimary()
            label.textColor = UIColor.appWhite()
            label.textAlignment = .justified
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 0
            label.text = text
            return label
        }()
        
        _ = addContent(title: title, content: textLabel)
    }
    
    func configureInformation(information: [(String, String)]) {
        guard information.count != 0 else {return}
        
        func createStackView(_ withInfo: (String, String)) -> UIStackView {
            let leftLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimary()
                label.textColor = UIColor.appWhite()
                label.text = withInfo.0
                label.textAlignment = .left
                return label
            }()
            
            let rightLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimaryHightlighed()
                label.textColor = UIColor.appWhite()
                label.text = withInfo.1
                label.textAlignment = .right
                return label
            }()
            
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.distribution = .fillEqually
                stackView.addArrangedSubview(leftLabel)
                stackView.addArrangedSubview(rightLabel)
                return stackView
            }()
            return stackView
        }
        
        let stackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 2
            
            let dividerLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appDivider()
                label.textColor = UIColor.appWhite()
                label.text = "Statistik"
                return label
            }()
            
            stackView.addArrangedSubview(dividerLabel)
            _ = information.map({stackView.addArrangedSubview(createStackView($0))})
            return stackView
        }()
        
        contentStackView.addArrangedSubview(stackView)
    }
}

class DetailsScrollView: UIScrollView {
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = UIStackView.Distribution.fill
        stackView.spacing = 30
        return stackView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        contentStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        return view
    }()
    
    private lazy var upperStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var informationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var redlistStackViewViewAndToxicityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var speciesViewStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private lazy var observationsTableView: ObservationsTableView = {
        let tableView = ObservationsTableView(automaticallyAdjustHeight: true)
        return tableView
    }()
    
    lazy var similarSpeciesView: SimilarSpeciesView = {
        let similarSpeciesView = SimilarSpeciesView()
        similarSpeciesView.translatesAutoresizingMaskIntoConstraints = false
        similarSpeciesView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        return similarSpeciesView
    }()
    
    private lazy var commentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        
        let label: UILabel = {
            let label = UILabel()
            label.font = UIFont.appPrimaryHightlighed()
            label.textColor = UIColor.appWhite()
            label.text = "Kommentarer"
            return label
        }()
        
        stackView.addArrangedSubview(label)
        return stackView
    }()
    
    
    weak var customDelegate: NavigationDelegate? {
        didSet {
//            observationsTableView.delegate = self.customDelegate
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        contentInsetAdjustmentBehavior = .never
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        addSubview(contentView)
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    
    public func configureScrollView(withMushroom mushroom: Mushroom) {
        configureUpperStackView(isObservation: false, first: mushroom.danishName ?? mushroom.fullName, second: mushroom.danishName != nil ? mushroom.fullName: mushroom.danishName, third: mushroom.attributes?.ecology, fouth: mushroom.attributes?.diagnosis)
        
        var informationArray = [(String, String)]()
        if let totalObservations = mushroom.totalObservations {
            informationArray.append(("Antal danske fund", "\(totalObservations)"))
        }
        
        if let latestAcceptedRecord = mushroom.lastAcceptedObservation {
            informationArray.append(("Seneste danske fund", Date(ISO8601String: latestAcceptedRecord)?.convert(into: DateFormatter.Style.long) ?? ""))
        }
        if let updatedAt = mushroom.updatedAt {
        informationArray.append(("Sidst opdateret d.:", Date(ISO8601String: updatedAt)?.convert(into: DateFormatter.Style.medium) ?? ""))
        }
        configureInformationStackView(informations: informationArray)
        
        configureRedlistInformation(redlistStatus: mushroom.redlistData?.status)
        configureToxicityInformation(toxicityLevel: mushroom.attributes?.toxicityLevel)
        configureLatestObservationsView(taxonID: mushroom.id)
    }
    
    public func configureScrollView(withObservation observation: Observation, showSpeciesView: Bool) {
       
    }
    
    private func configureComments(comments: [Comment]) {
//        guard comments.count > 0 else {return}
//        let commentsTableView: CommentsTableView = {
//            let tableView = CommentsTableView()
////            tableView.configure(comments: comments)
//            return tableView
//        }()
//        commentsStackView.addArrangedSubview(commentsTableView)
//        contentStackView.addArrangedSubview(commentsStackView)
    }
    
    private func configureUpperStackView(isObservation: Bool, first: String?, second: String?, third: String?, fouth: String?) {
        if let first = first, first != "" {
            let label: UILabel = {
                let label = UILabel()
                label.font = UIFont.appHeader()
                label.textColor = UIColor.appWhite()
                label.textAlignment = .center
                return label
            }()
            
            if isObservation {
                label.text = "Fund af: \(first)"
            } else {
                label.text = first
            }
            upperStackView.addArrangedSubview(label)
        }
            
            if let second = second, second != "" {
                let label: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.appPrimary()
                    label.textColor = UIColor.appWhite()
                    label.textAlignment = .center
                    return label
                }()
                
                if isObservation {
                    let userStackView = UIStackView()
                    userStackView.axis = .horizontal
                    userStackView.spacing = 5
                    
                    let iconView = UIImageView()
                    iconView.image = #imageLiteral(resourceName: "Profile")
                    iconView.translatesAutoresizingMaskIntoConstraints = false
                    iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
                    
                    label.text = second
                    userStackView.addArrangedSubview(iconView)
                    userStackView.addArrangedSubview(label)
                    upperStackView.addArrangedSubview(userStackView)
                } else {
                    label.text = second
                    upperStackView.addArrangedSubview(label)
                }
            }
            
            if let third = third, third != "" {
                let label: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.appPrimaryHightlighed()
                    label.textColor = UIColor.appWhite()
                    label.textAlignment = .justified
                    label.numberOfLines = 0
                    return label
                }()
                
                label.text = third
                upperStackView.addArrangedSubview(label)
            }
            
            if let fourth = fouth, fouth != "" {
                let label: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.appPrimary()
                    label.textColor = UIColor.appWhite()
                    label.textAlignment = .justified
                    label.numberOfLines = 0
                    return label
                }()
                
                label.text = fourth
                upperStackView.addArrangedSubview(label)
            }
            contentStackView.addArrangedSubview(upperStackView)
    }
    
    private func configureInformationStackView(informations: [(String, String)]) {
        func createStackView(_ withInfo: (String, String)) -> UIStackView {
            let leftLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimary()
                label.textColor = UIColor.appWhite()
                label.text = withInfo.0
                label.textAlignment = .left
                return label
            }()
            
            let rightLabel: UILabel = {
                let label = UILabel()
                label.font = UIFont.appPrimaryHightlighed()
                label.textColor = UIColor.appWhite()
                label.text = withInfo.1
                label.textAlignment = .right
                return label
            }()
            
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.addArrangedSubview(leftLabel)
                stackView.addArrangedSubview(rightLabel)
                return stackView
            }()
            return stackView
        }
        
        for information in informations {
            informationStackView.addArrangedSubview(createStackView(information))
        }
        if informationStackView.subviews.count > 0 {
            contentStackView.addArrangedSubview(informationStackView)
        }
    }
    
    private func configureRedlistInformation(redlistStatus: String?) {
        guard let status = redlistStatus else {return}
        
        let redlistView = RedlistView(detailed: true)
        redlistStackViewViewAndToxicityStackView.addArrangedSubview(redlistView)
        redlistView.configure(status)
        contentStackView.addArrangedSubview(redlistStackViewViewAndToxicityStackView)
    }
    
    private func configureToxicityInformation(toxicityLevel: ToxicityLevel?) {
        guard let toxicityLevel = toxicityLevel else {return}
        
        let toxicityView = ToxicityView()
        redlistStackViewViewAndToxicityStackView.addArrangedSubview(toxicityView)
        toxicityView.configure(toxicityLevel)
        
        if redlistStackViewViewAndToxicityStackView.superview == nil {
            contentStackView.addArrangedSubview(redlistStackViewViewAndToxicityStackView)
        }
    }
    
    
    
    private func configureLatestObservationsView(taxonID: Int?) {
        guard let taxonID = taxonID else {return}
        
        DataService.instance.getObservationsForMushroom(withID: taxonID, limit: 15, offset: 0) { [weak self] (result)  in
            switch result {
            case .Error(let error):
                self?.observationsTableView.tableViewState = .Error(error, nil)
            case .Success(let observations):
                self?.observationsTableView.tableViewState = .Paging(items: observations, max: nil)
            }
        }
    }
}
