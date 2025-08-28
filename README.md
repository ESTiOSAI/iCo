# AICo: AI Coin Curator

<p align="center"> <img src="docs/images/logo.png" width="200"/> </p> <p align="center"> <b>LLM 기반 코인 초보자를 위한 맞춤 큐레이션 서비스</b><br/> 아이폰과 아이패드 모두에서 최적화된 경험을 제공합니다. </p>

// 아이패드와 폰이 같이 있는 이미지면 좋을 듯

## ✨ Introduction

AICo는 **코인 입문자**를 위한 LLM 기반 큐레이션 서비스입니다.  
온보딩 단계에서 투자 성향을 분석하고, 실시간 시세/커뮤니티 데이터를 가공하여 **사용자 맞춤형 코인 정보**를 제공합니다.

단순한 시세 확인을 넘어,

- 📊 실시간 대시보드
- 🤖 챗봇 기반 Q&A
- 👁️ Vision을 활용한 이미지 인식/비식별화
- 📈 캔들 차트 및 AI 리포트
- 📋 북마크 및 위젯

등을 통해 **실용성과 확장성**을 모두 담았습니다.

---
## 🎨 Features
<table>
<tr>
<td align="center" width="250">
  
### 💈 대시보드  
<img src="docs/images/dashboard.png" width="200"/><br/>
투자 성향 기반 LLM 추천<br/>
커뮤니티 API 데이터로 실시간 동향 제공  

</td>
<td align="center" width="250">

### 🪙 마켓  
<img src="docs/images/market.png" width="200"/><br/>
웹소켓 실시간 코인 시세<br/>
정렬 / 필터링 및 시세 애니메이션  

</td>
<td align="center" width="250">

### 🤖 챗봇  
<img src="docs/images/chatbot.png" width="200"/><br/>
LLM 기반 코인 답변 챗봇<br/>
SSE Client & 에러 처리  

</td>
<td align="center" width="250">

### 👁️ Vision  
<img src="docs/images/vision.png" width="200"/><br/>
Apple Vision 이미지 전처리 / 비식별화<br/>
LLM 필터링 기능  

</td>
</tr>

<tr>
<td align="center" width="250">

### 📈 캔들 차트  
<img src="docs/images/chart.png" width="200"/><br/>
실시간 캔들 차트 구현<br/>
코인별 상세 데이터 가시화  

</td>
<td align="center" width="250">

### 📋 AI 리포트  
<img src="docs/images/report.png" width="200"/><br/>
선택한 코인 기반 리포트 자동 생성<br/>
🤯 문구 추가 예정  

</td>
<td align="center" width="250">

### 🔖 북마크  
<img src="docs/images/bookmark.png" width="200"/><br/>
관심 코인 저장 및 리포트 연동<br/>
PDF / 이미지 내보내기  

</td>
<td align="center" width="250">

### ⚙️ 위젯  
<img src="docs/images/widget.png" width="200"/><br/>
북마크한 코인 시세 확인<br/>
홈 화면에서 빠른 접근  

</td>
</tr>
</table>



## 🛠️ Tech Stack

<p align="center">
<img src="https://img.shields.io/badge/iOS-17-000000?style=flat&logo=apple&logoColor=white"/> <img src="https://img.shields.io/badge/Xcode-16-blue?style=flat&logo=xcode&logoColor=white"/> <img src="https://img.shields.io/badge/Swift-5.10-orange?style=flat&logo=swift&logoColor=white"/> <img src="https://img.shields.io/badge/SwiftUI-000000?style=flat&logo=swift&logoColor=white"/> 
<br><img src="https://img.shields.io/badge/CoreData-FFD700?style=flat"/> <img src="https://img.shields.io/badge/Async/await-1E90FF?style=flat"/> <img src="https://img.shields.io/badge/AsyncAlgorithms-4682B4?style=flat"/> <img src="https://img.shields.io/badge/WebSocket-008080?style=flat"/>
<br><img src="https://img.shields.io/badge/Vision-4B0082?style=flat"/> <img src="https://img.shields.io/badge/Charts-32CD32?style=flat"/>
</p>

## 🧩 Architecture

구조도 추가하기
<p align="center"> <img src="docs/images/architecture.png" width="500"/> </p>

```swift
AICo
├── App                     
│   ├── Resource      
├── Core                  
│   ├── Local (CoreData)     
│   └── Network (HTTP/WebSocket)
│   └── Util
├── Data                   
│   ├── API                
│   └── DB
├── Domain                   
│   ├── Model                
│   └── Interface
├── Features
│   ├── Base
│   ├── Main           
│   ├── Dashboard
│   ├── Market
│   ├── Chatbot
│   ├── Report
└── └── Chart

```


