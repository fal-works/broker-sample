package actor;

import broker.sound.Sound;

/**
	Functions internally used in `Army.new()`.
**/
class ArmyBuilder {
	static var defaultChunkCapacity: UInt = 64;

	public static function createPlayableActors(
		batch: BatchDraw,
		defaultTile: Tile,
		bullets: ActorAosoa
	): PlayableActorAosoa {
		final spriteFactory = () -> new BatchSprite(defaultTile);
		final fireCallback = (
			x,
			y,
			speed,
			direction
		) -> {
			bullets.emit(x, y, speed, direction);
			Sounds.lazer.play();
		};
		return new PlayableActorAosoa(
			1,
			1,
			batch,
			spriteFactory,
			defaultTile.width / 2,
			defaultTile.height / 2,
			fireCallback
		);
	}

	public static function createOnHitPlayable(aosoa: PlayableActorAosoa) {
		return (collider: Collider) -> {
			final id = ChunkEntityId.fromInt(collider.id);
			final chunk = aosoa.getChunk(id);
			final index = chunk.getReadIndex(id);
			chunk.damageEffectCoolTime[index] = 60;
		};
	}

	public static function createNonPlayableActors(
		maxEntityCount: UInt,
		batch: BatchDraw,
		tiles: Vector<Tile>,
		?bullets: ActorAosoa
	): NonPlayableActorAosoa {
		final chunkCapacity = UInts.min(defaultChunkCapacity, maxEntityCount);
		final chunkCount = Math.ceil(maxEntityCount / chunkCapacity);

		var aosoa: NonPlayableActorAosoa;

		final defaultTile = tiles[0];
		final spriteFactory = () -> new BatchSprite(defaultTile);

		final fireCallback = if (bullets != null) {
			function(x, y, speed, direction) bullets.emit(x, y, speed, direction);
		} else {
			function(x, y, speed, direction) aosoa.emit(x, y, speed, direction);
		};

		aosoa = new NonPlayableActorAosoa(
			chunkCapacity,
			chunkCount,
			batch,
			spriteFactory,
			defaultTile.width / 2,
			defaultTile.height / 2,
			fireCallback,
			tiles,
			8
		);
		return aosoa;
	}

	public static function createOnHitNonPlayable(
		aosoa: NonPlayableActorAosoa,
		?sound: Sound
	) {
		return (collider: Collider) -> {
			final id = ChunkEntityId.fromInt(collider.id);
			final chunk = aosoa.getChunk(id);
			final index = chunk.getWriteIndex(id);
			final deadBuffer = chunk.deadBuffer;

			if (sound != null && !deadBuffer[index]) sound.play();
			deadBuffer[index] = true;
		};
	}
}
