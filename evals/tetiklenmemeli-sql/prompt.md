---
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

Şu SQL ne yapıyor, kısaca açıklar mısın: SELECT b.Ad, COUNT(*) FROM Kusurlar k JOIN Bloklar b ON b.Id = k.BlokId WHERE k.Durum = 'Acik' GROUP BY b.Ad;
