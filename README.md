# MacPlayer

Простой аудиоплеер для macOS на SwiftUI.

## Функции

- Плейлист с треками (добавление через кнопку, перетаскиванием файлов в окно или Drag & Drop)
- **Пробел** — запустить выбранный трек
- **Esc** — остановить воспроизведение
- При запуске следующего трека текущий автоматически останавливается
- **Delete** — удалить трек из плейлиста
- Двойной клик по треку — запустить его

## Требования

- macOS 14 (Sonoma) или новее
- Для локальной сборки: Xcode 15+ (или Command Line Tools)

---

## Инструкция: загрузка на GitHub и сборка через GitHub Actions

### Шаг 1. Создайте репозиторий на GitHub

1. Зайдите на https://github.com и войдите в аккаунт.
2. Нажмите **+** → **New repository**.
3. Название, например `MacPlayer`. Тип — Public или Private.
4. **Не** ставьте галочки «Add README» и «.gitignore» (файлы уже есть).
5. Нажмите **Create repository**.

### Шаг 2. Загрузите файлы

**Вариант A — через Терминал (рекомендуется):**

```bash
cd путь/к/папке/MacPlayer
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/ВАШ_ЛОГИН/MacPlayer.git
git push -u origin main
```

При первом `git push` macOS может попросить войти в GitHub. Для пароля используйте **Personal Access Token** (Settings → Developer settings → Personal access tokens), а не обычный пароль.

**Вариант B — через сайт:** в репозитории нажмите **Add file → Upload files**, перетащите всё содержимое папки MacPlayer (включая скрытую папку `.github`) и нажмите **Commit changes**. Скрытые файлы в Finder видны по `Cmd + Shift + .`.

### Шаг 3. Дождитесь сборки

1. Откройте репозиторий на GitHub → вкладка **Actions**.
2. Выберите workflow **Build MacPlayer** и дождитесь зелёной галочки (обычно 3–5 минут).
3. Откройте завершённый запуск, внизу в разделе **Artifacts** скачайте `MacPlayer.zip`.

### Шаг 4. Запуск программы

1. Распакуйте `MacPlayer.zip` — получится `MacPlayer.app`.
2. Перенесите его в «Программы» (по желанию).
3. Так как приложение не подписано Apple, при первом запуске:
   - Нажмите правой кнопкой на `MacPlayer.app` → **Открыть** → **Открыть**.
   - Либо, если macOS пишет, что приложение «повреждено», выполните в Терминале:
     ```bash
     xattr -dr com.apple.quarantine /путь/к/MacPlayer.app
     ```

---

## Локальная сборка (необязательно)

```bash
cd MacPlayer
swift build -c release
```

Исполняемый файл появится в `.build/release/MacPlayer`. Для запуска с окном удобнее собрать `.app` вручную (шаги как в workflow) или открыть папку в Xcode (**File → Open**) и нажать **Run**.

---

## Структура проекта

```
MacPlayer/
├── Package.swift                  # описание Swift-пакета
├── Sources/MacPlayer/
│   ├── MacPlayerApp.swift         # точка входа приложения
│   ├── ContentView.swift          # интерфейс: список треков и панель управления
│   └── PlayerModel.swift          # логика плейлиста и воспроизведения, клавиши
├── packaging/Info.plist           # метаданные .app-бандла
├── .github/workflows/build.yml    # автосборка на GitHub Actions
└── .gitignore
```

## Поддерживаемые форматы

Всё, что понимает AVFoundation на macOS: MP3, AAC/M4A, WAV, AIFF, FLAC (macOS 11+) и др.
