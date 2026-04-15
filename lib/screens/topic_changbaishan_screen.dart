import 'package:flutter/material.dart';
import '../widgets/report_dialog.dart';

class TopicChangbaishanScreen extends StatelessWidget {
  const TopicChangbaishanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 顶部大图
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1A3A4A),
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
                    'assets/images/imga.png',
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
                          '吉林长白山',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '火山森林生态',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '邀你走出现代生活的温室，步入冬日之美',
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
          // 正文内容
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 引言
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F9FC),
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        left: BorderSide(
                          color: Color(0xFF1A3A4A),
                          width: 3,
                        ),
                      ),
                    ),
                    child: const Text(
                      '在中国东北的苍茫大地上，长白山如同一位沉默的巨人，以千万年的姿态守望着这片土地。它不仅是一座山，更是一部活着的地质史诗，一片被火山塑造的原始森林王国。',
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
                    '火山之上的生命奇迹',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '长白山是一座休眠火山，最近一次大规模喷发距今已有三百多年。正是这些远古的火山活动，为这片土地铺就了独特的生态基底。火山灰化作肥沃的土壤，熔岩冷却后形成奇特的地貌，而天池——那一汪碧蓝的火山口湖，则成为整座山脉最动人的眼眸。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '从山脚到山顶，长白山呈现出教科书般完美的垂直植被带谱。阔叶林、针阔混交林、针叶林、岳桦林、高山苔原，五个截然不同的生态世界层层叠叠，仿佛大自然用一座山浓缩了从温带到极地的全部风景。走在其中，每上升一百米，便像是穿越了一个纬度，周围的树木、花草、空气的味道都在悄然变化。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    '冬日里的静谧与壮美',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '如果说夏秋的长白山是一幅色彩斑斓的油画，那么冬天的长白山则是一首纯净的诗。大雪覆盖了一切喧嚣，整个世界只剩下黑与白的极简对话。针叶林披上厚厚的雪衣，枝条在重力下弯成优美的弧线，阳光穿过林间缝隙，在雪地上投下细碎的光斑。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '冬日的天池常常被云雾笼罩，偶尔云开雾散的瞬间，你会看到冰封的湖面泛着幽蓝的光，四周的火山岩壁覆满白雪，那种苍凉而圣洁的美，足以让任何语言都显得苍白。山间的温泉在零下三十度的空气中升腾起袅袅白烟，热气与冰雪交融，恍若仙境。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    '森林深处的生灵',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '长白山的原始森林是东北虎、紫貂、梅花鹿等珍稀动物的家园。这里的生态系统保持着难得的完整性，每一棵倒下的古木都会成为苔藓和菌类的温床，每一条溪流都滋养着无数微小的生命。冬天，你或许能在雪地上发现野兔的足迹，或者听到远处啄木鸟敲击树干的清脆声响。这些细微的生命痕迹，提醒着我们：即便在最严酷的季节，大自然的脉搏从未停歇。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    '走出温室，拥抱真实',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '我们习惯了恒温的办公室、四季如春的商场、触手可及的外卖。现代生活像一个精心调控的温室，舒适却也让人逐渐忘记了风的形状、雪的温度、泥土的气息。长白山是一个提醒——提醒我们身体里还住着一个渴望旷野的灵魂。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '当你踩着吱嘎作响的积雪走进长白山的密林，当凛冽的寒风掠过你的面颊，当你抬头望见那些挺立了数百年的古树，你会突然明白：人与自然之间，从来不需要隔着一层玻璃。那些被冰雪打磨过的风景，那些在严寒中依然蓬勃的生命，才是这个世界最真实、最动人的模样。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '长白山在等你。不是在屏幕里，不是在别人的照片中，而是在那片真实的冰雪与森林之间，等你亲自去呼吸、去触摸、去感受。走出温室，步入冬日之美，你会发现——原来寒冷也可以如此温柔。',
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
