//
//  DeviceModel.swift
//  AC Infinity for Mac
//
//  Created by cooltron on 2021/7/2.
//

import Foundation


class DeviceModel: NSObject {
    
    var connectPortName: String?
    var version : String?
    var deviceType : Int?
    var number : String?
    var status : String?
    var isOnline : Bool?     //  是否在线
    var level = 0
    var speed = 0
    var rev = 0
    
    var sendBytes = 0
    var receiveBytes = 0
    
    
    func resetModel() {
        
        version = nil
        deviceType = nil
        number = nil
        status = nil
        isOnline = nil
        
    }
    func getDeviceTypeName() -> String{
        
        switch deviceType {
        case 0:
            return "--"
        case 1:
            return "工业风扇/落地扇/排风扇/家庭风机/横流风机"
        case 2:
            return "调光器"
        case 3:
            return "管道风机(新)/家庭风机"
        case 4:
            return "管道风机(旧)/排风扇"
        case 5:
            return "壁扇/夹扇"
        case 6:
            return "加湿器/除湿器"
        default:
            return "--"

        }
        
    }
    func getDeviceTypeNameForEn() -> String{
        
        switch deviceType {
        case 0:
            return "--"
        case 1:
            return "Fan"
        case 2:
            return "Dimmer"
        case 3:
            return "Fan"
        case 4:
            return "Fan"
        case 5:
            return "Fan"
        case 6:
            return "Humidifier"
        default:
            return "--"
            
        }
        
    }
    
    func getDeviceType() -> String {
        
        guard let type = deviceType else {
            return "Other Device"
        }
        guard type != 65535 else {
            return "---"
        }
        if (type >= 4845 && type <= 5355) || (type >= 5890 && type <= 6510) || (type >= 7125 && type <= 7875) || (type >= 9500 && type <= 10500) {
            return "Fan"
        } else if type >= 3135 && type <= 3465 {
            return "Dimmer"
        } else if type >= 11400 && type <= 12600 {
            return "Humidifier"
        }
        
        
        
        return "Other Device"
    }
    
    
    func getAvailableType() -> Bool {
        
        if deviceType == 0 || deviceType == 6 {
            return false
        } else {
            return true
        }
        
    }
        
    //  设备信息指令查询   序列号  版本号
    class func checkDeviceNumber() -> Data {
        
        var data : [UInt8] = [0x80,0x00]
        
        data.append(self.dataCheckSum(data: data))
       
        let sendData = Data.init(bytes: data, count: data.count)
        
        return sendData
        
    }
//   设备状态指令查询   负载类型
    class func checkDeviceState() -> Data {

        var data : [UInt8] = [0x81,0x00]

        data.append(self.dataCheckSum(data: data))

        let sendData = Data.init(bytes: data, count: data.count)

        return sendData

    }
    //  查询风机状态
    class func checkStatus() -> Data {
        let data : [UInt8] = [0x93,0x00,0x93]
        let sendData = Data.init(bytes: data, count: data.count)
        
        return sendData
    }

    //  设置档位
    class func setDeviceFanLevel(level:Int) -> Data {
        
        let fanLevel = UInt8(level)
        
        var data = [0x92,0x01,fanLevel]
        
        data.append(self.dataCheckSum(data: data))
        
        let sendData = Data.init(bytes: data, count: data.count)
        
        return sendData
    }
    
    
    class func dataCheckSum(data:[UInt8]) -> UInt8 {
        
        var sum : UInt8 = 0
        
        for value in data {
            
            sum += value
            
        }
        
        return UInt8(sum%0xff)
        
    }
    ///   1.0.1新版本协议     3个查询指令，一个控制指令
    ///  设备序列号，版本信息查询
    class func getDeviceVersion() -> Data {
    
        var data : [UInt8] = [0x80,0x00]
        
        data.append(self.dataCheckSum(data: data))
       
        let sendData = Data.init(bytes: data, count: data.count)
        
        return sendData
    
    }
    ///   负载类型查询
    class func getDeviceInfomation() -> Data {
        
        var data : [UInt8] = [0x81,0x00]

        data.append(self.dataCheckSum(data: data))

        let sendData = Data.init(bytes: data, count: data.count)

        return sendData
        
    }
    //  查询风机状态  是否在线，风机档位，风机转速
    class func getFanStatus() -> Data {
        var data : [UInt8] = [0x93,0x00]
        data.append(self.dataCheckSum(data: data))
        
        let sendData = Data.init(bytes: data, count: data.count)
        return sendData
    }
    //  设置风机档位
    class func setFanSpeed(speed:Int) -> Data {
        
        let fanLevel = UInt8(speed)
        
        var data = [0x92,0x01,fanLevel]
        
        data.append(self.dataCheckSum(data: data))
        
        let sendData = Data.init(bytes: data, count: data.count)
        
        return sendData
        
    }
    
    
    /// Utils
    
    
    class func getHexStr(from data:Data) -> String {
        var str = ""
        data.enumerateBytes { (bytes, index, stop) in
            let dataBytes = bytes
            for index in 0..<dataBytes.count {
                let hexStr = String.init(format: "%x", (dataBytes[index]) & 0xff)
                if hexStr.count == 2 {
                    str.append(contentsOf: hexStr)
                } else {
                    str.append(contentsOf: "0\(hexStr)")
                }
            }
        }
        return str
    }
    class func getStringByHex(from string:String) -> String {
        var str = ""
        for index in 0..<string.count/2 {
            var intStr : UInt32 = 0
            let hexStr = self.substring(string: string, location: index*2, length: 2)
            let scanner = Scanner.init(string: hexStr)
            scanner.scanHexInt32(&intStr)
            let char  =  Character(UnicodeScalar(intStr)!)
            str.append(char)
        }
        return str
    }
    class func substring(string:String,location:Int,length:Int) -> String {
       guard location < string.count else {return string}
       let  nsrange = NSRange(location: location, length: length)
       let  start = string.index(string.startIndex, offsetBy: nsrange.lowerBound)
       let  end = string.index(string.startIndex, offsetBy: nsrange.upperBound)
       let  substringRange = start..<end
       return  String.init(string[substringRange])
    }
}
