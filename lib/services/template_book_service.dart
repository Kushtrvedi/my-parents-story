import '../models/parent_profile.dart';
import '../models/response.dart';
import '../models/generated_chapter.dart';
import 'storage_service.dart';

class TemplateBookService {
  final StorageService _storage;

  TemplateBookService(this._storage);

  static const Map<String, String> _categoryIntros = {
    'Childhood': 'My earliest years were filled with moments that shaped who I would become.',
    'Family': 'My family was the foundation of everything I knew and believed in.',
    'School': 'School was a place of discovery, challenge, and growth.',
    'Teenage Years': 'Those teenage years were a time of finding myself and learning about the world.',
    'Love': 'Love came into my life in ways I never expected.',
    'Marriage': 'Marriage brought new joys, new challenges, and a deeper understanding of partnership.',
    'Career': 'My working life taught me about purpose, perseverance, and contribution.',
    'Financial Journey': 'Money has been both a struggle and a blessing throughout my life.',
    'Parenting': 'Becoming a parent was the most transformative experience of my life.',
    'Challenges': 'Life tested me in ways I could never have predicted.',
    'Values': 'The principles I live by have been forged through experience and reflection.',
    'Legacy': 'When I think about what I leave behind, certain things matter most.',
  };

  static const Map<String, String> _categoryTransitions = {
    'Childhood': 'As I grew older, my world expanded beyond those early days.',
    'Family': 'Beyond my immediate family, school became another important world.',
    'School': 'The teenage years brought their own adventures and challenges.',
    'Teenage Years': 'It was during these years that love found its way into my heart.',
    'Love': 'Love naturally led to a deeper commitment and a new chapter.',
    'Marriage': 'With a family to support, my career took on new importance.',
    'Career': 'Alongside my career, I learned important lessons about money.',
    'Financial Journey': 'And then came the greatest joy of all — parenthood.',
    'Parenting': 'Of course, no life is without its difficulties.',
    'Challenges': 'Through it all, certain values have remained my compass.',
    'Values': 'When I look back on everything, what matters most is clear.',
    'Legacy': '',
  };

  String generateChapter(ParentProfile profile, String category, List<StoryResponse> responses) {
    final buffer = StringBuffer();
    final validResponses = responses.where((r) => r.hasAnswer).toList();

    if (validResponses.isEmpty) {
      buffer.writeln('This chapter is waiting to be filled with ${profile.name}\'s memories about ${category.toLowerCase()}.');
      return buffer.toString();
    }

    final intro = _categoryIntros[category];
    if (intro != null) {
      buffer.writeln(intro);
      buffer.writeln();
    }

    for (final response in validResponses) {
      buffer.writeln(response.answer.trim());
      buffer.writeln();
    }

    final transition = _categoryTransitions[category];
    if (transition != null && transition.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(transition);
    }

    return buffer.toString();
  }

  String generateFinalLetter(ParentProfile profile, List<StoryResponse> allResponses) {
    final buffer = StringBuffer();
    final validResponses = allResponses.where((r) => r.hasAnswer).toList();

    buffer.writeln('## What I Hope My Family Remembers');
    buffer.writeln();
    buffer.writeln('Dear Family,');
    buffer.writeln();
    buffer.writeln('As I sit here reflecting on my life, I am filled with gratitude for every moment that has shaped who I am. These pages hold not just my memories, but the love, lessons, and experiences that I carry with me every day.');
    buffer.writeln();

    final highlights = validResponses.length > 5 ? validResponses.sublist(0, 5) : validResponses;
    for (final response in highlights) {
      if (response.answer.length > 50) {
        buffer.writeln('${response.answer.substring(0, 100).trim()}...');
        buffer.writeln();
      }
    }

    buffer.writeln('I hope this book preserves not just what happened in my life, but the meaning behind it all. Every story, every lesson, every moment of joy or struggle — they all made me who I am, and they all connect to the family we have built together.');
    buffer.writeln();
    buffer.writeln('Remember me not just for what I did, but for what I believed in. Carry these stories forward, and know that love is the thread that connects every page of this book.');
    buffer.writeln();
    buffer.writeln('With all my love,');
    buffer.writeln('${profile.name}');

    return buffer.toString();
  }

  GeneratedBook generateBook(ParentProfile profile, List<StoryResponse> allResponses) {
    final chapters = generateAllChapters(profile);
    final letter = generateFinalLetter(profile, allResponses);
    return GeneratedBook(
      profileId: profile.id,
      chapters: chapters,
      finalLetter: letter,
    );
  }

  List<GeneratedChapter> generateAllChapters(ParentProfile profile) {
    final categories = [
      'Childhood', 'Family', 'School', 'Teenage Years', 'Love', 'Marriage',
      'Career', 'Financial Journey', 'Parenting', 'Challenges', 'Values', 'Legacy',
    ];

    final chapters = <GeneratedChapter>[];
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final responses = _storage.getResponsesForProfile(profile.id)
          .where((r) => r.category == category)
          .toList();

      final content = generateChapter(profile, category, responses);

      final chapter = GeneratedChapter(
        id: '${profile.id}_$category',
        profileId: profile.id,
        category: category,
        chapterNumber: i + 1,
        title: category,
        content: content,
      );

      _storage.saveChapter(chapter);
      chapters.add(chapter);
    }

    return chapters;
  }
}
