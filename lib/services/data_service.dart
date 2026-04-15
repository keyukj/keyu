import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../models/topic.dart';
import '../models/article.dart';
import '../models/comment.dart';

class DataService {
  static const String _postsKey = 'posts';
  static const String _usersKey = 'users';
  static const String _topicsKey = 'topics';
  static const String _articlesKey = 'articles';
  static const String _currentUserKey = 'current_user';
  static const String _commentsKey = 'comments';
  static const String _coinBalanceKey = 'coin_balance';

  // 获取所有帖子
  static Future<List<Post>> getPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString(_postsKey);
    
    if (postsJson == null) {
      // 返回默认数据
      final defaultPosts = _getDefaultPosts();
      await savePosts(defaultPosts);
      return defaultPosts;
    }
    
    final List<dynamic> postsList = json.decode(postsJson);
    return postsList.map((json) => Post.fromJson(json)).toList();
  }

  // 获取关注页面的帖子
  static Future<List<Post>> getFollowingPosts() async {
    return _getFollowingPosts();
  }

  // 获取发现页面的帖子
  static Future<List<Post>> getDiscoverPosts() async {
    return _getDiscoverPosts();
  }

  // 保存帖子
  static Future<void> savePosts(List<Post> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = json.encode(posts.map((post) => post.toJson()).toList());
    await prefs.setString(_postsKey, postsJson);
  }

  // 获取话题
  static Future<List<Topic>> getTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final topicsJson = prefs.getString(_topicsKey);
    
    if (topicsJson == null) {
      final defaultTopics = _getDefaultTopics();
      await saveTopics(defaultTopics);
      return defaultTopics;
    }
    
    final List<dynamic> topicsList = json.decode(topicsJson);
    return topicsList.map((json) => Topic.fromJson(json)).toList();
  }

  // 保存话题
  static Future<void> saveTopics(List<Topic> topics) async {
    final prefs = await SharedPreferences.getInstance();
    final topicsJson = json.encode(topics.map((topic) => topic.toJson()).toList());
    await prefs.setString(_topicsKey, topicsJson);
  }

  // 获取文章
  static Future<List<Article>> getArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final articlesJson = prefs.getString(_articlesKey);
    
    if (articlesJson == null) {
      final defaultArticles = _getDefaultArticles();
      await saveArticles(defaultArticles);
      return defaultArticles;
    }
    
    final List<dynamic> articlesList = json.decode(articlesJson);
    return articlesList.map((json) => Article.fromJson(json)).toList();
  }

  // 保存文章
  static Future<void> saveArticles(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final articlesJson = json.encode(articles.map((article) => article.toJson()).toList());
    await prefs.setString(_articlesKey, articlesJson);
  }

  // 获取当前用户
  static Future<User> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson == null) {
      final defaultUser = _getDefaultUser();
      await saveCurrentUser(defaultUser);
      return defaultUser;
    }
    
    return User.fromJson(json.decode(userJson));
  }

  // 保存当前用户
  static Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, json.encode(user.toJson()));
  }

  // 获取金币余额
  static Future<int> getCoinBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinBalanceKey) ?? 1250; // 默认余额1250
  }

  // 保存金币余额
  static Future<void> saveCoinBalance(int balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinBalanceKey, balance);
  }

  // 增加金币余额
  static Future<void> addCoins(int amount) async {
    final currentBalance = await getCoinBalance();
    await saveCoinBalance(currentBalance + amount);
  }

  // 扣除金币余额
  static Future<bool> deductCoins(int amount) async {
    final currentBalance = await getCoinBalance();
    if (currentBalance >= amount) {
      await saveCoinBalance(currentBalance - amount);
      return true;
    }
    return false;
  }

  // 关注页面的帖子数据
  static List<Post> _getFollowingPosts() {
    return [
      Post(
        id: 'follow_1',
        imageUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=400&auto=format&fit=crop',
        title: '瑞士的夏天是宫崎骏的童话世界吧 🇨🇭',
        username: '小雪Yuki',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 48,
        tags: ['#瑞士', '#童话世界', '#夏天'],
        description: '在瑞士的阿尔卑斯山脚下，每一个角落都像是从宫崎骏电影里走出来的场景。绿色的草地，清澈的湖水，还有远山如黛...',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 'follow_2',
        imageUrl: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?q=80&w=400&auto=format&fit=crop',
        title: '圣托里尼的蓝白梦境 💙',
        username: '旅行摄影师Alex',
        userAvatar: 'assets/img/头像男1.jpg',
        likes: 62,
        tags: ['#希腊', '#圣托里尼', '#蓝白建筑'],
        description: '爱琴海的风轻抚过脸庞，蓝白相间的建筑在夕阳下闪闪发光。这里是每个人心中的浪漫天堂。',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Post(
        id: 'follow_3',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=400&auto=format&fit=crop',
        title: '桂林山水甲天下 🏔️',
        username: '山水画师老李',
        userAvatar: 'assets/img/头像男2.jpg',
        likes: 89,
        tags: ['#桂林', '#山水', '#中国风'],
        description: '漓江的水清澈见底，两岸的山峰如诗如画。坐在竹筏上，感受千年不变的山水情怀。',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Post(
        id: 'follow_4',
        imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=400&auto=format&fit=crop',
        title: '森林小屋的治愈时光 🏡',
        username: '森林系女孩Emma',
        userAvatar: 'assets/img/头像女2.jpg',
        likes: 56,
        tags: ['#森林', '#小屋', '#治愈', '#慢生活'],
        description: '远离城市的喧嚣，在森林深处找到这间小屋。每天醒来都能听到鸟儿的歌声，这就是我想要的生活。',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Post(
        id: 'follow_5',
        imageUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?q=80&w=400&auto=format&fit=crop',
        title: '东京夜色迷人眼 🌃',
        username: '东京漫步者Ken',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 75,
        tags: ['#东京', '#夜景', '#霓虹灯'],
        description: '涩谷的十字路口，新宿的霓虹灯，东京的夜晚总是那么迷人。每一盏灯都诉说着这座城市的故事。',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      Post(
        id: 'follow_6',
        imageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?q=80&w=400&auto=format&fit=crop',
        title: '普罗旺斯的紫色浪漫 💜',
        username: '薰衣草少女Lily',
        userAvatar: 'assets/img/头像女3.jpg',
        likes: 95,
        tags: ['#普罗旺斯', '#薰衣草', '#法国', '#浪漫'],
        description: '六月的普罗旺斯，薰衣草花田一望无际。紫色的海洋在微风中轻舞，空气中弥漫着淡淡的花香。',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Post(
        id: 'follow_7',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=400&auto=format&fit=crop',
        title: '泰国清迈的天灯节 🏮',
        username: '东南亚文化探索者',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 127,
        tags: ['#泰国', '#清迈', '#天灯节', '#传统文化'],
        description: '万盏天灯同时升空的那一刻，整个夜空都被点亮了。每一盏灯都承载着人们最美好的愿望，飘向远方。',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      ),
      Post(
        id: 'follow_8',
        imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=400&auto=format&fit=crop',
        title: '318国道上的诗与远方 🛣️',
        username: '公路旅行家Sam',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 89,
        tags: ['#318国道', '#公路旅行', '#西藏'],
        description: '从成都到拉萨，2000多公里的路程，每一个转弯都是不同的风景。这条路，承载着太多人的梦想。',
        createdAt: DateTime.now().subtract(const Duration(hours: 16)),
      ),
      // 新增6条关注页面动态
      Post(
        id: 'follow_9',
        imageUrl: 'https://images.unsplash.com/photo-1519904981063-b0cf448d479e?q=80&w=400&auto=format&fit=crop',
        title: '巴厘岛的日出瑜伽 🧘‍♀️',
        username: '瑜伽导师Maya',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 67,
        tags: ['#巴厘岛', '#瑜伽', '#日出', '#身心灵'],
        description: '在巴厘岛的海边迎接第一缕阳光，伴随着海浪声练习瑜伽。这是身心灵最完美的结合。',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      Post(
        id: 'follow_10',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=400&auto=format&fit=crop',
        title: '黄山云海奇观 ☁️',
        username: '云海摄影师老张',
        userAvatar: 'assets/img/头像男2.jpg',
        likes: 103,
        tags: ['#黄山', '#云海', '#奇观', '#摄影'],
        description: '凌晨四点爬上黄山，只为等待这一刻的云海奇观。当云雾缭绕在山峰间，仿佛置身仙境。',
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      Post(
        id: 'follow_11',
        imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=400&auto=format&fit=crop',
        title: '挪威峡湾的极光夜 🌌',
        username: '极光猎人Nordic',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 128,
        tags: ['#挪威', '#峡湾', '#极光', '#夜空'],
        description: '在挪威的峡湾里等待极光的出现，当绿色的光带在夜空中舞动，整个世界都安静了下来。',
        createdAt: DateTime.now().subtract(const Duration(hours: 22)),
      ),
      Post(
        id: 'follow_12',
        imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=400&auto=format&fit=crop',
        title: '撒哈拉的星空露营 ⭐',
        username: '沙漠游牧者Sahara',
        userAvatar: 'assets/img/头像男1.jpg',
        likes: 94,
        tags: ['#撒哈拉', '#沙漠', '#星空', '#露营'],
        description: '在撒哈拉沙漠的深处搭起帐篷，夜晚的星空如钻石般闪烁。这里是地球上最接近宇宙的地方。',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Post(
        id: 'follow_13',
        imageUrl: 'https://images.unsplash.com/photo-1500622944204-b135684e99fd?q=80&w=400&auto=format&fit=crop',
        title: '冰岛蓝湖温泉体验 🌊',
        username: '北欧旅行达人Ice',
        userAvatar: 'assets/img/头像女3.jpg',
        likes: 86,
        tags: ['#冰岛', '#蓝湖', '#温泉', '#治愈'],
        description: '在冰岛的蓝湖温泉里泡澡，周围是火山岩和苔藓，这种对比强烈的美让人难以忘怀。',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      Post(
        id: 'follow_14',
        imageUrl: 'https://images.unsplash.com/photo-1433086966358-54859d0ed716?q=80&w=400&auto=format&fit=crop',
        title: '加拿大枫叶季的浪漫 🍁',
        username: '枫叶摄影师Maple',
        userAvatar: 'assets/img/头像女2.jpg',
        likes: 112,
        tags: ['#加拿大', '#枫叶', '#秋天', '#浪漫'],
        description: '十月的加拿大，满山的枫叶如火如荼。走在枫叶飘落的小径上，每一步都踩在诗意里。',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      ),
      // 再新增6条关注页面动态
      Post(
        id: 'follow_15',
        imageUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=400&auto=format&fit=crop',
        title: '马丘比丘的神秘日出 🌄',
        username: '印加文明探索者',
        userAvatar: 'assets/img/头像男1.jpg',
        likes: 156,
        tags: ['#马丘比丘', '#秘鲁', '#印加文明', '#日出'],
        description: '站在失落之城的废墟上，看着第一缕阳光照亮安第斯山脉。这里承载着千年的历史与神秘。',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      ),
      Post(
        id: 'follow_16',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=400&auto=format&fit=crop',
        title: '泰山日出的壮观 ⛰️',
        username: '五岳摄影师',
        userAvatar: 'assets/img/头像男2.jpg',
        likes: 89,
        tags: ['#泰山', '#日出', '#五岳', '#登山'],
        description: '会当凌绝顶，一览众山小。在泰山之巅看日出，感受古人诗句中的豪迈情怀。',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      ),
      Post(
        id: 'follow_17',
        imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=400&auto=format&fit=crop',
        title: '新疆天山的雪莲花 🌸',
        username: '高原植物学家',
        userAvatar: 'assets/img/头像女3.jpg',
        likes: 74,
        tags: ['#新疆', '#天山', '#雪莲花', '#高原'],
        description: '在海拔4000米的天山深处，终于找到了传说中的雪莲花。它的纯洁与坚韧让人敬畏。',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
      ),
      Post(
        id: 'follow_18',
        imageUrl: 'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?q=80&w=400&auto=format&fit=crop',
        title: '澳洲大堡礁的海底世界 🐠',
        username: '潜水教练Coral',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 132,
        tags: ['#澳洲', '#大堡礁', '#潜水', '#海洋'],
        description: '潜入大堡礁的怀抱，与五彩斑斓的珊瑚和热带鱼共舞。这里是地球上最美的海底花园。',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      ),
      Post(
        id: 'follow_19',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=400&auto=format&fit=crop',
        title: '华山论剑的豪情 ⚔️',
        username: '武侠迷老李',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 67,
        tags: ['#华山', '#武侠', '#险峰', '#豪情'],
        description: '站在华山之巅，想象着金庸笔下的华山论剑。这里的每一块石头都充满了江湖气息。',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 14)),
      ),
      Post(
        id: 'follow_20',
        imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=400&auto=format&fit=crop',
        title: '阿拉斯加的野生动物 🐻',
        username: '野生动物摄影师Bear',
        userAvatar: 'assets/img/头像女2.jpg',
        likes: 198,
        tags: ['#阿拉斯加', '#野生动物', '#棕熊', '#自然'],
        description: '在阿拉斯加的原野上，与棕熊不期而遇。这一刻，我们都是大自然的孩子。',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 16)),
      ),
    ];
  }

  // 发现页面的帖子数据
  static List<Post> _getDiscoverPosts() {
    return [
      Post(
        id: 'discover_1',
        imageUrl: 'https://images.unsplash.com/photo-1506929562872-bb421503ef21?q=80&w=400&auto=format&fit=crop',
        title: '马尔代夫的水上天堂 🏝️',
        username: '海岛控小美',
        userAvatar: 'assets/img/头像女2.jpg',
        likes: 92,
        tags: ['#马尔代夫', '#海岛', '#度假'],
        description: '清澈的海水，洁白的沙滩，还有那些建在水上的小屋。马尔代夫就是现实版的天堂。',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Post(
        id: 'discover_2',
        imageUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=400&auto=format&fit=crop',
        title: '印度泰姬陵的永恒之美 🕌',
        username: '古建筑摄影师Taj',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 156,
        tags: ['#印度', '#泰姬陵', '#古建筑', '#世界遗产'],
        description: '月光下的泰姬陵如梦如幻，这座爱情的纪念碑见证了沙贾汗对妻子永恒的爱。白色大理石在不同光线下呈现出不同的美。',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Post(
        id: 'discover_3',
        imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=400&auto=format&fit=crop',
        title: '亚马逊雨林探秘 🌿',
        username: '丛林探险者Tom',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 21,
        tags: ['#亚马逊', '#雨林', '#探险'],
        description: '深入地球之肺，探索最原始的自然世界。每一步都充满未知和惊喜。',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 'discover_4',
        imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=400&auto=format&fit=crop',
        title: '新西兰南岛的纯净之美 🗻',
        username: '纯净新西兰Anna',
        userAvatar: 'assets/img/头像女3.jpg',
        likes: 82,
        tags: ['#新西兰', '#南岛', '#纯净'],
        description: '库克山的雪峰，米尔福德峡湾的壮美，新西兰南岛就是大自然最完美的作品。',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Post(
        id: 'discover_5',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=400&auto=format&fit=crop',
        title: '九寨沟的五彩斑斓 🌈',
        username: '川西摄影师小张',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 92,
        tags: ['#九寨沟', '#五彩池', '#四川'],
        description: '五花海的绚烂，长海的深邃，九寨沟的每一处风景都是大自然的调色板。',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Post(
        id: 'discover_6',
        imageUrl: 'https://images.unsplash.com/photo-1519904981063-b0cf448d479e?q=80&w=400&auto=format&fit=crop',
        title: '巴厘岛的热带风情 🌺',
        username: '热带度假达人Lisa',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 76,
        tags: ['#巴厘岛', '#热带', '#度假', '#海滩'],
        description: '乌布的梯田，库塔的海滩，还有那些隐藏在丛林中的瀑布。巴厘岛是热带天堂的完美诠释。',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Post(
        id: 'discover_7',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=400&auto=format&fit=crop',
        title: '张家界的奇峰异石 ⛰️',
        username: '山峰摄影师老刘',
        userAvatar: 'assets/img/头像男1.jpg',
        likes: 68,
        tags: ['#张家界', '#奇峰', '#湖南', '#山水'],
        description: '天门山的玻璃栈道，袁家界的哈利路亚山，张家界的每一座山峰都像是从画中走出来的。',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Post(
        id: 'discover_8',
        imageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?q=80&w=400&auto=format&fit=crop',
        title: '土耳其的热气球之旅 🎈',
        username: '热气球飞行员Mike',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 95,
        tags: ['#土耳其', '#热气球', '#卡帕多奇亚'],
        description: '清晨的卡帕多奇亚，数百个热气球同时升空。从空中俯瞰这片神奇的土地，感受童话般的浪漫。',
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      ),
      Post(
        id: 'discover_9',
        imageUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?q=80&w=400&auto=format&fit=crop',
        title: '京都的古韵之美 🏮',
        username: '和风少女Sakura',
        userAvatar: 'assets/img/头像女3.jpg',
        likes: 84,
        tags: ['#京都', '#古韵', '#日本', '#传统'],
        description: '清水寺的樱花，金阁寺的倒影，还有那些穿着和服漫步在石板路上的身影。京都是时光的诗篇。',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Post(
        id: 'discover_10',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=400&auto=format&fit=crop',
        title: '西藏纳木错的圣湖之美 🏔️',
        username: '高原摄影师Tibet',
        userAvatar: 'assets/img/头像男2.jpg',
        likes: 127,
        tags: ['#西藏', '#纳木错', '#圣湖', '#高原'],
        description: '海拔4718米的纳木错如蓝宝石般镶嵌在雪山之间，湖水清澈见底，倒映着念青唐古拉山的雪峰。这里是离天空最近的圣湖。',
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      ),
      // 新增6条发现页面动态
      Post(
        id: 'discover_11',
        imageUrl: 'https://images.unsplash.com/photo-1551218808-94e220e084d2?q=80&w=400&auto=format&fit=crop',
        title: '巴黎咖啡馆的慢时光 ☕',
        username: '巴黎咖啡师Pierre',
        userAvatar: 'assets/img/头像男1.jpg',
        likes: 58,
        tags: ['#巴黎', '#咖啡馆', '#慢生活', '#法式浪漫'],
        description: '在塞纳河畔的小咖啡馆里，看着行人匆匆，品味一杯香浓的咖啡。这就是巴黎人的生活哲学。',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      Post(
        id: 'discover_12',
        imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=400&auto=format&fit=crop',
        title: '东京银座的霓虹夜 🌃',
        username: '夜景摄影师Neon',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 91,
        tags: ['#东京', '#银座', '#霓虹灯', '#夜景'],
        description: '银座的霓虹灯如星河般璀璨，每一盏灯都在诉说着这座不夜城的故事。东京的夜晚永远不会让人失望。',
        createdAt: DateTime.now().subtract(const Duration(hours: 11)),
      ),
      Post(
        id: 'discover_13',
        imageUrl: 'https://images.unsplash.com/photo-1523712999610-f77fbcfc3843?q=80&w=400&auto=format&fit=crop',
        title: '京都竹林的禅意 🎋',
        username: '禅意摄影师Zen',
        userAvatar: 'assets/img/头像男2.jpg',
        likes: 77,
        tags: ['#京都', '#竹林', '#禅意', '#静谧'],
        description: '嵯峨野竹林的绿色隧道，阳光透过竹叶洒下斑驳的光影。在这里，时间仿佛静止了。',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Post(
        id: 'discover_14',
        imageUrl: 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?q=80&w=400&auto=format&fit=crop',
        title: '挪威峡湾的壮美 ⛰️',
        username: '北欧探险家Fjord',
        userAvatar: 'assets/img/头像女2.jpg',
        likes: 105,
        tags: ['#挪威', '#峡湾', '#壮美', '#北欧'],
        description: '盖朗厄尔峡湾的瀑布从天而降，两岸的山峰直插云霄。挪威的峡湾是地球上最震撼的风景。',
        createdAt: DateTime.now().subtract(const Duration(hours: 13)),
      ),
      Post(
        id: 'discover_15',
        imageUrl: 'https://images.unsplash.com/photo-1500622944204-b135684e99fd?q=80&w=400&auto=format&fit=crop',
        title: '冰岛蓝冰洞奇观 ❄️',
        username: '冰川探险者Glacier',
        userAvatar: 'assets/img/头像男1.jpg',
        likes: 119,
        tags: ['#冰岛', '#蓝冰洞', '#奇观', '#冰川'],
        description: '瓦特纳冰川的蓝冰洞如水晶宫殿般梦幻，蓝色的冰壁在阳光下闪闪发光。这是大自然最神奇的艺术品。',
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      ),
      Post(
        id: 'discover_16',
        imageUrl: 'https://images.unsplash.com/photo-1433086966358-54859d0ed716?q=80&w=400&auto=format&fit=crop',
        title: '加拿大班夫的湖光山色 🏔️',
        username: '落基山摄影师Rocky',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 98,
        tags: ['#加拿大', '#班夫', '#湖泊', '#落基山脉'],
        description: '路易斯湖的翡翠绿如宝石般纯净，倒映着雪山的倩影。班夫国家公园是户外爱好者的天堂。',
        createdAt: DateTime.now().subtract(const Duration(hours: 15)),
      ),
      // 再新增6条发现页面动态
      Post(
        id: 'discover_17',
        imageUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=400&auto=format&fit=crop',
        title: '埃及金字塔的千年守望 🏺',
        username: '考古学家Pharaoh',
        userAvatar: 'assets/img/头像男1.jpg',
        likes: 143,
        tags: ['#埃及', '#金字塔', '#古文明', '#历史'],
        description: '站在吉萨金字塔前，感受四千年历史的厚重。这些石块见证了法老的荣耀与文明的兴衰。',
        createdAt: DateTime.now().subtract(const Duration(hours: 16)),
      ),
      Post(
        id: 'discover_18',
        imageUrl: 'https://images.unsplash.com/photo-1540979388789-6cee28a1cdc9?q=80&w=400&auto=format&fit=crop',
        title: '马尔代夫的水下餐厅 🐟',
        username: '海洋美食家Ocean',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 167,
        tags: ['#马尔代夫', '#水下餐厅', '#海洋', '#美食'],
        description: '在海底5米深的餐厅用餐，鲨鱼和鳐鱼在头顶游过。这是最浪漫的海底晚餐体验。',
        createdAt: DateTime.now().subtract(const Duration(hours: 17)),
      ),
      Post(
        id: 'discover_19',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=400&auto=format&fit=crop',
        title: '峨眉山的金顶佛光 ✨',
        username: '佛教文化研究者',
        userAvatar: 'assets/img/头像男2.jpg',
        likes: 88,
        tags: ['#峨眉山', '#佛光', '#四川', '#佛教'],
        description: '在峨眉山金顶看到了传说中的佛光奇观，七彩光环在云海中若隐若现，神圣而庄严。',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      Post(
        id: 'discover_20',
        imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=400&auto=format&fit=crop',
        title: '南极企鹅的萌态 🐧',
        username: '极地生物学家Penguin',
        userAvatar: 'assets/img/头像女3.jpg',
        likes: 234,
        tags: ['#南极', '#企鹅', '#极地', '#野生动物'],
        description: '在南极大陆与帝企鹅面对面，它们憨态可掬的样子让人忍俊不禁。这里是地球最后的净土。',
        createdAt: DateTime.now().subtract(const Duration(hours: 19)),
      ),
      Post(
        id: 'discover_21',
        imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=400&auto=format&fit=crop',
        title: '亚马逊雨林的生命奇迹 🦋',
        username: '雨林生态学家Amazon',
        userAvatar: 'assets/img/头像女2.jpg',
        likes: 156,
        tags: ['#亚马逊', '#雨林', '#生态', '#蝴蝶'],
        description: '在亚马逊雨林深处发现了新的蝴蝶品种，它们翅膀上的蓝色如宝石般璀璨。生命的多样性令人惊叹。',
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      Post(
        id: 'discover_22',
        imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=400&auto=format&fit=crop',
        title: '摩洛哥撒哈拉的驼铃声 🐪',
        username: '沙漠商队向导Camel',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 121,
        tags: ['#摩洛哥', '#撒哈拉', '#骆驼', '#沙漠'],
        description: '跟随骆驼商队穿越撒哈拉，驼铃声在沙丘间回响。这是千年不变的沙漠旋律。',
        createdAt: DateTime.now().subtract(const Duration(hours: 21)),
      ),
    ];
  }
  static List<Post> _getDefaultPosts() {
    return [
      Post(
        id: '1',
        imageUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?q=80&w=400&auto=format&fit=crop',
        title: '瑞士的夏天是宫崎骏的童话世界吧 🇨🇭',
        username: 'Yuki',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 48,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: '2',
        imageUrl: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?q=80&w=400&auto=format&fit=crop',
        title: '蓝白色的梦境',
        username: 'Alex',
        userAvatar: 'assets/img/头像男1.jpg',
        likes: 20,
        tags: ['#希腊', '#圣托里尼'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Post(
        id: '3',
        imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=400&auto=format&fit=crop',
        title: '在这条公路上开到世界尽头',
        username: 'Sam',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 89,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Post(
        id: '4',
        imageUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?q=80&w=400&auto=format&fit=crop',
        title: '夜晚的东京',
        username: 'Ken',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 53,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Post(
        id: '5',
        imageUrl: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=400&auto=format&fit=crop',
        title: '山间的小屋',
        username: 'Emma',
        userAvatar: 'assets/img/头像女2.jpg',
        likes: 56,
        tags: ['#山居', '#治愈'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Post(
        id: '6',
        imageUrl: 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?q=80&w=400&auto=format&fit=crop',
        title: '森林深处的秘密',
        username: 'Oliver',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 92,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  // 默认话题数据
  static List<Topic> _getDefaultTopics() {
    return [
      Topic(
        id: '1',
        title: '# 逃离城市',
        icon: 'fire',
        participantCount: 40,
        color: 'red',
      ),
      Topic(
        id: '2',
        title: '# 胶片旅行',
        icon: 'camera',
        participantCount: 80,
        color: 'purple',
      ),
      Topic(
        id: '3',
        title: '# 森林吸氧',
        icon: 'tree',
        participantCount: 90,
        color: 'green',
      ),
      Topic(
        id: '4',
        title: '# 海边治愈',
        icon: 'water',
        participantCount: 56,
        color: 'blue',
      ),
      Topic(
        id: '5',
        title: '# 山峰征服',
        icon: 'mountain',
        participantCount: 78,
        color: 'brown',
      ),
      Topic(
        id: '6',
        title: '# 古镇漫步',
        icon: 'temple',
        participantCount: 23,
        color: 'orange',
      ),
    ];
  }

  // 默认文章数据
  static List<Article> _getDefaultArticles() {
    return [
      Article(
        id: '1',
        title: '如何在京都的秋天，拍出一组王家卫风格的照片？',
        content: '京都的秋天有着独特的魅力，当满城的枫叶开始泛红，当银杏叶片片飘落，整座古都仿佛被大自然的画笔重新描绘了一遍。而在这样的季节里，如果你想要拍出一组王家卫风格的照片，那么你需要掌握几个关键要素...',
        coverImage: 'https://images.unsplash.com/photo-1523712999610-f77fbcfc3843?q=80&w=300&auto=format&fit=crop',
        authorName: '林间鹿',
        authorAvatar: 'assets/img/头像女2.jpg',
        views: 12000,
        readTime: 5,
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Article(
        id: '2',
        title: '在巴黎的咖啡馆里，如何拍出法式浪漫？',
        content: '巴黎的咖啡馆文化源远流长，每一家咖啡馆都有着自己独特的故事。从蒙马特高地的小酒馆到塞纳河畔的露天咖啡座，这些地方不仅是巴黎人生活的一部分，更是摄影师们捕捉法式浪漫的绝佳场所...',
        coverImage: 'https://images.unsplash.com/photo-1551218808-94e220e084d2?q=80&w=300&auto=format&fit=crop',
        authorName: '咖啡师小李',
        authorAvatar: 'assets/img/头像男1.jpg',
        views: 8500,
        readTime: 6,
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Article(
        id: '3',
        title: '东京街头摄影指南：捕捉都市的诗意瞬间',
        content: '东京，这座现代化的大都市，在霓虹灯的照耀下展现出独特的魅力。从涩谷的人潮涌动到新宿的夜色迷离，从浅草的传统风情到银座的时尚前沿，每一个角落都蕴藏着无数的摄影机会...',
        coverImage: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=300&auto=format&fit=crop',
        authorName: '街头摄影师',
        authorAvatar: 'assets/img/头像女1.jpg',
        views: 15600,
        readTime: 4,
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // 默认用户数据
  static User _getDefaultUser() {
    return User(
      id: 'current_user',
      username: 'travel_cat',
      displayName: '一只旅行喵',
      avatar: 'assets/img/头像女2.jpg',
      bio: '所有的相遇都是久别重逢',
      location: '上海',
      followers: 73,
      following: 42,
      totalLikes: 856,
      posts: ['user_post_1', 'user_post_2', 'user_post_3', 'user_post_4', 'user_post_5'],
      gender: 'female',
      age: 26,
      interests: ['摄影', '旅行', '美食', '咖啡', '电影', '音乐'],
      phone: '138****8888',
      email: 'travel_cat@example.com',
    );
  }

  // 获取默认用户数据（公开方法）
  static User getDefaultUser() {
    return _getDefaultUser();
  }

  // 获取用户帖子
  static Future<List<String>> getUserPosts() async {
    return [
      'https://images.unsplash.com/photo-1501785888041-af3ef285b470?q=80&w=200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?q=80&w=200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1433086966358-54859d0ed716?q=80&w=200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=200&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1500622944204-b135684e99fd?q=80&w=200&auto=format&fit=crop',
    ];
  }

  // 获取用户发布的动态
  static Future<List<Post>> getUserPublishedPosts() async {
    return [
      Post(
        id: 'user_post_1',
        imageUrl: 'assets/images/img_k.jpg',
        title: '日落时分的海边漫步 🌅',
        username: 'travel_cat',
        userAvatar: 'assets/img/头像女2.jpg',
        likes: 42,
        tags: [],
        description: '傍晚沿着海岸线散步，天空被染成了粉紫色，海浪轻轻拍打着沙滩。这种不期而遇的美好，才是旅行最迷人的地方。',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Post(
        id: 'user_post_2',
        imageUrl: 'assets/images/img_l.jpg',
        title: '山间晨雾中的宁静时光 🌄',
        username: 'travel_cat',
        userAvatar: 'assets/img/头像女2.jpg',
        likes: 68,
        tags: [],
        description: '清晨推开窗，山谷间弥漫着薄雾，远处的山峦层层叠叠。泡了一杯热茶坐在阳台上，听着鸟鸣声，感觉时间都慢了下来。',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Post(
        id: 'user_post_3',
        imageUrl: 'https://images.unsplash.com/photo-1433086966358-54859d0ed716?q=80&w=400&auto=format&fit=crop',
        title: '加拿大落基山脉 🏔️',
        username: 'travel_cat',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 68,
        tags: ['#加拿大', '#落基山脉', '#班夫'],
        description: '班夫国家公园的湖光山色，路易斯湖的翡翠绿，落基山脉是户外爱好者的天堂。',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
  // 获取Vision帖子
  static Future<List<Post>> getVisionPosts() async {
    return [
      Post(
        id: 'vision_1',
        imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=800&auto=format&fit=crop',
        title: '通往远方的路',
        username: 'RoadTraveler',
        userAvatar: 'assets/img/头像男1.jpg',
        likes: 50,
        description: '这条路通向何方？每一步都是未知的冒险',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Post(
        id: 'vision_2',
        imageUrl: 'https://images.unsplash.com/photo-1506929562872-bb421503ef21?q=80&w=800&auto=format&fit=crop',
        title: '热带的尽头',
        username: 'SeaSideGirl',
        userAvatar: 'assets/img/头像女2.jpg',
        likes: 73,
        description: '夏威夷的日落是一场盛大的谢幕',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Post(
        id: 'vision_3',
        imageUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?q=80&w=800&auto=format&fit=crop',
        title: '沙漠中的奇迹',
        username: '沙海行者',
        userAvatar: 'assets/img/头像男2.jpg',
        likes: 156,
        description: '撒哈拉沙漠深处的绿洲，生命在最荒芜的地方绽放',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Post(
        id: 'vision_4',
        imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?q=80&w=800&auto=format&fit=crop',
        title: '户外探险之旅',
        username: '野外探索者',
        userAvatar: 'assets/img/头像女3.jpg',
        likes: 20,
        description: '背包客的世界，每一步都是新的发现',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Post(
        id: 'vision_5',
        imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=800&auto=format&fit=crop',
        title: '山林深处的秘境',
        username: '徒步达人',
        userAvatar: 'assets/img/头像男3.jpg',
        likes: 21,
        description: '穿越原始森林，寻找内心的宁静',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Post(
        id: 'vision_6',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=800&auto=format&fit=crop',
        title: '九寨沟的童话世界',
        username: '川西摄影师',
        userAvatar: 'assets/img/头像女1.jpg',
        likes: 62,
        description: '五彩斑斓的海子，大自然最美的调色板',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
    ];
  }

  // 退出登录
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 清除用户相关的数据
    await prefs.remove(_currentUserKey);
    
    // 可以选择性地清除其他数据，比如用户的帖子、收藏等
    // await prefs.remove(_postsKey);
    // await prefs.remove(_usersKey);
    
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));
  }

  // 检查用户是否已登录
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }

  // 清除所有数据（可选，用于完全重置应用）
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // 获取帖子的评论
  static Future<List<Comment>> getPostComments(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString(_commentsKey);
    
    if (commentsJson == null) {
      final defaultComments = _getDefaultComments();
      await saveComments(defaultComments);
      return defaultComments.where((comment) => comment.postId == postId).toList();
    }
    
    final List<dynamic> commentsList = json.decode(commentsJson);
    final allComments = commentsList.map((json) => Comment.fromJson(json)).toList();
    return allComments.where((comment) => comment.postId == postId).toList();
  }

  // 保存评论
  static Future<void> saveComments(List<Comment> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = json.encode(comments.map((comment) => comment.toJson()).toList());
    await prefs.setString(_commentsKey, commentsJson);
  }

  // 添加新评论
  static Future<void> addComment(Comment comment) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString(_commentsKey);
    
    List<Comment> comments = [];
    if (commentsJson != null) {
      final List<dynamic> commentsList = json.decode(commentsJson);
      comments = commentsList.map((json) => Comment.fromJson(json)).toList();
    } else {
      comments = _getDefaultComments();
    }
    
    comments.add(comment);
    await saveComments(comments);
  }

  // 删除帖子
  static Future<void> deletePost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final postsJson = prefs.getString(_postsKey);
    
    if (postsJson != null) {
      final List<dynamic> postsList = json.decode(postsJson);
      List<Post> posts = postsList.map((json) => Post.fromJson(json)).toList();
      
      // 从列表中移除指定的帖子
      posts.removeWhere((post) => post.id == postId);
      
      // 保存更新后的帖子列表
      await savePosts(posts);
    }
    
    // 同时删除该帖子的所有评论
    await deletePostComments(postId);
  }

  // 删除帖子的所有评论
  static Future<void> deletePostComments(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString(_commentsKey);
    
    if (commentsJson != null) {
      final List<dynamic> commentsList = json.decode(commentsJson);
      List<Comment> comments = commentsList.map((json) => Comment.fromJson(json)).toList();
      
      // 移除该帖子的所有评论
      comments.removeWhere((comment) => comment.postId == postId);
      
      // 保存更新后的评论列表
      await saveComments(comments);
    }
  }
  // 默认评论数据
  static List<Comment> _getDefaultComments() {
    return [
      // vision_1 的评论 (4条)
      Comment(
        id: 'comment_1',
        postId: 'vision_1',
        userId: 'user_1',
        username: '山野行者',
        userAvatar: 'assets/img/头像男2.jpg',
        content: '这条路我也走过！真的太美了，每一个转弯都是惊喜 🚗',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likes: 12,
      ),
      Comment(
        id: 'comment_2',
        postId: 'vision_1',
        userId: 'user_2',
        username: '旅行小仙女',
        userAvatar: 'assets/img/头像女3.jpg',
        content: '好想去啊！请问这是哪里的路？',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        likes: 8,
      ),
      Comment(
        id: 'comment_3',
        postId: 'vision_1',
        userId: 'user_3',
        username: '摄影师老王',
        userAvatar: 'assets/img/头像男3.jpg',
        content: '构图很棒！这种延伸感拍得很有意境',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        likes: 15,
      ),
      Comment(
        id: 'comment_4',
        postId: 'vision_1',
        userId: 'user_4',
        username: '自驾游达人',
        userAvatar: 'assets/img/头像女1.jpg',
        content: '这应该是川藏线吧？我去年也走过，风景绝美！',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        likes: 6,
      ),

      // vision_2 的评论 (3条)
      Comment(
        id: 'comment_5',
        postId: 'vision_2',
        userId: 'user_5',
        username: '海岛控小美',
        userAvatar: 'assets/img/头像女2.jpg',
        content: '夏威夷的日落真的是世界级的！每次看都会被震撼到 🌅',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 23,
      ),
      Comment(
        id: 'comment_6',
        postId: 'vision_2',
        userId: 'user_6',
        username: '度假专家',
        userAvatar: 'assets/img/头像男1.jpg',
        content: '这个角度拍得太棒了！请问是在哪个海滩？',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        likes: 11,
      ),
      Comment(
        id: 'comment_7',
        postId: 'vision_2',
        userId: 'user_7',
        username: '椰子树下',
        userAvatar: 'assets/img/头像女3.jpg',
        content: '太治愈了！看着就想马上飞过去 ✈️',
        createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
        likes: 9,
      ),

      // vision_3 的评论 (3条)
      Comment(
        id: 'comment_8',
        postId: 'vision_3',
        userId: 'user_8',
        username: '草原牧民',
        userAvatar: 'assets/img/头像男3.jpg',
        content: '呼伦贝尔的草原真的是天堂！骑马的感觉太自由了 🐎',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 18,
      ),
      Comment(
        id: 'comment_9',
        postId: 'vision_3',
        userId: 'user_9',
        username: '内蒙古姑娘',
        userAvatar: 'assets/img/头像女3.jpg',
        content: '这就是我的家乡！欢迎大家来内蒙古做客 🏠',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        likes: 25,
      ),
      Comment(
        id: 'comment_10',
        postId: 'vision_3',
        userId: 'user_10',
        username: '城市逃离者',
        userAvatar: 'assets/img/头像男2.jpg',
        content: '看着这片草原，突然想辞职去放羊了 😂',
        createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
        likes: 14,
      ),

      // vision_4 的评论 (2条)
      Comment(
        id: 'comment_11',
        postId: 'vision_4',
        userId: 'user_11',
        username: '户外装备控',
        userAvatar: 'assets/img/头像男2.jpg',
        content: '背包客的生活真的很酷！请问你的装备清单能分享一下吗？',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likes: 16,
      ),
      Comment(
        id: 'comment_12',
        postId: 'vision_4',
        userId: 'user_12',
        username: '徒步爱好者',
        userAvatar: 'assets/img/头像女1.jpg',
        content: '这种探险的感觉太棒了！每一步都是新的发现 👣',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        likes: 12,
      ),

      // vision_5 的评论 (3条)
      Comment(
        id: 'comment_13',
        postId: 'vision_5',
        userId: 'user_13',
        username: '森林守护者',
        userAvatar: 'assets/img/头像男3.jpg',
        content: '原始森林的魅力无法抗拒！这种宁静是城市里找不到的 🌲',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        likes: 21,
      ),
      Comment(
        id: 'comment_14',
        postId: 'vision_5',
        userId: 'user_14',
        username: '自然摄影师',
        userAvatar: 'assets/img/头像女2.jpg',
        content: '光影效果太美了！森林里的光线总是这么神奇',
        createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
        likes: 19,
      ),
      Comment(
        id: 'comment_15',
        postId: 'vision_5',
        userId: 'user_15',
        username: '瑜伽老师',
        userAvatar: 'assets/img/头像女3.jpg',
        content: '在这样的环境里做瑜伽一定很棒！大自然是最好的瑜伽馆 🧘‍♀️',
        createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 20)),
        likes: 13,
      ),

      // vision_6 的评论 (3条)
      Comment(
        id: 'comment_16',
        postId: 'vision_6',
        userId: 'user_16',
        username: '川西旅行家',
        userAvatar: 'assets/img/头像男1.jpg',
        content: '九寨沟永远是我心中的白月光！这个调色板太美了 🎨',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 28,
      ),
      Comment(
        id: 'comment_17',
        postId: 'vision_6',
        userId: 'user_17',
        username: '色彩搭配师',
        userAvatar: 'assets/img/头像女1.jpg',
        content: '这种天然的色彩搭配真的是教科书级别的！',
        createdAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
        likes: 17,
      ),
      Comment(
        id: 'comment_18',
        postId: 'vision_6',
        userId: 'user_18',
        username: '地质学家',
        userAvatar: 'assets/img/头像男2.jpg',
        content: '九寨沟的地质结构造就了这些美丽的海子，大自然真是神奇的艺术家',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        likes: 22,
      ),
    ];
  }
}