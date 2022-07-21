//
//  Intention.swift
//  DesireAI
//
//  Created by leerie simpson on 7/19/22.
//

import Foundation
import GameplayKit


/// The behavior and urge to continue this behavior.
public struct Intention {
	public var id: String
	public var intensity: Int = 1
	public var intensification: Int = 0
	public var satiation: Int = 0
	public var behavior: Behavior
	
	public init(id: String, intensity: Int, intensification: Int, satiation: Int, behavior: Behavior) {
		self.id = id
		self.intensity = intensity
		self.intensification = intensification
		self.satiation = satiation
		self.behavior = behavior
	}
	
	mutating func intensify() {
		intensity += intensification
	}
	
	mutating func satisfy() {
		intensity -= satiation
	}
	
	mutating func act(on entity: GKEntity) {
		behavior.behave(entity: entity)
		satisfy()
	}
}
