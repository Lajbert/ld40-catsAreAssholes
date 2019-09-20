import dn.CdbHelper;
import dn.PathFinder;

class Level extends dn.Process {
	var lInfos : Data.LevelMap;
	var collMap : Map<Int,Bool>;
	public var wid : Int;
	public var hei : Int;
	public var pf : PathFinder;

	public function new(id:Data.LevelMapKind) {
		super(Game.ME);

		lInfos = Data.levelMap.get(id);
		collMap = new Map();
		wid = lInfos.width;
		hei = lInfos.height;
		pf = new dn.PathFinder(wid, hei);

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		for(l in lInfos.layers) {
			var tileSet = lInfos.props.getTileset(Data.levelMap, l.data.file);
			var sheet = hxd.Res.load(l.data.file).toTile();
			var bg = new h2d.TileGroup(sheet, root);
			var tiles = CdbHelper.getLayerTiles(l.data, sheet, lInfos.width, tileSet);

			if( l.name=="coll" ) {
				// Collisions
				for(t in tiles) {
					pf.setCollision(t.cx, t.cy);
					collMap.set(coordToId(t.cx,t.cy), true);
				}
			}
			else {
				// Tiles
				for(t in tiles)
					bg.add(t.x, t.y, t.t);
			}
		}
	}

	public function attachEntities() {
		for(m in lInfos.markers)
			switch( m.markerId ) {
				case Data.MarkerKind.Grandma : Game.ME.hero = new en.h.Grandma(m.x,m.y);
				case Data.MarkerKind.Sidekick : new en.h.Sidekick(m.x,m.y);
				case Data.MarkerKind.Cat : new en.Cat(m.x,m.y);
				case Data.MarkerKind.FoodTray :
					var e = new en.inter.FoodTray(m.x,m.y);
					if( m.data=="empty" )
						e.stock = 0;
				case Data.MarkerKind.Fridge : new en.inter.Fridge(m.x,m.y);
				case Data.MarkerKind.Litter : new en.inter.Litter(m.x,m.y);
				case Data.MarkerKind.TrashCan : new en.inter.TrashCan(m.x,m.y);
				case Data.MarkerKind.Ball : new en.f.Ball(m.x,m.y);
				case Data.MarkerKind.Shop : new en.inter.Shop(m.x,m.y);
				case Data.MarkerKind.Door : new en.inter.Door(m.x,m.y);
			}

		if( en.Cat.ALL.length>=1 )
			en.Cat.ALL[0].startEat();

		if( en.Cat.ALL.length>=2 )
			en.Cat.ALL[1].startShit();
	}

	public inline function hasColl(cx:Int, cy:Int) {
		return isValid(cx,cy) ? collMap.get( coordToId(cx,cy) )==true : true;
	}

	public inline function isValid(cx:Int,cy:Int) {
		return cx>=0 && cx<wid && cy>=0 && cy<hei;
	}
	public inline function coordToId(cx:Int,cy:Int) return cx+cy*wid;

	override public function onDispose() {
		super.onDispose();
	}
}
