# 공유 생성 스크립트 - 보내는 쪽 (보안 적용 포함)
New-Item -Path "C:\FileShare" -ItemType Directory -Force
icacls "C:\FileShare" /grant "Everyone:(OI)(CI)F" /T
cmd /c 'net share FileShare="C:\FileShare" /grant:Everyone,full'

# 방화벽 포트 허용
New-NetFirewallRule -DisplayName "Allow SMB TCP 445" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Allow
New-NetFirewallRule -DisplayName "Allow NetBIOS TCP 139" -Direction Inbound -Protocol TCP -LocalPort 139 -Action Allow
New-NetFirewallRule -DisplayName "Allow NetBIOS UDP 137" -Direction Inbound -Protocol UDP -LocalPort 137 -Action Allow
New-NetFirewallRule -DisplayName "Allow NetBIOS UDP 138" -Direction Inbound -Protocol UDP -LocalPort 138 -Action Allow

# 암호 보호 공유 설정 권고 (수동 설정)
# 제어판 > 고급 공유 설정 > 암호 보호 공유 켜기

# 받는 쪽 드라이브 연결 스크립트 (F 드라이브 예시)
$remoteIP = "192.168.100.10"
$driveLetter = "F:"
$sharePath = "\\$remoteIP\FileShare"
net use $driveLetter $sharePath /persistent:no

# robocopy 사용 예시 (대용량 복사 안정화)
robocopy "$driveLetter\" "C:\Backup" /E /Z /R:2 /W:5
