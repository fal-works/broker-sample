package scenes;

import broker.scene.SceneTypeId;
import broker.scene.Scene;
import broker.menu.Menu;

class TitleScene extends Scene {
	var font: Maybe<h2d.Font> = Maybe.none();
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

		final mainLayer = this.layers.main;
		mainLayer.add(createStartMessage(0.35 * Global.height, fontInfo));
		mainLayer.add(initializeMenu(0.5 * Global.height, font));
	}

	function initializeMenu(y: Float, font: h2d.Font): Menu {
		final menu = this.menu;

		final startTextField = createTextField("START", font, Center);
		final gotoPlayScene = () -> {
			Global.sceneTransitionTable.runTransition(this, new PlayScene());
		};
		menu.addOption({
			object: startTextField,
			onFocus: [() -> startTextField.textColor = 0xFFFFFF],
			onDefocus: [() -> startTextField.textColor = 0x808080],
			onSelect: [gotoPlayScene]
		});

		final quitTextField = createTextField("QUIT", font, Center);
		final quit = () -> {
			this.fadeOutTo(0xFF000000, 30, true);
			this.timers.push(({
				duration: 45,
				onComplete: () -> Sys.exit(0)
			}));
		};
		menu.addOption({
			object: quitTextField,
			onFocus: [() -> quitTextField.textColor = 0xFFFFFF],
			onDefocus: [() -> quitTextField.textColor = 0x808080],
			onSelect: [quit]
		});

		menu.setPosition(0.5 * Global.width, y);
		menu.focusAt(UInt.zero);

		return menu;
	}

	override function update(): Void {
		super.update();

		this.menu.listen();
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

	function createTextField(
		text: String,
		font: h2d.Font,
		?align: h2d.Text.Align
	): h2d.Text {
		final textField = new h2d.Text(font);
		textField.smooth = true;
		textField.text = text;
		if (align != null) textField.textAlign = align;
		return textField;
	}

	function createStartMessage(
		y: Float,
		fontInfo: { font: h2d.Font, isDefault: Bool }
	): h2d.Text {
		// "■" for testing multibyte
		final startMessage = fontInfo.isDefault ? "SAMPLE PROJECT" : "■ SAMPLE PROJECT ■";

		final textField = createTextField(startMessage, fontInfo.font, Center);
		textField.setPosition(0.5 * Global.width, y);

		return textField;
	}
}
