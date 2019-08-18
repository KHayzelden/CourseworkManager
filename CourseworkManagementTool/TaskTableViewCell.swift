
import UIKit
import CoreData

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskDatesLabel: UILabel!
    @IBOutlet weak var taskProgressSlider: UISlider!
    @IBOutlet weak var taskProgressLabel: UILabel!
    @IBOutlet weak var taskNotesField: UITextView!
    
    var task: Task?
    {
        didSet
        {
            self.refreshView()
        }
    }

    func refreshView()
    {
        self.setNeedsDisplay()
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/YYYY"
        
        taskNameLabel.text = task?.name
        taskDatesLabel.text = dateFormat.string(from: (task?.startDate!)!) + " → " + dateFormat.string(from: (task?.dueDate!)!)
        
        if (task?.notes == nil || task?.notes == "")
        {
            taskNotesField.isHidden = true
        }
        else
        {
            taskNotesField.text = task?.notes
        }
        
        if (task?.percentComplete != nil)
        {
            taskProgressSlider.value = Float((task?.percentComplete)!)
            taskProgressLabel.text = "Progress: " + String(Int((task?.percentComplete)!)) + "%"
        }
        else
        {
            taskProgressSlider.value = 0
            taskProgressLabel.text = "Progress: 0%"
        }
    }
    
    @IBAction func sliderChanged(_ sender: UISlider)
    {
        task?.setValue(Double(sender.value), forKey: "percentComplete")
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        taskProgressLabel.text = "Progress: " + String(Int(sender.value)) + "%"
    }
    
}
