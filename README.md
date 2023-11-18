# ShoppingList-Project


<p align="center">
    <img src="https://github.com/limsub/ShoppingList-Project/assets/99518799/9e73dd89-edbe-49cf-88a1-5d76d95ac07c" align="center" width="32%">
    <img src="https://github.com/limsub/ShoppingList-Project/assets/99518799/cf269938-4c20-4109-9a6f-43ddeaa5c857" align="center" width="32%">
    <img src="https://github.com/limsub/ShoppingList-Project/assets/99518799/1fff9ce5-2877-47a0-9541-126d460fb6fb" align="center" width="32%">
</p>


# 1. 요구사항 구현
- 네이버 쇼핑 API 활용 상품 검색
- 좋아요 기능 구현 (검색 화면, 좋아요 목록 화면, 상세 화면 동기화)
- Realm 활용 좋아요 목록 데이터베이스 구현


<br>

# 2. 사용 기술
- UIKit, SnapKit (Codebase UI)
- Alamofire, Codable
- WebKit
- Realm
- KingFisher
- NWPathMonitor

<br>

# 3. 구현 환경
- Targeted Device Families : iPhone Only
- iOS Deployment Target : iOS 13.0
- Portrait Only
- dark mode 대응

<br>


# 4. 기능
## 4 - 1. 네트워크 연결 감지
- NetworkMonitor 클래스를 싱글톤 패턴으로 구현하여 사용자의 네트워크 연결 상태를 확인하였다
- AppDelegate의 didFinishLauncingWithOptions에서 감지를 시작한다

<br>

- 연결이 끊겼을 때, 사용자가 네트워크가 필요한 작업을 시도하면 Alert을 띄워준다



<br>

## 4 - 2. Pagination
- 쇼핑 검색 화면에서 상품 30개 기준으로 pagination을 구현하였다
- ```UICollectionViewDataSourcePrefetching``` 프로토콜을 채택하여<br>
prefetch Item의 indexPath를 통해 pagination을 실행한다

<br>

- API의 파라미터 중 검색 시작 위치를 지정하는 ```start```의 최댓값이 100이기 때문에<br>
30개씩 데이터를 불러오면 pagination은 최대 3번 실행될 수 있다
- 초기 ```start```를 1로 지정하고 pagination 실행 시30씩 더해주는 방식으로 진행하였다
- 3번을 실행하고 스크롤을 맨 아래로 내렸을 때는 Alert을 띄워준다

<br>

#### 이슈 : 네트워크 재연결 시 자연스러운 pagination 불가능

- 네트워크가 끊긴 상태에서는 스크롤을 아래로 내려도 데이터를 불러올 수 없기 때문에 pagination이 진행되지 않는다.
- 스크롤이 맨 아래 있는 상태에서 다시 네트워크가 연결된다면, 사용자 입장에서는 자연스럽게 다음 데이터가 로드되는 것을 기대한다
- 하지만 이미 ```prefetchItemAt``` 함수가 모든 셀에 대해 실행되었기 때문에<br>
pagination이 동작하는 함수가 실행되지 않는다.
- 이 경우, 스크롤을 위로 어느 정도 올렸다가 다시 내려야 새로운 데이터를 확인할 수 있다

#### 해결 : Offset Based Pagination 활용
- 위의 특정 경우에 대해서만 offset based pagination 방법을 활용하였다
- 특정 경우 : 스크롤의 위치가 맨 아래, ```prfetchItemAt```은 실행되지 않음, ```start```를 증가시켜서 pagination은 가능한 상황

<br>

- ```UIScrollViewDelegate``` 프로토콜을 채택하여 ```scrollViewDidScroll``` 함수에서  <br>
```contentSize.height```와 ```contentOffset.y```의 차이로 시점을 판단하였다
- 네트워크가 재연결 되어도, 사용자가 살짝만 화면을 스크롤하면 바로 함수가 실행되어서 pagination이 자연스럽게 동작한다


