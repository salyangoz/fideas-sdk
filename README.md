![CocoaPods](https://img.shields.io/cocoapods/v/FideasLib.svg)

# FIDEAS SDK
# Installing
###  Cocoa Pods
```ruby
platform :ios, '9.0'
use_frameworks!

target 'MyApp' do
    pod 'FideasLib'
end
```

# Usage

#### Initialization

```swift
import FideasLib
```
### Register

#### Signature

```swift
    public func Register(IdentityNumber:String,
                         Name:String,
                         Surname:String,
                         Email:String,
                         PhoneNumber:String,
                         DateOfBirth:String,
                         RetailerID:String,
                         DeviceID:String,
                         callbackFunction:@escaping(_ result: RegisterOperationResult) -> Void
        )
```
#### Code Example
```swift
import UIKit
import FideasLib

class RegisterViewController: UIViewController
{
    func Register()->
    {
        let service = FideaConnector()
        service.Register(IdentityNumber: txtIdentityNumber.text!, Name: txtNameSurname.text!, Surname: "", 
        Email: txtEmail.text!, PhoneNumber: txtPhoneNumber.text!, DateOfBirth: txtBirthDate.text!, 
        RetailerID: _retailerID, DeviceID: self.GetDeviceID(),callbackFunction: {
                result in
                //Success
                if(result.OperationStatus == 200)
                {
                }
                else
                {}
          }
       )
    }
}
```

### Login

#### Signature

```swift
public func Login(Identity:String,MobileNumber:String,DeviceID:String,RetailerID:String,callback:@escaping(_ result: AuthenticationResult) -> Void)
```

#### Code Example

```swift
import UIKit
import FideasLib
class LoginViewController: UIViewController
{
    func Login()
    {
        let service = FideaConnector()
        service.Login(Identity: txtIdentityNumber.text!, MobileNumber: txtPhoneNumber.text!, DeviceID: self.GetDeviceID(), RetailerID: _retailerID, callback: {
            result in
            if(result.Result == AuthenticationResultTypes.Success)
            {
              }  
      })
    }
}
```
