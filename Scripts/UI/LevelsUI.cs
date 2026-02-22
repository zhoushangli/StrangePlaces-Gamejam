using Godot;
using Protogame2D.Core;
using Protogame2D.Services;
using Protogame2D.UI;
using System;
using System.Collections.Generic;

public partial class LevelsUI : UIBase
{
	// Called when the node enters the scene tree for the first time.
	[Export] private GridContainer _levelButtons;
	[Export] private NinePatchRect _sceneView;
	[Export] private Texture2D _lockedTexture;
	[Export] private Texture2D _unLockedTexture;
	[Export] private Texture2D _hoverTexture;
	[Export] private TextureButton _start;
	[Export] private TextureButton _back;
	[Export] private AudioStream _hoverSound;
	[Export] private AudioStream _pressSound;
	[Export] private AudioStream _gameBgm;
	
	[Export] private int finishedCnt;
	private Dictionary<TextureRect, bool> levelUnlocked;
	private Dictionary<TextureRect, bool> levelFinished;
	private Dictionary<TextureRect, int> levelsIdx;
	private List<TextureRect> levelsArray;
	int buttonCnt;
	public override void OnOpen(object args)
	{

		buttonCnt = 0;
		levelUnlocked = new Dictionary<TextureRect, bool>();
		levelsIdx = new Dictionary<TextureRect, int>();
		levelsArray = new List<TextureRect>();
		levelFinished = new Dictionary<TextureRect, bool>();
		//初始化每个按钮的信息，并且为按钮订阅函数
		_start.MouseEntered += OnButtonHovered;
		_start.Pressed += OnButtonPressedDown;
		_start.Pressed += OnStartPressed;

		_back.MouseEntered += OnButtonHovered;
		_back.Pressed += OnButtonPressedDown;
		_back.Pressed += OnBackPressed;
		foreach (var child in _levelButtons.GetChildren())
		{
			if (child is TextureRect b)
			{
				levelUnlocked[b] = false;
				levelFinished[b] = false;
				levelsIdx[b] = buttonCnt;
				levelsArray.Add(b);
				buttonCnt++;
				b.MouseEntered += () => OnButtonHovered(b);
				b.MouseExited += () => OnButtonNotHovered(b);
				b.GuiInput += (inputEvent) =>
				{
					// 1. 判断是否是鼠标按键事件
					if (inputEvent is InputEventMouseButton mouseEvent)
					{
						// 2. 检查：是否是左键 + 是否是按下动作（Pressed 为 true 是按下，false 是松开）
						if (mouseEvent.ButtonIndex == MouseButton.Left && mouseEvent.Pressed)
						{
							OnButtonPressedDown(b);
						}
					}
				};
			}			
		}
		//levelButton[]现在存储了所有的Level按钮
		//连接wire。
		enlightButtons(finishedCnt);
		int columns = _levelButtons.Columns;
		for(int i = 0; i < levelsArray.Count; i++)
		{
			var oneLevel = levelsArray[i];
			int currentCollumn = i % columns;
			int currentRow = i/columns;
			GD.Print($"关卡编号：{i}，位于行数：{currentRow},位于列数:{currentCollumn}");
			if (levelFinished[oneLevel])
			{
				
				TextureRect wireRight = oneLevel.GetNode<TextureRect>("WireRight");
				// if(currentRow % 2 == 0 && currentCollumn != columns - 1)
				// {
				// 	GD.Print("right wire allawed,idx = ", i);
				// 	wireRight.Visible = true;
				// }
				// else
				// {
				// 	wireRight.Visible = false;
				// }
				if(currentCollumn != columns-1)
				{
					GD.Print("right wire allawed,idx = ", i);
					wireRight.Visible = true;
				}
				else
				{
					wireRight.Visible = false;
				}
				//目前来看，wire up必为false。因为关卡是从上往下解锁的
				TextureRect wireUp = oneLevel.GetNode<TextureRect>("WireUp");
				wireUp.Visible = false;

				TextureRect wireLeft = oneLevel.GetNode<TextureRect>("WireLeft");
				if(currentRow%2 == 1 && currentCollumn != 0)
				{
					wireLeft.Visible = true;
				}
				else
				{
					wireLeft.Visible = false;
				}
				TextureRect wireDown = oneLevel.GetNode<TextureRect>("WireDown");
				if((currentRow%2 == 0 && currentCollumn == columns - 1)||
				(currentRow%2==1 && currentCollumn == 0))
				{
					// wireDown.Visible = true;
					// if(i + columns >= levelsArray.Count)
					// {
					// 	wireDown.Visible = false;
					// }
					wireDown.Visible = false;
				}
				else
				{
					wireDown.Visible = false;
				}
				
			}
			else//本关未完成，不显示与其相连的电线
			{
				foreach(TextureRect wire in oneLevel.GetChildren())
				{
					wire.Visible = false;
				}
			}
		}
	}
	void enlightButtons(int finishedCnt)
	{
		for(int i = 0;i < finishedCnt; i++)
		{
			TextureRect level = levelsArray[i];
			levelFinished[level] = true;
			levelUnlocked[level] = true;
			level.Texture = _unLockedTexture;
		}
		if(finishedCnt < levelsArray.Count)
		{
			TextureRect level = levelsArray[finishedCnt];
			levelUnlocked[level] = true;
			level.Texture = _unLockedTexture;
		}
	}
	void OnButtonHovered(TextureRect levelButton)
	{
		int idx = levelsIdx[levelButton];
		levelButton.Texture = _hoverTexture;
		Game.Instance.Get<AudioService>().PlaySfx(_hoverSound);
		_sceneView.GetNode<Label>("LevelIdx").Text = $"Level {idx}";
		_sceneView.GetNode<Label>("LevelName").Text = $"This is level {idx}.";
	}
	void OnButtonHovered()
	{
		Game.Instance.Get<AudioService>().PlaySfx(_hoverSound);
	}
	void OnButtonNotHovered(TextureRect levelButton)
	{
		if (levelUnlocked[levelButton] == true)//该关卡已解锁，则其texture从"被选中"退回到"已解锁"
		{
			levelButton.Texture = _unLockedTexture;
		}
		else
		{
			levelButton.Texture = _lockedTexture;
		}
	}
	void OnButtonPressedDown(TextureRect levelButton)
	{//针对Level Buttons的函数

		Game.Instance.Get<AudioService>().PlaySfx(_pressSound);
		Game.Instance.Get<AudioService>().PlayBgm(_gameBgm);
		Game.Instance.Get<UIService>().CloseTop();
        Game.Instance.Get<GameStateService>().ChangeGameState(GameState.Game);
        _=Game.Instance.Get<LevelService>().LoadLevel(levelButton.GetMeta("LevelPath").AsString());
		//加载reset按钮
		Game.Instance.Get<UIService>().Open<HUDUI>();
	}
	void OnButtonPressedDown()
	{
		Game.Instance.Get<AudioService>().PlaySfx(_pressSound);
	}
	void OnStartPressed()
	{
		//TODO
		GD.Print("start func not finished.");
	}
	void OnBackPressed()
	{
		//回到主菜单
		GD.Print("trying to back to main menu.");
		Game.Instance.Get<UIService>().CloseTop();
		Game.Instance.Get<UIService>().Open<MainMenuUI>();
		
	}
	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
	public override void OnClose()
	{

	}
	public override void _Ready()
	{
	}





}
