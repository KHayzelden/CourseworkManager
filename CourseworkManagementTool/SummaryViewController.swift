
import UIKit
import CoreData

class SummaryViewController: UIViewController {

    @IBOutlet weak var courseworkNameLabel: UILabel!
    @IBOutlet weak var courseworkModuleLabel: UILabel!
    @IBOutlet weak var courseworkLevelLabel: UILabel!
    @IBOutlet weak var courseworkWeightLabel: UILabel!
    @IBOutlet weak var courseworkMarkLabel: UILabel!
    @IBOutlet weak var courseworkNotesField: UITextView!
    @IBOutlet weak var courseworkPercentCompleteLabel: UILabel!
    @IBOutlet weak var courseworkDaysLeftLabel: UILabel!
    
    @IBOutlet weak var courseworkProgressView: UIView!
    
    var currentCoursework:Coursework?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchRequest: NSFetchRequest<Task>!
    var tasks: [Task]!
    
    var masterViewDelegate: MasterViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshView()
        if (currentCoursework != nil)
        {
            draw()
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let editCourseworkViewController = storyboard.instantiateViewController(withIdentifier: "editCourseworkPopover") as! EditCourseworkViewController;
        
        editCourseworkViewController.modalPresentationStyle = .popover
        
        let popover = editCourseworkViewController.popoverPresentationController!
        
        popover.sourceView = sender as UIView
        popover.sourceRect = sender.bounds
        
        editCourseworkViewController.coursework = currentCoursework
        
        self.present(editCourseworkViewController, animated: true, completion: nil);
    }
    
    func refreshView()
    {
        self.view.setNeedsDisplay()
        
        if (currentCoursework != nil)
        {
            courseworkNameLabel.text = currentCoursework?.name
            courseworkModuleLabel.text = "Module : " + (currentCoursework?.module)!
            
            if ((currentCoursework?.level)! < Int16(0))
            {
                courseworkLevelLabel.text = "Level : Not Specified"
            }
            else
            {
                courseworkLevelLabel.text = "Level : " + String((currentCoursework?.level)!)
            }
            
            if ((currentCoursework?.weight)! < Double(0))
            {
                courseworkWeightLabel.text = "Weight : Not Specified"
            }
            else
            {
                courseworkWeightLabel.text = "Weight : " + String((currentCoursework?.weight)!)
            }
            
            if ((currentCoursework?.mark)! < Double(0))
            {
                courseworkMarkLabel.text = "Mark : Not Specified"
            }
            else
            {
                courseworkMarkLabel.text = "Mark : " + String((currentCoursework?.mark)!)
            }
            
            if (currentCoursework?.notes != "")
            {
                courseworkNotesField.text = currentCoursework?.notes
            }
            else
            {
                courseworkNotesField.text = "No Notes"
            }
            
            self.view.isHidden = false
        }
        else
        {
            self.view.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let editCourseworkViewController = segue.destination as? EditCourseworkViewController else { return }
        editCourseworkViewController.delegate = self
        editCourseworkViewController.masterViewDelegate = masterViewDelegate
    }
    
    func draw()
    {
        let shapeLayerBase = CAShapeLayer()
        shapeLayerBase.fillColor = UIColor.clear.cgColor
        let halfSize:CGFloat = min( courseworkProgressView.frame.size.width/2, courseworkProgressView.frame.size.height/2)
        
        let circlePathBase = UIBezierPath(arcCenter: CGPoint(x:halfSize,y:halfSize), radius: 130, startAngle: 0, endAngle: 360, clockwise: true)
        
        shapeLayerBase.path = circlePathBase.cgPath
        shapeLayerBase.strokeColor = UIColor(red: 255/255.0, green: 126/255.0, blue: 121/255.0, alpha: 1.0).cgColor
        shapeLayerBase.lineWidth = 15
        shapeLayerBase.lineCap = kCALineCapRound
        
        courseworkProgressView.layer.addSublayer(shapeLayerBase)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        let end:CGFloat = (CGFloat(getPercentComplete()/100) * (2*CGFloat.pi)) - (CGFloat.pi/2)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x:halfSize,y:halfSize), radius: 130, startAngle: -CGFloat.pi / 2, endAngle: end, clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = UIColor(red: 20/255.0, green: 199/255.0, blue: 81/255.0, alpha: 1.0).cgColor
        shapeLayer.lineWidth = 15
        shapeLayer.lineCap = kCALineCapRound
        
        courseworkProgressView.layer.addSublayer(shapeLayer)
        
        let now = Date()
        
        if(currentCoursework != nil)
        {
            let daysLeft = Calendar.current.dateComponents([.day], from: now, to: (currentCoursework?.dueDate)!).day
            
            if(Int(daysLeft!) <= 0)
            {
                courseworkDaysLeftLabel.text = "Due"
            }
            if(Int(daysLeft!) == 1)
            {
                courseworkDaysLeftLabel.text = String(Int(daysLeft!)) + " day left !"
            }
            else
            {
                courseworkDaysLeftLabel.text = String(Int(daysLeft!)) + " days left !"
            }
            
            courseworkPercentCompleteLabel.text = String(Int(getPercentComplete())) + "% Complete"
        }
    }
    
    func getPercentComplete () -> Double
    {
        let taskFetcher = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        taskFetcher.predicate = NSPredicate(format: "coursework == %@", (currentCoursework?.name!)!)
        
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
