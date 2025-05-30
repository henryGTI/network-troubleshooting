### 🔐 RDP 포트(3389) 특정 IP만 허용하는 Windows 방화벽 설정 스크립트

### 📁 목적

Windows 시스템에서 RDP(Remote Desktop Protocol, TCP 3389 포트)를 사용할 때,  
**보안 강화를 위해 특정 IP에서만 접속을 허용하고 나머지는 차단**하기 위한 자동화 스크립트를 제공합니다.

---

### ✅ 기능 요약

- ✅ 기본 RDP 방화벽 규칙 활성화
- ✅ 기존 사용자 정의 3389 관련 규칙 제거
- ✅ 3389 포트 전체 차단
- ✅ 지정한 IP만 인바운드 연결 허용
- ✅ 결과 확인용 요약 출력

---

### 🛠️ 사용 방법

### 1. 스크립트 다운로드 또는 복사

스크립트 파일명: `rdp_firewall_restrict.ps1`

> 📎 이 저장소의 [`rdp_firewall_restrict.ps1`](./rdp_firewall_restrict.ps1) 파일을 다운로드하거나 복사하세요.

---

### 2. 관리자 권한 PowerShell 실행

```powershell
Start-Process powershell -Verb runAs
```

3. 스크립트 실행
```powershell
cd [스크립트 경로]
.\rdp_firewall_restrict.ps1
```

🧾 스크립트 주요 로직 요약
단계	내용
1️⃣	RDP 기본 방화벽 규칙 활성화
2️⃣	기존 3389 관련 사용자 정의 규칙 제거
3️⃣	모든 IP에 대해 3389 포트 인바운드 차단
4️⃣	지정된 IP(4개 예시)만 인바운드 허용
5️⃣	결과 요약 출력

💡 허용할 IP는 $allowedIPs 배열에서 수정 가능합니다.

```powershell
$allowedIPs = @("192.168.0.10", "192.168.0.11", "10.0.0.5", "10.0.0.6")

```

🧪 테스트 방법
포트 열림 테스트 (원격지 PC)
```
powershell
Test-NetConnection -ComputerName [서버 IP] -Port 3389
TcpTestSucceeded : True → 성공

False → 방화벽 차단 또는 IP 미허용
```
⚠️ 주의 사항
반드시 관리자 권한 PowerShell에서 실행해야 함

방화벽 설정은 시스템 보안에 영향을 줄 수 있으므로 주의하여 조작

조직 환경에서는 GPO나 타 보안 솔루션과의 충돌 가능성 확인

📜 참고 명령어
```powershell
# 현재 접속 중인 IP 확인
Get-NetTCPConnection -LocalPort 3389

# 허용 규칙 목록 확인
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "Allow_3389_IP_*" }

# 방화벽 상태 확인
Get-NetFirewallProfile
```

📌 파일 목록
파일명	설명
rdp_firewall_restrict.ps1	RDP 포트 제한 스크립트
README.md	설명 문서

🏷️ 태그
#WindowsFirewall #PowerShell #RDP #Security #3389 #RemoteDesktop