#### 이슈 : scrollViewDidScroll 함수의 연속 호출
- 특정 경우에만 함수가 실행되도록 구상하였는데, 한 번 실행되면 가능한 pagination까지 연속해서 실행되는 이슈가 발생했다.

- 네트워크 통신이기 때문에 셀을 로드하는 데 시간이 걸린다
- 따라서 ```contentSize.height```가 증가하는 시점보다 먼저 함수가 실행되어 <br>여전히 조건을 만족하는 상태이기 때문에 순식간에 pagination이 동작한다


#### 해결 : goEndScoll 변수 추가
- Bool type 변수 ```goEndScroll```을 pagination의 조건에 추가하여 네트워크 통신 시간의 한계를 해결하였다.

<br>

## 4 - 3. 검색 기능 (쇼핑 검색 화면)
- 검색 화면에서의 검색 조건은 searchBar의 검색 버튼을 누른 시점이다
- 따라서 검색 버튼을 누르지 않고 searchBar의 텍스트를 수정해도,<br> 화면에 나타나는 데이터는 기존 검색어를 기반으로 로드되어야 한다

#### 이슈 : 정렬 버튼 클릭 / pagination 시 다른 데이터 로드
- 새로운 데이터를 불러올 때, 검색 파라미터로 그 순간의 searchBar의 텍스트를 넣어주었기 때문에 <br>
사용자가 검색 버튼을 누르지도 않은 키워드에 대한 데이터가 화면에 나타난다

#### 해결 : searchingWord 변수 추가
- 모든 네트워크 통신이 이루어지는 지점에서 검색 파라미터로 searchingWord를 넣어준다
- searchingWord는 검색 버튼을 눌렀을 때만, searchBar의 텍스트로 값이 변경된다

#### 이슈 : 네트워크 재연결 시 다른 검색 데이터
- 네트워크가 끊긴 상황에서 사용자가 검색 버튼을 누르면, Alert이 나타나면서 검색이 불가능함을 알려준다
- 네트워크가 재연결되었을 때 화면에 나타나야 하는 데이터는 <br>
사용자가 검색에 실패한 키워드에 대한 데이터가 아니라,<br>
기존에 검색한 키워드에 대한 데이터라고 판단했다


<br>

- 정렬 버튼은 결국 모든 데이터를 다시 불러오는 작업이기 때문에 큰 문제가 되지 않을 수 있지만,
pagination이 실행될 때 아래에 다른 데이터를 불러오게 되면 상단과 하단에 서로 다른 데이터가 보이기 때문에 치명적인 문제점이 될 수 있다

#### 해결 : searcingWord 업데이트 조건 추가
- 네트워크가 연결된 상태에서만 searcingWord 값이 업데이트되도록 하였다.
- 즉, 네트워크 비연결 상태에서 검색한 키워드는 저장되지 않는다.

<br>

## 4 - 4. 좋아요 기능

### ShoppingCollectionViewCell
- 클로저를 선언하고, 좋아요 버튼이 눌리면 클로저가 실행되게 하였다
- 클로저의 값은 cell을 사용하는 곳에서 정의한다

<br>

### 검색 화면
- indexPath를 기준으로 해당 셀의 데이터(```Shopping``` 타입)를 확인한다
- 좋아요 해제
    1. realm 테이블에서 해당 데이터를 검색한다
    2. 검색한 결과를 그대로 테이블에서 삭제한다
- 좋아요 추가
    1. 현재 가진 데이터(```Shopping``` 타입)를 기반으로, 인스턴스(```LikesTable``` 타입)를 생성한다
    2. 데이터의 이미지 링크(```String```)를 통해 이미지 데이터(```Data```)를 생성하고 새롭게 만든 인스턴스의 프로퍼티로 저장한다
    3. 인스턴스를 테이블에 추가한다

<br>

### 좋아요 목록 화면
- indexPath를 기준으로 해당 셀의 데이터(```LikesTable``` 타입)를 확인한다
- 좋아요 해제
    1. 해당 데이터를 그대로 테이블에서 삭제한다<br>
    PK를 통해 데이터를 삭제하기 때문에 정상적으로 삭제된다

<br>

