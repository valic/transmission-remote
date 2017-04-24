//
//  TransmissionRequest.swift
//  transmission remote
//
//  Created by Mialin Valentin on 19.04.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class torrent {
    
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
    
    
    func requestAlamofire(json: [String: Any], completionHandler: @escaping (AnyObject?, NSError?) -> ()) {
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
        
        let url = URL(string: "http://192.168.64.100:9091/transmission/rpc/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        // insert json data to the request
        request.httpBody = jsonData
        request.setValue(transmissionSessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
        
        
        
        Alamofire.request(request).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                completionHandler(value as AnyObject, nil)
                
            case .failure(let error):
                
                if response.response?.statusCode == 409 {
                    if let SessionId = response.response?.allHeaderFields["X-Transmission-Session-Id"] as? String {
                        
                        self.transmissionSessionId = SessionId
                        request.setValue(self.transmissionSessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
                        
                        Alamofire.request(request).responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                
                                completionHandler(value as AnyObject, nil)
                                
                            case .failure(let error):
                                completionHandler(nil, error as NSError)
                                print("Failure \(error)")
                            }
                        }
                    }
                }
                else{
                    completionHandler(nil, error as NSError)
                    print("Failure \(error)")
                }
                
            }
        }
    }
    
    
    
    func torrentGet(completion: @escaping  ([torrent]) -> ()) {
        
        var torrentArray = [torrent]()
        
        let jsonString: [String: Any] = [
            "arguments": [ "fields" :  ["id", "name", "percentDone", "eta", "rateDownload", "rateUpload", "queuePosition", "peersGettingFromUs", "peersSendingToUs",  "peersConnected", "status"]],
            "method": "torrent-get"
        ]

        requestAlamofire(json: jsonString) { responseObject, error in
            let json = JSON(responseObject!)
            
            if json["result"].stringValue == "success" {
                for item in json["arguments"]["torrents"].arrayValue {
                    
                    torrentArray.append(torrent(id: item["id"].intValue,
                                                name: item["name"].stringValue,
                                                percentDone: item["percentDone"].floatValue,
                                                eta: item["eta"].intValue,
                                                rateDownload: item["rateDownload"].intValue,
                                                rateUpload: item["rateUpload"].intValue,
                                                status: item["status"].intValue,
                                                peersGettingFromUs: item["peersGettingFromUs"].intValue,
                                                peersSendingToUs: item["peersSendingToUs"].intValue,
                                                peersConnected: item["peersConnected"].intValue))
                }
            }
            completion(torrentArray)
        }
    }
    
    func stopTorrent(id: Int){
        
        let jsonString: [String: Any] = [
            "arguments": [ "ids" :  [id]],
            "method": "torrent-stop"
        ]
        
        requestAlamofire(json: jsonString) { responseObject, error in
        }
        
    }
    
    func startTorrent(id: Int){
        
        let jsonString: [String: Any] = [
            "arguments": [ "ids" :  [id]],
            "method": "torrent-start"
        ]
        
        requestAlamofire(json: jsonString) { responseObject, error in
        }
    }
    
    func deleteTorrent(id: Int){
        
        let jsonString: [String: Any] = [
            "arguments": [ "ids" :  [id]],
            "method": "torrent-remove"
        ]
        
        requestAlamofire(json: jsonString) { responseObject, error in
        }
    }
    
}


