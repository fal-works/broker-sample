package scenes;

import broker.scene.SceneTypeId;
import broker.scene.Scene;

class TitleScene extends Scene {
	override public inline function getTypeId(): SceneTypeId
		return SceneType.Title;

	override function initialize(): Void {
		super.initialize();

		var font: h2d.Font;
		var startMessage: String;
		if (hxd.Res.loader.fs.exists("my_font.fnt")) {
			font = new hxd.res.BitmapFont(hxd.Res.loader.fs.get("my_font.fnt")).toFont();
			startMessage = "■ START GAME ■";
		} else {
			font = hxd.res.DefaultFont.get();
			startMessage = "START GAME";
		}
		final textField = new h2d.Text(font);
		textField.text = "■ START GAME ■";
		textField.textAlign = Center;
		textField.setPosition(
			Global.width / 2,
			Global.height / 2 - textField.textHeight / 2
		);
		this.layers.main.add(textField);
	}

	override function update(): Void {
		super.update();

		if (Global.gamepad.buttons.A.isPressed) {
			Global.sceneTransitionTable.runTransition(this, new PlayScene());
		}
	}
}
