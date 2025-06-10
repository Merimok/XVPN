# 🔧 CI/CD Система XVPN - Руководство по сборке

**Дата:** 10 июня 2025  
**Статус:** ✅ Исправлена и готова к работе  

---

## 🐛 **Решенная проблема**

### **Ошибка:**
```
Run copy sing-box\\sing-box.exe build\\windows\\runner\\Release\\sing-box.exe
The system cannot find the path specified.
0 file(s) copied.
```

### **Причина:**
- Файлы `sing-box.exe` и `wintun.dll` не загружались автоматически в CI/CD
- Команды копирования выполнялись до скачивания зависимостей
- Неправильные пути в командах копирования

---

## ✅ **Реализованные исправления**

### 1. **Автоматическая загрузка sing-box**
```yaml
- name: Download latest sing-box binary
  shell: bash
  run: |
    VERSION=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep '"tag_name":' | cut -d '"' -f4)
    FILE="sing-box-${VERSION#v}-windows-amd64.exe"
    URL="https://github.com/SagerNet/sing-box/releases/download/${VERSION}/${FILE}"
    mkdir -p vpn_client/sing-box
    echo "Downloading $URL..."
    curl -L "$URL" -o "vpn_client/sing-box/sing-box.exe"
```

### 2. **Автоматическая загрузка Wintun**
```yaml
- name: Download Wintun DLL
  shell: bash
  run: |
    echo "Downloading Wintun DLL..."
    curl -L "https://www.wintun.net/builds/wintun-0.14.1.zip" -o wintun.zip
    unzip -q wintun.zip
    mkdir -p vpn_client/sing-box
    cp wintun/bin/amd64/wintun.dll vpn_client/sing-box/wintun.dll
    rm -rf wintun.zip wintun
```

### 3. **Исправленное копирование файлов**
```yaml
- name: Copy dependencies to release folder
  shell: cmd
  working-directory: vpn_client
  run: |
    copy sing-box\sing-box.exe build\windows\runner\Release\sing-box.exe
    if exist sing-box\wintun.dll copy sing-box\wintun.dll build\windows\runner\Release\wintun.dll
```

---

## 🔄 **Workflow архитектура**

### **1. build_windows.yml** - основная сборка
- **Триггер**: Push в main, Pull requests
- **Функции**: 
  - Скачивает sing-box и wintun автоматически
  - Собирает Flutter приложение
  - Копирует зависимости
  - Создает артефакты сборки

### **2. release.yml** - релиз сборка
- **Триггер**: Push тегов v*
- **Функции**:
  - Все из build_windows.yml
  - Создает ZIP архив
  - Публикует GitHub Release
  - Извлекает changelog автоматически

### **3. build.yml** - тестирование
- **Триггер**: Push, Pull requests
- **Функции**:
  - Запускает тесты
  - Проверяет код анализатором
  - Не создает сборку (только валидация)

---

## 📁 **Структура артефактов**

### **После успешной сборки:**
```
build/windows/runner/Release/
├── vpn_client.exe      ✅ Flutter приложение
├── sing-box.exe        ✅ VPN движок (автоскачан)
├── wintun.dll         ✅ Windows TUN драйвер (автоскачан)
├── data/              ✅ Flutter ресурсы
└── *.dll              ✅ Системные библиотеки
```

### **ZIP релиз содержит:**
- Готовое к запуску приложение
- Все необходимые зависимости
- Не требует дополнительных установок

---

## 🚀 **Использование CI/CD**

### **Для разработки (ветка main):**
```bash
git push origin main
# → запускается build_windows.yml
# → создается артефакт windows-build
```

### **Для релиза:**
```bash
git tag -a v1.2.6 -m "Release v1.2.6"
git push origin v1.2.6
# → запускается release.yml  
# → создается GitHub Release с ZIP файлом
```

### **Скачивание результатов:**
1. **Артефакты разработки**: GitHub Actions → build_windows → Artifacts
2. **Релиз файлы**: GitHub Releases → Latest Release → Assets

---

## 🔍 **Диагностика проблем**

### **Если сборка падает:**

1. **Проверить логи GitHub Actions**
2. **Типичные ошибки:**
   - Сеть недоступна (скачивание sing-box/wintun)
   - Flutter зависимости (pub get failed)
   - Ошибки компиляции (dart analyze failed)

3. **Отладка локально:**
```bash
# Проверить доступность sing-box API
curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest

# Проверить доступность Wintun
curl -I https://www.wintun.net/builds/wintun-0.14.1.zip

# Локальная сборка
cd vpn_client
flutter build windows --release
```

---

## 📊 **Статус системы**

### ✅ **Исправлено:**
- Автоматическое скачивание всех зависимостей
- Корректное копирование файлов  
- Правильная структура команд
- Создание полноценных релизов

### 🎯 **Результат:**
- **Полностью автоматическая** сборка Windows приложения
- **Нулевая ручная работа** для создания релизов
- **Готовые к распространению** ZIP файлы
- **Профессиональная** CI/CD система

---

## 📋 **Чек-лист релиза**

### **Перед созданием релиза:**
- ✅ Все тесты проходят
- ✅ Код проанализирован (flutter analyze)
- ✅ Версия обновлена в pubspec.yaml
- ✅ CHANGELOG.md обновлен
- ✅ Commit сообщения правильные

### **Создание релиза:**
```bash
# 1. Обновить версию
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: Update version to v1.2.6"

# 2. Создать тег
git tag -a v1.2.6 -m "Release v1.2.6: Description"

# 3. Отправить
git push origin main
git push origin v1.2.6

# 4. GitHub Actions автоматически:
#    - Соберет приложение
#    - Скачает зависимости  
#    - Создаст GitHub Release
#    - Опубликует ZIP файл
```

---

**✅ CI/CD система XVPN полностью готова и автоматизирована!**

*Обновлено: 10 июня 2025*  
*Статус: Production Ready* 🚀
