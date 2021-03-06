package actor;

import broker.entity.BasicAosoa;

interface ActorAosoa extends BasicAosoa {
	function update(): Void;
	function crashAll(): Void;
	function synchronize(): Void;
	function loadQuadTree(quadtree: Quadtree): Void;
	function findOverlapped(collider: Aabb, found: Reference<Bool>): Void;
}
