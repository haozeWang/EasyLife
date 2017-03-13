//
//  SharedNetwork.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/8.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit
import Foundation

class SharedNetwork: NSObject {
    static let SharedInstance = SharedNetwork()
    
    func getts() -> String{
        let test =  Date().timeIntervalSince1970
        let temp = "\(test)"
        let index = temp.index(temp.startIndex, offsetBy: 10)
        let res = temp.substring(to: index)
        return res
    }
    
    
    func getuid(ts : String)-> String{
        let test = "ts=\(ts as! String)&uid=U767389AA8"
        let key = "f4e9afhjuyblv14i"
        let hmacResult: String = test.hmac(algorithm: HMACAlgorithm.SHA1, key: key)
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        let escapedString = hmacResult.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        print("\(escapedString)")
        return escapedString!
    }
    
    
    
    
    func grabSomeData(_ urlString: String, completion:@escaping (AnyObject?) -> Void) {
        // Test that we can convert the `String` into an `NSURL` object.  If we can
        // not, then crash the application.
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let url = URL(string: urlString)  else {
            
            fatalError("No URL")
        }
        
        // Create a `NSURLSession` object
        let session = URLSession.shared
        
        // Create a task for the session object to complete
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            
            // Check for errors that occurred during the download.  If found, execute
            // the completion block with `nil`
            
            guard error == nil else {
                print("Error")
                
                completion(nil)
                return
            }
            
            // Print the response headers (for debugging purpose only)
            // print(response)
            
            // Test that the data has a value and unwrap it to the variable `let`.  If
            // it is `nil` than pass `nil` to the completion closure.
            
            guard let data = data else {
                print("No data")
                
                completion(nil)
                return
            }
            
            // Unserialze the JSON that was retrieved into an Array of Dictionaries.
            // Pass is as parameter to the completion block.
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                completion(json as AnyObject?)
            } catch {
                print("Error Json")
                completion(nil)
            }
        })
        
        // Start the downloading.  NSURLSession objects are created in the paused
        // state, so to start it we need to tell it to *resume*
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        task.resume()
    }

    
}


enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    func hmac(algorithm: HMACAlgorithm, key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        CCHmac(algorithm.toCCHmacAlgorithm(), cKey!, Int(strlen(cKey!)), cData!, Int(strlen(cData!)), &result)
        let hmacData:NSData = NSData(bytes: result, length: (Int(algorithm.digestLength())))
        let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
        return String(hmacBase64)
    }
}

