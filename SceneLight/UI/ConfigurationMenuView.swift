//
//  ConfigurationMenuView.swift
//  SceneLight
//
//  Created by Tomáš Pařízek on 13.03.2024.
//

import SwiftUI
import RealityKit

struct ConfigurationMenuView: View {

    @Environment(AppStore.self) private var store

    @Environment(\.scenePhase) private var scenePhase

    @Binding var configuration: SphereConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            if store.state.isShowingScenePreview {
                configureSceneView
            } else {
                showSceneView
            }
        }
        .padding(50)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                store.sendToMainActor(action: .configurationMenuDismissed)
            }
        }
    }
}

private extension ConfigurationMenuView {
    var showSceneView: some View {
        VStack {
            Spacer()
            
            showButton

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    @MainActor
    var configureSceneView: some View {
        VStack(alignment: .leading, spacing: 40) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Light")
                Picker("Light", selection: $configuration.lightMode) {
                    ForEach(SphereConfiguration.LightMode.allCases, id: \.self) {
                        Text($0.localizedTitle)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Toggle(isOn: $configuration.isCastingShadow) {
                Text("Cast shadow")
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Material")
                Picker("Material", selection: $configuration.materialType) {
                    ForEach(SphereConfiguration.MaterialType.allCases, id: \.self) {
                        Text($0.localizedTitle)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            ColorPicker("Color", selection: $configuration.color)

            if case .physicalBased = configuration.materialType {
                ColorPicker("Emissive color", selection: $configuration.emissiveColor)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Anisotropy")
                    Slider(value: $configuration.anisotropy, in: 0...1) {
                        Text("Anisotropy")
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Emissive intensity")
                    Slider(value: $configuration.emissiveIntensity, in: 0...1) {
                        Text("Emissive intensity")
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: $configuration.sheenColorIsEnabled) {
                        Text("Sheen color")
                    }
                    ColorPicker("", selection: $configuration.sheenColor)
                        .disabled(!configuration.sheenColorIsEnabled)
                        .opacity(configuration.sheenColorIsEnabled ? 1 : 0.5)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Clearcoat amount")
                    Slider(value: $configuration.clearcoatAmount, in: 0...1) {
                        Text("Clearcoat amount")
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Clearcoat roughness")
                    Slider(value: $configuration.clearcoatRoughness, in: 0...1) {
                        Text("Clearcoat roughness")
                    }
                }
            }

            if configuration.materialType != .unlit {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Metallic")
                    Slider(value: $configuration.metallic, in: 0...1) {
                        Text("Metallic")
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Roughness")
                    Slider(value: $configuration.roughness, in: 0...1) {
                        Text("Roughness")
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var showButton: some View {
        Button("Show preview") {
            withAnimation {
                store.sendToMainActor(action: .showScenePreviewTapped)
            }
        }
    }
}
