package gamepad;

import broker.input.physical.PhysicalInput;
import broker.input.physical.PadPort;
import broker.input.physical.KeyCode;
import broker.input.physical.PadCode;
import broker.input.builtin.simple.Button;
import broker.input.builtin.simple.ButtonStatusMap;

@:structInit
class GamepadBuilder implements ripper.Data {
	public final keyCodeMap: Map<Button, Array<KeyCode>>;
	public final padCodeMap: Map<Button, Array<PadCode>>;

	public final gamepadPort: PadPort;
	public final analogStickThreshold: Float;

	public final speedChangeButton: Button;
	public final defaultSpeed: Float;
	public final alternativeSpeed: Float;

	public function build() {
		final buttons = new ButtonStatusMap();

		final getButtonChecker = PhysicalInput.createButtonCheckerGenerator(
			keyCodeMap,
			padCodeMap,
			gamepadPort
		);
		final updateButtonStatus = buttons.createUpdater(getButtonChecker);

		final parameters: GamepadParameters = {
			updateButtonStatus: updateButtonStatus,
			gamepadPort: gamepadPort,
			analogStickThreshold: analogStickThreshold,
			speedChangeButtonStatus: buttons.get(speedChangeButton),
			defaultSpeed: defaultSpeed,
			alternativeSpeed: alternativeSpeed
		};

		return new Gamepad(buttons, parameters);
	}
}
