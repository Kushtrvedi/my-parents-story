#!/usr/bin/env python3
"""Add 10 missing translation keys to all 12 languages."""
import re

TRANSLATIONS = {
    'en': {
        'noQuestionsAvailable': 'No questions available.',
        'questionProgress': 'Question {current} of {total}',
        'continueLater': 'Continue later',
        'storyWillBecomePdf': "{name}'s story will become a beautiful PDF book.",
        'memoriesShared': '{completed} of {total} memories shared',
        'sharedFromApp': 'Shared from My Parents\' Story',
        'pdfMemoirTitle': "{name}'s Memoir",
        'pdfCreator': "My Parents' Story",
        'pdfLanguageSubject': 'Language: {generated} (Original: {original})',
        'unknown': 'Unknown',
    },
    'hi': {
        'noQuestionsAvailable': 'कोई प्रश्न उपलब्ध नहीं है।',
        'questionProgress': 'प्रश्न {current} / {total}',
        'continueLater': 'बाद में जारी रखें',
        'storyWillBecomePdf': '{name} की कहानी एक सुंदर PDF पुस्तक बनेगी।',
        'memoriesShared': '{completed} / {total} यादें साझा की गईं',
        'sharedFromApp': 'मेरे माता-पिता की कहानी से साझा किया गया',
        'pdfMemoirTitle': '{name} की स्मृति',
        'pdfCreator': 'मेरे माता-पिता की कहानी',
        'pdfLanguageSubject': 'भाषा: {generated} (मूल: {original})',
        'unknown': 'अज्ञात',
    },
    'gu': {
        'noQuestionsAvailable': 'કોઈ પ્રશ્નો ઉપલબ્ધ નથી.',
        'questionProgress': 'પ્રશ્ન {current} / {total}',
        'continueLater': 'પછી ચાલુ રાખો',
        'storyWillBecomePdf': '{name} ની વાર્તા એક સુંદર PDF પુસ્તક બનશે.',
        'memoriesShared': '{completed} / {total} યાદો શેર કરવામાં આવી',
        'sharedFromApp': 'મારા માતા-પિતાની વાર્તામાંથી શેર કર્યું',
        'pdfMemoirTitle': '{name} ની યાદ',
        'pdfCreator': 'મારા માતા-પિતાની વાર્તા',
        'pdfLanguageSubject': 'ભાષા: {generated} (મૂળ: {original})',
        'unknown': 'અજ્ઞાત',
    },
    'es': {
        'noQuestionsAvailable': 'No hay preguntas disponibles.',
        'questionProgress': 'Pregunta {current} de {total}',
        'continueLater': 'Continuar después',
        'storyWillBecomePdf': 'La historia de {name} se convertirá en un hermoso libro PDF.',
        'memoriesShared': '{completed} de {total} recuerdos compartidos',
        'sharedFromApp': 'Compartido desde La Historia de Mis Padres',
        'pdfMemoirTitle': 'Memorias de {name}',
        'pdfCreator': 'La Historia de Mis Padres',
        'pdfLanguageSubject': 'Idioma: {generated} (Original: {original})',
        'unknown': 'Desconocido',
    },
    'mr': {
        'noQuestionsAvailable': 'कोणतेही प्रश्न उपलब्ध नाहीत.',
        'questionProgress': 'प्रश्न {current} / {total}',
        'continueLater': 'नंतर सुरू ठेवा',
        'storyWillBecomePdf': '{name} ची कथा एक सुंदर PDF पुस्तक बनेल.',
        'memoriesShared': '{completed} / {total} आठवणी शेअर केल्या',
        'sharedFromApp': 'माझ्या आई-बाबांच्या कथेतून शेअर केले',
        'pdfMemoirTitle': '{name} ची आठवण',
        'pdfCreator': 'माझ्या आई-बाबांची कथा',
        'pdfLanguageSubject': 'भाषा: {generated} (मूळ: {original})',
        'unknown': 'अज्ञात',
    },
    'ta': {
        'noQuestionsAvailable': 'கேள்விகள் எதுவும் கிடைக்கவில்லை.',
        'questionProgress': 'கேள்வி {current} / {total}',
        'continueLater': 'பிறகு தொடரவும்',
        'storyWillBecomePdf': '{name} இன் கதை ஒரு அழகான PDF புத்தகமாக மாறும்.',
        'memoriesShared': '{completed} / {total} நினைவுகள் பகிரப்பட்டன',
        'sharedFromApp': 'என் பெற்றோரின் கதையிலிருந்து பகிரப்பட்டது',
        'pdfMemoirTitle': '{name} நினைவு',
        'pdfCreator': 'என் பெற்றோரின் கதை',
        'pdfLanguageSubject': 'மொழி: {generated} (அசல்: {original})',
        'unknown': 'அறியப்படாதது',
    },
    'te': {
        'noQuestionsAvailable': 'ప్రశ్నలు అందుబాటులో లేవు.',
        'questionProgress': 'ప్రశ్న {current} / {total}',
        'continueLater': 'తర్వాత కొనసాగించండి.',
        'storyWillBecomePdf': '{name} కథ ఒక అందమైన PDF పుస్తకంగా మారుతుంది.',
        'memoriesShared': '{completed} / {total} జ్ఞాపకాలు షేర్ చేయబడ్డాయి.',
        'sharedFromApp': 'నా తల్లిదండ్రుల కథ నుండి షేర్ చేయబడింది.',
        'pdfMemoirTitle': '{name} జ్ఞాపకం.',
        'pdfCreator': 'నా తల్లిదండ్రుల కథ.',
        'pdfLanguageSubject': 'భాష: {generated} (అసలు: {original}).',
        'unknown': 'తెలియదు.',
    },
    'ml': {
        'noQuestionsAvailable': 'ചോദ്യങ്ങൾ ലഭ്യമല്ല.',
        'questionProgress': 'ചോദ്യം {current} / {total}',
        'continueLater': 'പിന്നീട് തുടരുക.',
        'storyWillBecomePdf': '{name} ന്റെ കഥ ഒരു മനോഹര PDF പുസ്തകമാകും.',
        'memoriesShared': '{completed} / {total} ഓർമ്മകൾ പങ്കുവെക്കപ്പെട്ടു.',
        'sharedFromApp': 'എന്റെ മാതാപിതാക്കളുടെ കഥയിൽ നിന്ന് പങ്കുവെച്ചത്.',
        'pdfMemoirTitle': '{name} ന്റെ ഓർമ്മ.',
        'pdfCreator': 'എന്റെ മാതാപിതാക്കളുടെ കഥ.',
        'pdfLanguageSubject': 'ഭാഷ: {generated} (മൂലം: {original}).',
        'unknown': 'അറിയപ്പെടാത്തത്.',
    },
    'or': {
        'noQuestionsAvailable': 'କୌଣସି ପ୍ରଶ୍ନ ଉପଲବ୍ଧ ନାହିଁ।',
        'questionProgress': 'ପ୍ରଶ୍ନ {current} / {total}',
        'continueLater': 'ପରେ ଜାରି ରଖନ୍ତୁ।',
        'storyWillBecomePdf': '{name} ର କାହାଣୀ ଗୋଟିଏ ସୁନ୍ଦର PDF ପୁସ୍ତକ ହେବ।',
        'memoriesShared': '{completed} / {total} ସ୍ମୃତି ସେୟାର ହୋଇଛି।',
        'sharedFromApp': 'ମୋ ବାପାମାଙ୍କ କାହାଣୀରୁ ସେୟାର କରାଯାଇଛି।',
        'pdfMemoirTitle': '{name} ର ସ୍ମୃତି।',
        'pdfCreator': 'ମୋ ବାପାମାଙ୍କ କାହାଣୀ।',
        'pdfLanguageSubject': 'ଭାଷା: {generated} (ମୂଳ: {original})।',
        'unknown': 'ଅଜ୍ଞାତ।',
    },
    'pa': {
        'noQuestionsAvailable': 'ਕੋਈ ਸਵਾਲ ਉਪਲਬਧ ਨਹੀਂ ਹੈ।',
        'questionProgress': 'ਸਵਾਲ {current} / {total}',
        'continueLater': 'ਬਾਅਦ ਵਿੱਚ ਜਾਰੀ ਰੱਖੋ।',
        'storyWillBecomePdf': '{name} ਦੀ ਕਹਾਣੀ ਇੱਕ ਸੁੰਦਰ PDF ਕਿਤਾਬ ਬਣੇਗੀ।',
        'memoriesShared': '{completed} / {total} ਯਾਦਾਂ ਸਾਂਝੀਆਂ ਕੀਤੀਆਂ।',
        'sharedFromApp': 'ਮੇਰੇ ਮਾਂ-ਬਾਪ ਦੀ ਕਹਾਣੀ ਤੋਂ ਸਾਂਝਾ ਕੀਤਾ।',
        'pdfMemoirTitle': '{name} ਦੀ ਯਾਦ।',
        'pdfCreator': 'ਮੇਰੇ ਮਾਂ-ਬਾਪ ਦੀ ਕਹਾਣੀ।',
        'pdfLanguageSubject': 'ਭਾਸ਼ਾ: {generated} (ਮੂਲ: {original})।',
        'unknown': 'ਅਣਪਛਾਣਾ।',
    },
    'bn': {
        'noQuestionsAvailable': 'কোনো প্রশ্ন পাওয়া যায়নি।',
        'questionProgress': 'প্রশ্ন {current} / {total}',
        'continueLater': 'পরে চালিয়ে যান।',
        'storyWillBecomePdf': '{name} -এর গল্প একটি সুন্দর PDF বই হয়ে যাবে।',
        'memoriesShared': '{completed} / {total} স্মৃতি শেয়ার করা হয়েছে।',
        'sharedFromApp': 'আমার বাবা-মায়ের গল্প থেকে শেয়ার করা হয়েছে।',
        'pdfMemoirTitle': '{name} এর স্মৃতি।',
        'pdfCreator': 'আমার বাবা-মায়ের গল্প।',
        'pdfLanguageSubject': 'ভাষা: {generated} (মূল: {original})।',
        'unknown': 'অজানা।',
    },
    'kn': {
        'noQuestionsAvailable': 'ಯಾವುದೇ ಪ್ರಶ್ನೆಗಳು ಲಭ್ಯವಿಲ್ಲ.',
        'questionProgress': 'ಪ್ರಶ್ನೆ {current} / {total}',
        'continueLater': 'ನಂತರ ಮುಂದುವರಿಸಿ.',
        'storyWillBecomePdf': '{name} ನ ಕಥೆ ಒಂದು ಸುಂದರ PDF ಪುಸ್ತಕವಾಗುತ್ತದೆ.',
        'memoriesShared': '{completed} / {total} ನೆನಪುಗಳು ಹಂಚಿಕೊಳ್ಳಲಾಗಿದೆ.',
        'sharedFromApp': 'ನನ್ನ ತಂದೆ-ತಾಯಿಯ ಕಥೆಯಿಂದ ಹಂಚಿಕೊಳ್ಳಲಾಗಿದೆ.',
        'pdfMemoirTitle': '{name} ನ ನೆನಪು.',
        'pdfCreator': 'ನನ್ನ ತಂದೆ-ತಾಯಿಯ ಕಥೆ.',
        'pdfLanguageSubject': 'ಭಾಷೆ: {generated} (ಮೂಲ: {original}).',
        'unknown': 'ಅಜ್ಞಾತ.',
    },
}

