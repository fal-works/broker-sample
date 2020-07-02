package scenes;

import broker.scene.SceneTypeId;

enum abstract SceneType(SceneTypeId) to SceneTypeId {
	final All = SceneTypeId.ALL;
	final Title = SceneTypeId.from(0);
	final Play = SceneTypeId.from(1);
}
