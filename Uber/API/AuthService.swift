//
//  AuthService.swift
//  Twitter
//
//  Created by macbook-pro on 14/05/2020.
//

import Firebase


struct AuthService {
    static let shared = AuthService()
    
    func registerUser(_ user: AuthCredentials,_ completionHandler: @escaping ((Error?) -> Void)) {
        AUTH.createUser(withEmail: user.email, password: user.password) { authResult, error in
            if let error = error {
                completionHandler(error)
                return
            }
            guard let userUid = authResult?.user.uid else { return }
            let imageName = UUID().uuidString
            let imageRef = STORAGE_PROFILE_IMAGES.child(userUid).child(imageName)
            imageRef.putData(user.imageProfile, metadata: nil) { metadata, error in
                if let error = error {
                    completionHandler(error)
                    return
                }
                imageRef.downloadURL { url, error in
                    if let error = error {
                        completionHandler(error)
                        return
                    }
                    if let url = url {
                        let data : [String : Any] = ["fullname":user.fullName,
                                                     "username":user.username,
                                                     "email":user.email,
                                                     "userOption":user.userOption,
                                                     "timestamp":Date(),
                                                     "bio":"",
                                                     "profileImageURL":url.absoluteString]
                        REF_USERS.document(userUid).setData(data, completion: completionHandler)
                    }
                }
                
            }
            
        }
    }
    func logUserIn(email:String, password: String, _ completionHandler: @escaping ((AuthDataResult?, Error?) -> Void)) {
        AUTH.signIn(withEmail: email, password: password, completion: completionHandler)
    }
}
