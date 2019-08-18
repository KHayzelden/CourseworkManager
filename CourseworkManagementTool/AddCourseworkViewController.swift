
import UIKit
import CoreData
import EventKit

class AddCourseworkViewController: UIViewController, NSFetchedResultsControllerDelegate {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchRequest: NSFetchRequest<Coursework>!
    var courseworks: [Coursework]!
    
    var calendar: EKCalendar!
    
    @IBOutlet weak var courseworkNameField: UITextField!
    @IBOutlet weak var courseworkModuleField: UITextField!
    @IBOutlet weak var courseworkWeightField: UITextField!
    @IBOutlet weak var courseworkMarkField: UITextField!
    @IBOutlet weak var courseworkNotesField: UITextView!
    
    @IBOutlet weak var courseworkLevelSegementedControl: UISegmentedControl!
    @IBOutlet weak var courseworkDueDatePicker: UIDatePicker!
    @IBOutlet weak var courseworkReminderSwitch: UISwitch!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()

        courseworkNameField.becomeFirstResponder()
    }
    
    @IBAction func saveCoursework(_ sender: UIButton) {
        
        var isUnique: Bool = false
        
        var isValidWeight: Bool = true
        var hasWeight: Bool = false
        
        var isValidMark: Bool = true
        var hasMark: Bool = false
        
        var weight: Double?
        var mark: Double?
        
        // courseworks require name and module to exist, must be unique name
        
        if(courseworkNameField.text != "" && courseworkModuleField.text != "")
        {
            isUnique = checkUnique(courseworkNameField.text!)
        }
        else
        {
            alert(title: "Error", message: "Courseworks require a unique name and module.")
        }
        
        //checking for valid weight (double between 1 and 100)
        
        if(courseworkWeightField.text != "")
        {
            weight = Double(courseworkWeightField.text!)
            
            if (weight == nil)
            {
                isValidWeight = false
            }
            else if (weight! >= 100 ||   weight! <= 1)
            {
                isValidWeight = false
                
                alert(title: "Weight Error", message: "The weight must be a number between 0 and 100. Do not include the % symbol.")
            }
            else
            {
                hasWeight = true
            }
        }
        
        
        if(courseworkMarkField.text != "")
        {
            mark = Double(courseworkMarkField.text!)
            
            if (mark == nil)
            {
                isValidMark = false
            }
            else if (mark! >= 100 ||   mark! <= 1)
            {
                isValidMark = false
                
                alert(title: "Mark Error", message: "The mark must be a number between 0 and 100. Do not include the % symbol.")
            }
            else
            {
                hasMark = true
            }
        }
        
        if(isUnique && isValidWeight && isValidMark)
        {
            let newCoursework = Coursework(context: context)
            
            newCoursework.name = courseworkNameField.text
            newCoursework.module = courseworkModuleField.text
            newCoursework.notes = courseworkNotesField.text
            
            if (hasWeight)  { newCoursework.weight = weight! }
            else            { newCoursework.weight = -1 } //default values for program to know nothing was selected
            
            if (hasMark)    { newCoursework.mark = mark! }
            else            { newCoursework.mark = -1 } //default values for program to know nothing was selected
            
            //checks the level selected index, if -1 the value is left alone, otherwise will set to index +4 (ie 0 becomes 4, 1 becomes 5, etc) to represent the real value
            if(courseworkLevelSegementedControl.selectedSegmentIndex == -1)
            {
                newCoursework.level = Int16(courseworkLevelSegementedControl.selectedSegmentIndex)
            }
            else
            {
                newCoursework.level = Int16(courseworkLevelSegementedControl.selectedSegmentIndex + 4)
            }
            
            newCoursework.dueDate = courseworkDueDatePicker.date
            newCoursework.reminder = courseworkReminderSwitch.isOn
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            let eventStore = EKEventStore()

            eventStore.requestAccess(to: .event) { (granted, error) in

            let newEvent = EKEvent(eventStore: eventStore)

                newEvent.title = newCoursework.name! + " Due"
                newEvent.startDate = newCoursework.dueDate
                newEvent.endDate = newCoursework.dueDate
                newEvent.calendar = eventStore.defaultCalendarForNewEvents
                
                
                do
                {
                    try eventStore.save(newEvent, span: .thisEvent, commit: true)
                    
                    self.dismiss(animated: true, completion: nil)
                }
                catch
                {
                    print("save event error")
                }
            }
        }
        else
        {
            alert(title: "Name Error", message: "The name \"" + courseworkNameField.text! + "\" has already been taken. Courseworks must have a unique name and are not case sensitive.")
        }
        
    }
    
    //MARK: coursework names fetch
    
    func checkUnique (_ name: String) -> Bool {
        
        var isOk: Bool = true
        
        let courseworkFetcher = NSFetchRequest<NSFetchRequestResult>(entityName: "Coursework")
        
        do
        {
            courseworks = try managedObjectContext.fetch(courseworkFetcher) as! [Coursework]
        }
        catch
        {
            fatalError("Failed to fetch courseworks: \(error)")
        }
        
        for coursework in courseworks
        {
            if (coursework.name?.lowercased() == name.lowercased())
            {
                isOk = false
            }
        }
        
        return isOk
    }
    
    func alert(title:String, message:String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
}
