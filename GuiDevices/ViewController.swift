//
//  ViewController.swift
//  GuiDevices
//
//  Created by diagnosefiz on 09.08.17.
//  Copyright © 2017 diagnosefiz. All rights reserved.
//

import UIKit
import SwiftSocket
import SystemConfiguration


class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate, IPTableViewDelegate {
    
    @IBOutlet weak var connectStateLabel: UILabel!
    @IBOutlet weak var requestSwitch: UISwitch!
    @IBOutlet weak var getTextField: UITextField!
    @IBOutlet weak var responseView: UITextView!
    @IBOutlet weak var pickerViewU: UIPickerView!
    @IBOutlet weak var pickerViewI: UIPickerView!
    @IBOutlet weak var modePickerView: UIPickerView!
    @IBOutlet weak var taskCurrentLabel: UILabel!

    var request: String = "0"
    var pickerData: [String] = [String]()
    let numberU0 = Array(0...3)
    var numberU1 = Array(0...9)
    var number23 = Array(0...9)
    let numberI1 = Array(0...4)
    let modeValues = ["I max", "Limitation", "Unprotected"]
    let connect = Connect()
    var clientAddress = ""
    var clientPort = ""
    var timeInterval = ""
    var client:TCPClient?
    var taskVoltage:UInt32 = 0
    var taskCurrent: UInt32 = 0
    var taskMode: UInt8 = 0
    var rotationAngle: CGFloat = 0.0
    var customHeight: CGFloat = 0.0
    
    enum psMode_enum: UInt8{
        case mode_off
        case mode_overcurrentShutdown
        case mode_limitation
        case mode_timeShutdown
        case mode_lowCurrentShutdown
        case mode_Uadj
        case mode_Iadj
        
        case mode_raw
    }
    
// MARK: - Life cycle VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rotationAngle = 90 * (.pi/180)
        let y = modePickerView?.frame.origin.y
    
        self.view.backgroundColor = UIColor(red: 42/255, green: 42/255, blue: 42/255, alpha: 1)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // Connect data:
        self.pickerViewU?.delegate = self
        self.pickerViewU?.dataSource = self
        self.pickerViewI?.delegate = self
        self.pickerViewI?.dataSource = self
        self.modePickerView?.transform = CGAffineTransform(rotationAngle: rotationAngle)
        self.modePickerView?.frame = CGRect(x: 0, y: y!, width: view.frame.width, height: 50)
        self.modePickerView?.delegate = self
        self.modePickerView?.dataSource = self
        self.modePickerView?.selectRow(1, inComponent: 0, animated: true)
        connectStateLabel.textColor = UIColor.red
        updateTaskMode()
        requestSwitch.setOn(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
// MARK: - Delegate IPTableViewController
    
    func finishPassing(stringArray: [String]) {
        print(stringArray)
        clientAddress = stringArray[0]
        clientPort = stringArray[1]
        timeInterval = stringArray[2]
        print("IP:\(clientAddress)")
        print("Port:\(clientPort)")
        print("Time interval: \(timeInterval)")
        connect.connectWithTimeOut(address: clientAddress, port: Int32(clientPort)!)
        connectStateLabel.textColor = UIColor.green
        //вызов функции по таймеру каждые n секунд
        timerSendValues()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? IPTableViewController {
            destination.delegate = self
            connect.disconnect()
            connectStateLabel.textColor = UIColor.red
        }
    }
    
// MARK: - Delegate TextField
// Прячем клавиатуру
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
// MARK: - Connection to network
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
 
    
// MARK: - Delegates and data sources PickerView
// Количество колонок
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if (pickerView == pickerViewU || pickerView == pickerViewI) {
            return 5
        } else {
            return 1
        }
    }
    
// Количество строк для колонок
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (pickerView == pickerViewU) {
            if (component == 0) {
                return numberU0.count
            }
            if (component == 1) {
                return numberU1.count
            }
            if (component == 4) {
                return 1
            }
            else {
                return number23.count
            }
        } else if (pickerView == pickerViewI) {
            if (component == 1) {
                return numberI1.count
            }
            if (component == 0) {
                return 1
            }
            else {
                return number23.count
            }
        } else {  // pickerView == modePickerView
            return modeValues.count
        }
    }
    
