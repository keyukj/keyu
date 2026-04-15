import 'package:flutter/material.dart';
import '../widgets/report_dialog.dart';

class TopicNantaihangScreen extends StatelessWidget {
  const TopicNantaihangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF4A6741),
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
                    'assets/images/imgc.png',
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
                          '新乡南太行',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '徒步路线',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '挂壁长廊之上，体验红岩步道伴云海的震撼',
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
                      color: const Color(0xFFF3F7F2),
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        left: BorderSide(
                          color: Color(0xFF4A6741),
                          width: 3,
                        ),
                      ),
                    ),
                    child: const Text(
                      '太行山，中国地理版图上最刚烈的一笔。它从北向南绵延四百余公里，像一道巨大的阶梯横亘在华北平原与黄土高原之间。而南太行，正是这道阶梯最险峻、最壮美的段落。新乡，便是走进南太行的最佳入口。',
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
                    '绝壁之上的挂壁长廊',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '南太行最令人震撼的人文景观，莫过于那些凿刻在悬崖绝壁上的挂壁公路。上世纪六七十年代，山里的村民为了打通与外界的联系，用最原始的工具——钢钎和铁锤，一锤一锤地在千仞绝壁上凿出了通道。这些隧道没有图纸，没有机械，全凭血肉之躯与岩石较量，前后历时十余年。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '如今走在挂壁长廊中，阳光从侧面的石窗洒入，脚下是深不见底的峡谷，对面是层层叠叠的山峦。每一个凿痕都是一个故事，每一扇石窗都框住了一幅绝美的画。你会不由自主地放慢脚步，不是因为恐高，而是因为敬畏——敬畏自然的伟力，也敬畏人的意志。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '红岩步道，行走在色彩之上',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '南太行的岩石以红色砂岩为主，亿万年的地质运动将铁元素氧化后沉积在岩层中，赋予了这片山脉独特的赤红底色。沿着红岩步道徒步，脚下是温润的赭红色石板，两侧是刀削般的红色崖壁，头顶偶尔探出几棵倔强的崖柏，整个画面像是一幅浓墨重彩的山水画。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '雨后的红岩步道尤其动人。岩石被水浸润后颜色变得更加深沉饱满，溪水从崖壁上挂下来，形成一道道细长的瀑布。空气中弥漫着泥土和草木的清香，云雾在山谷间缓缓流动，走在其中，恍若置身水墨仙境。而当清晨的第一缕阳光照射到红岩上，整面崖壁会瞬间被点亮，那种金红交织的光芒，是任何滤镜都无法还原的真实之美。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '云海之巅，与天空对话',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '南太行的云海是徒步者最期待的奖赏。由于太行山东侧是华北平原，暖湿气流沿山势抬升，在海拔一千米以上的区域极易形成壮观的云海。清晨登上山脊，脚下是翻涌的白色云浪，远处的山峰像一座座孤岛漂浮在云端，日出的光芒穿透云层，将天地染成金色。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '站在崖边看云海，你会感到一种奇妙的错位——明明是在山顶，却像是站在海边。云浪拍打着岩壁，发出无声的涌动，偶尔一阵风来，云雾会漫过崖顶，将你整个人吞没，几秒后又退去，露出更加清晰的远山。这种与云共舞的体验，是南太行送给每一位徒步者最珍贵的礼物。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    '用脚步丈量山河',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '南太行的徒步路线丰富多样，从半天的轻装短线到三五天的重装穿越，总有一条适合你。无论你是初次尝试户外的新手，还是经验丰富的老驴友，这片山脉都能给你恰到好处的挑战与回馈。每一段上坡都在考验你的体能，每一个转角都可能藏着让你屏住呼吸的风景。',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF333333),
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '背上行囊，走进南太行。让双脚踩在亿万年的红岩之上，让目光穿越翻涌的云海，让心跳和着山风的节奏。在这里，你不是旅游者，而是行走者——用最古老的方式，与最壮美的山河相遇。',
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
