# Windows 독립망 환경에서 SMB 파일 전송 및 보안 점검 정리

## ✅ 1. 환경 개요

| 항목        | 내용                              |
|-------------|-----------------------------------|
| 네트워크    | 인터넷 차단된 독립망              |
| 운영체제    | Windows OS                         |
| 전송 대상   | 대용량 파일 (예: 40MB 이상)        |
| 도구 제한   | OpenSSH 설치 불가, SFTP 불가       |
| 전송 방식   | SMB 공유 폴더 (`net share`) 사용    |

---

## ✅ 2. 적용한 기술적 조치 (전송 방식)

### 2-1. 보내는 PC - 공유 설정

```powershell
New-Item -Path "C:\FileShare" -ItemType Directory -Force
icacls "C:\FileShare" /grant "Everyone:(OI)(CI)F" /T
cmd /c 'net share FileShare="C:\FileShare" /grant:Everyone,full'
```

### 2-2. 받는 PC - 공유 드라이브 연결

```powershell
net use F: \\192.168.100.10\FileShare /persistent:no
```

### 2-3. 전송 실패 시 대안 (`robocopy`)

```powershell
robocopy "F:\" "C:\Backup" /E /Z /R:2 /W:5
```

| 옵션 | 설명                            |
|------|---------------------------------|
| `/Z` | 중단 복구 가능한 복사           |
| `/E` | 하위 디렉토리 포함              |
| `/R` | 재시도 횟수                      |
| `/W` | 재시도 간격 (초)                |

---

## ✅ 3. 발생한 문제 및 원인

| 증상                       | 원인                                 |
|----------------------------|--------------------------------------|
| 복사 중 세션 끊김          | 탐색기/`copy` 명령의 메모리 한계     |
| 복사 실패, 탐색기 정지     | 버퍼 초과, 세션 타임아웃 발생        |
| 드라이브 연결 성공 후 접근 불가 | 권한/방화벽/세션 불일치 문제 가능성 |

---

## ✅ 4. 보안 관점 분석 및 대응

### 4-1. NetBIOS over TCP/IP의 보안 취약점

- 브로드캐스트로 내부 이름 정보 노출 위험
- SMBv1 사용 가능성 → 랜섬웨어(WannaCry 등)에 취약
- 게스트 계정 또는 익명 접근 가능성
- 세션 하이재킹 및 중간자 공격 가능성
- 불필요한 NetBIOS 포트 개방 (UDP 137, 138 / TCP 139)

---

### 4-2. 보안 설정 권장사항

| 항목                  | 설정 방법                                                  |
|-----------------------|-------------------------------------------------------------|
| NetBIOS 비활성화      | `ncpa.cpl > 어댑터 > 속성 > WINS > NetBIOS 사용 안 함`     |
| SMBv1 제거            | `Set-SmbServerConfiguration -EnableSMB1Protocol $false`    |
| 공유 권한 제한        | `Everyone` 대신 명시 사용자 지정                           |
| 암호 보호 공유 활성화 | `제어판 > 고급 공유 설정 > 암호 보호 공유 켜기`          |
| 방화벽 설정           | TCP 445만 허용, UDP 137-138/TCP 139 차단                    |

---

### 4-3. 고급 보안 조치 (선택)

- SMB 서명 강제 (`RequireSecuritySignature`)
- NTLMv2 인증 강제 (`LMCompatibilityLevel = 5`)
- 공유 접근 이벤트 로깅 활성화 (Event Viewer → 보안 로그)

---

## ✅ 5. 참고 명령어

```powershell
net share                      # 공유 목록 확인
net use                        # 드라이브 연결 확인
Get-NetFirewallRule            # 방화벽 규칙 확인
ipconfig /flushdns             # DNS 캐시 초기화
```

---

## ✅ 6. 요약

이 문서는 인터넷이 차단된 독립망 환경에서 Windows 간 파일 공유(SMB)를 이용한 파일 전송과 그에 따른 보안 리스크, 대응 방안을 포함하여 실무 및 시험 대비용으로 정리된 자료입니다.
