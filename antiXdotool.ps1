# Интервал времени для измерений в миллисекундах
$interval = 2000  # Увеличили интервал для точности измерений
# Количество измерений для анализа
$numMeasurements = 10  # Увеличили количество измерений для статистики

# Список для хранения результатов измерений количества введенных символов
$measurements = New-Object System.Collections.Generic.List[int]

# Проверка, существует ли тип UserInputTracker
if (-not ([System.Management.Automation.PSTypeName]'UserInputTracker').Type) {
    # Загрузка необходимых сборок
    Add-Type @"
using System;
using System.Runtime.InteropServices;

public class UserInputTracker {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);

    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }

    public static uint GetIdleTime() {
        LASTINPUTINFO lastInputInfo = new LASTINPUTINFO();
        lastInputInfo.cbSize = (uint)Marshal.SizeOf(lastInputInfo);
        GetLastInputInfo(ref lastInputInfo);

        return ((uint)Environment.TickCount - lastInputInfo.dwTime);
    }
}
"@
}

# Функция для выполнения измерений
function PerformMeasurement {
    # Получаем текущее время начала измерения
    $startTime = Get-Date

    # Переменная для хранения количества введенных символов
    $charCount = 0

    # Состояние клавиш
    $keyStates = @{}

    while ((Get-Date) -lt $startTime.AddMilliseconds($interval)) {
        # Проверяем все возможные клавиши
        for ($vk = 1; $vk -le 254; $vk++) {
            $state = [UserInputTracker]::GetAsyncKeyState($vk)
            if ($state -ne 0) {
                if (-not $keyStates.ContainsKey($vk)) {
                    $keyStates[$vk] = $state
                    $charCount++
                }
            } else {
                if ($keyStates.ContainsKey($vk)) {
                    $keyStates.Remove($vk)
                }
            }
        }
        Start-Sleep -Milliseconds 9  # 10 Уменьшаем частоту чтения, чтобы избежать двойного счета за одно нажатие
    }

    return $charCount
}

# Основной цикл для выполнения измерений
while ($true) {
    # Сбрасываем измерения перед началом нового цикла
    $measurements.Clear()

    for ($i = 0; $i -lt $numMeasurements; $i++) {
        $measurement = PerformMeasurement
        $measurements.Add($measurement)
        Start-Sleep -Milliseconds 5 #50
    }

    # Проверяем, если все измерения равны последнему
    if ($measurements -eq $measurements[0]) {
        # Выводим сообщение о возможной аномалии клавиатурного ввода
        Write-Output "Индекс совпадения за последние $numMeasurements измерений: ($($measurements[0]))"

        # Проверяем значение $measurements[0]
        if ($measurements[0] -gt 20) {
            Write-Output "Хакер Детектед"
        } else {
            Write-Output "Нормальная активность"
        }

        # Обнуляем накопленную статистику
        $measurements.Clear()
    }

    # Пауза перед следующим циклом измерений
    Start-Sleep -Milliseconds 100
}
