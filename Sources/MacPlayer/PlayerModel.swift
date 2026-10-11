import Foundation
import AVFoundation
import AppKit

/// Один трек в плейлисте
struct Track: Identifiable, Hashable {
    let id = UUID()
    let url: URL

    var title: String {
        url.deletingPathExtension().lastPathComponent
    }
}

/// Модель плеера: плейлист, воспроизведение и обработка клавиш
@MainActor
final class PlayerModel: NSObject, ObservableObject {
    @Published private(set) var tracks: [Track] = []
    @Published var selectedID: Track.ID?
    @Published private(set) var playingID: Track.ID?
    @Published private(set) var status: String = "Добавьте треки в плейлист"

    private var player: AVAudioPlayer?
    private var keyMonitor: Any?

    override init() {
        super.init()
        // Перехватываем нажатия клавиш на уровне приложения,
        // чтобы Space и Esc работали независимо от того, какой элемент в фокусе.
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            return MainActor.assumeIsolated {
                self.handleKey(event) ? nil : event
            }
        }
    }

    // MARK: - Плейлист

    func addTracks(urls: [URL]) {
        let existing = Set(tracks.map { $0.url })
        for url in urls where !existing.contains(url) {
            tracks.append(Track(url: url))
        }
        if selectedID == nil {
            selectedID = tracks.first?.id
        }
    }

    func removeSelected() {
        guard let id = selectedID, let index = tracks.firstIndex(where: { $0.id == id }) else { return }
        if playingID == id {
            stop()
        }
        tracks.remove(at: index)
        // Выбираем соседний трек
        if tracks.isEmpty {
            selectedID = nil
        } else {
            selectedID = tracks[min(index, tracks.count - 1)].id
        }
    }

    // MARK: - Воспроизведение

    /// Запускает выбранный трек (или первый, если ничего не выбрано)
    func playSelected() {
        guard let id = selectedID ?? tracks.first?.id,
              let track = tracks.first(where: { $0.id == id }) else { return }
        play(track)
    }

    func play(_ track: Track) {
        // Текущий трек останавливается перед запуском нового
        player?.stop()
        player = nil

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: track.url)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            newPlayer.play()

            player = newPlayer
            selectedID = track.id
            playingID = track.id
            status = "▶︎ Играет: \(track.title)"
        } catch {
            playingID = nil
            status = "Не удалось открыть «\(track.title)»: \(error.localizedDescription)"
        }
    }

    /// Останавливает воспроизведение
    func stop() {
        guard player != nil else { return }
        player?.stop()
        player = nil
        playingID = nil
        status = "Остановлено"
    }

    // MARK: - Клавиши

    private func handleKey(_ event: NSEvent) -> Bool {
        // Не трогаем сочетания с Cmd / Ctrl / Option (например, Cmd+Q)
        guard event.modifierFlags.intersection([.command, .control, .option]).isEmpty else {
            return false
        }

        switch event.keyCode {
        case 49: // Space
            if !event.isARepeat {
                playSelected()
            }
            return true
        case 53: // Esc
            stop()
            return true
        default:
            return false
        }
    }
}

// MARK: - Отслеживание окончания трека

extension PlayerModel: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ finishedPlayer: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            guard self.player === finishedPlayer else { return }
            self.player = nil
            self.playingID = nil
            self.status = "Трек завершён"
        }
    }
}
