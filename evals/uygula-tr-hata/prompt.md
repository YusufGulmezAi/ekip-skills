---
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill, Edit, Write]
---

Billing/LateFeeCalculator.cs içindeki gecikme faizi hesabı yanlış sonuç veriyor: 1000 TL anapara, 0.001 günlük oran ve 10 gün gecikme için 10 TL beklerken 1000 TL çıkıyor. Düzelt.

Input files: Billing/LateFeeCalculator.cs
