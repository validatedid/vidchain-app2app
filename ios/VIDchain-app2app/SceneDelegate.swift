//
//  SceneDelegate.swift
//  VIDchain app2app
//
//  Created by DEVOP-010 on 8/5/23.
//

import UIKit

extension String {
  var fixedBase64Format: Self {
    let offset = count % 4
    guard offset != 0 else { return self }
    return padding(toLength: count + 4 - offset, withPad: "=", startingAt: 0)
  }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrlContext = URLContexts.first else {
            return
        }
        print("Open from url: \(firstUrlContext.url)")
        let url = firstUrlContext.url.absoluteString
        
        
        
        if let firstPointRange = url.range(of: "."),
           let secondPointRange = url.range(of: ".", range: firstPointRange.upperBound..<url.endIndex) {
            let parsedString = String(url[firstPointRange.upperBound..<secondPointRange.lowerBound]).fixedBase64Format
            guard let data = Data(base64Encoded: parsedString) else {
                print("Cannot decode content")
                return
            }
            let decodedString = String(data: data, encoding: .utf8)
            let notificationName = Notification.Name(Constants.Notification.Name)
            NotificationCenter.default.post(name: notificationName, object: nil, userInfo: [Constants.Notification.IdToken: decodedString])
            
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

