# HOTFIX v1.2.10 - PowerShell/Bash Compatibility Fix

## Проблема
GitHub Actions CI/CD workflows падали с ошибкой PowerShell парсера при выполнении bash команд на Windows runners.

### Ошибка:
```
ParserError: C:\a\_temp\d9646580-e067-4245-a979-9491174b63d0.ps1:4
Line |
   4 |  if [ ! -f "windows/CMakeLists.txt" ] || [ ! -d "windows/runner" ]; th …
     |    ~
     | Missing '(' after 'if' in if statement.
Error: Process completed with exit code 1.
```

## Корневая причина
Windows runners в GitHub Actions по умолчанию используют **PowerShell**, но в workflows был написан **bash синтаксис** без указания shell.

### Проблемные команды:
```yaml
run: |
  if [ ! -f "windows/CMakeLists.txt" ] || [ ! -d "windows/runner" ]; then
    # bash синтаксис в PowerShell среде
  fi
```

## Решение
Добавлен явный указатель `shell: bash` для всех steps с bash командами.

### Исправленные workflows:

#### 1. **build_windows.yml**
```yaml
- name: Add Windows platform
  shell: bash  # ← ДОБАВЛЕНО
  run: |
    echo "=== ENSURING WINDOWS PLATFORM ==="
    if [ ! -f "windows/CMakeLists.txt" ] || [ ! -d "windows/runner" ]; then
      flutter create --platforms=windows .
    fi

- name: Build Flutter app (Windows)
  shell: bash  # ← ДОБАВЛЕНО
  run: |
    flutter build windows --release --verbose
    # bash проверки файлов...
```

#### 2. **release.yml**  
```yaml
- name: Add Windows platform (if needed)
  shell: bash  # ← ДОБАВЛЕНО
  run: |
    if [ ! -f "windows/CMakeLists.txt" ] || [ ! -d "windows/runner" ]; then
      flutter create --platforms=windows .
    fi

- name: Build Windows release
  shell: bash  # ← ДОБАВЛЕНО
  run: |
    flutter build windows --release --verbose
    # bash проверки...
```

## Изменённые файлы
- `.github/workflows/build_windows.yml` - Добавлен `shell: bash` для Windows platform и build steps
- `.github/workflows/release.yml` - Добавлен `shell: bash` для Windows platform и build steps  
- `vpn_client/pubspec.yaml` - Обновлена версия до 1.2.10+10
- `CHANGELOG.md` - Добавлены детали исправления

## Техническое объяснение
### Проблема смешанных shell environments:
```
Windows Runner Default: PowerShell
Our Commands: Bash syntax ([ ], ||, &&, etc.)
Result: PowerShell syntax error
```

### Решение с explicit shell:
```yaml
shell: bash  # Принудительное использование bash
run: |
  # Теперь bash команды работают корректно
  if [ -f "file.txt" ]; then
    echo "File exists"
  fi
```

## Ожидаемый результат
### ✅ После исправления:
1. **CI/CD workflows** должны выполняться без синтаксических ошибок
2. **Windows platform creation** должен работать корректно
3. **Flutter build process** должен завершиться успешно
4. **vpn_client.exe** должен быть создан в Release directory

### 🎯 Проверка успешности:
- ✅ Workflow `Add Windows platform` завершается без ошибок
- ✅ Workflow `Build Windows release` создает vpn_client.exe  
- ✅ GitHub Release содержит полноценный архив (~50-70MB)
- ✅ Архив содержит все Flutter файлы и зависимости

## Статус: ГОТОВО К ТЕСТИРОВАНИЮ
- **Версия**: 1.2.10+10
- **Тип**: Критическое исправление shell compatibility  
- **Приоритет**: Высокий
- **Готовность**: 100%

Этот hotfix должен окончательно решить проблемы с созданием vpn_client.exe в GitHub Actions.

---
*Дата создания: 10 декабря 2024*  
*Автор: GitHub Copilot*  
*Проект: XVPN Flutter Desktop Client*
