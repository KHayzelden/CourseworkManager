
import UIKit
import CoreData

class AddTaskViewController: UIViewController {

    var currentCoursework:Coursework?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchRequest: NSFetchRequest<Task>!
    var tasks: [Task]!
    
    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskNotesField: UITextView!
    @IBOutlet weak var taskStartDatePicker: UIDatePicker!
    @IBOutlet weak var taskDurationField: UITextField!
    @IBOutlet weak var taskDurationStepper: UIStepper!
    @IBOutlet weak var taskDueDatePicker: UIDatePicker!
    @IBOutlet weak var taskReminderSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        taskNameField.becomeFirstResponder()

    }

    @IBAction func saveTask(_ sender: UIButton) 
    {
        if (currentCoursework != nil)
        {
            var isUnique: Bool = false
            
            if(taskNameField.text != "")
            {
                isUnique = checkUnique(taskNameField.text!)
            }
            else
            {
                alert(title: "Task Name", message: "Tasks must have a name.")
            }
            
            if (isUnique)
            {
                let task = Task(context: context)
            
                task.name = taskNameField.text
                task.coursework = currentCoursework?.name
                task.notes = taskNotesField.text
                task.startDate = taskStartDatePicker.date
                task.dueDate = taskDueDatePicker.date
                task.reminder = taskReminderSwitch.isOn
                
                if (taskDurationField.text != "")
                {
                    task.estimatedTime = Int16(taskDurationField.text!)!
                }
                
                currentCoursework?.addToTaskRelationship(task)
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                dismiss(animated: true, completion: nil)
            }
            else
            {
                alert(title: "Task Name Error", message: "The task \"" + taskNameField.text! + "\" already exists in this coursework. Task names must be unique and are not case sensitive.")
            }
        }
        else
        {
            alert(title: "Coursework Error", message: "No coursework has been selected, this task will not be saved.")
            dismiss(animated: true, completion: nil)
        }
    }

    func checkUnique (_ name: String) -> Bool {
        
        var isOk: Bool = true
        
        let taskFetcher = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        taskFetcher.predicate = NSPredicate(format: "coursework == %@", (currentCoursework?.name!)!)
        
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
            if (task.name?.lowercased() == name.lowercased())
            {
                isOk = false
            }
        }
        
        return isOk
    }
    
    @IBAction func stepperChanged(_ sender: UIStepper)
    {
        if(sender.value != 0)   { taskDurationField.text = String(Int(sender.value)) }
        else                    { taskDurationField.text = "" }
    }
    
    func alert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
