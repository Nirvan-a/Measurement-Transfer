//
//  ViewController.swift
//  transition tool2
//
//  Created by nirvana on 2022/7/27.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    //注：方便语言切换，所有标题均从类中直接引用
    
    //存储不同度量衡单位
    var unitsList: [String] = ConvertData.converDataHealper.unitsLists[0]
    //存储度量衡对应的进制序列集
    var sequenceForName: [String: [Double]] = ConvertData.converDataHealper.measurements[0]
    //存储度量衡单位对应的具体进制序列
    var sequenceForUnit: [Double] = ConvertData.converDataHealper.measurements[0]["m"]! {
        didSet {
            showedTableView.reloadData()
        }
    }
    //存储输入结果
    var inputString: String = "0"
    //存储转换后的结果序列
    var resultList: [Double] {
        return sequenceForUnit.map {
            $0 * Double(inputString)!
        }
    }
    
    //tableView的代理执行
    //1.header设置
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        view.text = "  \(ConvertData.converDataHealper.titleLists[pickerView.selectedRow(inComponent: 0)])"
        view.textColor = .white
        view.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    //2.数据源处理
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return unitsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell") as! resultTableViewCell
        cell.symbolLabel.text = unitsList[indexPath.row]
        //补丁
        if indexPath.row <= ConvertData.converDataHealper.unitsNameLists[pickerView.selectedRow(inComponent: 0)].count - 1 {
            cell.nameLabel.text =
            ConvertData.converDataHealper.unitsNameLists[pickerView.selectedRow(inComponent: 0)][indexPath.row]
        }else {
            cell.nameLabel.text = ""
        }
        let result = (resultList[indexPath.row])
        cell.numberLabel.text = "\(result.prettyPrint(places: 6))"
        cell.numberLabel.textColor = .systemBlue
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //PickerView的代理执行
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return ConvertData.converDataHealper.nameLists.count
        default:
            return unitsList.count
        }
    }
    //1.设定各行标题
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                     forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        }
        pickerLabel?.numberOfLines = 0
        switch component {
        case 0:
            pickerLabel?.text = ConvertData.converDataHealper.nameLists[row]
            pickerLabel?.textAlignment = .center
        default:
            pickerLabel?.text = unitsList[row]
            pickerLabel?.textAlignment = .center
        }
        return pickerLabel!
    }
    //2.设定各行/列的 高/宽
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 42
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return 160
        default:
            return 160
        }
    }
    //3.根据选择来更新选项
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard component == 0 else {
            sequenceForUnit = sequenceForName[unitsList[row]]!
            return
        }
        unitsList = ConvertData.converDataHealper.unitsLists[row]
        //更新度量衡对应的进制序列集
        sequenceForName = ConvertData.converDataHealper.measurements[row]
        //同时将右侧序列复位（避免index超出的问题）
        pickerView.selectRow(0, inComponent: 1, animated: true)
        pickerView.reloadComponent(1)

        sequenceForUnit = sequenceForName[unitsList[0]]!
    }
    //1.tableView和pickerView部分
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var showedTableView: UITableView!
    //2.按键部分
    @IBOutlet var inputLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        showedTableView.delegate = self
        showedTableView.dataSource = self
        //避免header上面有一段空白
        showedTableView.sectionHeaderTopPadding = 0
    }
    
    func changeLanguage() {
        var alertTitle = "Language"
        var cancelTitle = "取消"
        if ConvertData.converDataHealper.isChinese {
            alertTitle = "语言"
            cancelTitle = "Cancel"
        }
        let alertController = UIAlertController(title: "\(alertTitle)", message: nil, preferredStyle: .alert)
        let alertAction1 = UIAlertAction(title: "简体中文", style: .default)
        { (action) in ConvertData.converDataHealper.isChinese = true
            self.showedTableView.reloadData()
            self.pickerView.reloadComponent(0)
        }
        let alertAction2 = UIAlertAction(title: "English", style: .default)
        { (action) in ConvertData.converDataHealper.isChinese = false
            self.showedTableView.reloadData()
            self.pickerView.reloadComponent(0)
        }
        let alertAction3 = UIAlertAction(title: "\(cancelTitle)", style: .cancel)
        
        alertController.addAction(alertAction1)
        alertController.addAction(alertAction2)
        alertController.addAction(alertAction3)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateUI() {
        inputLabel.text = inputString
        //补丁：避免滚动pickerview同时更新造成的崩溃
        if unitsList.count == ConvertData.converDataHealper.unitsNameLists[pickerView.selectedRow(inComponent: 0)].count {
            showedTableView.reloadData()
        }
    }
    @IBAction func numberButtontaped(_ sender: UIButton) {
        AudioServicesPlaySystemSound(SystemSoundID(1105))
        let primaryResult = inputString
        switch sender.titleLabel!.text! {
        case String("0"):
            if inputString.last! != "0" || inputString.count != 1 {
                inputString.append("0")
            }
        case String("."):
            if inputString.last! != "." && !inputString.contains("."){
                inputString.append(".")
            }
        case "+/-":
            if inputString.first! != "-" {
                inputString.insert("-", at: inputString.startIndex)
            }else {
                inputString.removeFirst()
            }
        case String("→"):
            if inputString.first! != "-" && inputString.count != 1{
                inputString.removeLast()
            }else if inputString.first! != "-" {
                inputString = "0"
            }else if inputString.count != 2{
                inputString.removeLast()
            }else {
                inputString = "0"
            }
        case String("🌐"):
            changeLanguage()
        case String("⚙︎"):
            return
        case String("C"):
            inputString = "0"
        case let numLit :
            if (inputString.last! == "0" && inputString.count == 1) ||
                (inputString.first! == "-" && inputString.count == 2 && inputString.last! == "0")
            {
                inputString.removeLast()
                inputString.append(String(numLit))
            }else {
                inputString.append(String(numLit))
            }
        }
        if (!(inputString.first! == "-") && inputString.count > 12) || (inputString.first! == "-" && inputString.count > 13)
        {
            inputString = primaryResult
            return
        }
        updateUI()
    }
    @IBAction func returnToPrimary(for segueButton: UIStoryboardSegue) {
    }
}

