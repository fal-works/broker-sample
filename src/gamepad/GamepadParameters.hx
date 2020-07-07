package gamepad;

import broker.input.ButtonStatus;
import broker.input.physical.PadPort;

/**
	Set of parameters to be stored/used by a `Gamepad` instance.
**/
@:structInit
class GamepadParameters implements ripper.Data {
	public final updateButtonStatus: () -> Void;
	public final gamepadPort: PadPort;
	public final analogStickThreshold: Float;

	public final speedChangeButtonStatus: ButtonStatus;
	public final defaultSpeed: Float;
	public final alternativeSpeed: Float;
}
