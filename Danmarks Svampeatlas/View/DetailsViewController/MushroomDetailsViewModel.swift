//
//  MushroomDetailsViewModel.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 03/10/2020.
//  Copyright © 2020 NaturhistoriskMuseum. All rights reserved.
//

import Foundation
import ELKit

enum MushroomError: ELError {
    
    var title: String {
        return "some"
    }
    
    var message: String {
        return "some"
    }
    
    var recoveryAction: RecoveryAction? {
        return .activate
    }
    
    case any
}

class MushroomDetailsViewModel: NSObject {
    let mushroom = ELListener<State<Mushroom>>(.empty)

    init(id: Int) {
        DataService.instance.getMushroom(withID: id) { [weak mushroom] (result) in
            switch result {
            case .failure(let error):
                mushroom?.set(.error(error: MushroomError.any, handler: nil))
            case .success(let data):
                mushroom?.set(.items(items: [data]))
            }
        }
    }
}
