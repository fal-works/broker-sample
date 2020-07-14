import broker.scene.SceneStack;
import broker.tools.Gc;

class Main extends broker.App {
	static function main() {
		new Main(800, 600);
	}

	var sceneStack: SceneStack;

	override function initialize(): Void {
		#if js
		hxd.Res.initEmbed();
		#else
		hxd.Res.initLocal();
		#end

		Global.initialize();
		Sounds.initialize();

		final initialScene = new scenes.TitleScene();
		initialScene.fadeInFrom(ArgbColor.WHITE, 60, true);
		sceneStack = new SceneStack(initialScene, 16).newTag("scene stack");

		Gc.startLogging(100);
	}

	override function update() {
		Global.update();
		sceneStack.update();
	}
}
