# app2app VIDwallet integration

This repository contains a simple iOS application that shows an app2app integration with VIDwallet. The aim is to request the presentation of a credential of type "EmailCredential" and receive the information in the app for further purposes. In this demo, the app will simply show the payload received.

The process consists on two steps:

- Create an authentication request: the app uses VIDchain API to generate the signature of the request and then is provided to VIDwallet via deeplink.
- Receive an authentication response: the app receives a URL via deeplink with an id_token (JWT) that contains the `vp` (Verifiable Presentation) with the credential(s) requested.

The first step mainly happens at `ios/VIDchain-app2app/ViewController.swift` while the second at 
`ios/VIDchain-app2app/SceneDelegate.swift`.

Keep in mind that in this example:

- For the sake of simplicity, the authentication response is not validated.
- The credentialType requested in the example can be changed to any known type by the user.

# Prerequisites

Notice that this integration requires having an assertion, i.e. an apiKey to use VIDchain. If you do not own an apiKey for VIDchain, you can contact support@validated.org.
