import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onay_provider.dart';

/// Müşavirin onay bekleyen kusurları gördüğü ekran.
class OnayEkrani extends ConsumerWidget {
  const OnayEkrani({super.key});

  static const gerekceler = {
    'EksikFotograf': 'Eksik / yetersiz fotoğraf',
    'YanlisKriter': 'Yanlış kriter',
    'OnemHatali': 'Önem derecesi hatalı',
    'MahalAtlanmis': 'Mahal atlanmış',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kusurlar = ref.watch(onayBekleyenKusurlarProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Onay kutusu')),
      body: kusurlar.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Liste yüklenemedi. Tekrar deneyin.')),
        data: (liste) => liste.isEmpty
            ? const Center(child: Text('Onayınızı bekleyen kusur yok.'))
            : ListView.builder(
                itemCount: liste.length,
                itemBuilder: (context, i) {
                  final k = liste[i];
                  return ListTile(
                    title: Text('${k.daireNo} · ${k.mahal} · ${k.kriter}'),
                    subtitle: Text('Önem: ${k.onem}'),
                    trailing: Wrap(spacing: 8, children: [
                      OutlinedButton(
                        onPressed: () => _geriGonder(context, ref, k.id),
                        child: const Text('Geri gönder'),
                      ),
                      FilledButton(
                        onPressed: () => ref.read(onayServisiProvider).onayla(k.id),
                        child: const Text('Onayla'),
                      ),
                    ]),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _geriGonder(BuildContext context, WidgetRef ref, String id) async {
    final secim = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const ListTile(title: Text('Geri gönderme gerekçesi')),
        for (final e in gerekceler.entries)
          ListTile(title: Text(e.value), onTap: () => Navigator.pop(context, e.key)),
      ]),
    );
    if (secim != null) {
      await ref.read(onayServisiProvider).geriGonder(id, secim);
    }
  }
}
