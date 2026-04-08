import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/tips_repository.dart';

/// 学习记录状态
class LearningRecord {
  final Set<String> learnedTipIds;
  final Map<String, int> sceneStats;
  final int totalShoots;

  const LearningRecord({
    this.learnedTipIds = const {},
    this.sceneStats = const {},
    this.totalShoots = 0,
  });

  LearningRecord copyWith({
    Set<String>? learnedTipIds,
    Map<String, int>? sceneStats,
    int? totalShoots,
  }) {
    return LearningRecord(
      learnedTipIds: learnedTipIds ?? this.learnedTipIds,
      sceneStats: sceneStats ?? this.sceneStats,
      totalShoots: totalShoots ?? this.totalShoots,
    );
  }
}

/// 学习记录状态管理（持久化到 SharedPreferences）
class LearningNotifier extends StateNotifier<LearningRecord> {
  static const _keyLearnedTips = 'learned_tip_ids';
  static const _keySceneStats = 'scene_stats';
  static const _keyTotalShoots = 'total_shoots';

  LearningNotifier() : super(const LearningRecord()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final learnedIds = prefs.getStringList(_keyLearnedTips) ?? [];
    final sceneStatsJson = prefs.getString(_keySceneStats);
    final totalShoots = prefs.getInt(_keyTotalShoots) ?? 0;

    Map<String, int> sceneStats = {};
    if (sceneStatsJson != null) {
      final decoded = jsonDecode(sceneStatsJson) as Map<String, dynamic>;
      sceneStats = decoded.map((k, v) => MapEntry(k, v as int));
    }

    state = LearningRecord(
      learnedTipIds: Set<String>.from(learnedIds),
      sceneStats: sceneStats,
      totalShoots: totalShoots,
    );
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyLearnedTips, state.learnedTipIds.toList());
    await prefs.setString(_keySceneStats, jsonEncode(state.sceneStats));
    await prefs.setInt(_keyTotalShoots, state.totalShoots);
  }

  /// 标记技巧为已学习
  Future<void> markTipAsLearned(String tipId, String sceneTag) async {
    final newLearnedIds = Set<String>.from(state.learnedTipIds)..add(tipId);
    final newStats = Map<String, int>.from(state.sceneStats);
    newStats[sceneTag] = (newStats[sceneTag] ?? 0) + 1;
    
    state = state.copyWith(
      learnedTipIds: newLearnedIds,
      sceneStats: newStats,
    );
    await _saveToPrefs();
  }

  /// 增加拍摄次数
  Future<void> incrementShootCount(String sceneTag) async {
    final newStats = Map<String, int>.from(state.sceneStats);
    newStats[sceneTag] = (newStats[sceneTag] ?? 0) + 1;
    
    state = state.copyWith(
      totalShoots: state.totalShoots + 1,
      sceneStats: newStats,
    );
    await _saveToPrefs();
  }

  /// 检查技巧是否已学习
  bool isTipLearned(String tipId) {
    return state.learnedTipIds.contains(tipId);
  }

  /// 获取场景统计
  int getSceneCount(String sceneTag) {
    return state.sceneStats[sceneTag] ?? 0;
  }

  /// 获取进步提示
  String getProgressTip() {
    if (state.totalShoots == 0) {
      return '开始学习第一个技巧吧！';
    }
    
    final totalTips = TipsRepository.instance.tipCount;
    final learnedCount = state.learnedTipIds.length;
    final progress = (learnedCount / totalTips * 100).round();
    
    if (progress < 25) {
      return '继续保持学习！已掌握 ${learnedCount} 个技巧';
    } else if (progress < 50) {
      return '太棒了！已学习 $learnedCount 个技巧，继续加油！';
    } else if (progress < 75) {
      return '你已经学习了 $learnedCount 个技巧，进步明显！';
    } else if (progress < 100) {
      return '即将成为大师！还差 ${totalTips - learnedCount} 个技巧';
    } else {
      return '恭喜！你已掌握所有拍摄技巧 🌟';
    }
  }

  /// 重置学习记录
  Future<void> reset() async {
    state = const LearningRecord();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLearnedTips);
    await prefs.remove(_keySceneStats);
    await prefs.remove(_keyTotalShoots);
  }
}

/// 学习记录 Provider
final learningProvider = StateNotifierProvider<LearningNotifier, LearningRecord>((ref) {
  return LearningNotifier();
});

/// 技巧库 Provider
final tipsRepositoryProvider = Provider<TipsRepository>((ref) {
  return TipsRepository.instance;
});

/// 所有技巧列表 Provider
final allTipsProvider = Provider<List<dynamic>>((ref) {
  return TipsRepository.instance.getAllTips();
});

/// 选中的场景标签 Filter Provider
final selectedSceneTagsProvider = StateProvider<Set<String>>((ref) {
  return {};
});

/// 筛选后的技巧列表 Provider
final filteredTipsProvider = Provider<List<dynamic>>((ref) {
  final selectedTags = ref.watch(selectedSceneTagsProvider);
  final repository = ref.watch(tipsRepositoryProvider);
  
  if (selectedTags.isEmpty) {
    return repository.getAllTips();
  }
  
  return repository.getAllTips().where((tip) {
    return selectedTags.any((tag) => tip.sceneTags.contains(tag));
  }).toList();
});
