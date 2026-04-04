import 'package:flutter/material.dart';

import '../../../../app/bahboh_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.08, -0.32),
            radius: 1.1,
            colors: <Color>[
              Color(0xFF16061F),
              Color(0xFF080B13),
              Color(0xFF020307),
            ],
            stops: <double>[0.0, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 860;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    child: compact
                        ? _CompactSplash(constraints: constraints)
                        : const _WideSplash(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CompactSplash extends StatelessWidget {
  const _CompactSplash({required this.constraints});

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: _EnterButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                BahbohRouter.gameRoute,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'BAHBOH',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A glowing bubble puzzle where hidden color sets detonate and the board becomes light.',
          style: TextStyle(
            color: const Color(0xFFD8EFFF).withValues(alpha: 0.82),
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
              maxHeight: 320,
            ),
            child: _EnterableSplashArt(
              onTap: () {
                Navigator.of(context).pushReplacementNamed(
                  BahbohRouter.gameRoute,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _InstructionLine(
                label: 'DISCOVER',
                text: 'the hidden OK sets before the board fills.',
              ),
              const SizedBox(height: 16),
              _InstructionLine(
                label: 'MOVE',
                text: 'the falling bubble before it locks into place.',
              ),
              const SizedBox(height: 16),
              _InstructionLine(
                label: 'SURVIVE',
                text:
                    'the Not OK bubbles by letting matching danger colors annihilate cleanly.',
              ),
              const SizedBox(height: 16),
              _InstructionLine(
                label: 'PLAY',
                text: 'with quick drags, soft drops, and sharp timing.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WideSplash extends StatelessWidget {
  const _WideSplash();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 620,
                maxHeight: 620,
              ),
              child: _EnterableSplashArt(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    BahbohRouter.gameRoute,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 44),
        Expanded(
          flex: 4,
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: _EnterButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          BahbohRouter.gameRoute,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'BAHBOH',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A glowing bubble puzzle where hidden color sets detonate and the board becomes light.',
                    style: TextStyle(
                      color: const Color(0xFFD8EFFF).withValues(alpha: 0.82),
                      fontSize: 18,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 26),
                  _InstructionLine(
                    label: 'DISCOVER',
                    text: 'the hidden OK sets before the board fills.',
                  ),
                  const SizedBox(height: 18),
                  _InstructionLine(
                    label: 'MOVE',
                    text: 'the falling bubble before it locks into place.',
                  ),
                  const SizedBox(height: 18),
                  _InstructionLine(
                    label: 'SURVIVE',
                    text:
                        'the Not OK bubbles by letting matching danger colors annihilate cleanly.',
                  ),
                  const SizedBox(height: 18),
                  _InstructionLine(
                    label: 'PLAY',
                    text: 'with quick drags, soft drops, and sharp timing.',
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EnterableSplashArt extends StatelessWidget {
  const _EnterableSplashArt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Enter Bahboh',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox.expand(
            child: Center(
              child: Image.asset(
                'assets/branding/baboh.gif',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructionLine extends StatelessWidget {
  const _InstructionLine({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 98,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFF83CC),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EnterButton extends StatelessWidget {
  const _EnterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFFF61B4),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
      child: const Text('ENTER BAHBOH'),
    );
  }
}
