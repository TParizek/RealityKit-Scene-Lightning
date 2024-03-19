//
//  SphereConfiguration.swift
//  SceneLight
//
//  Created by Tomáš Pařízek on 19.03.2024.
//

import SwiftUI

struct SphereConfiguration: Equatable {
    var isCastingShadow = false
    var lightMode: LightMode = .none
    var materialType: MaterialType = .simple
    var color = Color.red
    var emissiveColor = Color.red
    var emissiveIntensity: Float = 0
    var roughness: Float = 0.5
    var metallic: Float = 0.5
    var anisotropy: Float = 0
    var clearcoatAmount: Float = 0
    var clearcoatRoughness: Float = 0
    var sheenColorIsEnabled = false
    var sheenColor = Color.red
}

extension SphereConfiguration {
    enum MaterialType: String, CaseIterable {
        case physicalBased
        case simple
        case unlit
    }

    enum LightMode: String, CaseIterable {
        case none
        case ambient
        case directional
        case mixed
    }
}

extension SphereConfiguration.MaterialType {
    var localizedTitle: String {
        switch self {
        case .physicalBased:
            return "Physical based"
        case .simple:
            return "Simple"
        case .unlit:
            return "Unlit"
        }
    }
}

extension SphereConfiguration.LightMode {
    var localizedTitle: String {
        switch self {
        case .none:
            return "None"
        case .ambient:
            return "Ambient"
        case .directional:
            return "Directional"
        case .mixed:
            return "Mixed"
        }
    }
}
