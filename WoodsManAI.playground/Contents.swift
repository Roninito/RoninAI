import Cocoa
import GameplayKit
import RoninAI
import RoninUtilities


extension Behavior {
	func mind(_ entity: GKEntity) -> MentalComponent {
		entity.component(ofType: BobsMentalComponent.self)!
	}
}

enum Locations: String {
	case Home, Shop, Woodlands
}

class EatFood: Behavior {
	override func behave(entity: GKEntity?) {
		var health = entity!.component(ofType: BobsMentalComponent.self)!.state["health"] as! Int
		health += 100
		entity!.component(ofType: BobsMentalComponent.self)!.state["health"] = health
		print("\(entity!.description) Eating food, health: \(health)")
		state = .success
	}
}

class ChopWood: Behavior {
	override func behave(entity: GKEntity?) {
		var wood = entity!.component(ofType: BobsMentalComponent.self)!.state["wood"] as! Int
		wood += 1
		entity!.component(ofType: BobsMentalComponent.self)!.state["wood"] = wood
		
		var health = entity!.component(ofType: BobsMentalComponent.self)!.state["health"] as! Int
		health -= 1
		entity!.component(ofType: BobsMentalComponent.self)!.state["health"] = health
		state = .success
		print("\(entity!.description) Choping Wood, current wood: \(wood)")
	}
}

class SellWood: Behavior {
	override func behave(entity: GKEntity?) {
		if mind(entity!).state["location"] as! String != Locations.Shop.rawValue {
			print("\(entity!.description) Cannot sell wood at \(mind(entity!).state["location"] as! String)")
		}
		else {
			let wood = mind(entity!).state["wood"] as! Int
			let coins = mind(entity!).state["coins"] as! Int
			mind(entity!).state["wood"] = 0
			mind(entity!).state["coins"] = coins + wood
			print("\(entity!.description) Selling \(wood) wood. coins: \(coins + wood)")
		}
	}
}

class Move: Behavior {
	var locationName: String
	
	init(to: String) {
		locationName = to
		super.init(name: "Move to \(to)", category: .action)
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func behave(entity: GKEntity?) {
		if mind(entity!).state["location"] as! String != locationName {
			mind(entity!).state["location"] = locationName
			print("\(entity!.description) Moving to \(locationName)")
		}
		state = .success
	}
}


let moveEat = Sequence()
moveEat.add(behavior: Move(to: Locations.Home.rawValue))
moveEat.add(behavior: EatFood())

let moveChop = Sequence()
moveChop.add(behavior: Move(to: Locations.Woodlands.rawValue))
moveChop.add(behavior: ChopWood())

let moveSell = Sequence()
moveSell.add(behavior: Move(to: Locations.Shop.rawValue))
moveSell.add(behavior: SellWood())


//: Notice here we doon't actually use the mental comp directly, instead we suubclass it providing an init that passeess in the entity..
class BobsMentalComponent: MentalComponent {
	init(woodsman: GKEntity) {
		super.init(decider:
					Decider([
						WeightedDecision("hungry?", weight:  {
							if (woodsman.component(ofType: BobsMentalComponent.self)!.state["health"] as! Int) < 10 { return 100 }
							return 0
						}, {
							return Intention(
								id: "Eat Food",
								intensity: 2,
								intensification: 0,
								satiation: 0,
								behavior: moveEat
							)}),
						WeightedDecision("chopWood?", weight: {
							if (woodsman.component(ofType: BobsMentalComponent.self)!.state["wood"] as! Int) < 99 {
								return  1
							}
							else {
								return 0
							}
						}, {
							return Intention(
								id: "ChopWood",
								intensity: 1,
								intensification: 0,
								satiation: 0,
								behavior: moveChop
							)}),
						WeightedDecision("sellWood", weight: {
							if woodsman.component(ofType: BobsMentalComponent.self)!.state["wood"] as! Int > 20 + GKRandomDistribution(forDieWithSideCount: 90).nextInt() {
								return 20
							}
							return 0
						}, {
							return Intention(
								id: "Sell Wood",
								intensity: 2,
								intensification: 0,
								satiation: 0,
								behavior: moveSell)
						})
					]), thinkRate: 0, behaveRate: 0)
		
		state = ["health": 2, "wood": 0, "location": "Home", "coins": 0]
	}
	
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

func createWoodsman() -> GKEntity {
	let woodsman = GKEntity()
	let mentalComponent = BobsMentalComponent(woodsman: woodsman)
	woodsman.addComponent(mentalComponent)
	return woodsman
}

let woodswoman = createWoodsman()
let woodsman = createWoodsman()


for i in 0..<1000 {
	woodsman.update(deltaTime:TimeInterval(i))
	woodswoman.update(deltaTime: TimeInterval(i))
}


print(woodsman.component(ofType: BobsMentalComponent.self)!.state)
print(woodswoman.component(ofType: BobsMentalComponent.self)!.state)
