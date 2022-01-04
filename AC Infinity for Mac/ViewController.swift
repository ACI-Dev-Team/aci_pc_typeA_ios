//
//  ViewController.swift
//  AC Infinity for Mac
//
//  Created by cooltron on 2021/6/30.
//

import Cocoa
import UserNotifications

class ViewController: NSViewController,ORSSerialPortDelegate,UNUserNotificationCenterDelegate,NSTableViewDelegate,NSTableViewDataSource {

    @objc let serialPortManager = ORSSerialPortManager.shared()
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var popBtn: NSPopUpButton!

    @IBOutlet weak var scanBtn: NSButton!

    
    @IBOutlet weak var backView: NSView!
    
    @IBOutlet weak var controlBackView: NSView!
    @IBOutlet weak var deviceImage: NSImageView!
//    @IBOutlet weak var statusImage: NSImageView!
    @IBOutlet weak var status: NSTextField!
    @IBOutlet weak var device: NSTextField!
    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var number: NSTextField!
    @IBOutlet weak var deviceTitle: NSTextField!
    
    @IBOutlet weak var lineBox: NSBox!
    @IBOutlet weak var slider: UPCircularSlider!
    //    @IBOutlet weak var levelLabel: NSTextField!
//    @IBOutlet weak var openDeviceBtn: NSButton!
    
    @IBOutlet weak var headerView: NSView!
    
    @IBOutlet weak var updateBtn: NSButton!
    
    @IBOutlet weak var connectBtn: NSButton!
    @IBOutlet weak var helpBtn: NSButton!
//    var allPorts = [ORSSerialPort]()
    
    var serialPorts =  [ORSSerialPort]()
    var deviceModels = [String:DeviceModel]()   //  key - device    portName = key
    var timer : Timer?

    var selectRow = 0

    
    
    @IBOutlet weak var sdLabel: NSTextField!
    @IBOutlet weak var rcLabel: NSTextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(serialPortsWereConnected(_:)), name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
        nc.addObserver(self, selector: #selector(serialPortsWereDisconnected(_:)), name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
       // NSUserNotificationCenter.default.delegate = self
      //  UNUserNotificationCenter.current().delegate = self
        
        self.view.wantsLayer = true
    
        self.slider.refreshLevel(0)
        self.slider.canTouch = false
        
        for port in self.serialPortManager.availablePorts {
            if port.isOpen == false {
                port.baudRate = 57600
                port.numberOfStopBits = 1
                port.delegate = self
                port.open()
            }
        }
        
        self.configUI()
        
        let slider = NSSlider.init()
        slider.sliderType = .circular
        
        self.addTimer()
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        self.tableView.selectRowIndexes(IndexSet.init(integer: self.selectRow), byExtendingSelection: false)
    }
    func configUI() {
        

        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = Color.cellBackColor.cgColor

        self.tableView.backgroundColor = Color.cellBackColor
        self.tableView.layer?.backgroundColor = Color.cellBackColor.cgColor

        self.tableView.wantsLayer = true
        self.tableView.layer?.borderWidth = 1
        self.tableView.layer?.borderColor = Color.color_707070.cgColor
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.scrollView.contentView.wantsLayer = true
        self.scrollView.contentView.layer?.borderColor = Color.color_707070.cgColor

        self.setBtnTitleColor(color: .white, btn: self.scanBtn)
//        self.lineBox.fillColor = .white
        
        self.scanBtn.wantsLayer = true
        self.scanBtn.layer?.cornerRadius = 17
        self.scanBtn.layer?.masksToBounds = true
        self.scanBtn.layer?.borderWidth = 0.5
        self.scanBtn.layer?.borderColor = NSColor.white.cgColor
        
        if #available(macOS 11.0, *) {
            self.tableView.style = .plain
        }
//        self.tableView.layer?.cornerRadius = 5
        self.controlBackView.wantsLayer = true
        self.controlBackView.layer?.backgroundColor = Color.defaultBackgroundColor.cgColor

        self.headerView.wantsLayer = true
        self.headerView.layer?.backgroundColor = Color.blueColor.cgColor

        self.lineBox.fillColor = ColorHelper.colorWithHexString(hex: "#a9a9a9")
        self.lineBox.boxType = .custom
        
        self.setBtnTitleColor(color: .white, btn: self.updateBtn)
        self.setBtnTitleColor(color: .white, btn: self.helpBtn)
        
