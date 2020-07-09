import actor.Army.PlayableArmy;
import banker.vector.Vector;
import banker.types.Reference;
import broker.App;
import broker.object.Object;
import broker.geometry.MutableAabb;
import broker.collision.*;
import broker.image.Tile;
import broker.draw.DrawArea;
import broker.draw.TileDraw;
import broker.draw.BatchDraw;
import broker.draw.BatchSprite;
import actor.*;
import particle.ParticleAosoa;

class World {
	public static inline final worldWidth: UInt = 720;
	public static inline final worldHeight: UInt = 560;
	static inline final maxPlayerAgentCount: UInt = 1;
	static inline final maxPlayerBulletCount: UInt = 256;
	static inline final maxEnemyAgentCount: UInt = 64;
	static inline final maxEnemyBulletCount: UInt = 1024;
	static inline final playerAgentHalfCollisionSize = 16.0;

	/**
		The layer that contains all drawable objects in `this` world.
	**/
	public final area: DrawArea;

	final particles: ParticleAosoa;

	final playerArmy: PlayableArmy;
	final enemyArmy: Army;
	final offenceCollisionDetector: CollisionDetector;
	final offenceCollisionHandler: Collider->Collider->Void;

	final playerAabb: MutableAabb = new MutableAabb();
	final foundDefenceCollision: Reference<Bool> = false;

	public function new() {
		final area = this.area = new DrawArea(worldWidth, worldHeight);

		final backgroundTile = Tile.fromArgb(0x80000000, area.width, area.height);
		final background = new TileDraw(backgroundTile);
		area.add(background);

		final armies = new Object();
		area.add(armies);

		final filter = new h2d.filter.Glow(0xFFFFFF, 0.7, 100, 1, 1, true);
		armies.setFilter(filter);

		particles = Global.particles = WorldBuilder.createParticles(area);
		playerArmy = WorldBuilder.createPlayerArmy(armies);
		enemyArmy = WorldBuilder.createEnemyArmy(armies);

		offenceCollisionDetector = CollisionDetector.createInterGroup(
			Space.partitionLevel,
			{
				left: {
					maxColliderCount: maxPlayerBulletCount,
					quadtree: playerArmy.bulletQuadtree
				},
				right: {
					maxColliderCount: maxEnemyAgentCount,
					quadtree: enemyArmy.agentQuadtree
				}
			}
		);
		offenceCollisionHandler = (playerBulletCollider, enemyAgentCollider) -> {
			playerArmy.onHitBullet(playerBulletCollider);
			enemyArmy.onHitAgent(enemyAgentCollider);
		};

		playerArmy.newAgent(0.5 * Global.width, 0.75 * Global.height, 0, 0);
	}

	public function update(): Void {
		particles.update();
		particles.synchronize();

		playerArmy.update();
		enemyArmy.update();

		if (Math.random() < 0.03) newEnemy();

		playerArmy.synchronize();
		enemyArmy.synchronize();

		playerArmy.reloadQuadtrees();
		enemyArmy.reloadQuadtrees();

		offenceCollisionDetector.detect(offenceCollisionHandler);

		if (playerHasCollided()) {
			enemyArmy.bullets.crashAll();
			enemyArmy.bullets.synchronize();
			playerArmy.playerAosoa.damage();
			Sounds.explosion.play();
		}
	}

	public function dispose(): Void {
		Global.particles = null;
	}

	function newEnemy(): Void {
		enemyArmy.newAgent(
			(0.1 + 0.8 * Math.random()) * Global.width,
			-32,
			1 + Math.random() * 1,
			0.5 * Math.PI
		);
	}

	function updatePlayerAabb(): Void {
		final playerPosition = Global.playerPosition;
		playerArmy.playerAosoa.assignPosition(playerPosition);
		final playerX = playerPosition.x();
		final playerY = playerPosition.y();

		final halfSize = playerAgentHalfCollisionSize;
		playerAabb.set(
			playerX - halfSize,
			playerY - halfSize,
			playerX + halfSize,
			playerY + halfSize
		);
	}

