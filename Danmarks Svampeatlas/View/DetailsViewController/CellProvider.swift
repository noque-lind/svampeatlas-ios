//
//  CellProvider.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 02/10/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import ELKit
import Then

protocol CellProviderDelegate: ObservationDetailHeaderCellDelegate, AddCommentCellDelegate {}

class CellProvider: NSObject, ELTableViewCellProvider {
    typealias CellItem = DetailsViewController.Item
    
    weak var delegate: CellProviderDelegate?
    
    func registerCells(tableView: UITableView) {
        tableView.register(ObservationDetailHeaderCell.self, forCellReuseIdentifier: String(describing: ObservationDetailHeaderCell.self))
        tableView.register(TextCell.self, forCellReuseIdentifier: String(describing: TextCell.self))
        tableView.register(MushroomCell.self, forCellReuseIdentifier: String(describing: MushroomCell.self))
        tableView.register(MushroomDetailsHeaderCell.self, forCellReuseIdentifier: String(describing: MushroomDetailsHeaderCell.self))
        tableView.register(InformationCell.self, forCellReuseIdentifier: String(describing: InformationCell.self))
        tableView.register(NewObservationCell.self, forCellReuseIdentifier: String(describing: NewObservationCell.self))
        tableView.register(MapViewCell.self, forCellReuseIdentifier: String(describing: MapViewCell.self))
        tableView.register(AddCommentCell.self, forCellReuseIdentifier: String(describing: AddCommentCell.self))
        tableView.register(CommentCell.self, forCellReuseIdentifier: String(describing: CommentCell.self))
    }
    
    func cellForItem(_ item: DetailsViewController.Item, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch item {
        case .mushroomHeader(mushroom: let mushroom):
            return tableView.dequeueReusableCell(withIdentifier: String(describing: MushroomDetailsHeaderCell.self), for: indexPath).then({($0 as? MushroomDetailsHeaderCell)?.configure(mushroom: mushroom)})
        case .observationHeader(observation: let observation):
            return tableView.dequeueReusableCell(withIdentifier: String(describing: ObservationDetailHeaderCell.self), for: indexPath).then({
                ($0 as? ObservationDetailHeaderCell)?.configure(observation: observation)
                ($0 as? ObservationDetailHeaderCell)?.delegate = self
            })
        case .text(text: let text):
            return tableView.dequeueReusableCell(withIdentifier: String(describing: TextCell.self), for: indexPath).then({($0 as? TextCell)?.configure(text: text)})
        case .informationView(information: let information):
            return tableView.dequeueReusableCell(withIdentifier: String(describing: InformationCell.self), for: indexPath).then({($0 as? InformationCell)?.configure(information: information)})
        case .observation(observation: let observation):
            return tableView.dequeueReusableCell(withIdentifier: String(describing: NewObservationCell.self), for: indexPath).then({($0 as? NewObservationCell)?.configure(observation: observation)})
        case .heatMap(userRegion: let userRegion, observations: let observations):
            return tableView.dequeueReusableCell(withIdentifier: String(describing: MapViewCell.self), for: indexPath).then({($0 as? MapViewCell)?.configure(userRegion: userRegion, observations: observations)})
        case .observationLocation(observation: let observation):
            return tableView.dequeueReusableCell(withIdentifier: String(describing: MapViewCell.self), for: indexPath).then({($0 as? MapViewCell)?.configure(observation: observation)})
        case .comment(comment: let comment):
            return tableView.dequeueReusableCell(withIdentifier: String(describing: CommentCell.self), for: indexPath).then({($0 as? CommentCell)?.configureCell(comment: comment)})
        case .addComment(session: _):
            return tableView.dequeueReusableCell(withIdentifier: String(describing: AddCommentCell.self), for: indexPath).then({
                ($0 as? AddCommentCell)?.configureCell(descriptionText: NSLocalizedString("commentsTableView_cell_title", comment: ""), placeholder: nil, content: nil, delegate: self)
                ($0 as? AddCommentCell)?.delegate = self
            })
        case .mushroom(mushroom: let mushroom):
            return tableView.dequeueReusableCell(withIdentifier: String(describing: MushroomCell.self), for: indexPath).then({
                ($0 as? MushroomCell)?.configureCell(mushroom: mushroom)
            })
        }
    }
    
    func heightForItem(_ item: DetailsViewController.Item, tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension CellProvider: ObservationDetailHeaderCellDelegate, AddCommentCellDelegate {
    func moreButtonPressed() {
        delegate?.moreButtonPressed()
    }
    
    func enterButtonPressed(withText: String) {
        delegate?.enterButtonPressed(withText: withText)
    }
}

extension CellProvider: ELTextViewDelegate {
    func shouldChangeHeight() {
        
    }
}
