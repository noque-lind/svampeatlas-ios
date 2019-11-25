//
//  ErrorCell.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 08/10/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class ErrorCell: UITableViewCell {
    
    static let identifier = "ErrorCell"
    
    private let errorView: ErrorView = {
       let view = ErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        
        contentView.addSubview(errorView)
        errorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        errorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        errorView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        errorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func configure(error: AppError, handler: ((RecoveryAction?) -> ())?) {
        errorView.configure(error: error, handler: handler)
    }
}