### 상세 화면
- ```LikesTable``` 타입으로 화면에 나타나는 데이터가 저장된다 (```newProduct```)
    - 이 데이터는 PK를 제외한 다른 값을 계속 클래스 내에서 유지시키는 역할을 한다
- 좋아요 해제 or 추가 시에도 이 데이터는 유지되어야 하기 때문에 새로운 데이터를 생성해서 작업하였다




<br>


- 좋아요 해제
    1. realm 테이블에서 해당 데이터를 검색한다
    2. 검색한 결과를 그대로 테이블에서 제거한다
- 좋아요 추가
    1. 저장된 데이터를 기반으로 인스턴스를 새로 생성한다
        - 기존 데이터와 동일한 타입이기 때문에 이미지 데이터도 바로 선언해준다
    2. 인스턴스를 테이블에 추가한다


<br>

### 네트워크 이슈
- realm에 데이터를 추가하고, 삭제하는 과정은 네트워크와 상관 없기 때문에 문제가 되지 않았지만, 이미지 데이터를 저장하는 방식에서 문제가 생겼다.


- 현재 이미지를 ```Data``` 타입으로 변환해서 테이블에 저장하고 있기 때문에 <br>
이미지를 변환하는 과정에서 네트워크 통신이 되지 않는다면 ```nil``` 값이 저장된다

- 좋아요 목록에서는 테이블에 저장된 데이터들을 그대로 보여주는데,<Br>
이미지가 설정되지 않은(```nil```) 셀은 재사용 메커니즘에 의해 다른 셀의 이미지를 보여주게 된다


- 결과적으로 사용자 입장에서 정상적이지 않은 데이터를 확인하게 된다


#### 해결
- 네트워크가 끊긴 상황에서 좋아요 목록에 추가할 때, Alert을 띄워 이미지는 저장되지 않는 점을 명시한다
- 이미지 데이터 값이 ```nil```일 때, 기본 이미지를 등록해서 다른 이미지가 중복되지 않게 했다.


<br>

- 상세 화면에서 좋아요 기능
    1. 네트워크가 연결된 상태로 들어온 경우
        - 이미지 데이터를 받아왔기 때문에 네트워크가 끊겨도 정상적으로 이미지 저장이 가능하다
    2. 네트워크가 끊긴 상태로 들어온 경우
        - 이미지 데이터를 받아오지 못했기 때문에 네트워크가 연결되어도 이미지 저장을 할 수 없다
        - 사용자에게 Alert으로 상황을 명시한다

<br>


### 좋아요 중복 이슈
- 검색 화면에서 데이터를 좋아요 목록에 추가할 때,<br>
이미지 데이터를 url로부터 변환하는 과정에서 발생하는 시간 때문에<br>
버튼을 누른 시점과 실제로 데이터가 테이블에 추가되는 시점에 어느 정도 차이가 생긴다
- 그래서 좋아요 버튼을 연속으로 빠르게 두 번 클릭하면<br>
좋아요 목록에 해당 제품이 두 개 중복해서 나타나는 것을 확인할 수 있었다.

#### 해결
- 기존에는 좋아요 추가, 해제와 상관없이 먼저 버튼 이미지를 바꾸고 realm 관련 코드를 실행했다.
- 연속으로 두 번 클릭하는 것을 방지하기 위해 좋아요 버튼의 이미지로 조건을 추가했다.<br> 조건문 이후에 버튼 이미지를 바꾸는 코드를 작성하였다


<br>



# 5. 추가 구현

## 5 - 1. tabBar Item 클릭
- 기본 : 화면 전환
- 검색 화면, 좋아요 목록 화면 : 스크롤 시점을 맨 위로 올린다
- 상세 화면 : 이전 화면으로 돌아간다

## 5 - 2. 데이터 없음을 나타내는 view
- 검색 화면 : 검색하지 않았거나, 입력한 키워드에 대한 데이터가 없는 경우 나타난다
- 좋아요 목록 화면 : 입력한 키워드에 맞는 데이터가 없는 경우 나타난다
- 셀 : 이미지 데이터 값이 nil일 때, 이미지에 나타난다
- 상세 화면 : 웹 컨텐츠를 띄우는 데 실패한 경우, 웹뷰가 사라지고 나타난다. 새로고침 버튼을 눌러서 성공하게 되면, 다시 웹뷰가 나타난다

