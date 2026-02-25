Write-Host "Проверка скачивания flutter.zip..."
if (Test-Path "$env:TEMP\flutter.zip") {
    Write-Host "Начинаем распаковку Flutter SDK в C:\ (это может занять несколько минут)..."
    Expand-Archive -Path "$env:TEMP\flutter.zip" -DestinationPath "C:\" -Force
    
    Write-Host "Прописываем Flutter в переменные среды..."
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notmatch "C:\\flutter\\bin") {
        [Environment]::SetEnvironmentVariable("Path", $currentPath + ";C:\flutter\bin", "User")
        Write-Host "Flutter успешно добавлен в систему! Для того, чтобы он заработал, вам нужно ПЕРЕЗАПУСТИТЬ терминал (закрыть это черное окно и открыть заново)."
    } else {
        Write-Host "Flutter уже есть в переменных среды Windows."
    }
} else {
    Write-Host "Файл $env:TEMP\flutter.zip еще не скачался или загрузка оборвалась."
    Write-Host "Пожалуйста, скачайте его вручную с сайта https://flutter.dev и распакуйте в C:\flutter "
}
