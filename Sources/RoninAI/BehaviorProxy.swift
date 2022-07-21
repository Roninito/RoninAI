//
//  File.swift
//  
//
//  Created by leerie simpson on 10/5/21.
//

import Foundation
import SwiftUI


/// An object providing a binding to the this behavior and bindings to several of its values, for use by BehaviorViews.
public class BehaviorProxy: ObservableObject {
	
	/// Allows placement options to be
	@Published public var showingPlacementOptions: Bool = false
	
	/// A binding to the behaviors name.
	public lazy var name = Binding.init(
		get: { self.behavior.name },
		set: { self.behavior.name = $0 }
	)
	
	/// A binding to the behavior's state.
	public lazy var state = Binding.init(
		get: { self.behavior.state.rawValue },
		set: { self.behavior.state = Behavior.BehaviorState(rawValue: $0)! }
	)
	
	/// A reference to the behavior that spawned it.
	@Published public var behavior: Behavior!
	
	
	public var viewPosition: CGPoint = .zero {
		didSet {
			print("BehaviorProxy: recieving viewPosition for behavior: \(behavior.id)")
		}
	}
	
	/// Creates a proxy for the given behavior, supplying bindings to common values.
	public init(behavior: Behavior) {
		self.behavior = behavior
	}
}
