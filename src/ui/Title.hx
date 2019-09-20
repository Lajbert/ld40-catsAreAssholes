package ui;

class Title extends dn.Process {
	public static var ME : Title;

	var bg : HSprite;
	var grandma : HSprite;
	var about : h2d.Flow;
	var cat0 : HSprite;
	var cat1 : HSprite;
	var chars : h2d.Object;
	var press : h2d.Text;
	var ctrl : dn.heaps.Controller.ControllerAccess;

	public function new() {
		super(Main.ME);
		ME = this;
		ctrl = Main.ME.ctrlMaster.createAccess("title");

		createRoot(Main.ME.root);

		bg = Assets.gameElements.h_get("title",0.5,0.5, root);

		chars = new h2d.Object(root);
		grandma = Assets.gameElements.h_getAndPlay("heroWalk",chars);
		grandma.setCenterRatio(0.5,1);
		grandma.anim.setSpeed(0.2);
		grandma.scaleX = -1;

		cat0 = Assets.gameElements.h_getAndPlay("ncatAngryWalk",chars);
		cat0.setCenterRatio(0.5,1);
		cat0.anim.setSpeed(0.17);
		cat0.scaleX = -1;

		cat1 = Assets.gameElements.h_getAndPlay("wcatDash",chars);
		cat1.setCenterRatio(0.5,1);
		cat1.anim.setSpeed(0.3);
		cat1.scaleX = -1;

		//var house = Assets.gameElements.h_get("introHouse",chars);
		//house.setCenterRatio(0.5,1);
		//house.anim.setSpeed(0.3);
		//house.scaleX = -1;
		//house.y = 3;

		var t = 1.5;
		tw.createS(grandma.x, 80>-50, TEaseOut, t);
		tw.createS(cat0.x, 90>30, TEaseOut, t);
		tw.createS(cat1.x, 110>50, TEaseOut, t);
		delayer.addS(function() {
			var t = 7;
			tw.createS(grandma.x, -40, TEaseOut, t);
			tw.createS(cat0.x, 0, TEaseOut, t);
			tw.createS(cat1.x, 30, TEaseOut, t);
			//tw.createS(house.x, 80>90, TEaseOut, t);
		},t);

		about = new h2d.Flow(root);
		about.visible = false;
		about.backgroundTile = Assets.gameElements.getTile("window");
		about.borderHeight = about.borderWidth = 8;
		about.padding = 10;
		about.isVertical = true;
		about.verticalSpacing = 10;
		about.horizontalAlign = Left;
		addAbout("Hi there!", 0xFFBF00);
		addAbout("I created this game in 3 days for the Ludum Dare 40 game jam.");
		addAbout("The theme was \"The more you have, the worse it is\".");
		addAbout("Have fun!");
		addAbout("Sébastien Bénard\n@deepnightFR\nwww.deepnight.net)", 0x894E88);

		press = new h2d.Text(Assets.font, root);
		press.text = "Press SPACE to start";

		onResize();
	}

	function addAbout(str:String,?c=0xFFFFFF) {
		var tf = new h2d.Text(Assets.font, about);
		tf.text = str;
		tf.textColor = c;
		tf.maxWidth = 220;
	}

	function getWid() return Boot.ME.s2d.width/Const.SCALE;
	function getHei() return Boot.ME.s2d.height/Const.SCALE;

	override public function onResize() {
		super.onResize();

		press.x = Std.int( getWid()*0.5 - press.textWidth*0.5 );
		press.y = getHei()-20;
		bg.x = getWid()*0.5;
		bg.y = getHei()*0.5;
		chars.x = getWid()*0.5;
		chars.y = getHei()*0.5 + 31;
		about.x = getWid()*0.5 - about.outerWidth*0.5;
		//about.y = getHei() - about.outerHeight - 20;
		about.y = 10;
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
		ctrl.dispose();
	}

	function close() {
		cd.setS("closing", 99999);
		Main.ME.setBlack(true, function() {
			destroy();
			Main.ME.restartGame();
		});
	}

	override public function update() {
		super.update();

		if( cd.has("closing") )
			return;

		if( ctrl.aPressed() || ctrl.bPressed() || ctrl.xPressed() ) {
			if( about.visible ) {
				close();
				Assets.SBANK.bleep2(1);
			}
			else {
				Assets.SBANK.menu0(1);
				about.visible = true;
				tw.createS(about.alpha,0>1,0.3);
				tw.createS(about.y,-about.outerHeight>10,0.3);
			}
		}

		press.alpha = 0.65 + Math.sin(ftime*0.1)*0.35;
	}
}

