//
//  File.swift
//  
//
//  Created by leerie simpson on 10/5/21.
//

import Foundation
import SwiftUI


public struct BehaviorDropDelegate: DropDelegate {
	
	public enum PlacementOptions { case asParent, asYoungerSibling, asOlderSibling, asFirstChild, asLastChild, asDecorator }

	
	// utility class to allow the delegate to load and cache behavior objects on drop.
	public class BehaviorContainer {
		public var behavior: Behavior?
	}
	
	
	public var droppedBehaviorContainer = BehaviorContainer()
	private weak var behavior: Behavior!
	
	
	public init(behavior: Behavior) {
		self.behavior = behavior
	}
	
	
	public func performDrop(info: DropInfo) -> Bool {
		if let behaviorItemProvider =  info.itemProviders(for: [Behavior.uTType]).first {
			behaviorItemProvider.loadItem(forTypeIdentifier: Behavior.uTType.identifier, options: nil) { droppedObject, error in
				if error != nil {
					print("BehaviorDropDelegate: Error received while performing drop operation with behavior type.")
				}
				else {
					DispatchQueue.main.async {
						// show placement options and store the dropped behavior
						self.behavior.proxy.showingPlacementOptions = true
						
						if BehaviorBuilder.lastBuiltBehavior?.parent != nil {
							if let behaviorIndex = BehaviorBuilder.lastBuiltBehavior!.parent?.children?.firstIndex(of: BehaviorBuilder.lastBuiltBehavior!) {
								BehaviorBuilder.lastBuiltBehavior!.parent?.children?.remove(at: behaviorIndex)
								BehaviorBuilder.lastBuiltBehavior?.parent?.objectWillChange.send()
							}
						}
						
						// cache the behavior in the drop container for use after the user selects a placement option.
						if let behavior = BehaviorBuilder.lastBuiltBehavior {
							self.droppedBehaviorContainer.behavior = behavior
							BehaviorBuilder.lastBuiltBehavior = nil
						}
					}
				}
			}
			return true
		}
		return false
	}
	
	
	func addAsParent() {
		let droppedBehavior = behavior.dropDelegate.droppedBehaviorContainer.behavior!
		let oldParent = behavior.parent

		// remove behavior from it's parent
		behavior.parent?.children?.removeAll(where: { $0 == behavior })
		// add it to the new parent
		droppedBehavior.children?.insert(behavior, at: 0)
		// add the new parent to the old parent.
		
		// root parents cannot
		if let nonRootParent = oldParent, oldParent?.parent != nil {
			nonRootParent.children?.insert(droppedBehavior, at: 0)
		}
		//
		oldParent?.children?.insert(droppedBehavior, at: 0)
	}
	
	
	/// Placed in front of
	func addAsOlderSibling() {
		behavior.add(AsOlderSibling: droppedBehaviorContainer.behavior!)
	}
	
	
	/// Placed in front of
	func addAsYoungerSibling() {
		behavior.add(asYoungerSibling: droppedBehaviorContainer.behavior!)
	}
	
	
	// fix move these methods to behavior

	func addAsFirstChild() {
		behavior.add(asFirstChild: droppedBehaviorContainer.behavior!)
	}
	
	
	func addAsLastChild() {
		behavior.add(asLastChild: droppedBehaviorContainer.behavior!)
	}
	
	
	func addAsDecorator() {
		behavior.add(asDecorator: droppedBehaviorContainer.behavior!)
	}
}
