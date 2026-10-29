# Teşhis araçları

## .NET
- **EF Core sorguları:** geliştirmede `optionsBuilder.LogTo(Console.WriteLine, LogLevel.Information).EnableSensitiveDataLogging()`; üretilen SQL'i görmek için `query.ToQueryString()`.
- **Çalışan süreç:** `dotnet-counters monitor -p <pid>` (CPU, GC, thread pool), `dotnet-trace collect -p <pid>`, takılma/bellek için `dotnet-dump collect -p <pid>` ve `dotnet-dump analyze`. Araçlar `dotnet tool install -g dotnet-counters` vb. ile kurulur; kurulum onay ister.
- **İstek akışı:** `HttpLogging` ara katmanı (yalnız geliştirme); Serilog/OpenTelemetry varsa trace id ile ilgili kayıtları birleştir.
- **Testte yeniden üretim:** `WebApplicationFactory` ile uç noktayı gerçek ara katmanlarla çağır; veri tabanı farkı şüphesi varsa Testcontainers ile gerçek motor.
- **Bisect:** `git bisect start`, `git bisect bad`, `git bisect good <commit>`, her adımda tek testi çalıştır.

## Flutter
- **Çalışma zamanı hataları:** Dart & Flutter MCP sunucusu kuruluysa `get_runtime_errors`, `get_widget_tree`; değilse `flutter run` çıktısı ve `flutter logs`.
- **Görsel ve yerleşim:** Flutter DevTools (Inspector, Layout Explorer); taşma hatasında `RenderFlex overflowed` satırındaki widget yolunu izle.
- **Performans:** profil modunda çalıştır (`flutter run --profile`), DevTools Performance; debug modda ölçme.
- **Platform:** Android `adb logcat`, iOS Xcode konsolu; izin ve yapılandırma hataları çoğu zaman yalnızca burada görünür.
- **Test:** `flutter test --plain-name "ad"` ile tek testi tekrar tekrar çalıştır; kararsız testte `pumpAndSettle` zaman aşımı ve gerçek zamanlayıcılara bak.
