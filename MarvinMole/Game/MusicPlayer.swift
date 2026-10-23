//
//  MusicPlayer.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import AVFoundation
import UIKit

/// Background music, independent of scenes, so it keeps playing across scene transitions.
/// It pauses while the app is in the background (or interrupted, e.g. by Control Center or a call),
/// and carries on when the app is back.
final class MusicPlayer {
    static let shared = MusicPlayer()

    private var player: AVAudioPlayer? = nil
    private var fileName: String? = nil

    /// Set while the music is paused because the app is not active
    private var isPausedForBackground = false

    private init() {
        // game music: mixes with other apps' audio, and is silent when the ring/silent switch says so
        try? AVAudioSession.sharedInstance().setCategory(.ambient)

        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.pauseForBackground()
        }
        center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.resumeFromBackground()
        }
    }

    private func pauseForBackground() {
        if let player, player.isPlaying {
            player.pause()
            isPausedForBackground = true
        }
    }

    private func resumeFromBackground() {
        if isPausedForBackground {
            isPausedForBackground = false
            player?.play()
        }
    }

    /// Starts looping the music, unless it is already playing (then nothing changes)
    /// - Parameters:
    ///   - fileName: Music file in the app bundle
    ///   - volume: Playback volume, 0 ... 1
    func play(_ fileName: String, volume: Float = 0.6) {
        if let player, player.isPlaying, self.fileName == fileName {
            player.setVolume(volume, fadeDuration: 0.3)      // e.g. cancels a fade-out in progress
            return
        }
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil),
              let player = try? AVAudioPlayer(contentsOf: url) else {
            return
        }
        player.numberOfLoops = -1
        player.volume = volume
        player.play()
        self.player = player
        self.fileName = fileName
    }

    /// Fades the music out, then stops it
    func fadeOut(duration: TimeInterval = 1.0) {
        guard let player, player.isPlaying else {
            return
        }
        player.setVolume(0, fadeDuration: duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            // only stop if nothing restarted the music meanwhile
            if let current = self?.player, current === player, current.volume == 0 {
                current.stop()
                self?.player = nil
            }
        }
    }
}