        self.connectBtn.wantsLayer = true
        self.connectBtn.layer?.cornerRadius = 17
        self.connectBtn.layer?.masksToBounds = true
        self.connectBtn.layer?.borderWidth = 0.5
        self.connectBtn.layer?.borderColor = NSColor.white.cgColor
        self.setBtnTitleColor(color: .white, btn: self.connectBtn)

        
        self.slider.target = self
        self.slider.action = #selector(valueChanged(sender:))
        self.slider.label.alignment = .center

        
    }
    func addTimer() {
        
        if timer == nil {
            timer = Timer.init(timeInterval: 10, target: self, selector: #selector(refreshList), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .common)
        }
        
    }
    func resetZero() {
            
    }
    
    override var representedObject: Any? {
        didSet {
            
        // Update the view, if already loaded.
        }
    }
    @objc func refreshList() {
        let temPorts = self.serialPorts
        for port in temPorts {
            if !self.serialPortManager.availablePorts.contains(port) {
                self.serialPorts.remove(at: self.serialPorts.firstIndex(of: port)!)
                self.deviceModels[port.name] = nil
                if self.selectRow >= self.serialPorts.count {
                    self.selectRow -= 1
                }
            }
        }
        if self.selectRow < 0 {
            self.selectRow = 0
        }
        if temPorts.count != self.serialPorts.count {

            self.reloadListName()
            if self.selectRow < self.serialPorts.count {
                let port = self.serialPorts[self.selectRow]
                let model = self.deviceModels[port.name]
                self.setSelectModelDetails(deviceModel:model)

            }
            
        }
        
        for port in self.serialPortManager.availablePorts {
            if !self.serialPorts.contains(port) && port.name != "-SerialPort"{
                if port.isOpen == false {
                    port.baudRate = 57600
                    port.numberOfStopBits = 1
                    port.delegate = self
                    port.open()
                }
            }
        }
    }
    @objc func disconnetPort(port:ORSSerialPort) {
        
        if self.serialPorts.contains(port) {
            var index = self.serialPorts.firstIndex(of: port)!
            self.serialPorts.remove(at: index)
            self.deviceModels[port.name] = nil
            if self.selectRow >= index {
                self.selectRow -= 1
            }
            if self.selectRow < 0 {
                self.selectRow = 0
            }
            DispatchQueue.main.async {
//                self.tableView.reloadData()
                self.reloadListName()
                if self.selectRow < self.serialPorts.count {
                    let port = self.serialPorts[self.selectRow]
                    let model = self.deviceModels[port.name]
                    self.setSelectModelDetails(deviceModel:model)

                }
            }
        }

    }
    @IBAction func refreshAction(_ sender: Any) {
        
        self.refreshList()
        
        
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
    }

    @IBAction func helpAction(_ sender: NSButton) {
        
        NSWorkspace.shared.open(URL.init(string: "https://www.acinfinity.com/")!)
        
    }
 
    @IBAction func openDeviceAction(_ sender: NSButton) {
        
        
    }
    
    @IBAction func creaseAction(_ sender: Any) {
        
        guard self.slider.canTouch == true else {
            return
        }
        
        let port = self.serialPorts[self.selectRow]
        let model = self.deviceModels[port.name]

        if model?.level != nil && model!.level < 11 {
            model?.level += 1
            if port.isOpen == true {
                self.sendData(data: DeviceModel.setDeviceFanLevel(level: model!.level), port: port)
            }
        }
       
        
    }
    
    @IBAction func decreaseAction(_ sender: Any) {
        
        guard self.slider.canTouch == true else {
            return
        }
        
        
        let port = self.serialPorts[self.selectRow]
        let model = self.deviceModels[port.name]


        if model?.level != nil && model!.level > 0 {
            model?.level -= 1
            if port.isOpen == true {
                self.sendData(data: DeviceModel.setDeviceFanLevel(level: model!.level), port: port)
            }
        }

    }
    @IBAction func connectAction(_ sender: NSButton) {
        
        if self.serialPorts.count > self.selectRow {
            
            let port = self.serialPorts[self.selectRow]
            if port.isOpen {
                
                port.close()
            } else {
                port.open()
            }
            
            
        }
        
        
        
        
    }
    func connectPort(port:ORSSerialPort) {
        
    }
    
    struct versionType : Encodable{
        let platformVersion : String?
        let type : Int?
    }
    
    @IBAction func updateAction(_ sender: NSButton) {
        
   

    }
    
    func showUpdateAlert() {
        let alert = NSAlert.init()
        alert.messageText = "Firmware update"
        alert.informativeText = "Your firmware is up-to-date"
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning
        alert.runModal()
    }
    func showHasUpdateAlert(version:String?,url:String?) {
        if version == nil || url == nil {
            return
        }
        let alert = NSAlert.init()
        alert.messageText = "Firmware update"
        alert.informativeText = "Version \(version!) is Available,please update to get the lastest features."
        alert.addButton(withTitle: "Update")
        alert.alertStyle = .warning
        if let window = self.view.window {
            alert.beginSheetModal(for: window) { (response) in
                NSWorkspace.shared.open(URL.init(string: url!)!)
            }
            
        }
        
    }
    @objc func valueChanged(sender:UPCircularSlider) {
        
        let port = self.serialPorts[self.selectRow]
        let model = self.deviceModels[port.name]

//
        model?.level = sender.levelValue
        if port.isOpen == true {
            self.sendData(data: DeviceModel.setDeviceFanLevel(level: model!.level), port: port)
        }
    

        
        
        
    }
    // MARK: - tableView dataSource
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {

        
        return self.serialPorts.count
    }
//    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        return self.serialPortManager.availablePorts[row]
//    }
    //返回每一行的内容
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        return nil
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as! NSTableCellView
        cell.textField?.stringValue = self.serialPorts[row].name
        cell.textField?.isEditable = false
        cell.textField?.textColor = .white
//        cell.backgroundStyle = .light
        cell.wantsLayer = true
        cell.layer?.backgroundColor = NSColor.red.cgColor

        return cell
    }

    func tableView(_ tableView: NSTableView, shouldTrackCell cell: NSCell, for tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }

  
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        
    }
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        
    }
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        self.selectRow = row
        let port = self.serialPorts[row]
        
        if port.isOpen {
            let model = self.deviceModels[port.name]
            if model != nil {

                self.portOpenState(port: port)
                self.setSelectModelDetails(deviceModel: model)
                
                
                
                
            }
            
            
            if model?.version != nil {
                
            }
            if model?.isOnline == true {
//                self.controlBackView.isHidden = false
            }else{
//                self.controlBackView.isHidden = true
            }
            
        }else {
            port.open()
        }
        
        return true
    }
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {

        let view = HighlightView.init(frame: NSRect(x: 0, y: 0, width: 260, height: 40))
        var cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as? NSTableCellView
        cell?.frame = NSRect(x: 0, y: 0, width: 260, height: 40)

        cell?.textField?.stringValue = self.serialPorts[row].name
        if let model = self.deviceModels[self.serialPorts[row].name] {
            cell?.textField?.stringValue = model.getDeviceType()
        } else {
            cell?.textField?.stringValue = self.serialPorts[row].name
        }
        cell?.textField?.isEditable = false
        cell?.textField?.textColor = .white
        cell?.textField?.font = NSFont.init(name: "Avenir-Medium", size: 12)

        cell!.wantsLayer = true
    
//        cell!.layer?.backgroundColor = NSColor.red.cgColor
        view.addSubview(cell!)
        let lineView = NSView.init(frame: NSRect(x: 0, y: 39, width: 260, height: 1))
        
        lineView.wantsLayer = true
        lineView.layer?.backgroundColor = ColorHelper.colorWithHexString(hex: "#707070").cgColor
        view.addSubview(lineView)
        view.cell = cell
        return view

    }
    // MARK: - ORSSerialPortDelegate
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
 
        self.sendData(data: DeviceModel.checkDeviceNumber(), port: serialPort)
    
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {

        if self.serialPorts.count > self.selectRow {
            let port = self.serialPorts[self.selectRow]
            if port == serialPort {
                self.portOpenState(port: port)
            }
        } else {
            self.portOpenState(port: nil)
        }
        
        
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {

        let u8a = data.map {$0}
        print("serial receive:\(DeviceModel.getHexStr(from: data))")
        
///   新协议 1.0.1
        if u8a.count > 0 {

            if u8a.first == 0x40 {

                NSObject.cancelPreviousPerformRequests(withTarget: self)

                guard u8a.count >= 12 else{
                    return
                }
                let device = DeviceModel.init()

                let numberStr = DeviceModel.getHexStr(from: data.subdata(in: 2..<data.count-5))
                let number = DeviceModel.getStringByHex(from: numberStr)

                device.number = number
                let hardVersion = "\(Int(u8a[8]))"+"."+"\(Int(u8a[9]))"
                let softVersion = "\(Int(u8a[10]))"+"."+"\(Int(u8a[11]))"
                device.version = "\(hardVersion) - \(softVersion)"
                device.connectPortName = serialPort.name
                device.receiveBytes = data.count
                device.sendBytes = 3
                var addDevice = false
                if !self.serialPorts.contains(serialPort) {
                    self.serialPorts.append(serialPort)
                    self.deviceModels[serialPort.name] = device
                    addDevice = true
                }
                if serialPort.isOpen {
                    self.sendData(data: DeviceModel.checkDeviceState(), port: serialPort)
                }


                DispatchQueue.main.async {
                    if self.serialPorts.count > self.selectRow {
                        let port = self.serialPorts[self.selectRow]
                        if port == serialPort {
                            self.number.stringValue = "SERIES NUMBER: \(device.number ?? "FAILED")"
                            self.version.stringValue = "MODEL VERSION: \(device.version ?? "FAILED")"
                            self.portOpenState(port: port)
                        }
                    }
                    let index = self.serialPorts.firstIndex(of: serialPort)
                    if addDevice {
                        self.reloadListName()
                    }else {
                        self.reloadIndexOfTableView(index: index!)
                    }

                }

            } else if u8a.first == 0x41 {

                guard u8a.count >= 5 else {
                    return
                }

                let deviceType = Int(u8a[2])*256+Int(u8a[3])
                let deviceModel = self.deviceModels[serialPort.name] ?? DeviceModel.init()
                
                deviceModel.deviceType = deviceType
                

                deviceModel.receiveBytes += data.count

                if serialPort.isOpen {
                    self.sendData(data: DeviceModel.checkStatus(), port: serialPort)
                }
                if self.serialPorts.count > self.selectRow {
                    let port = self.serialPorts[self.selectRow]
                    if port == serialPort {
                        self.deviceStatusLabelState(deviceModel: deviceModel)

                    }
                }
                self.deviceModels[serialPort.name] = deviceModel

                let index = self.serialPorts.firstIndex(of: serialPort)
                self.reloadIndexOfTableView(index: index!)

            } else if u8a.first == 0x33 {

                let isOnline = Int(u8a[2])
                let model = self.deviceModels[serialPort.name] ?? DeviceModel.init()
                model.isOnline = isOnline == 0 ? false : true
                model.level = Int(u8a[3])
                model.rev = Int(u8a[4])*256+Int(u8a[5])
                model.receiveBytes += data.count
                if self.serialPorts.count > self.selectRow {
                    let port = self.serialPorts[self.selectRow]
                    if port == serialPort {
                        self.deviceOpenState(deviceModel: model)
                    }
                }



            } else if u8a.first == 0x32 {
                
                let isSuccess = u8a[2]
                if isSuccess == 0 {
                    
                    self.sendData(data: DeviceModel.checkStatus(), port: serialPort)
                  
                    
                }else {
                    DispatchQueue.main.async {
                       
                        if self.serialPorts.count > self.selectRow {
                            let port = self.serialPorts[self.selectRow]
                            if port == serialPort {
                                let model = self.deviceModels[serialPort.name]
                                model?.receiveBytes += data.count
                                if model != nil {
                                    self.slider.refreshLevel(model?.level ?? 0)
                                }
                                self.deviceModels[serialPort.name] = model
                            }
                        }
                        
                        
                    }
                    
                    
                }
                
                
            }else if u8a.first == 0xa1 {

                guard u8a.count >= 5 else {
                    return
                }
                let model = self.deviceModels[serialPort.name]
                let deviceType = Int(u8a[3])*256+Int(u8a[4])
                let isOnline = Int(u8a[2])
                model?.isOnline = isOnline == 0 ? false : true
                model?.deviceType = deviceType
                model?.receiveBytes += data.count

                self.deviceModels[serialPort.name] = model

                /// test
                
                if self.serialPorts.count > self.selectRow {
                    let port = self.serialPorts[self.selectRow]
                    if port == serialPort {
                        self.deviceStatusLabelState(deviceModel: model)
                        self.deviceOpenState(deviceModel: model)

                    }
                }
                let index = self.serialPorts.firstIndex(of: serialPort)
                self.reloadIndexOfTableView(index: index!)

            }

        }

        
    }
    
    func setSelectModelDetails(deviceModel:DeviceModel?) {
        
        
        self.number.stringValue = "SERIES NUMBER: \(deviceModel?.number ?? "FAILED")"
        self.version.stringValue = "MODEL VERSION: \(deviceModel?.version ?? "FAILED")"
        
        if deviceModel?.getAvailableType() == true {
            self.slider.canTouch = true
        } else {
            self.slider.canTouch = false
        }
        self.deviceStatusLabelState(deviceModel: deviceModel)
        self.deviceOpenState(deviceModel: deviceModel)
        

        
    }
    
    
    func portOpenState(port:ORSSerialPort?) {

        DispatchQueue.main.async {
            guard port != nil else {
                self.deviceImage.image = NSImage.init(named: NSImage.Name("NSStatusUnavailable"))
                self.slider.refreshLevel(0)
                self.slider.canTouch = false
                self.number.stringValue = "SERIES NUMBER:"
                self.version.stringValue = "MODEL VERSION:"
                self.device.stringValue = "CURRENT DEVICE:"
                self.status.stringValue = ""
                return
            }
            if port!.isOpen == true {
                self.status.stringValue = "CONNECTED"
                self.status.textColor = ColorHelper.colorWithHexString(hex: "#00c342")
                self.setBtnTitleColor(color: .white, btn: self.connectBtn, "DISCONNECT")
                self.slider.canTouch = true

            }else {
                self.status.stringValue = "DISCONNECTED"
                self.status.textColor = NSColor.red
                self.setBtnTitleColor(color: .white, btn: self.connectBtn, "CONNECT")
                self.slider.canTouch = false

            }
        }
    }
    
    func deviceOpenState(deviceModel:DeviceModel?) {

        
        DispatchQueue.main.async {
            self.sdLabel.stringValue = "RECEIVED: \(deviceModel?.receiveBytes ?? 0 ) BYTES"
            self.rcLabel.stringValue = "SENT: \(deviceModel?.sendBytes ??  0 ) BYTES"

            guard deviceModel != nil else {
                self.deviceImage.image = NSImage.init(named: NSImage.Name("NSStatusUnavailable"))
                self.slider.refreshLevel(0)
                self.slider.canTouch = false
                return
            }
            if deviceModel!.isOnline == true {
//                self.status.stringValue = "CONNECTED"
//                self.status.textColor = ColorHelper.colorWithHexString(hex: "#00c342")
                self.deviceImage.image = NSImage.init(named: NSImage.Name("NSStatusAvailable"))
                self.slider.canTouch = true
                self.slider.refreshLevel(deviceModel?.level ?? 0)
            }else {
//                self.status.stringValue = "DISCONNECTED"
//                self.status.textColor = NSColor.red
//                self.controlBackView.isHidden = true
                self.deviceImage.image = NSImage.init(named: NSImage.Name("NSStatusUnavailable"))
                self.slider.canTouch = false
                self.slider.refreshLevel( 0)
            }
        }
    }
    func deviceStatusLabelState(deviceModel:DeviceModel?) {
        
        self.sdLabel.stringValue = "RECEIVED: \(deviceModel?.receiveBytes ?? 0 ) BYTES"
        self.rcLabel.stringValue = "SENT: \(deviceModel?.sendBytes ??  0 ) BYTES"
        
        guard deviceModel != nil else {

            self.slider.canTouch = false
            self.slider.refreshLevel(deviceModel?.level ?? 0)
            self.device.stringValue = "CURRENT DEVICE: --"

            self.reloadListName()
            return
        }
        DispatchQueue.main.async {
            if deviceModel!.deviceType == 0{

                self.slider.canTouch = false
            } else {

                self.slider.canTouch = true
            }

            self.device.stringValue = "CURRENT DEVICE: \(deviceModel!.getDeviceType())"
            
        }
    }
    func reloadListName() {
        
        DispatchQueue.main.async { [self] in
            self.tableView.reloadData()
            if self.serialPorts.count > self.selectRow {
                let model = self.deviceModels[self.serialPorts[self.selectRow].name]
                self.setSelectModelDetails(deviceModel: model)

                self.tableView.selectRowIndexes(IndexSet.init(integer: self.selectRow), byExtendingSelection: false)

            }
            
        }
    }
    @objc func selectTableRow() {
        DispatchQueue.main.async {
            self.tableView.selectRowIndexes(IndexSet.init(integer: self.selectRow), byExtendingSelection: false)
        }
    }
    func reloadIndexOfTableView(index:Int) {
        if self.tableView.numberOfRows > index {
            let view = self.tableView.rowView(atRow: index, makeIfNecessary: false) as? HighlightView
       
            if let model = self.deviceModels[self.serialPorts[index].name] {
                view?.cell?.textField?.stringValue = model.getDeviceType()
            } else {
                view?.cell?.textField?.stringValue = self.serialPorts[index].name
            }
        }
        
    }
    
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
       // self.serialPort = nil
       // self.openCloseButton.title = "Open"
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
       // print("SerialPort \(serialPort) encountered an error: \(error)")
    }
    
    // MARK: - NSUserNotifcationCenterDelegate
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        let popTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
            center.removeDeliveredNotification(notification)
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
   
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let popTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
//          //  center.removeDeliveredNotification(notification)
//            center.removeAllDeliveredNotifications()
//        }
//
//    }
//
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//
//
//    }

    
  
    
    
    
    // MARK: - Notifications
    
    @objc func serialPortsWereConnected(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let connectedPorts = userInfo[ORSConnectedSerialPortsKey] as! [ORSSerialPort]
            print("Ports were connected: \(connectedPorts)")
            self.postUserNotificationForConnectedPorts(connectedPorts)
            self.refreshList()
        }
    }
    
    @objc func serialPortsWereDisconnected(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let disconnectedPorts: [ORSSerialPort] = userInfo[ORSDisconnectedSerialPortsKey] as! [ORSSerialPort]
            print("Ports were disconnected: \(disconnectedPorts)")
            self.postUserNotificationForDisconnectedPorts(disconnectedPorts)
            self.disconnetPort(port: disconnectedPorts.first!)
        }
    }
    
    func postUserNotificationForConnectedPorts(_ connectedPorts: [ORSSerialPort]) {
        let unc = NSUserNotificationCenter.default
        for port in connectedPorts {
            let userNote = NSUserNotification()
            userNote.title = NSLocalizedString("Serial Port Connected", comment: "Serial Port Connected")
            userNote.informativeText = "Serial Port \(port.name) was connected to your Mac."
            userNote.soundName = nil;
            unc.deliver(userNote)
        }
    }
    
    func postUserNotificationForDisconnectedPorts(_ disconnectedPorts: [ORSSerialPort]) {
        let unc = NSUserNotificationCenter.default
        for port in disconnectedPorts {
            let userNote = NSUserNotification()
            userNote.title = NSLocalizedString("Serial Port Disconnected", comment: "Serial Port Disconnected")
            userNote.informativeText = "Serial Port \(port.name) was disconnected from your Mac."
            userNote.soundName = nil;
            unc.deliver(userNote)
        }
    }
    
    func sendData(data:Data,port:ORSSerialPort?) {
        
        
        print("serial send:\(DeviceModel.getHexStr(from: data))")
        guard port != nil else {
            return
        }
        let model = self.deviceModels[port!.name]
        if model != nil {
            model?.sendBytes += data.count
        }
//        self.sendBytes += data.count
        
        port?.send(data)
        
        DispatchQueue.main.async {
            self.sdLabel.stringValue = "RECEIVED: \(model?.receiveBytes ?? 0 ) BYTES"
            self.rcLabel.stringValue = "SENT: \(model?.sendBytes ??  0 ) BYTES"
        }
//
    }
    @objc func reGetDeviceNum() {
        
        if self.selectRow < self.serialPorts.count {
            let port = self.serialPorts[self.selectRow]
            
            self.sendData(data: DeviceModel.checkDeviceNumber(), port: port)
        
        }
        
        
    }
    func setBtnTitleColor(color:NSColor,btn:NSButton,_ title:String? = nil) {
        
        let style = NSMutableParagraphStyle.init()
        style.alignment = .center
        let dicArr = [NSAttributedString.Key.foregroundColor:color]
        if title != nil {
            let mutableString = NSMutableAttributedString.init(string: title!)
            mutableString.addAttributes(dicArr, range: NSMakeRange(0, title!.count))
            btn.attributedTitle = mutableString
        } else {
            let mutableString = NSMutableAttributedString.init(string: btn.title)
            mutableString.addAttributes(dicArr, range: NSMakeRange(0, btn.title.count))
            btn.attributedTitle = mutableString
        }
        
    }
    
    
}

