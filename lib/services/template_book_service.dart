import '../models/parent_profile.dart';
import '../models/memory.dart';
import '../models/generated_chapter.dart';
import '../data/questions.dart';
import 'storage_service.dart';

class TemplateBookService {
  final StorageService _storage;

  TemplateBookService(this._storage);

  static const Map<String, String> _chapterIntros = {
    'ch01': 'Every family has a story that begins before we were born. These are the roots that made us who we are.',
    'ch02': 'The very beginning of my life — the day I was born and the earliest memories that shaped me.',
    'ch03': 'The place where I grew up shaped who I became. These are the streets, the sounds, and the smells I remember.',
    'ch04': 'School was where I first discovered the world beyond my family. These are the lessons that stayed with me.',
    'ch05': 'The friends I grew up with became part of my story. Together, we navigated the journey from childhood to adolescence.',
    'ch06': 'When I was young, everything felt possible. These are the dreams I held and the person I was becoming.',
    'ch07': 'Learning shaped me in ways I didn\'t always realize. The knowledge I gained became part of who I am.',
    'ch08': 'Work took up so much of my life, but it also gave me purpose, pride, and stories worth telling.',
    'ch09': 'Love found me in ways I never expected. These are the moments that taught my heart to feel deeply.',
    'ch10': 'Building a life with someone I loved was one of the greatest journeys of my life.',
    'ch11': 'Becoming a parent changed everything. It was the most transformative experience of my life.',
    'ch12': 'The home I built held so many memories — laughter, warmth, and the love of family.',
    'ch13': 'The traditions we kept connected us to our roots and to each other. They were the fabric of our family.',
    'ch14': 'Life wasn\'t always easy, but every challenge taught me something about strength and resilience.',
    'ch15': 'Some moments changed the direction of my life. These are the successes and turning points that defined me.',
    'ch16': 'What I believe in has guided me through every chapter of my life. These are the principles I live by.',
    'ch17': 'The places I\'ve been and the things I\'ve seen became part of who I am.',
    'ch18': 'A life well-lived teaches us things no school ever could. These are the lessons I carry with me.',
    'ch19': 'What I leave behind matters. These are the things I want future generations to know and remember.',
    'ch20': 'As I look back on my life, these are the things that matter most to me.',
  };

  static const Map<String, String> _chapterTransitions = {
    'ch01': 'From those roots, a new life began to unfold.',
    'ch02': 'As I grew older, the world around me came into clearer focus.',
    'ch03': 'Beyond my home and neighbourhood, school became another important world.',
    'ch04': 'The friendships I formed during those years became some of the most important in my life.',
    'ch05': 'With friends by my side, I began to dream about the future.',
    'ch06': 'Those dreams led me to pursue knowledge and skills that would shape my career.',
    'ch07': 'Education opened doors to the working world, where I would spend so many years.',
    'ch08': 'Alongside my career, love found its way into my heart.',
    'ch09': 'Love naturally led to a deeper commitment and a new chapter of partnership.',
    'ch10': 'Building a home together, we welcomed the greatest joy of all — our children.',
    'ch11': 'Our home became a place of warmth, tradition, and countless memories.',
    'ch12': 'Through festivals and traditions, we celebrated the bonds that held us together.',
    'ch13': 'Of course, no life is without its difficulties, but each challenge made us stronger.',
    'ch14': 'Through it all, there were moments of triumph that lighted our path.',
    'ch15': 'Guided by my values, I found meaning in every experience.',
    'ch16': 'And sometimes, the greatest discoveries came from simply going somewhere new.',
    'ch17': 'Every journey taught me something about life, about others, and about myself.',
    'ch18': 'These lessons became the foundation of what I want to pass on.',
    'ch19': 'And now, as I reflect on everything, I see clearly what matters most.',
    'ch20': '',
  };

  String generateChapter(ParentProfile profile, String chapterId, List<Memory> responses) {
    final buffer = StringBuffer();
    final validResponses = responses.where((r) => r.hasAnswer).toList();

    if (validResponses.isEmpty) {
      buffer.writeln('This chapter is waiting to be filled with ${profile.name}\'s memories.');
      return buffer.toString();
    }

    final intro = _chapterIntros[chapterId];
    if (intro != null) {
      buffer.writeln(intro);
      buffer.writeln();
    }

    for (final response in validResponses) {
      buffer.writeln(response.answer.trim());
      buffer.writeln();
    }

    final transition = _chapterTransitions[chapterId];
    if (transition != null && transition.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(transition);
    }

    return buffer.toString();
  }

  String generateFinalLetter(ParentProfile profile, List<Memory> allResponses) {
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

  GeneratedBook generateBook(ParentProfile profile, List<Memory> allResponses) {
    final chapters = generateAllChapters(profile);
    final letter = generateFinalLetter(profile, allResponses);
    return GeneratedBook(
      profileId: profile.id,
      chapters: chapters,
      finalLetter: letter,
    );
  }

  List<GeneratedChapter> generateAllChapters(ParentProfile profile) {
    final allChapters = QuestionDatabase.chapters;
    final chapters = <GeneratedChapter>[];

    for (final chapter in allChapters) {
      final responses = _storage.getMemoriesForChapter(profile.id, chapter.id);

      final content = generateChapter(profile, chapter.id, responses);

      final generatedChapter = GeneratedChapter(
        id: '${profile.id}_${chapter.id}',
        profileId: profile.id,
        category: chapter.id,
        chapterNumber: chapter.number,
        title: chapter.title,
        content: content,
      );

      _storage.saveChapter(generatedChapter);
      chapters.add(generatedChapter);
    }

    return chapters;
  }
}
