package scenes;

import broker.scene.SceneTypeId;
import broker.scene.Scene;
import broker.draw.TileDraw;
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
		return SceneType.Play;

	override function initialize(): Void {
		super.initialize();

		this.world = new World(this.layers.main);

		this.musicChannel = Sounds.music.play().unwrap();

		this.layers.background.add(TileDraw.fromImage(hxd.Res.background));
	}

	override function update(): Void {
		super.update();
		this.world.update();

		final buttons = Global.gamepad.buttons;

		if (buttons.Y.isJustPressed) {
			this.goToTitle();
			return;
		}

		if (buttons.B.isJustPressed)
			musicChannel.fadeOut(2.0);
	}

	override function activate(): Void {
		super.activate();
		Global.resetParticles(this.layers.main);
	}

	override function deactivate(): Void
		SoundManager.stopAll();

	override function destroy(): Void
		SoundManager.stopAll();

	function goToTitle(): Void {
		if (this.isTransitioning) return;
		final nextScene = new TitleScene();
		Global.sceneTransitionTable.runTransition(this, nextScene);
	}
}
