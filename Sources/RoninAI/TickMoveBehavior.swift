//
//  File.swift
//  
//
//  Created by leerie simpson on 10/23/21.
//

import Foundation
import SceneKit


/// Behavior to set the move goal when a move target has been set by the patrol intention.
/// Required Memory and TickMove Components.
//class TickMoveBehavior: Behavior {
//	
//	
//	override init() {
//		super.init(name: "MoveBehavior", category: .action)
//	}
//	
//	
//	public required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented")
//	}
//	
//	
//	override func behave() {
//		guard let memoryComponent = component.entity?.component(ofType: MemoryComponent.self) else { return }
//		guard let tickMoveComponent = component.entity?.component(ofType: TickMoveComponent.self) else { return }
//		guard let recalledMoveTarget = memoryComponent.memories.filter({ $0.id == "move-target" }).first else { return }
//		
//		let moveTargetPosition = recalledMoveTarget.info["finalDestination"] as! SCNVector3
//		tickMoveComponent.waypoints.removeAll()
//		tickMoveComponent.waypoints = [SIMD3(moveTargetPosition)]
//		
//	}
//}
