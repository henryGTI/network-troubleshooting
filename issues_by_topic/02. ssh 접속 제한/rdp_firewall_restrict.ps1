# rdp_firewall_restrict.ps1
# ✅ Windows RDP(3389) 방화벽 설정: 특정 IP만 허용, 그 외 모두 차단

# 🔒 관리자 권한 확인
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "이 스크립트는 관리자 권한으로 실행해야 합니다."
    exit
}

Write-Host "✅ RDP 방화벽 설정 스크립트를 실행합니다..." -ForegroundColor Cyan

# 1️⃣ 기본 RDP 규칙 복원 (방화벽 그룹 활성화)
Write-Host "`n1️⃣ 기본 RDP 규칙 활성화 중..."
Enable-NetFirewallRule -Group "@firewallapi.dll,-28752" -ErrorAction SilentlyContinue

# 2️⃣ 기존 사용자 정의 3389 규칙 제거
Write-Host "`n2️⃣ 기존 사용자 정의 RDP 규칙 제거..."
Get-NetFirewallRule | Where-Object {
    $_.DisplayName -like "*3389*" -and $_.Group -eq $null
} | Remove-NetFirewallRule -ErrorAction SilentlyContinue

# 3️⃣ 3389 포트 전체 차단 규칙 추가
Write-Host "`n3️⃣ 전체 3389 포트 인바운드 차단..."
New-NetFirewallRule `
  -DisplayName "Block_3389_All" `
  -Direction Inbound `
  -Action Block `
  -Protocol TCP `
  -LocalPort 3389 `
  -Profile Any

# 4️⃣ 허용할 IP 목록 정의
$allowedIPs = @(
  "192.168.0.10",
  "192.168.0.11",
  "10.0.0.5",
  "10.0.0.6"
)

# 5️⃣ 각 IP에 대해 인바운드 허용 규칙 생성
Write-Host "`n4️⃣ 지정된 IP만 허용 중..."
$count = 1
foreach ($ip in $allowedIPs) {
    New-NetFirewallRule `
      -DisplayName "Allow_3389_IP_$count" `
      -Direction Inbound `
      -Action Allow `
      -Protocol TCP `
      -LocalPort 3389 `
      -RemoteAddress $ip `
      -Profile Any
    $count++
}

# 6️⃣ 결과 확인 출력
Write-Host "`n📋 허용된 IP 규칙 목록:"
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "Allow_3389_IP_*" } |
  ForEach-Object {
    $af = $_ | Get-NetFirewallAddressFilter
    [PSCustomObject]@{
      Rule        = $_.DisplayName
      IP          = $af.RemoteAddress
      Enabled     = $_.Enabled
      Profile     = $_.Profile
    }
  } | Format-Table -AutoSize

Write-Host "`n🎉 완료! 이제 지정된 IP에서만 RDP(3389) 접속이 가능합니다." -ForegroundColor Green
