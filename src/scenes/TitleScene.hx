package scenes;

import broker.scene.SceneTypeId;
import broker.scene.Scene;

class TitleScene extends Scene {
	override public inline function getTypeId(): SceneTypeId
		return SceneType.Title;

	override function initialize(): Void {
		super.initialize();

		this.layers.main.add(this.createStartMessage());
	}

	override function update(): Void {
		super.update();

		if (Global.gamepad.buttons.A.isJustPressed) {
			Global.sceneTransitionTable.runTransition(this, new PlayScene());
		}
	}

	function createStartMessage() {
		var font: h2d.Font;
		var startMessage: String;

		final fileSystem = hxd.Res.loader.fs;
		if (fileSystem.exists("my_font.fnt")) {
			// The file is not included in this repository. Provide `my_font.fnt` yourself for testing this.
			font = new hxd.res.BitmapFont(fileSystem.get("my_font.fnt")).toFont();
			startMessage = "■ START GAME ■"; // testing multibyte
		} else {
			font = hxd.res.DefaultFont.get();
			startMessage = "START GAME";
		}

		final textField = new h2d.Text(font);
		textField.text = startMessage;
		textField.textAlign = Center;
		textField.setPosition(
			Global.width / 2,
			Global.height / 2 - textField.textHeight / 2
		);

		return textField;
	}
}
