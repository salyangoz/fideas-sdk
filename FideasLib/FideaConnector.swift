//
//  FideaConnector.swift
//  FideasLib
//
//  Created by SERHAT YALCIN on 4.10.2017.
//  Copyright © 2017 Salyangoz. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

public class FideaConnector: NSObject {
    
    //http://37.131.253.21/Mobile/DataviewService.asmx?wsdl=
    var ServiceUrl = String()
    public override init() {
        ServiceUrl = "http://37.131.253.21/Mobile/DataviewService.asmx?wsdl="
    }
    public init(Url:String)
    {
        ServiceUrl = Url
    }
    public func Authenticate(ClientID:String,ClientSecret:String)->AuthenticationResult{
        let retval = AuthenticationResult()
        //Alamofire.request("", method: "POST", parameters: "", encoding: "", headers: ")
        return retval
    }
    public func Register(IdentityNumber:String,
                         Name:String,
                         Surname:String,
                         Email:String,
                         PhoneNumber:String,
                         DateOfBirth:String,
                         RetailerID:String,
                         DeviceID:String)->RegisterOperationResult{
        
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "FirstName" : Name,
            "Surname" : Surname,
            "DateOfBirth" : DateOfBirth,
            "MobileNumber" : PhoneNumber,
            "EmailAddress" : Email,
            "DeviceID" : DeviceID,
            "RetailerId" : RetailerID,
            "SequanceID" : "1",
            "AccessToken" : "token"
        ]
        
