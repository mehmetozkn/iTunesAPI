# iTunesAPI – App Screenshot Search

iTunes Search API ile `software` araması yapan, sonuçlardaki tüm screenshot'ları indirip grid'de listeleyen UIKit uygulaması.

## Özellikler
- Search bar'lı collection view, yazdıkça arama (0.5 sn debounce)
- Her sonucun `screenshotUrls` içindeki tüm imajlar indirilir
- Aynı anda en fazla **3** indirme (`OperationQueue.maxConcurrentOperationCount = 3`)
- İndirme ve decode arka planda, UI kilitlenmez
- İmaja dokununca büyük hali ayrı bir controller ile present edilir
- Tüm view'lar programatik, layout SnapKit ile
- Clean Swift (VIP) mimarisi
- Unit testler (Swift Testing)
- SnapKit dışında 3rd party kütüphane yok

## Mimari

```
SearchViewController ──► SearchInteractor ──► SearchPresenter
        ▲                    │                       │
        │                    ▼                       │
        │        SearchWorker / ImageDownloadWorker  │
        └──────────────── (weak) ◄───────────────────┘

SearchRouter ──► PreviewViewController
```

| Katman | Görevi |
|---|---|
| `SearchViewController` | Kullanıcı aksiyonları, debounce, collection view |
| `SearchInteractor` | Arama, indirme başlatma/iptal, eski cevapları yoksayma |
| `SearchPresenter` | Mesaj/placeholder gibi ekran kararları, ViewModel üretimi |
| `SearchRouter` | Preview ekranına geçiş |
| `SearchConfigurator` | Parçaları constructor injection ile bağlar |
| `SearchWorker` | Arama isteği (`SearchEndpoint` + `NetworkClient`, `callAsFunction`) |
| `NetworkClient` | Ortak networking katmanı: istek, status kontrolü, decode, main thread'e dönüş |
| `Endpoint` | Bir isteğin tarifi (base URL, path, query); her endpoint küçük bir struct |
| `ImageDownloadWorker` | 3'lü `OperationQueue` + cache kontrolü |
| `ImageInMemoryStorage` | `NSCache` tabanlı in-memory imaj cache'i |

## Alınan Kararlar
- **Debounce (`DispatchWorkItem`)**: Her harfte istek atmamak ve API'nin ~20 istek/dk limitine takılmamak için.
- **Eski isteklerin iptali**: Yeni aramada önceki `dataTask` ve bekleyen indirmeler iptal edilir; geç gelen cevap `term` karşılaştırmasıyla yoksayılır.
- **`OperationQueue` + semaphore**: Operation, indirme bitene kadar bekler; böylece 3'lü sınır gerçekten indirme sayısını sınırlar. Alternatifi KVO'lu asenkron `Operation`.
- **`NSCache`**: Thread-safe, bellek darlığında kendini boşaltır. Kalıcılık gerekirse `URLCache` disk kapasitesi artırılabilir.
- **`preparingForDisplay()`**: İmaj decode'u arka planda yapılır, scroll sırasında takılma olmaz.
- **Base networking katmanı**: Status code kontrolü, decode ve main thread'e dönüş `NetworkClient`'ta bir kez yazıldı; yeni endpoint için sadece `Endpoint`'e uyan bir struct eklenir. Resim indirme JSON olmadığı ve kendi kuyruğu olduğu için bu katmanı kullanmaz.
- **Düz grid**: Tüm screenshot'lar tek listeye düzleştirildi (`asScreenshotURLs()`).
- **Lokalizasyon**: Kullanıcıya görünen tüm metinler `tr.lproj/Localizable.strings` içinde; kodda `Strings.searchTitle.localized()` şeklinde kullanılır. `Strings` enum'u elle yazıldı (R.swift gibi 3rd party yok), her anahtarın çevirisi olduğu unit test ile doğrulanır.

## Gereksinimler
- Xcode 26+, iOS 15.0+
- SnapKit (Swift Package Manager)

## Testler
`⌘U` ile çalıştırılır. Interactor, Presenter, response mapping ve indirme kuyruğu test edilir; bağımlılıklar fake'lerle değiştirilir.
