//
//  NotesViewModel.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 27/08/2021.
//  Copyright © 2021 NaturhistoriskMuseum. All rights reserved.
//

import CoreData
import ELKit
import Foundation

class NotebookViewModel: NSObject, NSFetchedResultsControllerDelegate {
        
    private let session: Session
    private let controller: NSFetchedResultsController<CDNote>
    
    let notes = ELListener<SimpleState<[CDNote]>>.init(.empty)
    let deleteNote = ELEvent<IndexPath>.init()
    let show = ELEvent<ELNotificationView>.init()
    let present = ELEvent<UIViewController>.init()
    let loading = ELListener<Bool>.init(false)
    
    init(session: Session) {
        self.session = session
        controller = Database.instance.notesRepository.getController()
   
        super.init()
        controller.delegate = self
        getNotes()
        evaluteData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert, .update:
            evaluateNotes()
        default: return
        }
    }
    
    private func getNotes() {
        do {
           try? controller.performFetch()
            evaluateNotes()
        }
    }
    
    private func evaluateNotes() {
        if let fetchedObjects = controller.fetchedObjects, !fetchedObjects.isEmpty {
            notes.set(.items(item: fetchedObjects))
        } else {
            notes.set(.error(error: CoreDataError.noEntries(category: .Notes), handler: nil))
        }
    }
    
    private func evaluteData() {
        func shouldDownload() {
            show.post(value: .appNotification(style: .action(backgroundColor: .appPrimaryColour(), actions: [.positive(NSLocalizedString("action_fetchData", comment: ""), { [weak self] in
                self?.present.post(value: OfflineDownloader())
            }), .neutral(NSLocalizedString("action_no", comment: ""), {
        
            })]), primaryText: NSLocalizedString("prompt_taxonData_title", comment: ""), secondaryText: NSLocalizedString("prompt_taxonData_message", comment: ""), location: .bottom))
        }
        
        if UserDefaultsHelper.shouldUpdateDatabase {
                shouldDownload()
        }
    }
    
    func deleteNote(note: CDNote, indexPath: IndexPath) {
        Database.instance.notesRepository.delete(note: note) { [weak self] result in
            switch result {
            case .success:
                    self?.deleteNote.post(value: indexPath)
            case .failure(let error):
                return
            }
        }
    }
}
