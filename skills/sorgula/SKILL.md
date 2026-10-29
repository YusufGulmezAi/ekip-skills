---
name: sorgula
description: Kod yazmadan önce belirsiz bir isteği, numaralı sorular ve her soruda önerilen bir cevapla netleştirir. USE FOR — kullanıcı bir fikir, özellik veya değişiklik tarif ediyor ama kapsam, davranış, veri modeli ya da sınırlar belli değil; "şöyle bir şey istiyorum", "nasıl yapsak", "bir özellik ekleyelim", "I want to add", "how should we", "design", "plan this" gibi ifadeler; bir istekte iki veya daha fazla makul yorum varsa. DO NOT USE FOR — isteği tek anlamlı ve küçük işler (bunlar doğrudan `uygula`), yazılmış kodun incelenmesi (`incele`).
argument-hint: "[netleştirilecek fikir veya istek]"
---

# Sorgula

Amaç: kodlamaya başlamadan önce kararları netleştirmek. Belirsizlikle yazılan kod, yanlış şeyi doğru yapar ve geri alması pahalıdır. Soruları iyi sorarsan kullanıcı çoğunu "evet" diyerek geçer.

## Yöntem

1. **Önce gerçekleri kendin bul.** Varsa `docs/agent/ogrenimler.md` dosyasını oku; orada cevaplanmış bir şeyi sorma. Sonra kod tabanına, mevcut desenlere, benzer özelliklere bak. Kullanıcıya kodda cevabı olan bir şeyi sorma; bulmak senin işin. Büyük keşif gerekiyorsa alt ajan kullan.
2. **Cepheyi belirle.** Cephe: ön koşulları zaten belli olan ve şu an karar verilebilecek sorular. Henüz karar verilmemiş bir şeye bağlı soruları sonraya bırak.
3. **Cepheyi tek turda sor.** Soruları numarala; her soruya önerdiğin cevabı ve bir cümlelik gerekçesini ekle. Soruyu öyle kur ki "evet" önerini kabul etsin. Tek turda en fazla 5 soru; öncelik sırası: kapsam > güvenlik/veri > kullanıcı deneyimi > teknik ayrıntı.
4. **Cevaplarla yeni cephe açılıyorsa tekrarla.** Açılmıyorsa bitir.
5. **Sonucu yaz.** Aşağıdaki biçimde kısa bir özet ver ve sonraki adımı öner: ekran içeriyorsa `tasarla`, birden fazla katmana dokunuyorsa `planla`, küçükse `uygula`. Geri alması pahalı kararları "karar kaydı adayı" olarak işaretle; `belgele` bunları ADR'ye çevirir. Onay almadan kod, iskelet veya paket kurulumu yapma; bunların hepsi "inşa" sayılır.

## Özet biçimi
- **Amaç:** tek cümle.
- **Kapsam içinde / dışında:** iki kısa liste.
- **Kararlar:** her soru için verilen cevap.
- **Bitti ölçütü:** gözlemlenebilir ve doğrulanabilir bir cümle.
- **Açık kalanlar:** varsa, sonraya bırakılan sorular.

## Örnek soru
> 2. Aidat gecikme faizi günlük mü, aylık mı hesaplansın? **Önerim: günlük**, çünkü mevcut `LateFeeCalculator` günlük oran bekliyor ve değiştirmek üç çağıranı etkiler.
