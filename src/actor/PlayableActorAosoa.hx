package actor;

/**
	AoSoA of `PlayableActor`.
**/
@:build(banker.aosoa.Aosoa.fromChunk(actor.PlayableActor.PlayableActorChunk))
@:banker_verified
class PlayableActorAosoa implements ActorAosoa {}
