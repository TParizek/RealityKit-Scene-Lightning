//
//  AppStore.swift
//  SceneLight
//
//  Created by Tomáš Pařízek on 14.03.2024.
//

import Combine
import Foundation
import SwiftUI
import RealityKit

@Observable
final class AppStore: Store {
    var state = State()

    func send(action: Action) {
        switch action {
        case .showScenePreviewTapped:
            state = state.updating(\.isShowingScenePreview, with: true)

        case .scenePreviewDismissed:
            state = state.updating(\.isShowingScenePreview, with: false)

        case .configurationMenuDismissed:
            state = state.updating(\.isShowingScenePreview, with: false)
        }
    }
}
