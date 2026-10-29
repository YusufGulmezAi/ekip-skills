# `docs/mesajlar.md` şablonu — ortak mesaj anahtarı sözleşmesi

Backend `.resx` ve Flutter ARB aynı anahtarları kullanır; API `code` + `params` döner, istemci kendi dilinde üretir. Yeni anahtar = sözleşme değişikliği (planla, Dalga 1).

```markdown
# Mesaj anahtarları

| Anahtar | Parametreler | tr | en |
|---|---|---|---|
| DefectAssigned | defectNo, contractor | {0} numaralı kusur {1} firmasına atandı | Defect {0} assigned to {1} |
| DefectNotAwaitingApproval | — | Kusur onay beklemiyor | Defect is not awaiting approval |
| OpenDefectsCount | count (çoğul) | Açık kusur yok / 1 açık kusur / {n} açık kusur | No open defects / 1 open defect / {n} open defects |
```
Kurallar: anahtar İngilizce PascalCase; parametre sırası tüm dillerde aynı; çoğul kurallı anahtarlar işaretli; silinen anahtar bir sürüm boyunca "kullanımdan kalktı" notuyla kalır.
