import actor.Army.PlayableArmy;
import banker.vector.Vector;
import banker.types.Reference;
import broker.geometry.MutableAabb;
import broker.collision.*;
import broker.scene.Layer;
import actor.*;

class World {
	static inline final maxPlayerAgentCount: UInt = 1;
	static inline final maxPlayerBulletCount: UInt = 256;
	static inline final maxEnemyAgentCount: UInt = 64;
	static inline final maxEnemyBulletCount: UInt = 1024;
	static inline final playerAgentHalfCollisionSize = 16.0;

	/**
		The layer that contains all drawable objects in `this` world.
	**/
	public final layer: Layer;

	final playerArmy: PlayableArmy;
	final enemyArmy: Army;
	final offenceCollisionDetector: CollisionDetector;
	final offenceCollisionHandler: Collider->Collider->Void;

	final playerAabb: MutableAabb = new MutableAabb();
	final foundDefenceCollision: Reference<Bool> = false;

	public function new(parentLayer: Layer) {
		this.layer = new Layer();
		parentLayer.add(this.layer);

		final filter = new h2d.filter.Glow(0xFFFFFF, 0.7, 100, 1, 1, true);
		this.layer.setFilter(filter);

		playerArmy = WorldBuilder.createPlayerArmy(this.layer);
		enemyArmy = WorldBuilder.createEnemyArmy(this.layer);

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
		playerAabb.set(playerPosition.x()
			- playerAgentHalfCollisionSize,
			playerPosition.y()
			- playerAgentHalfCollisionSize,
			playerPosition.x()
			+ playerAgentHalfCollisionSize,
			playerPosition.y()
			+ playerAgentHalfCollisionSize);
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
	public static function createPlayerArmy(layer: Layer) {
		final agentTile = h2d.Tile.fromColor(0xE0FFE0, 48, 48).center();
		final agentBatch = new h2d.SpriteBatch(agentTile, layer);

		final bulletTile = h2d.Tile.fromColor(0xE0FFE0, 16, 16).center();
		final bulletBatch = new h2d.SpriteBatch(bulletTile, layer);

		final bullets = ArmyBuilder.createNonPlayableActors(
			World.maxPlayerBulletCount,
			bulletBatch,
			Vector.fromArrayCopy([bulletTile])
		);
		final onHitBullet = ArmyBuilder.createOnHitNonPlayable(bullets);

		final agents = ArmyBuilder.createPlayableActors(agentBatch, bullets);
		final onHitAgent = ArmyBuilder.createOnHitPlayable(agents);

		return new Army.PlayableArmy(agents, onHitAgent, bullets, onHitBullet);
	}

	public static function createEnemyArmy(layer: Layer) {
		final agentTiles = broker.image.FrameTiles.fromImage(hxd.Res.enemy_72px).frames;
		final agentBatch = new h2d.SpriteBatch(agentTiles[0], layer);
		agentBatch.hasRotationScale = true;

		final bulletTile = h2d.Tile.fromColor(0xD0D0FF, 16, 16).center();
		final bulletBatch = new h2d.SpriteBatch(bulletTile, layer);
		bulletBatch.hasRotationScale = true;

		final bullets = ArmyBuilder.createNonPlayableActors(
			World.maxEnemyBulletCount,
			bulletBatch,
			Vector.fromArrayCopy([bulletTile])
		);
		final onHitBullet = ArmyBuilder.createOnHitNonPlayable(bullets);

		final agents = ArmyBuilder.createNonPlayableActors(
			World.maxEnemyAgentCount,
			agentBatch,
			agentTiles,
			bullets
		);
		final onHitAgent = ArmyBuilder.createOnHitNonPlayable(agents, Sounds.explosion);

		return new Army.NonPlayableArmy(agents, onHitAgent, bullets, onHitBullet);
	}
}
