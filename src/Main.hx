import broker.scene.SceneStack;
import broker.tools.Gc;

class Main extends hxd.App {
	static function main()
		new Main();

	var sceneStack: SceneStack;

	override function init() {
		hxd.Res.initLocal();

		broker.input.physical.PhysicalInput.initialize();
		broker.scene.heaps.Scene.setApplication(this);
		Global.initialize();
		Sounds.initialize();

		final initialScene = new scenes.TitleScene(s2d);
		initialScene.fadeInFrom(ArgbColor.WHITE, 60, true);
		sceneStack = new SceneStack(initialScene, 16).newTag("scene stack");

		Gc.startLogging(100);
	}

	override function update(dt: Float) {
		Global.update();
		sceneStack.update();

		Gc.update();
	}
}
