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
    public override init() {
        
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
        
        let url = NSURL(string:"http://37.131.253.21/Mobile/DataviewService.asmx?wsdl=" as String)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        
        let xmlValue = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
            + "<soapenv:Header/>"
            + "<soapenv:Body>"
            + "<dvt:ProcessApplicationXML>"
            + "<dvt:XmlRequest>"
            + "<Request>"
            + "<IdentityNumber>\(IdentityNumber)</IdentityNumber>"
            + "<FirstName>\(Name)</FirstName>"
            + "<Surname>\(Surname)</Surname>"
            + "<DateOfBirth>\(DateOfBirth)</DateOfBirth>"
            + "<MobileNumber>\(PhoneNumber)</MobileNumber>"
            + "<EmailAddress>\(Email)</EmailAddress>"
            + "<DeviceID>\(DeviceID)</DeviceID>"
            + "<RetailerId>\(RetailerID)</RetailerId>"
            + "<SequenceID>1</SequenceID>"
            + "<AccessToken>aaaaaaaab</AccessToken>"
            + "</Request>"
            + "</dvt:XmlRequest>"
            + "</dvt:ProcessApplicationXML>"
            + "</soapenv:Body>"
            + "</soapenv:Envelope>"
        req.httpBody = xmlValue.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
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
        let xmlBody = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
        + "<soapenv:Header/>"
        + "<soapenv:Body>"
        + "<dvt:ProcessApplicationXML>"
        + "<dvt:XmlRequest>"
        + "<Request>"
            + (Identity == "" ? "": "<IdentityNumber>\(Identity)</IdentityNumber>")
        + (MobileNumber == "" ? "" : "<MobileNumber>\(MobileNumber)</MobileNumber>")
        + "<DeviceID>\(DeviceID)</DeviceID>"
        + "<RetailerId>\(RetailerID)</RetailerId>"
        + "<SequenceID>2</SequenceID>"
        + "</Request>"
        + "</dvt:XmlRequest>"
        + "</dvt:ProcessApplicationXML>"
        + "</soapenv:Body>"
        + "</soapenv:Envelope>"
        
        let url = NSURL(string:"http://37.131.253.21/Mobile/DataviewService.asmx?wsdl=" as String)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlBody.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
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
        let xmlBody = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
            + "<soapenv:Header/>"
            + "<soapenv:Body>"
            + "<dvt:ProcessApplicationXML>"
            + "<dvt:XmlRequest>"
            + "<Request>"
            + "<IdentityNumber>\(IdentityNumber)</IdentityNumber>"
            + "<FirstName>\(FirstName)</FirstName>"
            + "<Surname>\(LastName)</Surname>"
            + "<DateOfBirth>\(DateOfBirth)</DateOfBirth>"
            + "<MobileNumber>\(MobileNumber)</MobileNumber>"
             + "<EmailAddress>\(Email)</EmailAddress>"
            + "<DeviceID>\(DeviceID)</DeviceID>"
            + "<RetailerId>\(RetailerID)</RetailerId>"
            + "<SequenceID>2</SequenceID>"
            + "</Request>"
            + "</dvt:XmlRequest>"
            + "</dvt:ProcessApplicationXML>"
            + "</soapenv:Body>"
            + "</soapenv:Envelope>"
        
        let url = NSURL(string:"http://37.131.253.21/Mobile/DataviewService.asmx?wsdl=" as String)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlBody.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        
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
    
    public func CheckKKBResponse(PhoneNumber:String,
                                 IdentityNumber:String,
                                 MerchantID:String,
                                 DeviceID:String)->KKBResponse{
        let response = KKBResponse()
        
        return response;
    }
    
    public func Report(DateOfBirth:Date,
                       PINNumber:String,
                       KKBRequestID:String,
                       DeviceID:String)->ReportResult{
        
        let result = ReportResult()
        
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
        
        let xmlBody = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:dvt=\"http://dvtransaction.com/\">"
            + "<soapenv:Header/>"
            + "<soapenv:Body>"
            + "<dvt:ProcessApplicationXML>"
            + "<dvt:XmlRequest>"
            + "<Request>"
            + "<IdentityNumber>\(IdentityNumber)</IdentityNumber>"
            + "<FirstName>\(FirstName)</FirstName>"
            + "<Surname>\(LastName)</Surname>"
            + "<DateOfBirth>\(DateOfBirth)</DateOfBirth>"
            + "<MobileNumber>\(MobileNumber)</MobileNumber>"
            + "<EmailAddress>\(EmailAddress)</EmailAddress>"
            + "<DeviceID>\(DeviceID)</DeviceID>"
            + "<RetailerId>\(RetailerID)</RetailerId>"
            + "<SequenceID>3</SequenceID>"
            + "</Request>"
            + "</dvt:XmlRequest>"
            + "</dvt:ProcessApplicationXML>"
            + "</soapenv:Body>"
            + "</soapenv:Envelope>"
        
        let url = NSURL(string:"http://37.131.253.21/Mobile/DataviewService.asmx?wsdl=" as String)
        var req = URLRequest(url: url! as URL)
        req.httpMethod = "POST"
        req.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        req.httpBody = xmlBody.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
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
