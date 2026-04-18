import 'package:flutter/material.dart';

import '../widgets/highlight_card.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 960;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(isCompact: isCompact),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: isCompact ? double.infinity : 620,
                        child: _HeroCopy(theme: theme),
                      ),
                      SizedBox(
                        width: isCompact ? double.infinity : 500,
                        child: const _PreviewPanel(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: const [
                      HighlightCard(
                        title: 'Identidad validada',
                        description:
                            'Cada perfil pasa por revision manual con cedula y foto de perfil.',
                      ),
                      HighlightCard(
                        title: 'Datos bajo consentimiento',
                        description:
                            'Cada usuario decide que informacion personal pone a la venta.',
                      ),
                      HighlightCard(
                        title: 'Monetizacion clara',
                        description:
                            'Puntos, compras internas, wallet de ganancias y auditoria completa.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7A2EFF), Color(0xFFFF4FA3)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Text(
          'Pega2EC',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (!isCompact)
          FilledButton.tonal(
            onPressed: () {},
            child: const Text('Panel admin proximamente'),
          ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0F2),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Perfiles verificados, chat pagado y control admin real',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'La primera base web de Pega2EC ya esta lista para crecer.',
          style: theme.textTheme.displayLarge,
        ),
        const SizedBox(height: 20),
        Text(
          'Este frontend inicia con una estructura modular para construir registro validado, puntos, desbloqueos temporales de datos, chat 1 a 1 pagado y panel administrativo sin rehacer la app despues.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.web),
              label: const Text('MVP web en construccion'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shield_outlined),
              label: const Text('Moderacion centralizada'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF20113A), Color(0xFF5120A8)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 260,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFC2D9), Color(0xFFE8D7FF)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 120,
                        color: Color(0xFF7A2EFF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        '@mary2345',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Chip(label: Text('Serio')),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '27 anos • Quito, Pichincha',
                  style: TextStyle(
                    color: Color(0xFF5F5873),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Busca una relacion seria, valora la honestidad y prefiere perfiles validados.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    Chip(label: Text('Instagram a la venta')),
                    Chip(label: Text('Telefono a la venta')),
                    Chip(label: Text('Chat disponible')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(
                child: _StatTile(label: 'Wallet', value: '124 pts'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatTile(label: 'Ganancias', value: '43 pts'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatTile(label: 'Accesos', value: '18 hoy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
