---
type: llm
focus: trace
weight: 1
---

Yanıt /bildir uç noktasında HttpClient'ın istek başına using ile oluşturulmasını (soket tükenmesi; IHttpClientFactory önerisi) ve .Result ile senkron beklemeyi (thread-pool tükenmesi) en az Önemli düzeyde bildiriyor.
