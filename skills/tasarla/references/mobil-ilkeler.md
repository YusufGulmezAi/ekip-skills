# Mobil ve tablet ekran ilkeleri

## Küçük bileşenler
- Ekran = küçük, yeniden kullanılan parçaların birleşimi: durum rozeti, sayaç, satır, kart başlığı, segmentli seçici, foto küçük resmi. Her parça kendi dosyasında (≤ 150 satır), kendi dartdoc'u ve widget testiyle.
- Tek bir dev "kart" yerine 3–6 küçük parça yan yana / alt alta. Bir bileşen ekranın üçte birinden fazlasını kaplıyorsa bölünür.
- Parçalar tasarım sisteminden gelir; ekran özel bileşen tanımlamaz, var olanı birleştirir. Yeni parça gerekiyorsa önce tasarım sistemine eklenir.

## Yoğun, dolu ekranlar
- Saha personeli ekranı kaydırmadan görmek ister: ilk ekranda özet (sayaçlar, ilerleme) + çalışılacak liste birlikte. Boş geniş alanlar, dev başlıklar, tek büyük düğme için ayrılmış yarım ekran yok.
- Liste satırı tek satırda üç bilgi taşır (ad · alt bilgi · durum); ikincil bilgi küçük puntoda, gizlenmez.
- Boşluk hiyerarşi için kullanılır, doldurmak için değil: satır içi 8, parçalar arası 12, bölümler arası 16 px. Dokunma hedefi yine ≥ 48 px; yoğunluk satır yüksekliğini düşürür, hedefi değil.
- Tablet yatayda iki/üç panel (liste · detay · medya); telefonda sekmeli veya alt sayfa, asla boş yan alan.

## Canlı ve anlamlı renk
- Durum renkleri doygun ve ayırt edilir: başarı yeşil, sorun kırmızı, bekleyen turuncu/amber, bilgi mavi; her biri hem dolgu (soft) hem metin tonuyla, 4.5:1 kontrast korunarak. Gri üstüne gri, pastel üstüne pastel yok.
- Vurgu rengi tek ve belirgin; birincil eylem ve aktif öğe onu kullanır. Tasarım sisteminin masaüstü tonu çok soluksa "mobil tonu" olarak daha doygun eşdeğerleri tanımlanır ve sisteme eklenir (ezilmez, genişletilir).
- Renk tek başına anlam taşımaz: her durum renk + etiket metni + gerekiyorsa simge.

## Yapay zekâ üretimi görünümünden kaçınma
- Yok: mor-mavi gradyan kahraman alanı, emoji simgeler, her kartta aynı yuvarlatılmış köşe ve gölge, sol kenar şeritli kartlar, her şeyi ortalamak, dev 100vh açılış, "hoş geldiniz" ekranı, lorem ipsum, uydurma istatistik.
- Var: ürünün kendi verisi ve terimleri (daire no, mahal, kriter), gerçek yoğunlukta örnek veri, ekrana özgü en az bir ayrıntı (ör. kriter başına foto sayısı), belirgin ama tutarlı tipografi (iki aile: metin + sayısal mono).
- Her ekranda boş, yükleniyor, hata ve çevrimdışı durumu da tasarlanır; "mutlu yol" tek başına teslim sayılmaz.
