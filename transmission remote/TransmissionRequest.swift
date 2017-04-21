//
//  TransmissionRequest.swift
//  transmission remote
//
//  Created by Mialin Valentin on 19.04.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import Foundation

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
            
/*
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                if httpStatus.statusCode == 409 {
                    
                    if let sessionId = httpStatus.allHeaderFields["X-Transmission-Session-Id"] as? String {
                        self.transmissionSessionId = sessionId

                    
                    }
                
                
               print("statusCode should be 200, but is \(httpStatus.statusCode)")
               print("response = \(String(describing: response))")

                self.resultData = data2
            
            
           let responseString = String(data: data2, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            
            

        }
            }*/
            self.resultResponse = response
            self.resultData = data2
            semaphore.signal()
        }
        
        task.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (resultData!, resultResponse!)
}

    func testName(json: [String: Any]) -> Data? {
        
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


    func torrentGet() -> [(id:Int, name:String, percentDone:Float, eta:Int, rateDownload:Int, status:Int)] {
        
        var names = [(id:Int, name:String, percentDone:Float, eta:Int, rateDownload:Int, status:Int)]()
        
        let jsonString: [String: Any] = [
            "arguments": [ "fields" :  ["id", "name", "percentDone", "eta", "rateDownload", "status"]],
            "method": "torrent-get"
        ]
        
       let requestResult = testName(json: jsonString)
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
                let status = torrents["status"] as? Int
                
                names.append((id: id!, name: name!, percentDone: percentDone!, eta: eta!, rateDownload: rateDownload! , status: status!))
            }
            
           // names = field[0]["name"] as! String
            // print(names) // ==> Test1
        }
        
        return names
        
    }
}
        
