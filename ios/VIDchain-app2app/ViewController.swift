//
//  ViewController.swift
//  VIDchain app2app
//
//  Created by DEVOP-010 on 8/5/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var content: UITextView!
    
    let client_id = "myapp://" // set here your app URL scheme


    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationName = Notification.Name(Constants.Notification.Name)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: notificationName, object: nil)
    }
    
    func showProgressIndicator() {
        requestButton.isEnabled = false
        activityIndicator.startAnimating()
    }
    
    func hideProgressIndicator() {
        DispatchQueue.main.async {
            self.requestButton.isEnabled = true
            self.activityIndicator.stopAnimating()
        }
    }

    @objc func handleNotification(_ notification: Notification) {
        if let idtoken = notification.userInfo?[Constants.Notification.IdToken] as? String {
            if let jsonData = idtoken.data(using: .utf8) {
                if let formattedJson = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed ) {
                    if let formattedData = try? JSONSerialization.data(withJSONObject: formattedJson, options: .prettyPrinted) {
                        content.text = String(data: formattedData, encoding: .utf8)
                    }
                }
            }
            
        }
    }


    @IBAction func requestEmailCredential(_ sender: Any) {
        
        let sessionsBody:[String: Any] = [
            "grantType": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": "<INSERT HERE ASSERTION>", // This assertion should look like (with your apiKey): ewogICAgImlzcyI6ImVudGl0YXRTd2FnZ2VyIiwKICAgImF1ZCI6InZpZGNoYWluLWFwaSIsCiAgICJub25jZSI6InotMDQyN2RjMjUxNWIxIiwKICAgImNhbGxiYWNrVXJsIjoiaHR0cDovLzEyNy4wLjAuMTo4MDgwL2RlbW8vZW50aXRhdC1leGVtcGxlL2NhbGxiYWNrIiwKICAgImFwaUtleSI6ICI2MDAxMGMwZi05MmQ2LTQyMDYtYmFjYi1hMDRhYzA4MGVjNjMiCn0=
            "scope": "vidchain profile entity",
            "expiresIn": 2592000
        ]
        
        let jsonSessionsBody = try? JSONSerialization.data(withJSONObject: sessionsBody)
        
        guard let sessionsUrl = URL(string: "https://staging.vidchain.net/api/v1/sessions")
        else {return}
        var sessionsRequest = URLRequest(url: sessionsUrl)
        sessionsRequest.httpMethod = "POST"
        sessionsRequest.httpBody = jsonSessionsBody
        sessionsRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        showProgressIndicator()
        URLSession.shared.dataTask(with: sessionsRequest) { data, response, error in
            guard let data = data else {
                self.hideProgressIndicator()
                return
            }
            self.handleSessions(data: data)
        }
        .resume()
        
        
    }
    
    func handleSessions(data: Data){
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)

        if let dict = jsonObject as? [String: Any], let accessToken = dict["accessToken"] as? String {
            self.signAuthenticationRequest(accessToken)
        }
    }
    
    func signAuthenticationRequest(_ accessToken: String){
        let signAuthBody:[String: Any] = [
                "issuer": "did:ethr:0xDfBA7E7D6fd9D3B5B900cE2aa3d9E6aA43574FC0", // set your entity DID
                "payload": [
                    "iss": "did:ethr:0xDfBA7E7D6fd9D3B5B900cE2aa3d9E6aA43574FC0", // set your entity DID
                    "scope": "openid did_authn EmailCredential",
                    "registration": [
                        "jwks_uri": "https://api.vidchain.net/api/v1/identifiers/did:ethr:0xDfBA7E7D6fd9D3B5B900cE2aa3d9E6aA43574FC0;transform-keys=jwks", // set your entity DID in the path
                        "id_token_signed_response_alg": "ES256K"
                    ],
                    "client_id": self.client_id,
                    "nonce": "tgPf607_6SOaR3sFzPCQEBKIoYD8uUwB6tFC8wEYssI", // set random value
                    "state": "1f50031ed2e57ed52cf5fc81", // set random value
                    "response_type": "id_token",
                    "response_mode": "fragment",
                    "response_context": "rp",
                    "claims": [
                        "vc": [
                            "EmailCredential": [
                                "essential": true
                            ]
                        ]
                    ]
                ] as [String : Any],
                "type": "EcdsaSecp256k1Signature2019",
                "expiresIn": 600,
                "alg": "ES256K",
                "kid": "did:ethr:0xDfBA7E7D6fd9D3B5B900cE2aa3d9E6aA43574FC0#keys-1" // set your entity DID plus #keys-1
        ]
        
        let jsonSignAuthBody = try? JSONSerialization.data(withJSONObject: signAuthBody)
        
        guard let signAuthUrl = URL(string: "https://staging.vidchain.net/api/v1/signatures")
        else {return}
        var signAuthRequest = URLRequest(url: signAuthUrl)
        signAuthRequest.httpMethod = "POST"
        signAuthRequest.httpBody = jsonSignAuthBody
        signAuthRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        signAuthRequest.setValue("Bearer " + accessToken , forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: signAuthRequest) { data, response, error in
            guard let data = data else {
                return
            }
            self.handleSignAuth(data: data)
            self.hideProgressIndicator()
        }
        .resume()
    }
    
    func handleSignAuth(data: Data){
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)

        if let dict = jsonObject as? [String: Any], let jws = dict["jws"] as? String {
            self.requestVP(jws)
        }
    }
    
    
    func requestVP(_ jws: String){
        // Notice that the state and nonce must be the same as previously provided in the signed request
        guard let requestUrl = URL(string: "vidchain://did-auth?openid://?response_type=id_token&client_id=" + self.client_id + "&scope=openid%20did_authn%20EmailCredential&state=1f50031ed2e57ed52cf5fc81&nonce=tgPf607_6SOaR3sFzPCQEBKIoYD8uUwB6tFC8wEYssI&request=" + jws)
        else {
            print("request url could not be created")
            return
        }
        DispatchQueue.main.async {
            print(requestUrl)
            if UIApplication.shared.canOpenURL(requestUrl) {
                UIApplication.shared.open(requestUrl)
            }
        }
       
    }
}

