import 'package:flutter/material.dart';

class CoinIcon extends StatelessWidget {
  final double size;
  final bool isSelected;

  const CoinIcon({
    super.key,
    this.size = 20,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 1.2,
          colors: isSelected
              ? [
                  const Color(0xFFF72E1E).withValues(alpha: 0.9),
                  const Color(0xFFF72E1E),
                  const Color(0xFFD32F2F),
                ]
              : [
                  const Color(0xFFFFF176), // 浅黄色高光
                  const Color(0xFFFFD54F), // 金黄色
                  const Color(0xFFFF8F00), // 深橙色
                  const Color(0xFFE65100), // 更深的橙色边缘
                ],
          stops: const [0.0, 0.4, 0.8, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.1),
          ),
          BoxShadow(
            color: const Color(0xFFFFD54F).withValues(alpha: 0.3),
            blurRadius: size * 0.1,
            offset: Offset(0, -size * 0.05),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 内圈阴影
          Container(
            margin: EdgeInsets.all(size * 0.1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(0.3, 0.3),
                radius: 0.8,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // 人民币符号
          Center(
            child: Text(
              '¥',
              style: TextStyle(
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Colors.white
                    : Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: Offset(0, size * 0.02),
                    blurRadius: size * 0.05,
                  ),
                ],
              ),
            ),
          ),
          // 高光效果
          Positioned(
            top: size * 0.15,
            left: size * 0.2,
            child: Container(
              width: size * 0.3,
              height: size * 0.15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.1),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}