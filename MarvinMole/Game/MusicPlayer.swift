//
//  MusicPlayer.swift
//  MarvinMole
//
//  (c) Morten Perriard 2026
//

import AVFoundation

/// Background music, independent of scenes, so it keeps playing across scene transitions
final class MusicPlayer {
    static let shared = MusicPlayer()

    private var player: AVAudioPlayer? = nil
    private var fileName: String? = nil

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
