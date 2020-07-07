import broker.input.physical.KeyCode;
import broker.input.physical.PadCode;
import broker.input.physical.PadMultitap;
import broker.geometry.MutablePoint;
import broker.math.Random;
import broker.scene.Layer;
import broker.scene.transition.SceneTransitionTable;
import broker.scene.transition.FadeSceneTransition;
import broker.sound.SoundManager;
import gamepad.GamepadBuilder;
import particle.ParticleAosoa;
import scenes.SceneType;

class Global {
	public static final defaultGamepadBuilder: GamepadBuilder = {
		keyCodeMap: [
			A => [KeyCode.Z],
			B => [KeyCode.X],
			X => [KeyCode.SHIFT],
			Y => [KeyCode.ESC],
			D_LEFT => [KeyCode.LEFT],
			D_UP => [KeyCode.UP],
			D_RIGHT => [KeyCode.RIGHT],
			D_DOWN => [KeyCode.DOWN]
		],
		padCodeMap: [
			A => [PadCode.A],
			B => [PadCode.B],
			X => [PadCode.X],
			Y => [PadCode.Y],
			D_LEFT => [PadCode.LEFT],
			D_UP => [PadCode.UP],
			D_RIGHT => [PadCode.RIGHT],
			D_DOWN => [PadCode.DOWN]
		],
		gamepadPort: PadMultitap.ports[0],
		analogStickThreshold: 0.1,
		speedChangeButton: X,
		defaultSpeed: 9,
		alternativeSpeed: 3
	};

	public static inline final width: UInt = 800;
	public static inline final height: UInt = 600;

	public static var gamepad(default, null) = defaultGamepadBuilder.build();

	public static final playerPosition = new MutablePoint();

	public static var particles(default, null): ParticleAosoa;

	public static final sceneTransitionTable = new SceneTransitionTable();

	public static function initialize(): Void {
		final dummyLayer = new Layer();
		resetParticles(dummyLayer, 1);

		sceneTransitionTable.add({
			precedingType: SceneType.All,
			succeedingType: SceneType.Play,
			transition: ({
				color: 0xFF000000,
				fadeOutDuration: 30,
				intervalDuration: 30,
				fadeInDuration: 30,
				destroy: true
			} : FadeSceneTransition)
		});

		sceneTransitionTable.add({
			precedingType: SceneType.Play,
			succeedingType: SceneType.All,
			transition: ({
				color: 0xFF000000,
				fadeOutDuration: 30,
				intervalDuration: 30,
				fadeInDuration: 30,
				destroy: true
			} : FadeSceneTransition)
		});
	}

	public static function update(): Void {
		broker.Global.tick();
		SoundManager.update();

		gamepad.update();

		particles.update();
		particles.synchronize();
	}

	public static function emitParticles(
		x: Float,
		y: Float,
		minSpeed: Float,
		maxSpeed: Float,
		count: UInt
	): Void {
		var i = UInt.zero;
		while (i < count) {
			particles.emit(x, y, Random.between(minSpeed, maxSpeed), Random.angle());
			++i;
		}
	}

	public static function resetParticles(
		parentLayer: Layer,
		maxEntityCount: UInt = 1024
	): Void {
		final chunkCapacity: UInt = 128;
		final chunkCount: UInt = Math.ceil(maxEntityCount / chunkCapacity);

		final tile = h2d.Tile.fromColor(0xFFFFFF, 12, 12).center();
		final batch = new h2d.SpriteBatch(tile, parentLayer);
		batch.hasRotationScale = true;
		final spriteFactory = () -> new h2d.SpriteBatch.BatchElement(tile);
		particles = new ParticleAosoa(
			chunkCapacity,
			chunkCount,
			batch,
			spriteFactory
		);
	}
}

class HabitableZone {
	static extern inline final margin: Float = 64;
	public static extern inline final leftX: Float = 0 - margin;
	public static extern inline final topY: Float = 0 - margin;
	public static extern inline final rightX: Float = 800 + margin;
	public static extern inline final bottomY: Float = 600 + margin;

	public static extern inline function containsPoint(x: Float, y: Float): Bool
		return y < bottomY && topY <= y && leftX <= x && x < rightX;
}
