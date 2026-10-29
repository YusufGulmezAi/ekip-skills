# Inceleme bulgulari - PR #44 (KusurEndpoints)

1. **[Kritik]** `KusurEndpoints.cs` - `POST /kusurlar/{id}/onayla` rol kontrolu yapmiyor;
   grup yalnizca RequireAuthorization tasiyor, musavir rolu aranmiyor. Oturum acmis herhangi
   bir kullanici (ornegin taseron) kusuru onaylayabilir.
2. **[Kritik]** `KusurEndpoints.cs` - `GET /kusurlar` kimlik dogrulamasiz, AllowAnonymous
   gibi calisiyor; herkes kusur listesini cekebilir.
3. **[Oneri]** Tum Turkce tip ve uye adlari (KusurDto, GeriGonderIstegi, MapKusurEndpoints...)
   kod-Ingilizce kuralina gore DefectDto, ReturnRequest vb. olarak tum kod tabaninda
   yeniden adlandirilmali.
