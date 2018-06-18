//
//  String+Additions.swift
//  RepoSearch
//
//  Created by Shantanu Dutta on 17/06/18.
//  Copyright © 2018 Shantanu Dutta. All rights reserved.
//

import Foundation

extension String {
    
    func dataUsingEncoding(_ encoding: String.Encoding) -> Data? {
        let nsSt = self as NSString
        return nsSt.data(using: encoding.rawValue)
    }
    //MARK:- Base64 Encoding/Decoding
    func base64Encode() -> String {
        let data = self.dataUsingEncoding(String.Encoding.utf8)
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
    
    func base64Decode() -> String? {
        if let decodedData = Data(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0)) {
            return NSString(data: decodedData, encoding: String.Encoding.utf8.rawValue) as String?
        }
        return nil
    }
    
    var removeInvalidCharacters: String {
        return self.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: Http.Constants.bracketStarttag.get(), with: "").replacingOccurrences(of: Http.Constants.bracketEndtag.get(), with: "")
    }
}
