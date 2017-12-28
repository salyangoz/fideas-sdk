//
//  ReportResult.swift
//  FideasLib
//
//  Created by SERHAT YALCIN on 4.10.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import UIKit

public class ReportResult {
    init() {
        
    }
    public var IsSuccess = Bool()
    public var UnusedLimit = String()
    public var LimitPerCustomer = String()
    public var CreditScore = String()
    public var Decision : DecisionEngine?
}
