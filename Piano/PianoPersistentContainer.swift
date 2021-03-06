//
//  PianoPersistentContainer.swift
//  Piano
//
//  Created by kevin on 2016. 12. 20..
//  Copyright © 2016년 Piano. All rights reserved.
//

import UIKit
import CoreData

class PianoPersistentContainer: NSPersistentContainer {
    
    weak var detailViewController: DetailViewController?
    
    func saveWhenAppWillBeTerminal() {
        detailViewController?.saveCoreDataWhenExit(isTerminal: true)
    }
    
    func saveWhenAppGoToBackground() {
        detailViewController?.saveCoreDataWhenExit(isTerminal: false)
    }
    
    func makeKeyboardHide(){
        detailViewController?.textView?.makeTappable()
        detailViewController?.textView?.becomeFirstResponder()
        detailViewController?.textView?.resignFirstResponder()
        
        DispatchQueue.main.async { [weak self] in
            self?.detailViewController?.tapFinishEffect()
        }
    }
}
