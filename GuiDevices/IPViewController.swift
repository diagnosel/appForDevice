//
//  IPViewController.swift
//  GuiDevices
//
//  Created by diagnosefiz on 21.08.17.
//  Copyright © 2017 diagnosefiz. All rights reserved.
//

import UIKit
import InputMask

protocol IPTableViewDelegate {
    func finishPassing(stringArray: [String])
}

class IPTableViewController: UITableViewController, UITextFieldDelegate {
   
    var IP = ""
    var portText = ""
    var timeIntervalText = ""
    var delegate: IPTableViewDelegate?
    
    @IBOutlet weak var timeInterval: UITextField!
    @IBOutlet weak var ip_1: UITextField!
    @IBOutlet weak var ip_2: UITextField!
    @IBOutlet weak var ip_3: UITextField!
    @IBOutlet weak var ip_4: UITextField!
    @IBOutlet weak var port: UITextField!
    
// MARK: - VC LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 42/255, green: 42/255, blue: 42/255, alpha: 1)
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
// Добавим delegate, чтобы можно было использовать функцию спрятать клавитуру
        self.ip_1?.delegate = self
        self.ip_2?.delegate = self
        self.ip_3?.delegate = self
        self.ip_4?.delegate = self
        self.port?.delegate = self
        self.timeInterval.delegate = self
        
        self.addDoneButtonOnKeyboard()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 // Имена секций
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            if (section == 0){
                return "Connection"
            }
            if (section == 1){
                 return "Time Interval"
            }
        return ""
    }
    
// Добавим кнопку Done справа вверху клавиатуры
// Done убирает клавиатуру
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(IPTableViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.port.inputAccessoryView = doneToolbar
        self.ip_1.inputAccessoryView = doneToolbar
        self.ip_2.inputAccessoryView = doneToolbar
        self.ip_3.inputAccessoryView = doneToolbar
        self.ip_4.inputAccessoryView = doneToolbar
        self.timeInterval.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction() {
        self.port.resignFirstResponder()
        self.ip_1.resignFirstResponder()
        self.ip_2.resignFirstResponder()
        self.ip_3.resignFirstResponder()
        self.ip_4.resignFirstResponder()
        self.timeInterval.resignFirstResponder()
    }
    
// MARK: - Delegates TableView
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    
// MARK: - Actions
    
    @IBAction func Done(_ sender: UIBarButtonItem) {
        
        IP = self.ip_1.text! + "." + self.ip_2.text! + "." + self.ip_3.text! + "." + self.ip_4.text!
        portText = self.port.text!
        timeIntervalText = self.timeInterval.text!
        let arrayString = [IP, portText, timeIntervalText]
        delegate?.finishPassing(stringArray: arrayString)
        //возврат на предыдущий VC
        self.navigationController?.popViewController(animated: true)
    }
}