        let xmlEngine = XmlCreatorEngine()
        let xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        let opresult = RegisterOperationResult()
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let response = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let responseCode = response["ResponseCode"].element?.text
                    let responseMessage = response["ResponseDescription"].element?.text
                    if(responseCode == "200")
                    {
                        opresult.OperationStatus = 200
                        opresult.ResultDescription = ""
                    }
                    else
                    {
                        opresult.ServiceStatus = 200
                        opresult.OperationStatus = Int(responseCode!)!
                        opresult.ResultDescription = responseMessage!
                    }
                }
                else
                {
                    opresult.OperationStatus = responseCode!
                    
                }
        }
        return opresult
    }
    
    public func Login(Identity:String,MobileNumber:String,DeviceID:String,RetailerID:String)->AuthenticationResult{
        
        let authResult = AuthenticationResult()
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": Identity,
            "MobileNumber" : MobileNumber,
            "DeviceID" : DeviceID,
            "RetailerId" : RetailerID,
            "SequanceID" : "2",
            "AccessToken" : "token"
        ]
        
        let xmlEngine = XmlCreatorEngine()
        let xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")

        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let response = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let responseCode = response["ResponseCode"].element?.text
                    //let responseMessage = response["ResponseDescription"].element?.text
                    if(responseCode == "200")
                    {
                        let decision = response["DecisionEngine"]
                        
                        let customer = CustomerProfile()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        
                        customer.MobileNumber = response["MobileNumber"].element!.text
                        customer.IdentityNumber = response["IdentityNumber"].element!.text
                        
                        customer.MembershipDate = dateFormatter.date(from: response["MembershipDate"].element!.text)!
                        customer.DateOfBirth = dateFormatter.date(from: response["DateOfBirth"].element!.text)!
                        if(decision.children.count>0)
                        {
                            customer.KKBResult = KKBResponse()
                            customer.KKBResult?.Decision = decision["Decision"].element!.text
                            customer.KKBResult?.ReasonCode = decision["ReasonCode"].element!.text
                            customer.KKBResult?.ApplicationScore = Int(decision["ApplicationScore"].element!.text)!
                            customer.KKBResult?.ReasonDescription = decision["ReasonDescription"].element!.text
                            customer.KKBResult?.AdverseActionCode1 = decision["AdverseActionCode1"].element!.text
                            customer.KKBResult?.AdverseActionDesc1 = decision["AdverseActionDesc1"].element!.text
                        }
                        
                        
                    }
                    else
                    {
                        
                    }
                }
                else
                {
                    authResult.OperationResult = responseCode!
                    
                }
        }
        
        return authResult
    }
    
    public func RequestKKB(PhoneNumber:String,
                           IdentityNumber:String,
                           FirstName:String,
                           LastName:String,
                           DateOfBirth:String,
                           MobileNumber:String,
                           Email:String,
                           RetailerID:String,
                           DeviceID:String)-> KKBRequestResponse {
        
        //Check the request
        //If the deviceId same but the cellPhone or identityNumber is different we should block the request
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "FirstName" : FirstName,
            "Surname" : LastName,
            "DateOfBirth" : DateOfBirth,
            "MobileNumber" : MobileNumber,
            "EmailAddress" : Email,
            "DeviceID" : DeviceID,
            "RetailerId" : RetailerID,
            "SequanceID" : "4",
            "AccessToken" : "token",
            "Flags":  ["LoginFlag" : "Y" ]
        ]
        
        let xmlEngine = XmlCreatorEngine()
        let xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        
        let retval = KKBRequestResponse()
        
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let response = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let kkb = response["KKB"]
                    retval.RequestID = Int((kkb["KKBtalepId"].element?.text)!)!
                    retval.ErrorCode = Int((kkb["talepBaslatResponse"]["hataKodu"].element?.text)!)!
                    retval.ErrorMessage = (kkb["talepBaslatResponse"]["hataMesaji"].element?.text)!
                    retval.RequestResult = Int((kkb["talepBaslatResponse"]["islemSonucu"].element?.text)!)!
                    
                }
                else
                {
                    retval.ErrorCode = responseCode!
                    retval.ErrorMessage = "KKB işlemi sırasında bir hata oluştu. Lütfen daha sonra tekrardan deneyiniz."
                    
                }
        }
        
        return retval;
    }
    
    public func CheckKKBResponse(IdentityNumber:String,
                                 DateOfBirth:String,
                                 Pin:String,
                                 RequestID:String
                                 )->KKBResponse{
        let response = KKBResponse()
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "DateOfBirth" : DateOfBirth,
            "Pin" : Pin,
            "KKBTalepId" : RequestID,
            "SequanceID" : "5"
            
        ]
        
        let xmlEngine = XmlCreatorEngine()
        let xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let resp = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    response.Decision = (resp["DECISION"].element?.text)!
                    
                }
                else
                {
                    
                }
        }
        
        return response;
    }
    
    public func Report(IdentityNumber:String,
                       DateOfBirth:String,
                       RequestID:String
                       )->ReportResult{
        
        let result = ReportResult()
        
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "DateOfBirth" : DateOfBirth,
            "KKBTalepId" : RequestID,
            "SequanceID" : "6"
        ]
        
        let xmlEngine = XmlCreatorEngine()
        let xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let r = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    result.Result = (r["RESULT"].element?.text)!
                    
                }
                else
                {
                    
                }
        }
        
        return result;
    }
    
    public func UpdateProfile(IdentityNumber:String,
                              FirstName:String,
                              LastName:String,
                              DateOfBirth:Date,
                              MobileNumber:String,
                              EmailAddress:String,
                              DeviceID:String,
                              RetailerID:String
                              )-> UpdateOperationResult {
        
        
        let requestParams:Dictionary<String,Any?> = [
            "IdentityNumber": IdentityNumber,
            "FirstName" : FirstName,
            "Surname" : LastName,
            "DateOfBirth" : DateOfBirth,
            "MobileNumber" : MobileNumber,
            "EmailAddress" : EmailAddress,
            "DeviceID" : DeviceID,
            "RetailerId" : RetailerID,
            "SequanceID" : "3",
            "AccessToken" : "token"
        ]
        
        let xmlEngine = XmlCreatorEngine()
        let xmlContent = xmlEngine.CreateXmlRequest(Prefix: "", params: requestParams, Suffix: "")
        
        
        let url = NSURL(string:ServiceUrl)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlContent.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let result = UpdateOperationResult()
        
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let response = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let respCode = response["ResponseCode"].element?.text
                    let responseMessage = response["ResponseDescription"].element?.text
                    if(respCode == "200")
                    {
                        result.Result = 200
                        result.Message = "Profil Başarılı bir şekilde güncellenmiştir."
                    }
                    else
                    {
                        result.Result = Int(respCode!)!
                        result.Message = responseMessage!
                    }
                }
                else
                {
                    result.Result = responseCode!
                    result.Message = "İşlem sırasında bir hata ile karşılaşıldı."
                }
        }
        
        return result
    }
                       
}
