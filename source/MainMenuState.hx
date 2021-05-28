package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;

#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'discord', 'options'];
	#else
	var optionShit:Array<String> = ['freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	var newInput:Bool = true;

	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		bg.angle = 180;

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		

		var tex = Paths.getSparrowAtlas('Lenny_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0 +  (i * 160), 0 );
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.addByPrefix('enter', optionShit[i] + " enter", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(Y);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItems.forEach(function(spr:FlxSprite)
			{	
				spr.visible = false;
			});
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(30, FlxG.height - 30, 0, gameVer + " FNF", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var modNameMenu:FlxText = new FlxText(30, FlxG.height - 50, 0, "VS. Lenny", 12);
		modNameMenu.scrollFactor.set();
		modNameMenu.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(modNameMenu);

		FlxG.camera.zoom = 5;
		FlxTween.tween(bg, { angle:0}, 1, { 
			ease: FlxEase.sineInOut
		});
		FlxTween.tween(FlxG.camera, { zoom: 1}, 1.1, { 
			ease: FlxEase.sineInOut ,
			onComplete: function(twn:FlxTween)
			{
				menuItems.forEach(function(spr:FlxSprite)
				{	
					spr.visible = true;
					spr.animation.play('enter');
					new FlxTimer().start(1, function(e:FlxTimer)
					{
						spr.animation.play('idle');
						changeItem();
					});
				});
			}
		});
		
		/*FlxTween.tween(bg, { angle:0}, 1, { ease: FlxEase.quartInOut});
		FlxTween.tween(spr, { x: 0, y: 50 }, 0.9, { ease: FlxEase.quartInOut});*/
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem(-1);
		changeItem(1);

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'discord')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://discord.gg/jh9UtFxFFV", "&"]);
					#else
					FlxG.openURL('https://discord.gg/jh9UtFxFFV');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];
								

								switch (daChoice)
								{
									case 'freeplay':	
										FlxTween.tween(FlxG.camera, { x: 0, y: 50 }, 0.5, { 
											ease: FlxEase.sineInOut,
											onComplete: function(twn:FlxTween)
											{
												FlxTween.tween(FlxG.camera, { zoom: 5}, 1.5, { 
													ease: FlxEase.sineInOut,
													onComplete: function(twn:FlxTween)
													{
														FlxG.switchState(new FreeplayState());
														
														trace("Freeplay Menu Selected");
													} 
												});

											}
										});
										

									case 'options':
										FlxTween.tween(FlxG.camera, { x: 0, y: 100 }, 0.5, { 
											ease: FlxEase.sineInOut,
											onComplete: function(twn:FlxTween)
											{
												FlxTween.tween(FlxG.camera, { zoom: 5}, 1.5, { 
													ease: FlxEase.sineInOut,
													onComplete: function(twn:FlxTween)
													{
														FlxG.switchState(new OptionsMenu());
													} 
												});

											}
										});
									case 'story mode':
										FlxTween.tween(FlxG.camera, { x: 0, y: 200 }, 0.5, { 
											ease: FlxEase.sineInOut,
											onComplete: function(twn:FlxTween)
											{
												FlxTween.tween(FlxG.camera, { zoom: 5}, 1.5, { 
													ease: FlxEase.sineInOut,
													onComplete: function(twn:FlxTween)
													{
														FlxG.switchState(new StoryMenuState());
													} 
												});
												
												
											}
										});
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		// menuItems.forEach(function(spr:FlxSprite)
		// {
		// 	spr.screenCenter(x);
		// });
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
