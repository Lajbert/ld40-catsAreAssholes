class Main extends dn.Process {
	public static var BG = 0x0e0829;
	public static var ME : Main;
	public var console : Console;
	var black : h2d.Bitmap;

	public function new() {
		super();

		ME = this;

		// Engine init
		engine.backgroundColor = 0xff<<24|Main.BG;
		#if hl
			@:privateAccess hxd.Window.getInstance().window.vsync = true;
			#if !debug
				@:privateAccess hxd.Window.getInstance().window.displayMode = Borderless;
			#end
		#end

		// Resources
		#if debug
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed({compressSounds:true});
        #end

		createRoot(Boot.ME.s2d);
		root.filter = new h2d.filter.ColorMatrix();

		Assets.init();
		Data.load( hxd.Res.data.entry.getText() );
		hxd.Timer.wantedFPS = Const.FPS;
		console = new Console();
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.font);
		// dn.Lib.ludumProtection(this);

		#if debug
		hxd.Res.data.watch( function() {
			delayer.cancelById("reload");
			delayer.addS("reload", function() {
				trace("reloaded");
				Data.load( hxd.Res.data.entry.getBytes().toString() );
				restartGame();
			},1);
		});
		#end

		black = new h2d.Bitmap(h2d.Tile.fromColor(BG,1,1), root);
		black.visible = false;

		delayer.addF(function() {
			#if debug
			restartGame();
			#else
			new ui.Title();
			#end

			Assets.music.playOnGroup(1,true);
			#if debug
			dn.heaps.Sfx.toggleMuteGroup(1);
			#end

			onResize();
		}, 1);

	}

	var presses : Map<Int,Bool>;
	public function keyPressed(k:Int) {
		if( console.isActive() )
			return false;

		if( presses==null )
			presses = new Map();

		if( presses.exists(k) )
			return false;

		presses.set(k, true);
		return hxd.Key.isDown(k);
	}

	public function setBlack(on:Bool, ?cb:Void->Void) {
		if( on ) {
			black.visible = true;
			tw.createS(black.alpha, 0>1, 0.6).onEnd = function() {
				if( cb!=null )
					cb();
			}
		}
		else {
			tw.createS(black.alpha, 0, 0.3).onEnd = function() {
				black.visible = false;
				if( cb!=null )
					cb();
			}
		}

	}

	override public function onResize() {
		super.onResize();

		// Auto scaling
		if( Const.AUTO_SCALE_TARGET_HEIGHT>0 )
			Const.SCALE = M.ceil( h()/Const.AUTO_SCALE_TARGET_HEIGHT );
		root.setScale(Const.SCALE);

		black.scaleX = Boot.ME.s2d.width;
		black.scaleY = Boot.ME.s2d.height;
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	public function restartGame() {
		if( ui.ShopWindow.ME!=null )
			ui.ShopWindow.ME.destroy();

		if( Game.ME!=null ) {
			setBlack(true, function() {
				Game.ME.destroy();
				delayer.addS(function() {
					new Game( new h2d.Object(root) );
					tw.createS(Game.ME.root.alpha, 0>1, 0.4);
					setBlack(false);
				},0.5);
			});
		}
		else {
			new Game( new h2d.Object(root) );
			tw.createS(Game.ME.root.alpha, 0>1, 0.4);
			setBlack(false);
		}
	}

	override function postUpdate() {
		super.postUpdate();

		root.over(black);

		for(k in presses.keys())
			if( !hxd.Key.isDown(k) )
				presses.remove(k);
	}


	override function update() {
		super.update();

		if( keyPressed(hxd.Key.M) )
			dn.heaps.Sfx.toggleMuteGroup(1);
	}
}
