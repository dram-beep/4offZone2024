#This function is based on code from  https://github.com/winadm/posh/blob/master/scripts/ScreenshotPoSh/PS-Capture-Local-Screen.ps1
$Path = "C:\Users\offzone1\Desktop\hacker\screen2"
# Проверяем, что каталог для хранения скриншотов создан, если нет - создаем его
If (!(test-path $path)) {
New-Item -ItemType Directory -Force -Path $path
}
Add-Type -AssemblyName System.Windows.Forms


while ($true) {
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
# Получаем разрешение экрана
$image = New-Object System.Drawing.Bitmap($screen.Width, $screen.Height)
# Создаем графический объект
$graphic = [System.Drawing.Graphics]::FromImage($image)

$point = New-Object System.Drawing.Point(0, 0)
$graphic.CopyFromScreen($point, $point, $image.Size);
$cursorBounds = New-Object System.Drawing.Rectangle([System.Windows.Forms.Cursor]::Position, [System.Windows.Forms.Cursor]::Current.Size)
# Получаем скриншот экрана
[System.Windows.Forms.Cursors]::Default.Draw($graphic, $cursorBounds)
$screen_file = "$Path\" + $env:computername + "_" + $env:username + "_" + "$((get-date).tostring('yyyy.MM.dd-HH.mm.ss')).png"
# Сохранить скриншот в png файл
$image.Save($screen_file, [System.Drawing.Imaging.ImageFormat]::Png)

# Путь к файлу PNG
$pngFile = "$screen_file"

# Путь к уменьшенной копии изображения
$sampleFile = "sample_image.png"
# Временный файл для хранения результатов
$tempFile = "temp_colors.txt"

try {
    # Команда ImageMagick для создания уменьшенной копии изображения с 10% случайных пикселей
    magick $pngFile -resize 100% -sample 10% $sampleFile

    # Проверка, существует ли файл $sampleFile
    if (-Not (Test-Path $sampleFile)) {
        Write-Error "Не удалось создать уменьшенное изображение."
        exit
    }

    # Команда ImageMagick для извлечения цветов и их частоты из уменьшенного изображения
    magick $sampleFile -format %c histogram:info:- > $tempFile

    # Проверка, существует ли файл $tempFile
    if (-Not (Test-Path $tempFile)) {
        Write-Error "Не удалось создать файл с гистограммой цветов."
        exit
    }
 

 # Чтение, сортировка и выбор топ-7 цветов
$colors = Get-Content $tempFile | ForEach-Object {
    # Пример строки: "  800: (255,0,0) #FF0000 red"
    $line = $_
    if ($line -match '\s+(\d+):\s+\((\d+),(\d+),(\d+)(?:,\d+)?\)\s+#\w+\s+\w+') {
        [PSCustomObject]@{
            Count = [int]$matches[1]
            Color = "$($matches[2]), $($matches[3]), $($matches[4])"
        }
    } else {
        Write-Output "Строка не соответствует ожидаемому формату: $line"
    }
} | Sort-Object Count -Descending

# Проверка наличия цветов
if ($colors.Count -eq 0) {
    Write-Output "Не найдено ни одного цвета."
} else {
    # Вывод результатов
    $colors | ForEach-Object {
      # Write-Output "Color: $($_.Color), Count: $($_.Count)"
    }

    # Исключение цвета с максимальным количеством
    $maxColor = $colors | Select-Object -First 1
  #  Write-Output "Исключен цвет с максимальным количеством: $($maxColor.Color), Count: $($maxColor.Count)"
    $colors = $colors | Where-Object { $_ -ne $maxColor }

    # Проверка наличия оставшихся цветов после фильтрации
    if ($colors.Count -eq 0) {
     #   Write-Output "Все топ-7 цветов имеют одинаковое количество."
    } else {
        # Вывод топ-7 цветов после исключения максимального
        $colors = $colors | Select-Object -First 6

        $colors | ForEach-Object {
          #  Write-Output "Color: $($_.Color), Count: $($_.Count)"
        }

        # Вычисление общего количества для расчета процентного отличия
        $totalCount = ($colors | Measure-Object -Property Count -Sum).Sum

        # Вычисление процентного отличия для оставшихся шести цветов
        $percentages = $colors | ForEach-Object {
            $percent = $_.Count / $totalCount * 100
            [PSCustomObject]@{
                Color = $_.Color
                Count = $_.Count
                Percentage = $percent
            }
        }

        # Вывод результатов процентного отличия
        $percentages | ForEach-Object {
         #   Write-Output "Color: $($_.Color), Count: $($_.Count), Percentage: $($_.Percentage.ToString("0.00"))%"
        }

        # Вычисление и вывод процентного отличия между минимальным и максимальным количеством
        $minCount = $colors | Select-Object -Last 1 -ExpandProperty Count
        $percentDifference = ($maxColor.Count - $minCount) / $maxColor.Count * 100
        Write-Output "Процентное отличие между минимальным и максимальным количеством: $($percentDifference.ToString("0.00"))%"
         # Проверка условия процентного отличия
            if ($percentDifference -lt 8) {
                # Окно "АЛАРМ" при процентном отличии менее 8%
                [System.Windows.Forms.MessageBox]::Show("АЛАРМ", "Внимание!", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Exclamation)
                    }
    }
}



} catch {
    Write-Error "Произошла ошибка: $_"
} finally {
    # Удаление временных файлов
    Remove-Item $screen_file
    if (Test-Path $tempFile) {
        Remove-Item $tempFile
    }
    if (Test-Path $sampleFile) {
        Remove-Item $sampleFile
    }
}

Start-Sleep -Seconds 2
}