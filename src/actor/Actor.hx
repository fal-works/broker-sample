package actor;

@:banker_verified
class Actor extends broker.entity.BasicBatchEntity {
	@:nullSafety(Off)
	@:banker_chunkLevelFinal
	var halfTileWidth: Float;

	@:nullSafety(Off)
	@:banker_chunkLevelFinal
	var halfTileHeight: Float;

	@:banker_factoryWithId((id: ChunkEntityId) -> new Collider(id.int()))
	@:banker_swap
	var collider: Collider;

	/**
		Clojure function for emitting a new bullet.
	**/
	@:banker_chunkLevelFinal
	var fire: FireCallback;

	/**
		Elapsed frame count of each entity.
	**/
	var frameCount: UInt = UInt.zero;

	/**
		`true` if the entity should be disused in the next call of `update()`.
		May be set in collision detection process.
	**/
	var dead: Bool = false;

	@:banker_useEntity
	static function emit(
		sprite: BatchSprite,
		x: WritableVector<Float>,
		y: WritableVector<Float>,
		vx: WritableVector<Float>,
		vy: WritableVector<Float>,
		frameCount: WritableVector<UInt>,
		dead: WritableVector<Bool>,
		i: Int,
		usedSprites: WritableVector<BatchSprite>,
		usedCount: Int,
		initialX: Float,
		initialY: Float,
		speed: Float,
		direction: Float
	): Void {
		x[i] = initialX;
		y[i] = initialY;
		vx[i] = speed * cos(direction);
		vy[i] = speed * sin(direction);
		frameCount[i] = UInt.zero;
		dead[i] = false;
		usedSprites[usedCount] = sprite;
		++usedCount;
	}

	/**
		Registers entities to `quadtree`.
		@param quadtree
	**/
	static function loadQuadTree(
		id: ChunkEntityId,
		x: Float,
		y: Float,
		collider: Collider,
		halfTileWidth: Float,
		halfTileHeight: Float,
		quadtree: Quadtree,
		i: UInt
	): Void {
		final left = x - halfTileWidth;
		final top = y - halfTileHeight;
		final right = x + halfTileWidth;
		final bottom = y + halfTileHeight;

		final cellIndex = Space.getCellIndex(left, top, right, bottom);
		if (cellIndex.isSome()) {
			collider.setBounds(left, top, right, bottom);
			quadtree.loadAt(cellIndex, collider);
		}
	}

	/**
		Set `found` to `true` if any entity overlaps `otherAabb`.
		@param otherAabb
		@param found
	**/
	static function findOverlapped(
		x: Float,
		y: Float,
		halfTileWidth: Float,
		halfTileHeight: Float,
		otherAabb: Aabb,
		found: Reference<Bool>
	): Void {
		if (otherAabb.overlapsAabb(
			x - halfTileWidth,
			y - halfTileHeight,
			x + halfTileWidth,
			y + halfTileHeight
		)) {
			found.set(true);
		}
	}

	/**
		Disuses all entities currently in use and emits particles.
	**/
	static function crashAll(
		x: Float,
		y: Float,
		sprite: BatchSprite,
		i: Int,
		disuse: Bool,
		disusedSprites: banker.vector.WritableVector<BatchSprite>,
		disusedCount: Int
	): Void {
		disuse = true;
		disusedSprites[disusedCount] = sprite;
		++disusedCount;
		Global.emitParticles(x, y, 1, 6, 6);
	}
}
