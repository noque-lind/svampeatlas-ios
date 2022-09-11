//
//  NoteCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 28/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import UIKit.UITableViewCell

class NoteCell: UITableViewCell {
    
    static let identifier = "NoteCell"
    
    private let mImageView = DownloadableImageView().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .appPrimaryColour()
    })
    
    private let imageCountLabel = PaddedLabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.paddingTop = 4
        $0.paddingBottom = 4
        $0.paddingLeft = 4
        $0.paddingRight = 4
        $0.textColor = .appWhite()
        $0.font = .appPrimaryHightlighed()
        $0.backgroundColor = .black.withAlphaComponent(0.7)
        $0.layer.maskedCorners = [CACornerMask.layerMinXMinYCorner]
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    })
    
    private let upperTitle = UILabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .appWhite()
        $0.font = .appMuted(customSize: 9)
    })
    
    private let mainTitle = UILabel().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .appWhite()
        $0.font = .appPrimaryHightlighed()
    })
    
    private let statusLabel = UILabel().then({
        $0.font = .appPrimaryHightlighed(customSize: 12)
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var actionButton = UIButton().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .appGreen()
        $0.setImage(#imageLiteral(resourceName: "Icons_MenuIcons_Upload"), for: [])
        $0.imageEdgeInsets = .init(top: 6, left: 6, bottom: 6, right: 6)
        $0.layer.cornerRadius = .cornerRadius()
        $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        $0.widthAnchor.constraint(equalTo: $0.heightAnchor).isActive = true
        $0.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        $0.clipsToBounds = true
    })
    
    var uploadPressed: (() -> Void)?
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        backgroundColor = highlighted ? UIColor.appSecondaryColour().withAlphaComponent(0.3): UIColor.clear
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        mImageView.image = #imageLiteral(resourceName: "Icons_Utils_Missing")
        mImageView.url = nil
        super.prepareForReuse()
    }
    
    @objc private func actionButtonPressed() {
        uploadPressed?()
    }
    
    private func setupView() {
        backgroundColor = .clear
        selectionStyle = .none
    
        let imageViewStackView = UIStackView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.alignment = .center
            $0.axis = .horizontal
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            let containerView = UIView().then({
                $0.backgroundColor = .clear
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.heightAnchor.constraint(equalTo: $0.widthAnchor).isActive = true
                $0.widthAnchor.constraint(equalToConstant: 70).isActive = true
                $0.layer.cornerRadius = .cornerRadius()
                $0.clipsToBounds = true
                $0.addSubview(mImageView)
                $0.addSubview(imageCountLabel)
                
                ELSnap.snapView(mImageView, toSuperview: $0)
                imageCountLabel.trailingAnchor.constraint(equalTo: $0.trailingAnchor).isActive = true
                imageCountLabel.bottomAnchor.constraint(equalTo: $0.bottomAnchor).isActive = true
            })
            
            $0.addArrangedSubview(containerView)
        })
        
        let textStackView = UIStackView().then({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fillProportionally
            $0.spacing = 2
            $0.addArrangedSubview(upperTitle)
            $0.addArrangedSubview(mainTitle)
        })
        
        contentView.do({
            $0.addSubview(imageViewStackView)
            $0.addSubview(textStackView)
            $0.addSubview(statusLabel)
            $0.addSubview(actionButton)
        })
        
        imageViewStackView.do({
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
            $0.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        })
        
        textStackView.do({
            $0.leadingAnchor.constraint(equalTo: imageViewStackView.trailingAnchor, constant: 16).isActive = true
            $0.topAnchor.constraint(equalTo: imageViewStackView.topAnchor, constant: 16).isActive = true
            $0.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -8).isActive = true
            $0.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -8).isActive = true
        })
        
        statusLabel.do({
            $0.leadingAnchor.constraint(equalTo: textStackView.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: textStackView.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: imageViewStackView.bottomAnchor, constant: -16).isActive = true
        })
        
        actionButton.do({
            $0.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        })
        
    }
    
    func configure(note: CDNote) {
        if let image = (note.images?.allObjects as? [CDNoteImage])?.first, let url = image.url {
            mImageView.loadImage(url: url)
        } else {
            mImageView.url = nil
            mImageView.image = #imageLiteral(resourceName: "Icons_Utils_Missing")
        }
        
        imageCountLabel.text = "\(note.images?.allObjects.count ?? 0)"
       
        upperTitle.text = "\(note.observationDate?.convert(into: .short, ignoreRecentFormatting: true, ignoreTime: true) ?? "Ingen dato") | \(note.locality?.name ?? "Lokation ikke valgt")"
        mainTitle.text = note.specie != nil ? (note.specie?.danishName ?? note.specie?.fullName): "Ikke valgt art"
        
//        guard note.specie != nil, note.vegetationType != nil, note.substrate != nil, note.locality != nil, note.location != nil else {
//            actionButton.isEnabled = false
//            statusLabel.text = NSLocalizedString("✗ Not ready for upload", comment: "")
//            statusLabel.textColor = .appRed()
//            return}
//        statusLabel.text = NSLocalizedString("✔︎ Ready for upload", comment: "")
//        statusLabel.textColor = .appGreen()
//        actionButton.isEnabled = true
    
    }
}
