
import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchRequest: NSFetchRequest<Task>!
    var tasks: [Task]!
    
    var masterViewDelegate: MasterViewController?
    
    func configureView() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTaskSegue"
        {
            if let addTaskViewController = segue.destination as? AddTaskViewController{
                addTaskViewController.currentCoursework = coursework
            }
        }
        if segue.identifier == "summarySegue"
        {
            if let summaryViewController = segue.destination as? SummaryViewController{
                summaryViewController.currentCoursework = coursework
                summaryViewController.masterViewDelegate = masterViewDelegate
            }
        }
    }
    
    var coursework: Coursework? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    //MARK: tableView delegate section
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        
        let task = fetchedResultsController.object(at: indexPath)
        
        cell.task = task
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        
        //
        
    }
    
    //MARK: fetch results controller
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<Task> {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        
        let currentCoursework  = self.coursework
        let request:NSFetchRequest<Task> = Task.fetchRequest()
        
        request.fetchBatchSize = 50
        
//change to date
        let taskNameSortDescriptior = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))

        request.sortDescriptors = [taskNameSortDescriptior]
        
        if(self.coursework != nil){
            let predicate = NSPredicate(format: "courseworkRelationship = %@", currentCoursework!)
            request.predicate = predicate
        }
        else {
            let predicate = NSPredicate(format: "courseworkRelationship = %@", "")
            request.predicate = predicate
        }
        
        let frc = NSFetchedResultsController<Task>(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: #keyPath(Task.coursework),
            cacheName:nil)
        frc.delegate = self
        _fetchedResultsController = frc
        
        do
        {
            try _fetchedResultsController!.performFetch()
        }
        catch
        {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        
        return frc as! NSFetchedResultsController<NSFetchRequestResult> as! NSFetchedResultsController<Task>
    }
    
    //MARK: fetch results table view functions
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case NSFetchedResultsChangeType(rawValue: 0)!:
            // iOS 8 bug - Do nothing if we get an invalid change type.
            break
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: newIndexPath!)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            //    default: break
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        // self.tableView.reloadData()
    }

    //MARK: editing a task
    
    @IBAction func editTaskButtonPressed(_ sender: UIBarButtonItem)
    {
        if (tableView.indexPathForSelectedRow != nil)
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let editTaskViewController = storyboard.instantiateViewController(withIdentifier: "editTaskViewPopover") as! EditTaskViewController;

            editTaskViewController.delegate = self
            
            editTaskViewController.modalPresentationStyle = .popover
            
            let popover = editTaskViewController.popoverPresentationController!

            popover.sourceView = self.view
            popover.sourceRect = CGRect( x: self.view.bounds.midX, y: 0, width: 0, height: 0 )
            
            editTaskViewController.currentCoursework = coursework
            editTaskViewController.task = fetchedResultsController.object(at: (tableView.indexPathForSelectedRow)!)
            
            self.present(editTaskViewController, animated: true, completion: nil);
        }
        else
        {
            alert(title: "Edit Task", message: "Please select a task to edit first.")
        }
    }
    
    func refreshView()
    {
        self.tableView.setNeedsDisplay()
    }
    
    func alert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

