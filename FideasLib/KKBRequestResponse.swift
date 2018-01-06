//
//  KKBRequestResponse.swift
//  FideasLib
//
//  Created by SERHAT YALCIN on 20.11.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import UIKit

public class KKBRequestResponse {
    
    public init()
    {}
    public var RequestID = Int()
    public var ErrorCode = Int()
    public var ErrorMessage = String()
    public var RequestResult = Int()
    
    public var Decision : DecisionEngine?
    
}
