
import UIKit
import CoreData

class CourseworkTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moduleNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var percentCompleteProgressView: UIProgressView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchRequest: NSFetchRequest<Task>!
    var tasks: [Task]!
    
    var coursework: Coursework?
    {
        didSet
        {
            self.update()
        }
    }
    
    func update()
    {
        nameLabel.text = coursework?.name
        moduleNameLabel.text = coursework?.module
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yy"
        
        percentCompleteProgressView.setProgress(Float(getPercentComplete()/100), animated: false)
        
        dueDateLabel.text = "Due: " + dateFormat.string(from: (coursework?.dueDate!)!)
    }
    
    func getPercentComplete () -> Double
    {
        let taskFetcher = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        taskFetcher.predicate = NSPredicate(format: "coursework == %@", (coursework?.name!)!)
        
        var numberOfTasks:Int = 0
        var percentTotal:Double = 0
        
        var percentComplete:Double = 0
        
        do
        {
            tasks = try managedObjectContext.fetch(taskFetcher) as! [Task]
        }
        catch
        {
            fatalError("Failed to fetch tasks: \(error)")
        }
        
        for task in tasks
        {
            numberOfTasks = numberOfTasks + 1
            percentTotal = percentTotal + task.percentComplete
        }
        
        if(numberOfTasks > 0)
        {
            percentComplete = percentTotal / Double(numberOfTasks)
        }
        
        return percentComplete
    }
}
