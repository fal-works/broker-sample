import hxd.Res;
import broker.scene.SceneStack;
import broker.tools.Gc;
import broker.sound.SoundManager;
import scenes.PlayScene;

class Main extends hxd.App {
	static function main()
		new Main();

	var sceneStack: SceneStack;

	override function init() {
		Res.initLocal();

		broker.input.heaps.HeapsKeyTools.initialize();
		broker.input.heaps.HeapsPadTools.initialize();
		broker.scene.heaps.Scene.setApplication(this);
		Global.initialize();

		final initialScene = new PlayScene(s2d);
		initialScene.fadeInFrom(ArgbColor.WHITE, 60, true);
		sceneStack = new SceneStack(initialScene, 16).newTag("scene stack");

		Gc.startLogging(100);

		hxd.Window.getInstance().onClose = () -> {
			SoundManager.disposeAll();
			return true;
		};
	}

	override function update(dt: Float) {
		Global.update();
		sceneStack.update();

		Gc.update();
	}
}
