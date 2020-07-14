package scenes;

import broker.scene.SceneTypeId;
import broker.scene.Scene;
import broker.menu.Menu;
import broker.menu.MenuOption;
import broker.timer.Timer;
import broker.tools.Window;
import broker.text.*;

class TitleScene extends Scene {
	var font: Maybe<Font> = Maybe.none();
	var useDefaultFont = false;
	var menu = Menu.create({
		initialOptions: [],
		listenFocusPrevious: [()->Global.gamepad.buttons.D_UP.isJustPressed],
		listenFocusNext: [()->Global.gamepad.buttons.D_DOWN.isJustPressed],
		listenSelect: [()->Global.gamepad.buttons.A.isJustPressed],
		onAddOption: [(object, index) -> object.setPosition(0.0, index * 48.0)]
	});

	override public inline function getTypeId(): SceneTypeId
		return SceneType.Title;

	override function initialize(): Void {
		super.initialize();

		final fontInfo = prepareFont();
		final font = fontInfo.font;
		this.useDefaultFont = fontInfo.isDefault;

		final mainLayer = this.layers.main;
		mainLayer.add(createStartMessage(0.35 * Global.height, fontInfo));
		mainLayer.add(initializeMenu(0.5 * Global.height, font));
	}

	function initializeMenu(y: Float, font: Font): Menu {
		final menu = this.menu;

		final gotoPlayScene = () -> {
			Global.sceneTransitionTable.runTransition(this, new PlayScene());
		};
		menu.addOption(createMenuOption("START", font, gotoPlayScene));

		final quit = () -> {
			final fadeOut = this.fadeOutTo(0xFF000000, 30, true);
			final closeWindow: Timer = {
				duration: 15,
				onComplete: () -> Window.close()
			};
			fadeOut.setNext(closeWindow);
		};
		menu.addOption(createMenuOption("QUIT", font, quit));

		menu.setPosition(0.5 * Global.width, y);
		menu.focusAt(UInt.zero);

		return menu;
	}

	function createMenuOption(text: String, font: Font, onSelect: Void->Void): MenuOption {
		final textField = new Text(text, Center, font);
		textField.textRgb = 0xFFFFFF;
		return {
			object: textField,
			onFocus: [() -> textField.alpha = 1.0],
			onDefocus: [() -> textField.alpha = 0.5],
			onSelect: [onSelect]
		};
	}

	override function update(): Void {
		super.update();

		this.menu.listen();
	}

	override function destroy(): Void {
		super.destroy();
		if (font.isSome() && !useDefaultFont) font.unwrap().dispose();
	}

	function prepareFont(): { font: Font, isDefault: Bool } {
		var font: Font;
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

	function createStartMessage(
		y: Float,
		fontInfo: { font: Font, isDefault: Bool }
	): Text {
		// "■" for testing multibyte
		final startMessage = fontInfo.isDefault ? "SAMPLE PROJECT" : "■ SAMPLE PROJECT ■";

		final textField = new Text(startMessage, Center, fontInfo.font);
		textField.setPosition(0.5 * Global.width, y);

		return textField;
	}
}
