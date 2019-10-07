import UIKit
import CryptoSwift

var str = "Hello, playground"
print(str)

do {
    let aes = try AES(key: "razvanrazvanrazv", iv: "razvanrazvanrazv")
    let cipherText = try aes.encrypt(Array("this is a classified audio recording".utf8))
    print(cipherText)
    
    let plainText = try aes.decrypt(cipherText)
    
    let stringCipher = String(bytes: cipherText, encoding: .utf16BigEndian)
    
    
    print(stringCipher!)
    let plainText2 = try aes.decrypt(Array(base64: stringCipher!))
        
    print(String(bytes: plainText, encoding: .utf8)!)
} catch {
    
}