# Read file
with open(r'C:\Users\kush_\my_parents_story\lib\l10n\translations.dart', 'r', encoding='utf-8') as f:
    content = f.read()

for lang, keys in TRANSLATIONS.items():
    # Find the withLove key for this language and add keys after it
    # The pattern: find `'withLove':` line followed by `    },` for this language block
    # We need to find the right block
    
    # Find the language block header
    lang_pattern = f"'{lang}': {{"
    lang_pos = content.find(lang_pattern)
    if lang_pos == -1:
        print(f"WARNING: Language '{lang}' not found!")
        continue
    
    # Find the closing of this language block by counting braces
    # Start from lang_pos
    brace_count = 0
    block_start = content.find('{', lang_pos)
    pos = block_start
    while pos < len(content):
        if content[pos] == '{':
            brace_count += 1
        elif content[pos] == '}':
            brace_count -= 1
            if brace_count == 0:
                block_end = pos
                break
        pos += 1
    
    # Find the last entry before closing brace (the 'withLove' line)
    # Find the closing '    },\n    ' pattern
    close_pattern = '    },'
    close_pos = content.rfind(close_pattern, lang_pos, block_end)
    if close_pos == -1:
        print(f"WARNING: Could not find closing for '{lang}'!")
        continue
    
    # Build the keys block to insert
    keys_lines = []
    for key, value in keys.items():
        # Escape any single quotes in value
        escaped_value = value.replace("'", "\\'")
        keys_lines.append(f"      '{key}': '{escaped_value}',")
    
    keys_block = '\n' + '\n'.join(keys_lines)
    
    # Insert before the closing '    },'
    content = content[:close_pos] + keys_block + '\n' + content[close_pos:]

# Write file
with open(r'C:\Users\kush_\my_parents_story\lib\l10n\translations.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Done! Added keys to all 12 languages.")
