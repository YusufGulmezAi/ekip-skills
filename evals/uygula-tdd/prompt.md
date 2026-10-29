---
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill, Edit, Write]
---

KusurEndpoints'e kusuru ustlenme ucu ekle: POST /kusurlar/{id}/ustlen. Yalnizca Onaylandi durumundaki kusur ustlenilebilir; degilse Conflict donsun.
