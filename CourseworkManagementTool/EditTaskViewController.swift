
import UIKit
import CoreData

class EditTaskViewController: UIViewController {

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
    
    var originalName: String = ""
    
    var task: Task?
    
    var delegate: DetailViewController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setFields()
        
        taskNameField.becomeFirstResponder()
    }
    
    func setFields ()
    {
        originalName = (task?.name)!
        
        taskNameField.text = task?.name
        
        taskNotesField.text = task?.notes

        taskStartDatePicker.date = (task?.startDate)!
        taskDueDatePicker.date = (task?.dueDate)!
        
        taskDurationField.text = String((task?.estimatedTime)!)
        taskDurationStepper.value = Double((task?.estimatedTime)!)
        
        taskReminderSwitch.isOn = (task?.reminder)!
    }

    @IBAction func saveChangesButton(_ sender: UIButton) {
        
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
            task?.setValue(taskNameField.text, forKey: "name")
            
            task?.setValue(taskNotesField.text, forKey: "notes")
            
            task?.setValue(taskStartDatePicker.date, forKey: "startDate")
            task?.setValue(taskDueDatePicker.date, forKey: "dueDate")

            task?.setValue(taskReminderSwitch.isOn, forKey: "reminder")
            
            if (taskDurationField.text != "")
            {
                task?.setValue(Int16(taskDurationField.text!)!, forKey: "estimatedTime")
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            delegate?.refreshView()
            delegate?.tableView.reloadData()
            
            dismiss(animated: true, completion: nil)
        }
        else
        {
            alert(title: "Task Name Error", message: "The task \"" + taskNameField.text! + "\" already exists in this coursework. Task names must be unique and are not case sensitive.")
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
        
        if(taskNameField.text != originalName)
        {
            for task in tasks
            {
                if (task.name?.lowercased() == name.lowercased())
                {
                    isOk = false
                }
            }
        }
        
        return isOk
    }
    
    @IBAction func stepperChanged(_ sender: UIStepper) {
        
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
