import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var model: PlayerModel

    var body: some View {
        VStack(spacing: 0) {
            // Список треков
            List(selection: $model.selectedID) {
                ForEach(model.tracks) { track in
                    HStack(spacing: 10) {
                        Image(systemName: model.playingID == track.id ? "speaker.wave.2.fill" : "music.note")
                            .foregroundStyle(model.playingID == track.id ? Color.accentColor : Color.secondary)
                            .frame(width: 20)
                        Text(track.title)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                    }
                    .padding(.vertical, 2)
                    .contentShape(Rectangle())
                    .tag(track.id)
                    .onTapGesture(count: 2) {
                        model.play(track)
                    }
                }
            }
            .overlay {
                if model.tracks.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Перетащите аудиофайлы сюда\nили нажмите «Добавить треки»")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                for provider in providers {
                    _ = provider.loadObject(ofClass: URL.self) { url, _ in
                        guard let url else { return }
                        Task { @MainActor in
                            model.addTracks(urls: [url])
                        }
                    }
                }
                return true
            }
            .onDeleteCommand {
                model.removeSelected()
            }

            Divider()

            // Нижняя панель
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                    Text(model.status)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                }

                HStack {
                    Button("Добавить треки…") {
                        openFiles()
                    }
                    Spacer()
                    Text("Space — играть выбранный · Esc — стоп · Delete — удалить")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
        }
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func openFiles() {
        let panel = NSOpenPanel()
        panel.title = "Выберите аудиофайлы"
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.audio]

        if panel.runModal() == .OK {
            model.addTracks(urls: panel.urls)
        }
    }
}
