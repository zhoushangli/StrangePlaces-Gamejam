using Godot;
using Protogame2D.Core;
using System.Collections.Generic;

public partial class AudioService : Node, IService
{
    [Export] private AudioStreamPlayer _bgmPlayer;
    [Export] private int _sfxPoolSize = 5;
    [Export] private Node _sfxContainer;
    
    private List<AudioStreamPlayer> _sfxPlayers = new();

    public void Init()
    {
        Name = "AudioService";

        // === SFX Pool ===
        for (int i = 0; i < _sfxPoolSize; i++)
        {
            var player = new AudioStreamPlayer();
            player.Name = $"SFXPlayer_{i}";
            player.Bus = "SFX";
            _sfxContainer.AddChild(player);
            _sfxPlayers.Add(player);
        }
    }

    public void Shutdown()
    {
        _bgmPlayer.Stop();
        foreach (var player in _sfxPlayers)
        {
            player.Stop();
        }
    }

    public void PlayBgm(AudioStream stream, bool loop = true)
    {
        if (_bgmPlayer.Stream == stream)
            return;

        _bgmPlayer.Stop();

        if (stream is AudioStreamWav wav)
        {
            var inst = (AudioStreamWav)wav.Duplicate(true);
            _bgmPlayer.Stream = inst;

            if (loop)
            {
                inst.LoopBegin = 0;

                // LoopEnd 用“采样点”更稳：长度(秒) * 采样率
                int endSamples = Mathf.Max(1, (int)Mathf.Round(inst.GetLength() * inst.MixRate));
                inst.LoopEnd = endSamples;

                inst.LoopMode = AudioStreamWav.LoopModeEnum.Forward;
            }
            else
            {
                inst.LoopMode = AudioStreamWav.LoopModeEnum.Disabled;
            }
        }
        else
        {
            _bgmPlayer.Stream = stream;
        }

        _bgmPlayer.Play();
        GD.Print($"[AudioService] Playing BGM: {stream.ResourcePath}, Loop: {loop}");
    }

    public void StopBgm()
    {
        _bgmPlayer.Stop();
    }

    public void PlaySfx(AudioStream stream)
    {
        foreach (var player in _sfxPlayers)
        {
            if (!player.Playing)
            {
                player.Stream = stream;
                player.Play();
                return;
            }
        }

        GD.Print("No free SFX player!");
    }
}
