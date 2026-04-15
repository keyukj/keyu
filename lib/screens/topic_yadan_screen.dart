import 'package:flutter/material.dart';
import '../widgets/report_dialog.dart';

class TopicYadanScreen extends StatelessWidget {
  const TopicYadanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF8B5E3C),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.flag_outlined, color: Colors.white),
                onPressed: () => showReportDialog(context, message: '是否举报该专题页？'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/imgb.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '青海雅丹',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '独特雅丹地貌',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '生态观景、星空露营组合，让旅程充满野趣',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF8F3),
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        left: BorderSide(
                          color: Color(0xFF8B5E3C),
                          width: 3,
                        ),
                      ),
                    ),
                    child: const Text(
                      '在青海的西北角，柴达木盆地的深处，有一片被风雕刻了千万年的大地。这里没有树木，没有河流，只有无尽的风蚀土丘在荒原上列阵而立，像是一座被时间遗忘的城池。这就是青海雅丹——地球上最接近火星表面的地方。',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF555555),
                        height: 1.8,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '风的杰作，时间的雕塑',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '雅丹地貌的形成是一场漫长的对话——风与岩石之间持续了数百万年的低语。湖泊干涸后留下的沉积岩层，在西北风年复一年的吹蚀下，软弱的部分被一点点剥离，坚硬的部分则倔强地留了下来。于是，大自然用最朴素的工具——风和沙，雕刻出了这片令人叹为观止的地质奇观。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '行走在雅丹群中，你会看到形态各异的风蚀土丘：有的像沉睡的巨鲸，有的像远航的舰队，有的像守望的武士。它们在不同的光线下呈现出截然不同的面貌——清晨是温柔的金色，正午是刺目的白，而黄昏时分，整片雅丹被染成深沉的赭红，仿佛大地在燃烧。当地人把这里叫做"魔鬼城"，因为夜晚的风穿过土丘间的缝隙，会发出呜咽般的声响，像是远古的灵魂在诉说着什么。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '荒野中的生态密码',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '看似荒凉的雅丹并非毫无生机。在土丘的背风面，偶尔能看到顽强生长的骆驼刺和红柳，它们的根系深入地下数米，汲取着微薄的水分。偶尔掠过天际的鹰隼，提醒着你这片土地上仍有完整的食物链在运转。春秋季节，成群的候鸟会从这片区域上空飞过，它们以雅丹群落作为迁徙途中的地标，就像古代的旅人依靠星辰辨别方向。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '近年来，当地在保护生态的前提下开辟了观景步道，让旅行者可以近距离感受雅丹的壮美，同时不破坏这片脆弱的地貌。每一步都踩在亿万年的地质记忆上，这种体验是任何人造景观都无法复制的。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '星空下的露营夜',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '如果说白天的雅丹属于风和阳光，那么夜晚的雅丹则完全属于星空。这里远离一切光污染，海拔超过三千米，空气干燥通透，是中国最顶级的观星地之一。当夜幕降临，银河像一条发光的河流横贯天际，繁星密得让人几乎忘记了呼吸。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '在雅丹群落间支起帐篷，躺在睡袋里透过帐篷的天窗仰望星空，你会真切地感受到自己与宇宙之间那种既渺小又亲密的关系。流星不时划过夜空，不需要许愿，光是这一刻的存在本身就已经足够珍贵。篝火在风中摇曳，远处的土丘在星光下呈现出神秘的剪影，整个世界安静得只剩下风声和自己的心跳。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '让旅程充满野趣',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '青海雅丹的魅力在于它的"野"。这里没有精心修剪的花园，没有标准化的旅游设施，有的只是大地最原始的面貌和天空最纯粹的颜色。你需要带上足够的水和食物，需要忍受白天的暴晒和夜晚的寒冷，需要接受风沙偶尔的"问候"。但正是这些不便，让旅行回归了它最本真的意义——走出舒适区，用身体去丈量世界，用感官去接收那些在城市里永远收不到的信号。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '当你站在雅丹的最高处，四周是无边的荒原，头顶是无垠的天空，风从亘古吹来又向未来吹去——那一刻你会明白，真正的旅行不是打卡和拍照，而是让自己成为风景的一部分，哪怕只是短暂的一瞬。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
