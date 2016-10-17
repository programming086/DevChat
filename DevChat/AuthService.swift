//
//  AuthService.swift
//  DevChat
//
//  Created by Mark Price on 7/13/16.
//  Copyright © 2016 Devslopes. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias Completion = (errMsg: String?, data: AnyObject?) -> Void

class AuthService {
    private static let _instance = AuthService()
    
    static var instance: AuthService {
        return _instance
    }
    
    func login(email: String, password: String, onComplete: Completion?) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                if let errorCode = FIRAuthErrorCode(rawValue: error!.code) {
                    if errorCode == .errorCodeUserNotFound {
                        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                self.handleFirebaseError(error: error!, onComplete: onComplete)
                            } else {
                                if user?.uid != nil {
                                    
                                    DataService.instance.saveUser(uid: user!.uid)
                                    //Sign in
                                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                                        if error != nil {
                                            self.handleFirebaseError(error: error!, onComplete: onComplete)
                                        } else {
                                            onComplete?(errMsg: nil, data: user)
                                        }
                                    })
                                }
                            }
                        })
                    }
                } else {
                    //Handle all other errors
                    self.handleFirebaseError(error: error!, onComplete: onComplete)
                }
            } else {
                //Successfully logged in
                onComplete?(errMsg: nil, data: user)
            }
            
        })
    }
    
    func handleFirebaseError(error: NSError, onComplete: Completion?) {
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            switch (errorCode) {
            case .errorCodeInvalidEmail:
                onComplete?(errMsg: "Invalid email address", data: nil)
                break
            case .errorCodeWrongPassword:
                onComplete?(errMsg: "Invalid password", data: nil)
                break
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
                onComplete?(errMsg: "Could not create account. Email already in use", data: nil)
                break
            default:
                onComplete?(errMsg: "There was a problem authenticating. Try again.", data: nil)
            }
        }
    }
    
    
    
    
}
