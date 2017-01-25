////
////  FolderListViewController.swift
////  Piano
////
////  Created by 김찬기 on 2016. 11. 20..
////  Copyright © 2016년 Piano. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class FolderListViewController: UIViewController {
//    
//    var isRestoreState: Bool = true
//    @IBOutlet weak var tableView: UITableView!
//    var indicatingCell: () -> Void = {}
//    let coreDataStack = PianoData.coreDataStack
//    
//    @IBOutlet var addFolderButton: UIButton!
//    @IBAction func tapAddFolderButton(_ sender: Any) {
//        guard let fetchedObjects = resultsController.fetchedObjects else { return }
//        let alert = UIAlertController(title: "새로운 폴더", message: "이 폴더의 이름을 입력하십시오.", preferredStyle: .alert)
//        
//        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in }
//        let ok = UIAlertAction(title: "저장", style: .default) { [unowned self](action) in
//            guard let text = alert.textFields?.first?.text else { return }
//            let context = self.coreDataStack.viewContext
//            do {
//                let newFolder = Folder(context: context)
//                newFolder.name = text
//                newFolder.order = Int16(fetchedObjects.count)
//                newFolder.memos = []
//                
//                try context.save()
//            } catch {
//                print("Error importing folders: \(error.localizedDescription)")
//            }
//        }
//        
//        ok.isEnabled = false
//        alert.addAction(cancel)
//        alert.addAction(ok)
//        
//        alert.addTextField { (textField) in
//            textField.placeholder = "이름"
//            textField.returnKeyType = .done
//            textField.enablesReturnKeyAutomatically = true
//            textField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
//        }
//        
//        present(alert, animated: true, completion: nil)
//        
//    }
//    
//    func textChanged(sender: AnyObject) {
//        let tf = sender as! UITextField
//        var resp : UIResponder! = tf
//        while !(resp is UIAlertController) { resp = resp.next }
//        let alert = resp as! UIAlertController
//        alert.actions[1].isEnabled = (tf.text != "")
//    }
//    
//    lazy var resultsController: NSFetchedResultsController<Folder> = {
//        let context = self.coreDataStack.viewContext
//        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
//        let dateSort = NSSortDescriptor(key: #keyPath(Folder.order), ascending: true)
//        request.sortDescriptors = [dateSort]
//        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: nil, cacheName: nil)
//        controller.delegate = self
//        return controller
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        do {
//            try resultsController.performFetch()
//        } catch {
//            print("Error performing fetch \(error.localizedDescription)")
//        }
//        
//        
//        if !isRestoreState {
//            //갯수가 0보다 크다면 맨 위에 폴더를 넘겨 세그웨이 실행
//            if let objects = resultsController.fetchedObjects, objects.count > 0 {
//                let indexPath = IndexPath(row: 0, section: 0)
//                performSegue(withIdentifier: "MemoList", sender: resultsController.object(at: indexPath))
//            }
//        }
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        indicatingCell()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(FolderListViewController.preferredContentSizeChanged(notification:)), name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
//    }
//    
//    func preferredContentSizeChanged(notification: Notification) {
//        tableView.reloadData()
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "MemoList" {
//            
//            if let folder = sender as? Folder {
//                let des = segue.destination as! MemoListViewController
//                des.title = folder.name
//                des.folder = folder
//            }
//        }
//    }
//}
//
//extension FolderListViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "FolderCell")
//        //TODO: localization
//        
//        configure(cell: cell, at: indexPath)
//        return cell
//    }
//    
//    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
//        let folder = resultsController.object(at: indexPath)
//        
//        cell.textLabel?.text = folder.name
//        cell.textLabel?.textColor = #colorLiteral(red: 0.2558659911, green: 0.2558728456, blue: 0.2558691502, alpha: 1)
//        cell.detailTextLabel?.textColor = #colorLiteral(red: 0.2558659911, green: 0.2558728456, blue: 0.2558691502, alpha: 1)
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return resultsController.sections?.count ?? 0
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return resultsController.sections?[section].numberOfObjects ?? 0
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Folder"
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return addFolderButton
//    }
//}
//
//extension FolderListViewController: UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 44
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 44
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let folder = resultsController.object(at: indexPath)
//        performSegue(withIdentifier: "MemoList", sender: folder)
//        
//        indicatingCell = { [unowned self] in
//            self.tableView.deselectRow(at: indexPath, animated: true)
//        }
//    }
//    
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        
//        //폴더를 지우면 영원히 복구할 수 없다는 경고 메시지를 띄워주기
//        let alert = UIAlertController(title: "폴더를 삭제하겠습니까?", message: "폴더를 삭제하면 그 안에 있던 메모들을 복구할 방법이 없습니다.", preferredStyle: .alert)
//        
//        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in }
//        let delete = UIAlertAction(title: "삭제", style: .destructive) { [unowned self](action) in
//            let folder = self.resultsController.object(at: indexPath)
//            
//            for item in folder.memos {
//                let memo = item as! Memo
//                self.coreDataStack.viewContext.delete(memo)
//            }
//            self.coreDataStack.viewContext.delete(folder)
//        }
//        alert.addAction(cancel)
//        alert.addAction(delete)
//        
//
//        present(alert, animated: true, completion: nil)
//    }
//}
//
//extension FolderListViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .delete:
//            guard let indexPath = indexPath else { return }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        case .insert:
//            guard let newIndexPath = newIndexPath else { return }
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
//        case .update:
//            guard let indexPath = indexPath else { return }
//            if let cell = tableView.cellForRow(at: indexPath) {
//                configure(cell: cell, at: indexPath)
//            }
//        case .move:
//            guard let indexPath = indexPath,
//                let newIndexPath = newIndexPath else { return }
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
//        }
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
//}
//
//extension FolderListViewController {
//    override func applicationFinishedRestoringState() {
//        
//        do {
//            try resultsController.performFetch()
//        } catch {
//            print("Error performing fetch \(error.localizedDescription)")
//        }
//        
//    }
//}