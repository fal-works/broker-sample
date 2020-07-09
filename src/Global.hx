import broker.input.physical.KeyCode;
import broker.input.physical.PadCode;
import broker.input.physical.PadMultitap;
import broker.geometry.MutablePoint;
import broker.math.Random;
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

	/**
		Refers to the particles of the current `World` instance.
	**/
	@:nullSafety(Off)
	public static var particles: ParticleAosoa;

	public static final sceneTransitionTable = new SceneTransitionTable();

	public static function initialize(): Void {
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
		broker.App.tick();
		SoundManager.update();

		gamepad.update();
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
}