	function playerHasCollided(): Bool {
		updatePlayerAabb();

		foundDefenceCollision.set(false);
		enemyArmy.bullets.findOverlapped(playerAabb, foundDefenceCollision);

		return foundDefenceCollision.get();
	}
}

/**
	Functions internally used in `World.new()`.
**/
@:access(World)
private class WorldBuilder {
	public static function createParticles(
		parent: Object,
		maxEntityCount: UInt = 1024
	): ParticleAosoa {
		final chunkCapacity: UInt = 128;
		final chunkCount: UInt = Math.ceil(maxEntityCount / chunkCapacity);

		final tile = Tile.fromRgb(0xFFFFFF, 12, 12).toCentered();
		final batch = new BatchDraw(tile.getTexture(), App.width, App.height);
		parent.addChild(batch);
		final spriteFactory = () -> new BatchSprite(tile);

		return new ParticleAosoa(chunkCapacity, chunkCount, batch, spriteFactory);
	}

	public static function createPlayerArmy(parent: Object) {
		final agentTile = Tile.fromRgb(0xE0FFE0, 48, 48).toCentered();
		final agentBatch = new BatchDraw(
			agentTile.getTexture(),
			App.width,
			App.height,
			false
		);
		parent.addChild(agentBatch);

		final bulletTile = Tile.fromRgb(0xE0FFE0, 16, 16).toCentered();
		final bulletBatch = new BatchDraw(
			bulletTile.getTexture(),
			App.width,
			App.height,
			false
		);
		parent.addChild(bulletBatch);

		final bullets = ArmyBuilder.createNonPlayableActors(
			World.maxPlayerBulletCount,
			bulletBatch,
			Vector.fromArrayCopy([bulletTile])
		);
		final onHitBullet = ArmyBuilder.createOnHitNonPlayable(bullets);

		final agents = ArmyBuilder.createPlayableActors(
			agentBatch,
			agentTile,
			bullets
		);
		final onHitAgent = ArmyBuilder.createOnHitPlayable(agents);

		return new Army.PlayableArmy(agents, onHitAgent, bullets, onHitBullet);
	}

	public static function createEnemyArmy(parent: Object) {
		final atlas = broker.image.Atlas.from(Vertical([
			Unit(hxd.Res.enemy_72px), // enemy
			Unit(hxd.Res.enemy_bullet_24px) // enemy_bullet
		]));
		final texture = atlas.texture;

		final agentTiles = atlas.get("enemy").toVector();
		final agentBatch = new BatchDraw(texture, App.width, App.height);
		parent.addChild(agentBatch);

		final bulletTiles = atlas.get("enemy_bullet").toVector();
		final bulletBatch = new BatchDraw(texture, App.width, App.height);
		parent.addChild(bulletBatch);

		final bullets = ArmyBuilder.createNonPlayableActors(
			World.maxEnemyBulletCount,
			bulletBatch,
			bulletTiles
		);
		final onHitBullet = ArmyBuilder.createOnHitNonPlayable(bullets);

		final agents = ArmyBuilder.createNonPlayableActors(
			World.maxEnemyAgentCount,
			agentBatch,
			agentTiles,
			bullets
		);
		final onHitAgent = ArmyBuilder.createOnHitNonPlayable(
			agents,
			Sounds.explosion
		);

		return new Army.NonPlayableArmy(agents, onHitAgent, bullets, onHitBullet);
	}
}

class HabitableZone {
	static extern inline final margin: Float = 64;
	public static extern inline final leftX: Float = 0 - margin;
	public static extern inline final topY: Float = 0 - margin;
	public static extern inline final rightX: Float = World.worldWidth + margin;
	public static extern inline final bottomY: Float = World.worldHeight + margin;

	public static extern inline function containsPoint(x: Float, y: Float): Bool
		return y < bottomY && topY <= y && leftX <= x && x < rightX;
}
