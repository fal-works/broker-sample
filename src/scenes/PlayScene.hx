package scenes;

import hxd.Res;
import broker.scene.SceneTypeId;
import broker.scene.Scene;
import broker.scene.SceneObject;
import broker.sound.*;

class PlayScene extends Scene {
	var world: World;
	var sounds: Sounds;
	var musicChannel: SoundChannel;
	var explosionSound: Sound;

	public function new(?heapsScene: h2d.Scene) {
		super(heapsScene);

		@:nullSafety(Off) {
			this.world = null;
			this.sounds = null;
			this.musicChannel = cast null;
		}
	}

	override public inline function getTypeId(): SceneTypeId
		return SceneType.play;

	override function initialize(): Void {
		super.initialize();

		this.world = new World(this.layers.main);

		this.musicChannel = Sounds.music.play().unwrap();

		this.layers.background.add(SceneObject.fromImage(Res.background));
	}

	override function update(): Void {
		super.update();
		this.world.update();

		final buttons = Global.gamepad.buttons;

		if (buttons.Y.isPressed) {
			this.goToNextScene();
			return;
		}

		if (buttons.B.isJustPressed)
			musicChannel.fadeOut(2.0);
	}

	override function activate(): Void {
		super.activate();
		Global.resetParticles(this.layers.main);
	}

	function goToNextScene(): Void {
		final nextScene = new PlayScene();
		Global.sceneTransitionTable.runTransition(this, nextScene);
	}
}
