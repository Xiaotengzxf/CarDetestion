//
//  NetworkManager.swift
//  CarDetecion
//
//  Created by 张晓飞 on 2017/3/13.
//  Copyright © 2017年 inewhome. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkManager {
    
    static let sharedInstall = NetworkManager() // 单例
    
    let domain = "http://119.23.128.214:8080/carWeb/"
    
    enum CustomError : Int , Error {
        case Custom
    }
    
    
    func request(url: String , params : Parameters? , callback : @escaping (_ json : JSON? ,_ error : Error?)->()) {
        Alamofire.request("\(domain)\(url)", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    print("返回内容：\(value)")
                    callback(JSON(value) , nil)
                }else{
                    callback(nil , CustomError.Custom)
                }
                
            case .failure(let error):
                callback(nil , error)
            }
        }
    }
    
    func upload(url: String , params : [String : String]? ,data : Data? , callback : @escaping (_ json : JSON? ,_ error : Error?)->()) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if data != nil {
                    multipartFormData.append(data!, withName: "image", fileName: "image.jpg", mimeType: "image/jpg")
                }
                if params != nil {
                    for (key , value) in params! {
                        multipartFormData.append(value.data(using: .utf8)!, withName: key)
                    }
                }
        },
            to: "\(domain)\(url)",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        callback(JSON(data: response.data!), nil)
                    }
                case .failure(let encodingError):
                    callback(nil , encodingError)
                }
        }
        )
    }
}
