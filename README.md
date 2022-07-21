# RoninAI

While researhing the concept of GOAP and how to implement it I thought deeply about how I could built it utilizing RoninUtilities. I got the the point where I thought about adding aStar to the utilities and that almost became another project unto itself. How to make AStar Abstract and Generic enough to be reused for all sorts of "search problems". 

I like the concept of planning but see that at design time for actual use it creates a host of issues that require trial and testing to get right. How far to plan is simple for simple goals when working back from the current state, but reacting to unforeseen circumstances and when to abandon the plan requires a wonderful mind. 

Then I thought more about utilizing the concept of thinking and behaving and using thouhts to drive the behavior. Thoughts in this system can be thought of as the Desires, Needs, Mandates, Jobs or Responsibilities of the AI. RoninUtilities.Decider is perfect for this. Then I added the concept of Intent, this is the behavior and the 'urge' to continue this behavior when thoughts produce new Intentions. This value allows the designer to control what intentions outweight the current. Wrapped up in this concept is the idea of urge are 'intensification' and 'satiation' implying that the urge may grow as the intention is ignored and that the as some behavior is performed with a certain urge, as it is performed, the urge lessens and may cause the behavior to be superceeeded by a more intense Intention.

Behavior utilize basic behavior tree concepts and provides a Framework to be adopted by Subclassing and Composing these utilizing our CompositeBehavior. These behavior have built in state which allow them to run over multiple frames until abandoned, failure or success.

The MentalComponent is a GKComponent that is to be subclassed into a Mentality type. These mentalities may be swapped out if neccessary to give an entity a new "mindset". Another approach when using this component would be to assign them based on the class or type of entity. 

Enemy AI may have separate Guarding, Patroling and Engaging Mentalities that are swapped out based on some state of the entity. Or the EnemyMentalityComponent could simply decide what to do in response to the state of the entity or outside world. The latter is the prefered design but for complex scenarios the ability decompose these states of mind into their own decision making and behavior simplifies the system. Patrol movement may uitilize Walk and slower behavior, whilde Engage prefer running and faster actions.

This Library is geared towards GamplayKit and SceneKit so in real world applications we have DecisionTrees, FSMs, Strategists and the GKAgent (movement, obstacle avoidance and flocking behavior). My games generally utilize these underlying systems alongside the SCNScene and SCNPhysicsWorld simulation to provide feedback to the agents and their SCNNodes. Expect to see the AnimationSystemComponent there too which manages an AnimationStateMachine and and utilizes the EventService to switch states as event are broadcast from other parts of the simulation such as agent movement or behavior. 

Given the above context, this system of designing the AI works for me, but is not a formal approach such as GOAP or FSM, this is a Rigging. The goal of this rig is to allow agents to make decisions which turn into intentions which are formed from underlying behavior that is Acted out in the scene. I try to be declarative as posiblle in my own code so this system is simple enough to work but fuzzy enough to be interesting.
