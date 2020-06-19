package scenes;

import hxd.Res;
import broker.scene.SceneTypeId;
import broker.scene.heaps.Scene;
import broker.sound.*;

class PlayScene extends Scene {
	var world: World;
	var music: Sound;
	var musicChannel: SoundChannel;

	public function new(?heapsScene: h2d.Scene) {
		super(if (heapsScene != null) heapsScene else new h2d.Scene());

		@:nullSafety(Off) {
			this.world = null;
			this.music = null;
			this.musicChannel = cast null;
		}
	}

	override public inline function getTypeId(): SceneTypeId
		return SceneType.play;

	override function initialize(): Void {
		super.initialize();

		this.world = new World(this.mainLayer);

		this.music = {
			data: Res.music_466998,
			isLooped: true,
			preventsLayered: true
		};
		this.musicChannel = music.play().unwrap();
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
		Global.resetParticles(this.mainLayer);
	}

	function goToNextScene(): Void {
		final nextScene = new PlayScene();
		Global.sceneTransitionTable.runTransition(this, nextScene);
	}
}
