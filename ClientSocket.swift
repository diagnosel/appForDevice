//
//  Connect.swift
//  GuiDevices
//
//  Created by diagnosefiz on 09.08.17.
//  Copyright © 2017 diagnosefiz. All rights reserved.
//

import Foundation
import SwiftSocket

class Connect: NSObject {
    var ViewController: ViewController?
    
    let client = TCPClient(address: "", port: 0)
    var ipPort: [String] = []
    var address = ""
    var port = ""
    var data:Data = Data()
    var entrySend: Int = 0
        
// MARK: - Networks
    
    func disconnect() {
        client.close()
    }
    
// Подключение
    func connectWithTimeOut(address: String, port: Int32) {
        client.address = address
        client.port = port
        client.connect(timeout: 10)
        
        switch client.connect(timeout: 100) {
        case .success:
            print("connect to server")
            guard let data = client.read(1024*10) else { return }
            
            if let response = String(bytes: data, encoding: .utf8) {
                print("response: \(response)")
            }
        case .failure(let error):
            print("error:\(error)")
        }
    }
    
// Отправка данных на сервер
    func send(textU: UInt32, textI: UInt32, request: String, mode: UInt8) {
        var requestUInt8: UInt8 = 0
        if (request == "None") {
            requestUInt8 = 0
        }
        else if (request == "ON") {
            requestUInt8 = 1
        }
        else if (request == "OFF") {
            requestUInt8 = 2
        }
        
        var structUI = PStypes(u        : textU,
                               i        : textI,
                               time     : 10_000,
                               request  : requestUInt8,
                               mode     : mode)
        print("U: \(textU)", "I: \(textI)", "Request:\(requestUInt8)", "Task mode:\(mode)")
        let bufferData = NSData(bytes   : &structUI,
                                length  : MemoryLayout.size(ofValue: structUI))
        data = bufferData as Data
        
        let result = client.send(data: data)
        // Двойная отправка
//        if(self.entrySend == 1){
//            _ = client.send(data: self.data)
//        }
//        
//        self.entrySend += 1
//        
//        if (self.entrySend >= 2) {
//            self.entrySend = 0
//        }
        
        
        print("Send result: \(result)")
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
}
