//
//  ParamsBuilder.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/22/20.
//

import Alamofire

class ParamsBuilder {
    var params = Parameters()
    
    @discardableResult
    func appendIfNotNil(key: String, value: Any?) -> ParamsBuilder {
        if value != nil {
            params[key] = value
        }
        return self
    }
    
    @discardableResult
    func appendFromHandler(_ handler: (ParamsBuilder) -> Void) -> ParamsBuilder {
        handler(self)
        return self
    }
    
    @discardableResult
    func appendIfNotNil(key: String, fromHandler: (ParamsBuilder) -> Any?) -> ParamsBuilder {
        if let value = fromHandler(self) {
            params[key] = value
        }
        return self
    }
}

