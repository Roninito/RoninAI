//
//  Desire.swift
//  DesireAI
//
//  Created by leerie simpson on 7/17/22.
//

import Foundation
import RoninUtilities
import GameplayKit

/// Consider this the mentality of the entity it inhabits.
open class MentalComponent: GKComponent {
	
	// returns an intent fro
	var decider: Decider
	public var state: [String: Any]
	var intent: Intention?
	
	var thinkInterval: TimeInterval
	var behaveInterval: TimeInterval
	var lastThinkTime: TimeInterval = 0
	var lastBehaveTime: TimeInterval = 0
	var isUsingTimedThoughtsAndBehavior = false
	
	public init(decider: Decider, state: [String : Any] = [:], thinkRate: TimeInterval = 1, behaveRate: TimeInterval = 1) {
		self.decider = decider
		self.state = state
		thinkInterval = thinkRate
		behaveInterval = behaveRate
		super.init()
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func think() {
		intent = decider.decide() as? Intention
	}
	
	public override func update(deltaTime seconds: TimeInterval) {
		super.update(deltaTime: seconds)
		if isUsingTimedThoughtsAndBehavior {
			if seconds - lastThinkTime  >= thinkInterval {
				think()
				lastThinkTime = Date.now.timeIntervalSinceReferenceDate
			}
			if seconds - lastBehaveTime >= behaveInterval {
				intent?.behavior.behave(entity: entity)
				lastBehaveTime =  Date.now.timeIntervalSinceReferenceDate
			}
		}
		else {
			think()
			intent?.behavior.behave(entity: entity)
		}
	}
}



