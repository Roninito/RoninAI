//
//  File.swift
//  
//
//  Created by leerie simpson on 10/5/21.
//

import Foundation
import SwiftUI


struct BehaviorBuilder: Identifiable {
	public static var lastBuiltBehavior: Behavior?
	
	let id = UUID().uuidString
	var behaviorName: String
	var behaviorDescription: String
	var build: () -> Behavior
	
	// A list of behavior builders that are can build behavior.
		static var builders: [BehaviorBuilder] = [
			BehaviorBuilder(behaviorName: "Log", behaviorDescription: "Print to output", build: { Logging("Output") }),
			BehaviorBuilder(behaviorName: "Sequence", behaviorDescription: "", build: { Sequence() }),
			BehaviorBuilder(behaviorName: "Parallel", behaviorDescription: "", build: { Parallel() }),
			BehaviorBuilder(behaviorName: "Selector", behaviorDescription: "", build: { Selector() })
		]
}
