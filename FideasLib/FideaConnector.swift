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
        
        authResult.Result = AuthenticationResultTypes.Error
        
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseStatusCode = r.response?.statusCode
                if(responseStatusCode == 200)
                {
                    let response = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let responseCode = response["ResponseCode"].element?.text
                    let responseMessage = response["ResponseDescription"].element?.text
                    if(responseCode == "200"){
                        //let decision = response["DecisionEngine"]
                        
                        let customer = CustomerProfile()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        
                        customer.MobileNumber = response["MobileNumber"].element!.text
                        customer.IdentityNumber = response["IdentityNumber"].element!.text
                        
                        customer.MembershipDate = dateFormatter.date(from: response["MembershipDate"].element!.text)!
                        customer.DateOfBirth = dateFormatter.date(from: response["DateOfBirth"].element!.text)!
                        
                        
                        authResult.Result = AuthenticationResultTypes.Success
                        authResult.Profile = customer
                    }
                    else if (responseCode == "401")
                    {
                        authResult.Result = AuthenticationResultTypes.Failed
                        authResult.Profile = nil
                        authResult.ResponseMessage = responseMessage!
                    }
                }
                else
                {
                    authResult.OperationResult = responseStatusCode!
                    
                    
                }
        
            }
        return authResult
    }
    
    
    public func RequestKKB(MobileNumber:String,
                           IdentityNumber:String,
                           FirstName:String,
                           LastName:String,
                           DateOfBirth:String,
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
        
        response.IsSuccess = false
        Alamofire.request(req as URLRequestConvertible)
            .response{ r in
                let xml = SWXMLHash.parse(r.data!)
                let responseCode = r.response?.statusCode
                if(responseCode == 200)
                {
                    let resp = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let kkb = resp["KKB"]
                    if(kkb["talepOnayPin"].children.count>0)
                    {
                        if(kkb["talepOnayPin"]["return"].children.count>0)
                        {
                            response.ErrorCode = kkb["talepOnayPin"]["return"]["hataKod"].element!.text
                            response.ErrorMessage = kkb["talepOnayPin"]["return"]["hataMesaji"].element!.text
                            response.ProcessResult = kkb["talepOnayPin"]["return"]["islemSonucu"].element!.text
                        }
                    }
                    response.IsSuccess = true
                }
                else
                {
                    response.IsSuccess = false
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
                    let responseXml = xml["soap:Envelope"]["soap:Body"]["ProcessApplicationXMLResponse"]["ProcessApplicationXMLResult"]["Response"]
                    let kkbXml = responseXml["KKB"]
                    let decision = responseXml["DecisionEngine"]
                    if(kkbXml.children.count>0){
                        result.CreditScore = kkbXml["bkKrediNotu"].element!.text
                    }
                    if(decision.children.count>0)
                    {
                        //if (decision["DECISION"])
                        //{
                            result.Decision?.Decision = decision["DECISION"].element!.text
                        //}
                        
                        //if (decision["ReasonCode"])
                       // {
                            result.Decision?.ReasonCode = decision["ReasonCode"].element!.text
                        //}
                        //if (decision["ReasonDescription"])
                        //{
                            result.Decision?.ReasonCode = decision["ReasonDescription"].element!.text
                        //}
                    }
                    result.LimitPerCustomer = responseXml["LimitPerConsumer"].element!.text
                    result.UnusedLimit = responseXml["UnusedLimit"].element!.text
                    result.IsSuccess = true
                   
                    
                }
                else
                {
                  result.IsSuccess = false
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
