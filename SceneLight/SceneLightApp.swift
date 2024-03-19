//
//  SceneLightApp.swift
//  SceneLight
//
//  Created by Tomáš Pařízek on 13.03.2024.
//

import SwiftUI

@main
struct SceneLightApp: App {
    private static let scenePreviewImmersiveSpaceId = "scene-preview"

    @State private var store = AppStore()

    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var sphereConfiguration = SphereConfiguration()

    var body: some Scene {
        WindowGroup {
            ConfigurationMenuView(
                configuration: $sphereConfiguration
            )
            .environment(store)
        }
        .defaultSize(CGSize(width: 600, height: 1275))
        .onChange(of: store.state.isShowingScenePreview) { _, isShowingScenePreview in
            Task {
                if isShowingScenePreview {
                    await openImmersiveSpace(id: SceneLightApp.scenePreviewImmersiveSpaceId)
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }

        ImmersiveSpace(id: SceneLightApp.scenePreviewImmersiveSpaceId) {
            ScenePreview(
                configuration: $sphereConfiguration
            )
            .environment(store)
        }
    }
}
