import broker.sound.Sound;
import broker.sound.SoundManager;

/**
	Set of `broker.sound.Sound` instances.
**/
class Sounds {
	public static var music(default, null): Sound;
	public static var explosion(default, null): Sound;
	public static var lazer(default, null): Sound;

	#if heaps
	/**
		Call this after initializing `hxd.Res`.
	**/
	public static function initialize() {
		music = {
			data: hxd.Res.music_466998,
			isLooped: true,
			preventsLayered: true
		};

		explosion = {
			data: hxd.Res.sound_361259_explosion,
			preventsLayered: true
		};

		lazer = {
			data: hxd.Res.sound_361471_laser,
			preventsLayered: true
		};

		hxd.Window.getInstance().onClose = () -> {
			SoundManager.disposeAll();
			return true;
		};
	}
	#else
	public static function initialize() {}
	#end
}
