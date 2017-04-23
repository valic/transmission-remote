//
//  TransmissionRequest.swift
//  transmission remote
//
//  Created by Mialin Valentin on 19.04.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import Foundation

class torrent {
    
    // id:Int, name:String, percentDone:Float, eta:Int, rateDownload:Int, status:Int)
    
    var id:Int
    var name:String
    var percentDone:Float
    var eta:Int
    var rateDownload:Int
    var rateUpload:Int
    var status:Int
    var peersGettingFromUs:Int
    var peersSendingToUs:Int
    var peersConnected:Int
    
    init(id:Int, name:String, percentDone:Float, eta:Int, rateDownload:Int, rateUpload:Int, status:Int, peersGettingFromUs:Int, peersSendingToUs:Int, peersConnected:Int) {
        self.id = id
        self.name = name
        self.percentDone = percentDone
        self.eta = eta
        self.rateDownload = rateDownload
        self.rateUpload = rateUpload
        self.status = status
        self.peersGettingFromUs = peersGettingFromUs
        self.peersSendingToUs = peersSendingToUs
        self.peersConnected = peersConnected
        
        
        
    }
}

class TransmissionRequest{
    
    var transmissionSessionId = ""
    var resultData:Data?
    var resultResponse:URLResponse?
    
    
    func request(json: [String: Any], SessionId: String) -> (Data, URLResponse) {
        
        let userDefults = UserDefaults.standard
        var userName = ""
        var password = ""
        
        
        // userName
        if let userName_userDefults = userDefults.value(forKey: "userName") as? String {
            userName = userName_userDefults
        }
        // password
        if let password_userDefults = userDefults.value(forKey: "password") as? String {
            password = password_userDefults
        }
        
        let loginString = String(format: "%@:%@", userName, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        // create the request
        let url = URL(string: "http://192.168.64.100:9091/transmission/rpc/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        // insert json data to the request
        request.httpBody = jsonData
        request.setValue(SessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data2 = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            self.resultResponse = response
            self.resultData = data2
            semaphore.signal()
        }
        
        task.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (resultData!, resultResponse!)
    }
    

    func requestStart(json: [String: Any]) -> Data? {
        
        var result = request(json: json, SessionId: self.transmissionSessionId)
        
        if let httpStatus = result.1 as? HTTPURLResponse, httpStatus.statusCode != 200 {
            if httpStatus.statusCode == 409 {
                if let sessionId = httpStatus.allHeaderFields["X-Transmission-Session-Id"] as? String {
                    self.transmissionSessionId = sessionId
                    result = request(json: json, SessionId: self.transmissionSessionId)
                }
            }
            
        }
        return result.0
    }
    
    
    func torrentGet() -> [torrent] {
        
        var torrentArray = [torrent]()
        
        let jsonString: [String: Any] = [
            "arguments": [ "fields" :  ["id", "name", "percentDone", "eta", "rateDownload", "rateUpload", "queuePosition", "peersGettingFromUs", "peersSendingToUs",  "peersConnected", "status"]],
            "method": "torrent-get"
        ]
        
        let requestResult = requestStart(json: jsonString)
        //     print(requestResult!)
        
        if let json = try? JSONSerialization.jsonObject(with: requestResult!) as? [String:Any]{
            // print(json!)
            let arguments = json?["arguments"] as? [String:Any]
            let torrents = arguments?["torrents"] as? [[String:Any]]
            
            
            for torrents in torrents! {
                
                let id = torrents["id"] as? Int
                let name = torrents["name"] as? String
                let percentDone = torrents["percentDone"] as? Float
                let eta = torrents["eta"] as? Int
                let rateDownload = torrents["rateDownload"] as? Int
                let rateUpload = torrents["rateUpload"] as? Int
                let status = torrents["status"] as? Int
                
                let peersGettingFromUs = torrents["peersGettingFromUs"] as? Int
                let peersSendingToUs = torrents["peersSendingToUs"] as? Int
                let peersConnected = torrents["peersConnected"] as? Int
                
                
                torrentArray.append(torrent(id: id!, name: name!, percentDone: percentDone!, eta: eta!, rateDownload: rateDownload!, rateUpload: rateUpload!, status: status!, peersGettingFromUs: peersGettingFromUs!, peersSendingToUs: peersSendingToUs!, peersConnected: peersConnected!))
                
            }
        }
        
        return torrentArray
        
    }
    
    func stopTorrent(id: Int){
        
        let jsonString: [String: Any] = [
            "arguments": [ "ids" :  [id]],
            "method": "torrent-stop"
        ]
        
        _ = requestStart(json: jsonString)
        
    }
    
    func startTorrent(id: Int){
        
        let jsonString: [String: Any] = [
            "arguments": [ "ids" :  [id]],
            "method": "torrent-start"
        ]
        
        _ = requestStart(json: jsonString)
    }
    
    func deleteTorrent(id: Int){
        
        let jsonString: [String: Any] = [
            "arguments": [ "ids" :  [id]],
            "method": "torrent-remove"
        ]
        
        _ = requestStart(json: jsonString)
    }
    
}


