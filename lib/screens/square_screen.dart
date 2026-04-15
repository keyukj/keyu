import 'package:flutter/material.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/report_dialog.dart';
import 'post_dynamic_detail_screen.dart';
import 'user_profile_screen.dart';

class SquareScreen extends StatefulWidget {
  const SquareScreen({super.key});

  @override
  State<SquareScreen> createState() => _SquareScreenState();
}

class _SquareScreenState extends State<SquareScreen> {
  final List<Map<String, dynamic>> _posts = [
    {
      'avatar': 'assets/images/tx_a.jpg',
      'nickname': '半个朋友',
      'bio': '亲爱的，这世界在不停开花',
      'following': 35, 'followers': 67, 'totalLikes': 823,
      'time': '2分钟前',
      'location': '江苏省·苏州市',
      'content': '我就知道《中国国家地理》诚不欺我，杂志推荐的游龙湾简直美到无法置信啊！南太行的蓝色眼泪真的绝了！一定要选个天气晴朗的时候来，能见度比较高更加出片',
      'images': [
        'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=400&auto=format&fit=crop',
        'assets/images/img_g.jpg',
      ],
      'likes': 23,
      'comments': 3,
      'commentList': [
        {'name': '禁止表态', 'avatar': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=100&auto=format&fit=crop', 'text': '这个地方太绝了，必须收藏', 'time': '20分钟前'},
        {'name': '地球另一角落', 'avatar': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=100&auto=format&fit=crop', 'text': '请问门票多少钱呀', 'time': '35分钟前'},
        {'name': '靠岸', 'avatar': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=100&auto=format&fit=crop', 'text': '周末就去打卡', 'time': '1小时前'},
      ],
    },
    {
      'avatar': 'assets/images/tx_aa.jpg',
      'nickname': '人间凑数',
      'bio': '少年没有偏旁，自己就是华章',
      'following': 18, 'followers': 42, 'totalLikes': 356,
      'time': '2分钟前',
      'location': '浙江省·杭州市',
      'content': '西安我最最最喜欢的咖啡店出现了！从顺城南路沿着城墙走500m就到了，路过的时候天空下起了小雨，路边的木香花开得正欢',
      'images': [
        'assets/images/img_a.jpg',
      ],
      'likes': 45,
      'comments': 2,
      'commentList': [
        {'name': '取代日落', 'avatar': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=100&auto=format&fit=crop', 'text': '木香花好美啊', 'time': '15分钟前'},
        {'name': '半生', 'avatar': 'https://images.unsplash.com/photo-1432405972618-c6b0cfba8673?q=80&w=100&auto=format&fit=crop', 'text': '这家咖啡店叫什么名字', 'time': '40分钟前'},
      ],
    },
    {
      'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=100&auto=format&fit=crop',
      'nickname': '千逐',
      'bio': '你是世界上最闪耀的存在',
      'following': 52, 'followers': 89, 'totalLikes': 671,
      'time': '15分钟前',
      'location': '云南省·大理市',
      'content': '洱海边骑行真的太舒服了，风吹过来带着湖水的味道，远处的苍山云雾缭绕。停下来在路边的小咖啡馆坐了一下午，什么都不想，就看着湖面发呆，这才是生活该有的样子。',
      'images': [
        'assets/images/img_h.jpg',
        'assets/images/img_i.jpg',
      ],
      'likes': 67,
      'comments': 4,
      'commentList': [
        {'name': '二三', 'avatar': 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?q=80&w=100&auto=format&fit=crop', 'text': '大理真的是治愈系城市', 'time': '10分钟前'},
        {'name': '相对倾向', 'avatar': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=100&auto=format&fit=crop', 'text': '洱海边骑行是什么体验', 'time': '25分钟前'},
        {'name': '非重要角色', 'avatar': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=100&auto=format&fit=crop', 'text': '好想去啊', 'time': '50分钟前'},
        {'name': '卡夫', 'avatar': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=100&auto=format&fit=crop', 'text': '收藏了下次去', 'time': '1小时前'},
      ],
    },
    {
      'avatar': 'assets/images/tx_b.jpg',
      'nickname': '明天见',
      'bio': '所有的约定里，我最喜欢明天见',
      'following': 27, 'followers': 53, 'totalLikes': 492,
      'time': '30分钟前',
      'location': '四川省·成都市',
      'content': '成都的慢生活名不虚传，在人民公园喝了一杯盖碗茶，旁边大爷们在下棋，阳光透过竹叶洒下来，时间好像真的变慢了。晚上去了玉林路的小酒馆，和朋友聊到半夜，这座城市真的让人不想走。',
      'images': [
        'assets/images/img_b.jpg',
      ],
      'likes': 89,
      'comments': 3,
      'commentList': [
        {'name': '坠入', 'avatar': 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?q=80&w=100&auto=format&fit=crop', 'text': '玉林路小酒馆是赵雷那个吗', 'time': '20分钟前'},
        {'name': '海上森林', 'avatar': 'https://images.unsplash.com/photo-1414609245224-afa02bfb3fda?q=80&w=100&auto=format&fit=crop', 'text': '成都真的来了就不想走', 'time': '45分钟前'},
        {'name': '所遇皆真诚', 'avatar': 'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=100&auto=format&fit=crop', 'text': '盖碗茶绝了', 'time': '1小时前'},
      ],
    },
    // 纯文字动态
    {
      'avatar': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=100&auto=format&fit=crop',
      'nickname': '原則之外',
      'bio': '生活里的小角落',
      'following': 41, 'followers': 76, 'totalLikes': 538,
      'time': '45分钟前',
      'location': '湖南省·长沙市',
      'content': '在岳麓山下吃了一碗正宗的米粉，辣得眼泪都出来了但是停不下来。长沙人对吃的执着真的让人佩服，街边随便一家小店都能让你惊艳。明天准备去橘子洲头看日落，期待！',
      'images': <String>[],
      'likes': 34,
      'comments': 2,
      'commentList': [
        {'name': '月未眠', 'avatar': 'https://images.unsplash.com/photo-1473580044384-7ba9967e16a0?q=80&w=100&auto=format&fit=crop', 'text': '长沙米粉yyds', 'time': '30分钟前'},
        {'name': '雾都', 'avatar': 'https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=100&auto=format&fit=crop', 'text': '橘子洲头日落超美的', 'time': '1小时前'},
      ],
    },
    {
      'avatar': 'assets/images/tx_c.jpg',
      'nickname': '丢月亮',
      'bio': '于是我摊开双手 允许一切流走',
      'following': 63, 'followers': 31, 'totalLikes': 287,
      'time': '1小时前',
      'location': '西藏·拉萨市',
      'content': '终于到了布达拉宫脚下，站在广场上仰望的那一刻，所有的疲惫都值了。高反有点严重，头疼了一整天，但心里是满的。藏族阿妈递过来的酥油茶暖到心里，旅行的意义大概就是这些不期而遇的温暖吧。',
      'images': <String>[],
      'likes': 72,
      'comments': 1,
      'commentList': [
        {'name': '说与', 'avatar': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=100&auto=format&fit=crop', 'text': '酥油茶真的暖心', 'time': '2小时前'},
      ],
    },
    {
      'avatar': 'assets/images/tx_cc.jpg',
      'nickname': '山下',
      'bio': '镜头翻转记录自己世界',
      'following': 9, 'followers': 58, 'totalLikes': 745,
      'time': '2小时前',
      'location': '福建省·厦门市',
      'content': '鼓浪屿的小巷子里迷路了半天，结果误打误撞发现了一家超棒的手作甜品店。老板是个退休的音乐老师，店里放着黑胶唱片，猫咪趴在窗台上晒太阳。有时候迷路才是最好的旅行方式。',
      'images': <String>[],
      'likes': 56,
      'comments': 3,
      'commentList': [
        {'name': '棠梨', 'avatar': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=100&auto=format&fit=crop', 'text': '迷路才是旅行的意义', 'time': '1小时前'},
        {'name': '偷喝汽水', 'avatar': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=100&auto=format&fit=crop', 'text': '黑胶唱片好有氛围感', 'time': '2小时前'},
        {'name': '漫漫', 'avatar': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=100&auto=format&fit=crop', 'text': '求地址', 'time': '3小时前'},
      ],
    },
    // 文字+图片动态
    {
      'avatar': 'assets/images/tx_dd.jpg',
      'nickname': '梦境',
      'bio': '盛大且灿烂',
      'following': 74, 'followers': 23, 'totalLikes': 412,
      'time': '3小时前',
      'location': '甘肃省·敦煌市',
      'content': '鸣沙山月牙泉的日落太震撼了，金色的沙丘在夕阳下像是被点燃了一样。骑着骆驼走在沙漠里，耳边只有风声和驼铃声，仿佛穿越回了丝绸之路的年代。',
      'images': [
        'assets/images/img_j.jpg',
        'https://images.unsplash.com/photo-1473580044384-7ba9967e16a0?q=80&w=400&auto=format&fit=crop',
      ],
      'likes': 93,
      'comments': 5,
      'commentList': [
        {'name': '凌晨一点', 'avatar': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=100&auto=format&fit=crop', 'text': '骆驼骑着舒服吗', 'time': '2小时前'},
        {'name': '爱吃螺蛳粉', 'avatar': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=100&auto=format&fit=crop', 'text': '月牙泉太美了吧', 'time': '3小时前'},
        {'name': '桃木', 'avatar': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=100&auto=format&fit=crop', 'text': '丝绸之路的浪漫', 'time': '4小时前'},
        {'name': '知春', 'avatar': 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?q=80&w=100&auto=format&fit=crop', 'text': '日落时分去最好', 'time': '4小时前'},
        {'name': '无尽', 'avatar': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=100&auto=format&fit=crop', 'text': '想去想去', 'time': '5小时前'},
      ],
    },
    {
      'avatar': 'assets/images/tx_e.jpg',
      'nickname': '背影',
      'bio': '自由小狗正在上岛',
      'following': 46, 'followers': 91, 'totalLikes': 603,
      'time': '4小时前',
      'location': '贵州省·荔波县',
      'content': '荔波小七孔真的是人间仙境！水是那种不真实的蓝绿色，像打翻了调色盘一样。走在古桥上听着瀑布的声音，整个人都被治愈了。强烈推荐夏天来，水量大更壮观。',
      'images': [
        'assets/images/img_f.jpg',
      ],
      'likes': 78,
      'comments': 2,
      'commentList': [
        {'name': '夏七安', 'avatar': 'https://images.unsplash.com/photo-1432405972618-c6b0cfba8673?q=80&w=100&auto=format&fit=crop', 'text': '水的颜色也太仙了', 'time': '3小时前'},
        {'name': '低谷有雾', 'avatar': 'https://images.unsplash.com/photo-1439066615861-d1af74d74000?q=80&w=100&auto=format&fit=crop', 'text': '夏天去最好看', 'time': '4小时前'},
      ],
    },
    {
      'avatar': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?q=80&w=100&auto=format&fit=crop',
      'nickname': '人间客',
      'bio': '山有山的錯落我有我的平仄',
      'following': 33, 'followers': 47, 'totalLikes': 189,
      'time': '5小时前',
      'location': '新疆·伊犁州',
      'content': '伊犁的薰衣草花田终于等到了！紫色的花海一望无际，空气里都是甜甜的香味。远处的雪山和蓝天白云搭配在一起，随手一拍就是壁纸级别的照片，新疆真的太美了。',
      'images': [
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=400&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=400&auto=format&fit=crop',
      ],
      'likes': 56,
      'comments': 3,
      'commentList': [
        {'name': '孤单几公里', 'avatar': 'https://images.unsplash.com/photo-1414609245224-afa02bfb3fda?q=80&w=100&auto=format&fit=crop', 'text': '新疆永远的白月光', 'time': '4小时前'},
        {'name': '走向月亮', 'avatar': 'https://images.unsplash.com/photo-1509316785289-025f5b846b35?q=80&w=100&auto=format&fit=crop', 'text': '薰衣草花田太浪漫了', 'time': '5小时前'},
        {'name': '山复尔尔', 'avatar': 'https://images.unsplash.com/photo-1473580044384-7ba9967e16a0?q=80&w=100&auto=format&fit=crop', 'text': '随手一拍都是大片', 'time': '6小时前'},
      ],
    },
    {
      'avatar': 'assets/images/tx_gg.jpg',
      'nickname': '十二',
      'bio': '在细碎里感受生活的温度',
      'following': 21, 'followers': 84, 'totalLikes': 917,
      'time': '6小时前',
      'location': '安徽省·黄山市',
      'content': '宏村的清晨是最美的，薄雾笼罩着南湖，白墙黛瓦的倒影在水面上若隐若现。村口的老樟树下坐着写生的学生，画板上的色彩和眼前的风景一样温柔。徽州的美是骨子里的。',
      'images': [
        'assets/images/img_c.jpg',
      ],
      'likes': 45,
      'comments': 1,
      'commentList': [
        {'name': '潮温不见日', 'avatar': 'https://images.unsplash.com/photo-1519046904884-53103b34b206?q=80&w=100&auto=format&fit=crop', 'text': '徽州的美是骨子里的', 'time': '5小时前'},
      ],
    },
    {
      'avatar': 'assets/images/tx_h.jpg',
      'nickname': '遇见深秋',
      'bio': '好多想要记住的幸福瞬间',
      'following': 57, 'followers': 36, 'totalLikes': 564,
      'time': '8小时前',
      'location': '海南省·三亚市',
      'content': '蜈支洲岛的海水清澈得能看到水下的珊瑚和小鱼，浮潜的时候感觉自己进入了另一个世界。傍晚在沙滩上看日落，天空被染成了橘红色，海风吹着头发，这一刻什么烦恼都没有了。',
      'images': [
        'assets/images/img_d.jpg',
        'assets/images/img_e.jpg',
      ],
      'likes': 89,
      'comments': 4,
      'commentList': [
        {'name': '长夏', 'avatar': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=100&auto=format&fit=crop', 'text': '海水也太清了吧', 'time': '7小时前'},
        {'name': '池鱼', 'avatar': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=100&auto=format&fit=crop', 'text': '浮潜好玩吗', 'time': '7小时前'},
        {'name': '永恒', 'avatar': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=100&auto=format&fit=crop', 'text': '三亚永远不会让人失望', 'time': '8小时前'},
        {'name': '零下见冬', 'avatar': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=100&auto=format&fit=crop', 'text': '日落绝了', 'time': '9小时前'},
      ],
    },
    // 新增纯文字动态
    {
      'avatar': 'assets/images/tx_ee.jpg',
      'nickname': '不解语',
      'bio': '身处泥泞遥看满山花开',
      'following': 82, 'followers': 15, 'totalLikes': 231,
      'time': '10小时前',
      'location': '重庆市·渝中区',
      'content': '重庆的夜景真的名不虚传，站在洪崖洞顶层往下看，万家灯火倒映在嘉陵江上，像是掉进了千与千寻的世界。吃了一顿正宗的九宫格火锅，辣到灵魂出窍但根本停不下来，这座城市的魅力就在于它的热烈和真实。',
      'images': <String>[],
      'likes': 77,
      'comments': 2,
      'commentList': [
        {'name': '打瞌睡', 'avatar': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=100&auto=format&fit=crop', 'text': '重庆夜景绝了', 'time': '9小时前'},
        {'name': '隔在远远乡', 'avatar': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=100&auto=format&fit=crop', 'text': '九宫格火锅是灵魂', 'time': '10小时前'},
      ],
    },
    {
      'avatar': 'https://images.unsplash.com/photo-1546961342-ea5f71b193f3?q=80&w=100&auto=format&fit=crop',
      'nickname': '小爱神',
      'bio': '种自己的花，爱自己的宇宙',
      'following': 14, 'followers': 72, 'totalLikes': 438,
      'time': '12小时前',
      'location': '浙江省·莫干山',
      'content': '在莫干山的民宿里醒来，推开窗就是满眼的竹海和晨雾，空气里都是泥土和青草的味道。下午在山间小路散步，遇到一只野兔从脚边跑过，这种远离城市的宁静感太珍贵了。晚上坐在院子里看星星，突然觉得生活其实可以很简单。',
      'images': <String>[],
      'likes': 63,
      'comments': 1,
      'commentList': [
        {'name': '一只纯纯酱', 'avatar': 'https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?q=80&w=100&auto=format&fit=crop', 'text': '莫干山民宿推荐一下', 'time': '11小时前'},
      ],
    },
    // 新增文字+图片动态
    {
      'avatar': 'assets/images/tx_g.jpg',
      'nickname': '小猫',
      'bio': '羡慕过很多人，但更爱普通的自己',
      'following': 48, 'followers': 63, 'totalLikes': 782,
      'time': '昨天',
      'location': '青海省·茶卡盐湖',
      'content': '茶卡盐湖不愧是天空之镜，湖面像一面巨大的镜子把天空完美倒映出来，分不清哪里是天哪里是地。穿了一条红裙子拍照，效果绝了。建议下午四五点来，光线最好，人也少一些，可以拍到很干净的画面。',
      'images': [
        'https://images.unsplash.com/photo-1439066615861-d1af74d74000?q=80&w=400&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1414609245224-afa02bfb3fda?q=80&w=400&auto=format&fit=crop',
      ],
      'likes': 31,
      'comments': 3,
      'commentList': [
        {'name': '不见浪漫', 'avatar': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=100&auto=format&fit=crop', 'text': '天空之镜名不虚传', 'time': '昨天'},
        {'name': '失约于月光', 'avatar': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=100&auto=format&fit=crop', 'text': '红裙子拍照确实好看', 'time': '昨天'},
        {'name': '溺死的鱼', 'avatar': 'https://images.unsplash.com/photo-1432405972618-c6b0cfba8673?q=80&w=100&auto=format&fit=crop', 'text': '下午去光线最好', 'time': '昨天'},
      ],
    },
  ];

  final Map<int, bool> _likedPosts = {};
  final Map<int, bool> _followedPosts = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 16),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/imgdtbg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('动态', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                SizedBox(height: 4),
                Text('看看大家都去哪里耍了', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _posts.length,
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F0F0)),
              itemBuilder: (context, index) => _buildPostItem(_posts[index], index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post, int index) {
    final images = post['images'] as List<String>;
    final liked = _likedPosts[index] ?? false;
    final likes = post['likes'] as int;
    final imgSize = MediaQuery.of(context).size.width * 0.38;

    final followed = _followedPosts[index] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => PostDynamicDetailScreen(post: post),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像 + 昵称 + 时间 + 关注
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                        user: post,
                        posts: _posts.where((p) => p['nickname'] == post['nickname']).toList(),
                      ),
                    ));
                  },
                  child: Row(
                    children: [
                      AvatarWidget(imageUrl: post['avatar'], name: post['nickname'], size: 40),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post['nickname'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 2),
                          Text(post['time'], style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() { _followedPosts[index] = !followed; });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: followed ? const Color(0xFFF5F5F5) : const Color(0xFFF72E1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!followed) const Icon(Icons.add, color: Colors.white, size: 13),
                        if (!followed) const SizedBox(width: 2),
                        Text(followed ? '已关注' : '关注', style: TextStyle(fontSize: 11, color: followed ? const Color(0xFF999999) : Colors.white, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 正文
            Text(post['content'], style: const TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.6)),
            const SizedBox(height: 10),
            // 图片 1:1
            if (images.length == 1)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(images[0], width: imgSize, height: imgSize),
              )
            else if (images.length >= 2)
              Row(
                children: [
                  SizedBox(
                    width: imgSize,
                    height: imgSize,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImage(images[0]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: imgSize,
                    height: imgSize,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImage(images[1]),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            // 定位
            Row(
              children: [
                const Icon(Icons.location_on, size: 13, color: Color(0xFFF72E1E)),
                const SizedBox(width: 2),
                Text(post['location'], style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A1A), fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 10),
            // 底部操作栏
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showMoreActions(context, index),
                  child: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF999999)),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _likedPosts[index] = !liked;
                      post['likes'] = liked ? likes - 1 : likes + 1;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(liked ? Icons.favorite : Icons.favorite_border, size: 16, color: liked ? const Color(0xFFF72E1E) : const Color(0xFF999999)),
                      const SizedBox(width: 4),
                      Text('${post['likes']}', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF999999)),
                    const SizedBox(width: 4),
                    Text('${post['comments']}', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String url, {double? width, double? height}) {
    if (url.startsWith('http')) {
      return Image.network(url, width: width, height: height, fit: BoxFit.cover,
        loadingBuilder: (c, child, p) => p == null ? child : Container(width: width, height: height, color: const Color(0xFFEEEEEE)),
        errorBuilder: (c, e, s) => Container(width: width, height: height, color: const Color(0xFFEEEEEE)),
      );
    }
    return Image.asset(url, width: width, height: height, fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Container(width: width, height: height, color: const Color(0xFFEEEEEE)),
    );
  }

  void _showMoreActions(BuildContext ctx, int index) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Color(0xFFF72E1E)),
              title: const Text('举报', style: TextStyle(fontSize: 15, color: Color(0xFF1A1A1A))),
              onTap: () { Navigator.pop(context); showReportDialog(ctx); },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Color(0xFF1A1A1A)),
              title: const Text('拉黑', style: TextStyle(fontSize: 15, color: Color(0xFF1A1A1A))),
              onTap: () {
                Navigator.pop(context);
                setState(() { _posts.removeAt(index); });
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('已拉黑该用户')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off, color: Color(0xFF1A1A1A)),
              title: const Text('屏蔽', style: TextStyle(fontSize: 15, color: Color(0xFF1A1A1A))),
              onTap: () {
                Navigator.pop(context);
                setState(() { _posts.removeAt(index); });
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('已屏蔽该用户内容')));
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('取消', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color(0xFF999999))),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
