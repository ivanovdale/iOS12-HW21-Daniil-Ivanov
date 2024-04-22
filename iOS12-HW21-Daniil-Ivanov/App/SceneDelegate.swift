//
//  SceneDelegate.swift
//  iOS12-HW21-Daniil-Ivanov
//
//  Created by Daniil (work) on 17.04.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let client = HTTPClient()
        let magicCardsService = MagicCardsService(client: client)

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = MagicCardsViewController(magicCardsService: magicCardsService)
        window?.makeKeyAndVisible()
    }
}

