import '../models/category_model.dart';
import '../data/category_catalog.dart';

class CategoryRepository {
  const CategoryRepository();

  List<WordCategory> getAllCategories() => categoryCatalog;

  WordCategory? getById(String id) => categoryById(id);

  List<WordCategory> getByIds(Iterable<String> ids) {
    final idSet = ids.toSet();
    return categoryCatalog.where((category) => idSet.contains(category.id)).toList();
  }
}

const categoryRepository = CategoryRepository();
