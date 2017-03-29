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
                    print(value)
                    callback(JSON(value) , nil)
                }else{
                    callback(nil , CustomError.Custom)
                }
                
            case .failure(let error):
                callback(nil , error)
            }
        }
    }
}
