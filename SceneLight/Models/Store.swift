//
//  Store.swift
//  SceneLight
//
//  Created by Tomáš Pařízek on 14.03.2024.
//

import Foundation

protocol Store {
    associatedtype State: StoreState
    associatedtype Action

    @MainActor var state: State { get }

    @MainActor func send(action: Action)
}

extension Store {
    func sendToMainActor(action: Action) {
        Task {
            await send(action: action)
        }
    }
}

protocol StoreState {}

extension StoreState {
    func updating<Value>(_ keyPath: WritableKeyPath<Self, Value>, with value: Value) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}
