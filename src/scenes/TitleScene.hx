package scenes;

import broker.scene.SceneTypeId;
import broker.scene.Scene;

class TitleScene extends Scene {
	var font: Maybe<h2d.Font> = Maybe.none();

	override public inline function getTypeId(): SceneTypeId
		return SceneType.Title;

	override function initialize(): Void {
		super.initialize();

		final fontInfo = prepareFont();
		this.layers.main.add(this.createStartMessage(fontInfo));
	}

	override function update(): Void {
		super.update();

		if (Global.gamepad.buttons.A.isJustPressed) {
			Global.sceneTransitionTable.runTransition(this, new PlayScene());
		}
	}

	override function destroy(): Void {
		super.destroy();
		if (font.isSome()) font.unwrap().dispose();
	}

	function prepareFont(): { font: h2d.Font, isDefault: Bool } {
		var font: h2d.Font;
		var isDefault: Bool;

		final fileSystem = hxd.Res.loader.fs;
		if (fileSystem.exists("my_sdf_font.fnt")) {
			// The file is not included in this repository. Provide `my_sdf_font.fnt` yourself for testing this.
			final file = fileSystem.get("my_sdf_font.fnt");
			// Assuming the alpha channel is for distance
			font = new hxd.res.BitmapFont(file).toSdfFont(32, 3);
			isDefault = false;
		} else if (fileSystem.exists("my_font.fnt")) {
			// The file is not included in this repository. Provide `my_font.fnt` yourself for testing this.
			final file = fileSystem.get("my_font.fnt");
			font = new hxd.res.BitmapFont(file).toFont();
			isDefault = false;
		} else {
			font = hxd.res.DefaultFont.get();
			isDefault = true;
		}

		this.font = Maybe.from(font);
		return { font: font, isDefault: isDefault };
	}

	function createStartMessage(fontInfo: { font: h2d.Font, isDefault: Bool }): h2d.Text {
		// "■" for testing multibyte
		final startMessage = fontInfo.isDefault ? "SAMPLE PROJECT" : "■ SAMPLE PROJECT ■";

		final textField = new h2d.Text(fontInfo.font);
		textField.smooth = true;
		textField.text = startMessage;
		textField.textAlign = Center;
		textField.setPosition(
			Global.width / 2,
			Global.height / 2 - textField.textHeight / 2
		);

		return textField;
	}
}