## 🚀 Project Highlights

- ✅ **쓸만한 서비스**로 구현 (실기기 테스트 및 iPad 대응)
    
- ✅ **실용적인 아이패드 최적화** (SplitView / NavigationSplitView)
    
- ✅ **도전적인 기능들** (차트 / 웹소켓 / 무한 캐로셀 / 챗봇)
    
- ✅ **비동기 데이터 흐름 제어** (병렬 처리, 취소, 캐싱, TaskGroup)
    
- ✅ **위젯 지원**
- 
## 🎯 TroubleShooting

<details> <summary>LLM 프롬프트 튜닝 및 파이프라인 설계</summary>
  - LLM 응답의 일관성 부족 문제를 프롬프트 엔지니어링으로 해결 
  - 비동기 API 호출 순서를 제어하여 중복 요청 방지 
  - ![더보기](https://github.com/ESTiOSAI/AICo/edit/dev/README.md)

</details> 

<details> <summary>웹소켓 생명주기 관리</summary> - 백그라운드 전환 시 연결 해제 및 재연결 처리 - `Ping/Pong` 타임아웃 기반으로 안정적인 연결 유지 </details> 

<details> <summary>AsyncStream / AsyncAlgorithm 활용</summary> - 코인 시세 스트리밍을 `AsyncStream`으로 구현 - `AsyncAlgorithms`를 활용해 debounce / throttle 적용 </details> 

<details> <summary>캔들 차트 최적화</summary> - CoreGraphics 기반 성능 최적화 - 수천 개 데이터 처리 시 메모리 최적화 </details> 

<details> <summary>챗봇 스크롤 UX 개선</summary> - 새 메시지 입력 시 자동 스크롤 문제 해결 - SwiftUI List의 offset 제어를 Custom ScrollView로 교체 </details>

<details> <summary>무한 Carousel 구현</summary> - 무한 루프 성능 이슈 해결 (아이템 재사용 / 좌표 리셋) - 애니메이션 끊김 현상 개선 </details>

<details> <summary>Vision, LLM 파이프라인 설계</summary> - 이미지 비식별화 속도 최적화 - 얼굴 탐지 False Positive 최소화 </details> 

<details> <summary>위젯</summary> - `App Group` 기반 데이터 공유 - Background Refresh 시점 조정 </details> 

<details> <summary>아이패드 대응 Navigation / SplitView </summary> - `NavigationSplitView` 사용 - 화면 크기에 따른 동적 레이아웃 분리 </details> 

<details> <summary>네트워크 계층화 (Status Code 핸들링) </summary> - 공통 에러 핸들링 구조 설계 - `Status Code` 별 Retry / Fail 처리 </details> 

<details> <summary>비동기 Task 제어 (cancel, retry, caching, TaskGroup, debounce)</summary> - `TaskGroup`으로 병렬/배치 처리 - cancel, retry, caching, debounce 전략 통합 </details> 

<details> <summary>ImageLoader 최적화</summary> - GIF / JPEG 혼합 처리 시 메모리 최적화 - Prefetch + Cancel + Cache 전략 적용 </details>

## 📁 Architecture

아키텍처 구조도 이미지 그리기
### Structure

## 👥 Contributors

<table> <tr> <td align="center"><img src="docs/members/daehun.png" width="100"/><br/><b>강대훈</b></td> <td align="center"><img src="docs/members/minji.png" width="100"/><br/><b>강민지</b></td> <td align="center"><img src="docs/members/hyunjin.png" width="100"/><br/><b>백현진</b></td> <td align="center"><img src="docs/members/heejai.png" width="100"/><br/><b>서희재</b></td> <td align="center"><img src="docs/members/kangho.png" width="100"/><br/><b>이강호</b></td> <td align="center"><img src="docs/members/jihyun.png" width="100"/><br/><b>장지현</b></td> </tr> </table>
### 회고 한마디 씩

## 📎 Reference

- [Video]()

- [Figma]()

- [BandalArt-KMP](https://github.com/Nexters/BandalArt-KMP)
    
- [Keyme-iOS](https://github.com/leekangho0/keyme-iOS)
    
- [SOPT-iOS](https://github.com/sopt-makers/SOPT-iOS)
    
- [EST2nd4](https://github.com/leekangho0/EST2nd4)
    
- [Bottles_iOS](https://github.com/Nexters/Bottles_iOS)