// Помещаем данные в picker
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        var titleData: String
        rotationAngle = -90 * (.pi/180)
        var size: CGFloat = 0.0
        var nameFont: String = ""
        if (pickerView == pickerViewU) {
            if (component == 0) {
                titleData = String(numberU0[row])
            }
            else if (component == 1) {
                titleData = String(numberU1[row]) + "."
            }
            else if (component == 4) {
                titleData = "0"
            }
            else {
                titleData = String(number23[row])
            }
        } else if (pickerView == pickerViewI) {
            if (component == 0) {
                titleData = ""
            }
            else if (component == 1) {
                titleData = String(numberI1[row]) + "."
            }
            else {
                titleData = String(number23[row])
            }
        } else {  // pickerView == modePickerView
            titleData = String(modeValues[row])
            pickerLabel.transform = CGAffineTransform(rotationAngle: rotationAngle)
            pickerLabel.textAlignment = NSTextAlignment.center
        }
        if (pickerView == pickerViewU || pickerView == pickerViewI) {
            size = 27.0
            nameFont = "Segment7Standard"  //add font from resource project for U & I PickerView
            //nameFont = "Georgia"
        } else {
            size = 15.0
            nameFont = "Georgia"
        }
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: nameFont, size: size)!,NSForegroundColorAttributeName:UIColor.white])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if (pickerView == modePickerView) {
            return 90.0
        } else {
            return 27.0
        }
        
    }
    
// Выбор значений voltage, curent & task mode из PickerViews
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let maxVoltage:UInt32 = 36_000_000
        let maxCurrent:UInt32 = 4_000_000
        if (pickerView == pickerViewU) {
            taskVoltage =   UInt32(pickerViewU.selectedRow(inComponent: 0)) * 10_000_000 +  //Xx.xxx
                            UInt32(pickerViewU.selectedRow(inComponent: 1)) *  1_000_000 +  //xX.xxx
                            UInt32(pickerViewU.selectedRow(inComponent: 2)) *    100_000 +  //xx.Xxx
                            UInt32(pickerViewU.selectedRow(inComponent: 3)) *     10_000 +  //xx.xXx
                            UInt32(pickerViewU.selectedRow(inComponent: 4)) *      1_000    //xx.xxX
            if (taskVoltage > maxVoltage) {
                pickerView.selectRow(6, inComponent: 1, animated: true)
                pickerView.selectRow(0, inComponent: 2, animated: true)
                pickerView.selectRow(0, inComponent: 3, animated: true)
                taskVoltage = maxVoltage
            }
        } else if (pickerView == pickerViewI){
            taskCurrent =   UInt32(pickerViewI.selectedRow(inComponent: 1)) *  1_000_000 +  //_X.xxx
                            UInt32(pickerViewI.selectedRow(inComponent: 2)) *    100_000 +  //_x.Xxx
                            UInt32(pickerViewI.selectedRow(inComponent: 3)) *     10_000 +  //_x.xXx
                            UInt32(pickerViewI.selectedRow(inComponent: 4)) *      1_000    //_x.xxX
            if (taskCurrent > maxCurrent) {
                pickerView.selectRow(0, inComponent: 2, animated: true)
                pickerView.selectRow(0, inComponent: 3, animated: true)
                pickerView.selectRow(0, inComponent: 4, animated: true)
                taskCurrent = maxCurrent
            }
        } else { //pickerView == modePickerView
            updateTaskMode()
        }
    }
    
// MARK: - Actions
// Отправка сообщения с данными для БП
    
    @IBAction func SendMessage(_ sender: UIButton) {

        connect.send(textU      : taskVoltage,
                     textI      : taskCurrent,
                     request    : request,
                     mode       : taskMode)
//        request = "None"
    }
    
// Переход к -> Settings VC
    
    @IBAction func segueSettings(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "VcToIpTableView", sender: nil)
    }
    
// MARK: - SwitchOnOff
// Задаем значение request
    
    @IBAction func OnOffSwitchRequest(_ sender: UISwitch) {
        if requestSwitch.isOn {
            request = "ON"
        } else {
            request = "OFF"
        }
       print("request:\(request)")
    }
    
    private func appendToTextField(string: String) {
        print(string)
        responseView.text = responseView.text.appending("\n\(string)")
    }
    
// MARK - updateTaskMode
    
    func updateTaskMode(){
        var mode = modeValues[modePickerView.selectedRow(inComponent: 0)]
//        taskMode = modeValues[modePickerView.selectedRow(inComponent: 0)]
        switch mode {
            case "I max":
                taskMode = 2
            case "Limitation":
                taskMode = 1
            case "Unprotected":
                taskMode = 0
            default:
                taskMode = 2
        }

    }
    
// MARK - timerSendValues
    
    func timerSendValues() {
        
    _ = Timer.scheduledTimer(timeInterval: Double(timeInterval)!, target: self, selector: #selector(ViewController.SendMessage(_:)), userInfo: nil, repeats: true)
    }
}
