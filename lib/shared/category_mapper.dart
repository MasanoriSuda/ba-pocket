const Map<String, String> categoryKeyMap = {
  '洗顔': 'cleanser',
  '化粧水': 'toner',
  '乳液・クリーム': 'moisturizer',
  '美容液': 'serum',
  '日焼け止め': 'sunscreen',
  'その他': 'other',
};

String mapCategoryKey(String category) {
  return categoryKeyMap[category] ?? 'other';
}
