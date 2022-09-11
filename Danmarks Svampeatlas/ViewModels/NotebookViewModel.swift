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
        case .delete:
            guard let indexPath = indexPath else {return}
            deleteNote.post(value: indexPath)
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
        
        if let lastUpdateDate = UserDefaultsHelper.lastDataUpdateDate {
            let components = NSCalendar.current.dateComponents([Calendar.Component.day, Calendar.Component.hour], from: lastUpdateDate, to: Date())
            if let day = components.day, day > 30 {
                shouldDownload()
            }
        } else {
            shouldDownload()
        }
    }
    
    func deleteNote(note: CDNote, indexPath: IndexPath) {
        Database.instance.notesRepository.delete(note: note) { [weak self] result in
            switch result {
            case .success:
                print("here")
//                self?.deleteNote.post(value: indexPath)
            case .failure(let error):
                return
            }
        }
    }
    
    func uploadNote(note: CDNote, indexPath: IndexPath) {
        let userObservation = UserObservation(note)
        loading.set(true)
        session.uploadObservation(userObservation: .init(note)) { [weak self] result in
            self?.loading.set(false)
            DispatchQueue.main.async {
                switch result {
                case .success((let id, let imageCount)):
                    Database.instance.notesRepository.delete(note: note) { _ in }
                    if imageCount == userObservation.images.count {
                        self?.show.post(value: .appNotification(style: .success, primaryText: NSLocalizedString("addObservationVC_successfullUpload_title", comment: ""), secondaryText: "DMS: \(id)", location: .bottom))
                    } else {
                        self?.show.post(value: .appNotification(style: .warning(actions: nil), primaryText: NSLocalizedString("addObservationVC_successfullUpload_title", comment: ""), secondaryText: String(format: NSLocalizedString("addObservationError_imageUploadError", comment: ""), imageCount, userObservation.images.count), location: .bottom))
                    }
                case .failure(let error):
                    self?.show.post(value: .appNotification(style: .error(actions: nil), primaryText: error.title, secondaryText: error.message, location: .bottom))
                }
            }
        }
    }

}
