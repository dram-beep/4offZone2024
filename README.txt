README
These are additional materials for the presentation at OFFZONE2024 (https://offzone.moscow/). The materials are intended for informational and educational purposes and are not meant for use in production environments and/or systems not owned by you.

File Descriptions:

transfer.ps1 - Script for automating file transfer using xdotool.exe
antiXdotool.ps1 - Script for detecting the use of xdotool to copy files to a remote server. This is a concept and is not intended for use in production environments.
antiRAT.ps1 - Script for detecting the use of rat.exe to copy files from a remote server to your host. This is a concept and is not intended for use in production environments.

Videos:
transfer.mkv - Demonstration of using transfer.ps1 and RAT.exe to copy files between a remote RDP server and your host. Bypasses file copy restrictions when working with RDP.
antiXdotool.mkv - Demonstration of using antiXdotool.ps1 to detect the use of xdotool.exe for copying confidential data from a remote RDP server to a local host.
antiRAT.mkv - Demonstration of using antiRAT.ps1 to detect the use of RAT.exe for copying confidential data from a remote RDP server to a local host.

Additional Links:

For transfer.ps1 to work:
https://github.com/ebranlard/xdotool-for-windows
https://github.com/ebranlard/wmctrl-for-windows

For RAT to work:
https://github.com/pentestpartners/PTP-RAT/tree/master

For antiRAT.ps1 to work:
https://imagemagick.org/script/download.php#windows

The code for the screenshot function was used from:
https://github.com/winadm/posh/blob/master/scripts/ScreenshotPoSh/PS-Capture-Local-Screen.ps1
