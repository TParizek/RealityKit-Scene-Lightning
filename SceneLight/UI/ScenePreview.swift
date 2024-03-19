//
//  ScenePreview.swift
//  SceneLight
//
//  Created by Tomáš Pařízek on 13.03.2024.
//

import SwiftUI
import RealityKit

struct ScenePreview: View {

    @Environment(AppStore.self) private var store

    @Environment(\.scenePhase) private var scenePhase

    @Binding var configuration: SphereConfiguration

    private let entity = ModelEntity(
        mesh: .generateSphere(radius: 0.5),
        materials: [
            UnlitMaterial(color: .red)
        ],
        collisionShapes: [
            .generateSphere(radius: 0.5),
        ],
        mass: 0
    )

    var body: some View {
        RealityView { content in
            entity.position.y = 1
            entity.position.z = -3

            var component = GestureComponent()
            component.canDrag = true
            component.canScale = true
            component.canRotate = true
            entity.components.set(component)
            entity.generateCollisionShapes(recursive: true)
            entity.components.set(InputTargetComponent())

            content.add(entity)

            applySphereMaterialConfiguration(configuration)
        }
        .installGestures()
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                store.sendToMainActor(action: .scenePreviewDismissed)
            }
        }
        .onChange(of: configuration.isCastingShadow) { _, isCastingShadow in
            if isCastingShadow {
                entity.components.set(GroundingShadowComponent(castsShadow: true))
            } else {
                entity.components.remove(GroundingShadowComponent.self)
            }
        }
        .onChange(of: configuration.lightMode) { _, lightMode in
            entity.components.remove(ImageBasedLightComponent.self)
            entity.components.remove(ImageBasedLightReceiverComponent.self)

            guard lightMode != .none
            else { return }

            Task {
                let ambientEnvironmentResource = try await EnvironmentResource(named: "Ambient")
                let directionalEnvironmentResource = try await EnvironmentResource(named: "Directional")

                let lightComponent = switch lightMode {
                case .none:
                    fatalError("Invalid light mode")
                case .ambient:
                    ImageBasedLightComponent(
                        source: .single(ambientEnvironmentResource),
                        intensityExponent: 1
                    )
                case .directional:
                    ImageBasedLightComponent(
                        source: .single(directionalEnvironmentResource),
                        intensityExponent: 1
                    )
                case .mixed:
                    ImageBasedLightComponent(
                        source: .blend(directionalEnvironmentResource, ambientEnvironmentResource, 0.5),
                        intensityExponent: 1
                    )
                }
                entity.components[ImageBasedLightComponent.self] = lightComponent
                entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
            }
        }
        .onChange(of: configuration) { _, configuration in
            applySphereMaterialConfiguration(configuration)
        }
    }
}

private extension ScenePreview {
    func applySphereMaterialConfiguration(_ configuration: SphereConfiguration) {
        switch configuration.materialType {
        case .unlit:
            let material = UnlitMaterial(color: UIColor(configuration.color))
            entity.model?.materials = [material]

        case .simple:
            var material = SimpleMaterial(
                color: UIColor(configuration.color),
                roughness: .float(configuration.roughness),
                isMetallic: configuration.metallic > 0
            )
            material.metallic = .float(configuration.metallic)
            entity.model?.materials = [material]

        case .physicalBased:
            var material =  PhysicallyBasedMaterial()

            material.baseColor = .init(tint: UIColor(configuration.color))
            material.emissiveColor = .init(color: UIColor(configuration.emissiveColor))
            material.emissiveIntensity = configuration.emissiveIntensity
            material.roughness = .init(floatLiteral: configuration.roughness)
            material.metallic = .init(floatLiteral: configuration.metallic)
            material.anisotropyLevel = .init(floatLiteral: configuration.anisotropy)
            material.clearcoat = .init(floatLiteral: configuration.clearcoatAmount)
            material.clearcoatRoughness = .init(floatLiteral: configuration.clearcoatRoughness)

            if configuration.sheenColorIsEnabled {
                material.sheen = .init(tint: UIColor(configuration.sheenColor))
            } else {
                material.sheen = nil
            }

            entity.model?.materials = [material]
        }
    }
}
