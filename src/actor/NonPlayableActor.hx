package actor;

@:banker_verified
class NonPlayableActor extends Actor {
	@:banker_chunkLevelFinal
	var rotationVelocity: Float = 0.03;

	@:nullSafety(Off)
	@:banker_chunkLevelFinal
	var tiles: Vector<Tile>;

	@:banker_chunkLevelFinal
	var animationIntervalFrames: UInt;

	static function update(
		sprite: BatchSprite,
		x: WritableVector<Float>,
		y: WritableVector<Float>,
		vx: Float,
		vy: Float,
		frameCount: WritableVector<UInt>,
		i: Int,
		disuse: Bool,
		disusedSprites: WritableVector<BatchSprite>,
		disusedCount: Int,
		dead: WritableVector<Bool>,
		rotationVelocity: Float,
		tiles: Vector<Tile>,
		animationIntervalFrames: UInt
	): Void {
		final currentX = x[i];
		final currentY = y[i];

		if (dead[i] || !HabitableZone.containsPoint(currentX, currentY)) {
			disuse = true;
			disusedSprites[disusedCount] = sprite;
			++disusedCount;
			if (dead[i]) Global.emitParticles(currentX, currentY, 2, 16, 32);
		} else {
			x[i] = currentX + vx;
			y[i] = currentY + vy;
		}

		sprite.rotation += rotationVelocity;
		sprite.tile = tiles.ref[
			UInts.divide(frameCount[i], animationIntervalFrames) % tiles.length
		];
		++frameCount[i];
	}

	static function mayFire(
		x: Float,
		y: Float,
		fire: FireCallback
	): Void {
		if (y < 240 && Random.bool(0.01)) {
			final playerPosition = Global.playerPosition;
			fire(
				x,
				y,
				4,
				Math.atan2(playerPosition.y() - y, playerPosition.x() - x)
			);
		}
	}
}

@:build(banker.aosoa.Chunk.fromStructure(actor.NonPlayableActor))
@:banker_verified
class NonPlayableActorChunk {}
