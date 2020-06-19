package actor;

/**
	AoSoA of `NonPlayableActor`.
**/
@:build(banker.aosoa.Aosoa.fromChunk(actor.NonPlayableActor.NonPlayableActorChunk))
@:banker_verified
class NonPlayableActorAosoa implements ActorAosoa {}
