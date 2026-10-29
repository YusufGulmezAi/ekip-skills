# Flutter kontrol listesi

**Kritik adayları**
- Sır veya anahtar uygulama paketine gömülü; `--dart-define` değerleri de paketten çıkarılabilir, sır için uygun değil.
- Yayın derlemesinde `--obfuscate --split-debug-info` yok (uygulama tersine çevrilebilir).
- Platform izni yalnızca Dart tarafında: `Info.plist` / `AndroidManifest.xml` karşılığı eksik.

**Önemli adayları**
- Public sınıf/üyede Türkçe dartdoc yok; İngilizce olmayan sınıf veya dosya adı; kullanıcı metni ARB yerine kodda; parametreli metin `'$x ...'` birleştirmesiyle (ARB yer tutucusu yerine).
- Belirteç `SharedPreferences`'ta; `badCertificateCallback` ile sertifika doğrulaması kapatılmış.
- `await` sonrasında `BuildContext` kullanımı: `use_build_context_synchronously` lint'i susturulmuşsa (`// ignore`) özellikle bak.
- `dispose()` edilmeyen controller, stream aboneliği, animasyon, zamanlayıcı.
- `build()` içinde ağır iş, ağ çağrısı, her yenilemede yeni nesne/future üretimi.
- Büyük listede `ListView(children: ...)` → `ListView.builder`.
- State yönetimi tutarsızlığı: projenin seçili yaklaşımı (Riverpod/Bloc/Provider) dururken karışık `setState`.
- Üretilmiş dosyaların (`*.g.dart`, `*.freezed.dart`) elle düzenlenmesi veya güncellenmeden bırakılması.
- Eskimiş API: `WillPopScope`→`PopScope`, `MaterialStateProperty`→`WidgetStateProperty`, `withOpacity`→`withValues(alpha:)`.

**Öneri**
- Mümkün yerde `const` eksikliği.
- Kütüphanede (`packages/<urun>_ui` / `lib/shared/widgets`) karşılığı olan parçanın ekranda yerel widget olarak yeniden yazılması; bileşen içinde doğrudan renk/boşluk sabiti (token yerine).
- Ekranın üçte birinden büyük tek bileşen; boş geniş alanlar; gri üstüne gri durum rengi; emoji simge (mobil ilkelerine aykırı).