## 5 - 3. 데이터에 검색 키워드 표시
- 검색 화면과 좋아요 목록 화면에서 검색한 키워드에 맞는 데이터가 셀에 나타날 때, <br>
해당 데이터의 title에 포함된 검색 키워드의 폰트를 키워서 사용자가 확인할 수 있게 하였다
- ```NSMutableAttributedString``` 을 활용하였다

## 5 - 4. webView 내 버튼
- 상세 화면의 webView에 뒤로가기, 새로고침, 앞으로 가기 버튼을 생성하였다
- 웹 내에서 화면 이동이 필요한 경우 사용한다
- 네트워크가 끊겨서 화면이 로드에 실패한 후, 네트워크를 재연결하면 새로고침 버튼을 통해 webView를 확인할 수 있다

## 5 - 5. 예외상황 Alert
- 사용자에게 특정 상황에 대한 명시가 필요하다고 판단되는 경우, Alert을 띄워 확인할 수 있게 하였다
- 네트워크 연결이 끊긴 경우
    - 검색 버튼(검색 화면), 정렬 버튼 클릭 시 기능이 불가능함을 명시한다
    - 좋아요 목록 추가 시 이미지 데이터는 저장되지 않음을 명시한다
    - pagination 시도 시 데이터를 불러올 수 없음을 명시한다
- 모든 데이터를 다 불러온 경우
    - 더 이상 불러올 데이터가 없음을 명시한다
- 공백으로만 이루어진 문자열을 검색하는 경우 (검색 화면)
    - 해당 문자열은 검색이 불가능함을 명시한다

<br>


# 6. 회고
### 6 - 1. 이미지 저장 방식
- url을 통해 이미지를 Data 타입으로 변환해서 DB에 저장하는 방식을 이용하였다
- 그래서 디비에 데이터를 추가할 때마다 data 변환을 해야 해서 시간이 소요되었다
- 이 과정은 ```DispatchQueue.global().async``` 를 통해 UI적으로 불편함 없이 진행할 수 있다
- 하지만, 해당 데이터가 필요한 작업이 그 직후에 있으면 어쩔 수 없이 시간적 한계를 받아야 한다

<br>

- 예를 들면 검색 화면에서 셀을 클릭했을 때, 해당 데이터를 ```LikeTables``` 타입으로 변환해서 상세 화면 페이지로 값전달을 해야 한다.
- 이 과정에서 data 변환 후 화면 전환을 해야 하기 때문에 일정 시간 후 다음 화면이 등장한다

<br>

- 이 문제 때문에 셀을 연속으로 빠르게 선택했을 때, 다음 화면이 여러 개 등장하는 이슈가 생긴다

<br>

- 좋아요 버튼도 같은 이슈가 있었고, 이 때는 아예 클릭이 되지 않게 막아버렸다
- 코드적으로 깔끔한 방법은 아니라고 생각한다
- 또한, 중복된 데이터를 방지하기 위해 버튼 기능을 막아버려서, 버튼이 정상적으로 두 번 눌리는 것도 아닌 상태이다
- 즉, 기능적으로도 깔끔한 방법은 아니다

<br>

- UI적으로 불편함이 없게 하는 보다 효율적인 로직을 구상해 봐야겠다

<br>

#### 여러 화면 등장하는 이슈 해결 (9/11)
- 추가적인 시간이 필요한 이유는 이미지 데이터를 불러오는 작업 하나 때문이다
- 그래서 그 외의 작업을 해당 작업보다 먼저 진행시켰다.
- 즉, 화면 전환을 먼저 하고, 나중에 이미지 데이터를 넘겨주는 방식으로 수정했다

<br>

- 결과적으로 빠르게 셀을 클릭했을 때 화면이 여러 번 나타나는 이슈는 해결할 수 있었다.
