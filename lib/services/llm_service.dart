import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class LLMService {
  // For demo purposes, we'll use a simple API endpoint.
  // In production, you would use your actual LLM API (OpenAI, Anthropic, etc.)
  static const String _baseUrlMobile = 'http://localhost:5002';
  static const String _baseUrlWeb = 'http://127.0.0.1:5002';

  static String get baseUrl => kIsWeb ? _baseUrlWeb : _baseUrlMobile;
  static String get chatEndpoint => '$baseUrl/chat';

  // Track the current locale
  Locale? currentLocale;

  // For explanations about deficiencies
  Future<String> getDeficiencyExplanation(
      String deficiencyType, double confidence) async {
    try {
      // In a real app, you would call your LLM API here
      // For now, let's simulate with static content
      return _generateDeficiencyExplanation(deficiencyType, confidence);
    } catch (e) {
      print('Error getting deficiency explanation: $e');
      return 'Unable to generate explanation. Please try again later.';
    }
  }

  // For treatment recommendations
  Future<String> getTreatmentRecommendation(String deficiencyType) async {
    try {
      print('Getting treatment recommendation for $deficiencyType');
      // In a real app, you would call your LLM API here

      // Always use the full, uninterrupted treatment text
      final response = _generateTreatmentRecommendation(deficiencyType);

      // Make sure the response is complete and not interrupted
      if (currentLocale?.languageCode == 'tl') {
        return 'Para sa kakulangan ng $deficiencyType sa iyong mga puno ng saging, narito ang mga hakbang na dapat gawin:\n\n$response';
      } else {
        return 'For $deficiencyType deficiency in your banana plants, here are the steps you should take:\n\n$response';
      }
    } catch (e) {
      print('Error getting treatment recommendation: $e');
      if (currentLocale?.languageCode == 'tl') {
        return 'Hindi ko ma-generate ang rekomendasyon sa paggamot ngayon. Pakisubukang muli mamaya.';
      } else {
        return 'Unable to generate treatment recommendation. Please try again later.';
      }
    }
  }

  // For answering farmer questions
  Future<String> answerFarmerQuestion(String deficiencyType, String question,
      {String? context}) async {
    try {
      print('Deficiency type: $deficiencyType');
      print('Question: $question');
      print('Context available: ${context != null && context.isNotEmpty}');

      // Check if question is in Tagalog/Filipino
      bool isTagalog =
          _detectTagalog(question) || currentLocale?.languageCode == 'tl';

      print('Is Tagalog: $isTagalog');

      // If we have a deficiency type and context, always use context-based responses
      // instead of just checking for simple action questions
      if (deficiencyType.isNotEmpty && context != null && context.isNotEmpty) {
        print('Using context-aware response for $deficiencyType');

        // For simple action questions, provide direct treatment advice
        bool isSimpleActionQuestion =
            _isSimpleActionQuestion(question, isTagalog);
        if (isSimpleActionQuestion) {
          print('Simple action question detected, providing treatment answer');
          return _generateSpecificTreatmentAnswer(deficiencyType, isTagalog);
        }

        // For other questions, generate a contextual response based on the deficiency
        // and conversation history
        return _generateContextualAnswer(
            deficiencyType, question, context, isTagalog);
      }

      // For new conversations or when no deficiency is identified yet
      String prompt;

      // Create a better prompt that maintains context
      if (context != null && context.isNotEmpty) {
        // Use conversation history for context-aware responses
        prompt = "Conversation history:\n$context\n\n"
            "The farmer's banana plant has $deficiencyType deficiency. "
            "Question: $question\n\n"
            "${isTagalog ? 'Respond in Tagalog/Filipino language using professional but accessible language. Avoid overly casual language like "naku pare".' : 'Respond in English.'}\n"
            "Important: Always acknowledge and reference the $deficiencyType deficiency that was already detected. "
            "Don't ask for symptoms again if they were already provided. "
            "Focus specifically on practical $deficiencyType deficiency treatment and management.";
      } else {
        prompt = "The farmer's banana plant has $deficiencyType deficiency. "
            "Question: $question\n\n"
            "${isTagalog ? 'Respond in Tagalog/Filipino language using professional but accessible language. Avoid overly casual language like "naku pare".' : 'Respond in English.'}\n"
            "Important: Always acknowledge the $deficiencyType deficiency that was already detected. "
            "Focus specifically on practical $deficiencyType deficiency treatment and management.";
      }

      // For now, let's simulate with a hardcoded response system
      // In a real implementation, you would send the prompt to your LLM API
      print('Generated prompt: $prompt');

      // Check for simple action questions as a fallback
      bool isSimpleActionQuestion =
          _isSimpleActionQuestion(question, isTagalog);
      if (deficiencyType.isNotEmpty && isSimpleActionQuestion) {
        print('Simple action question detected, providing treatment answer');
        return _generateSpecificTreatmentAnswer(deficiencyType, isTagalog);
      }

      return _generateAnswer(deficiencyType, question, isTagalog: isTagalog);
    } catch (e) {
      print('Error answering question: $e');
      if (currentLocale?.languageCode == 'tl') {
        return 'Paumanhin, hindi ko ma-proseso ang iyong katanungan. Pakisubukang muli.';
      } else {
        return 'Sorry, I could not process your question. Please try again.';
      }
    }
  }

  // Generate a contextual answer based on deficiency, question, and conversation history
  String _generateContextualAnswer(
      String deficiency, String question, String context, bool isTagalog) {
    print('Generating contextual answer for $deficiency question: $question');
    print('Context length: ${context.length}');

    // Extract key information from the context
    bool hasAskedAboutTreatment = context.toLowerCase().contains('treatment') ||
        context.toLowerCase().contains('paggamot') ||
        context.toLowerCase().contains('lunas');

    bool hasAskedAboutPrevention = context.toLowerCase().contains('prevent') ||
        context.toLowerCase().contains('iwas') ||
        context.toLowerCase().contains('prevention');

    bool hasAskedAboutCause = context.toLowerCase().contains('cause') ||
        context.toLowerCase().contains('sanhi') ||
        context.toLowerCase().contains('bakit');

    // IMPROVED: Check for common follow-up patterns that indicate continuation of a conversation
    bool isFollowUpQuestion = _isFollowUpQuestion(question, isTagalog);
    print('Is follow-up question: $isFollowUpQuestion');

    // For simple follow-up questions, ensure we maintain reference to the deficiency
    if (isFollowUpQuestion) {
      print('Handling follow-up question with reinforced context awareness');
      return _generateSpecificTreatmentAnswer(deficiency, isTagalog);
    }

    if (isTagalog) {
      // If it's related to treatment but not a simple action question
      if (question.toLowerCase().contains('paano') ||
          question.toLowerCase().contains('treatment') ||
          question.toLowerCase().contains('gamutin') ||
          question.toLowerCase().contains('lunas')) {
        return _generateTagalogAnswer(deficiency, 'paano gamutin');
      }

      // If it's about prevention
      if (question.toLowerCase().contains('iwas') ||
          question.toLowerCase().contains('prevent') ||
          question.toLowerCase().contains('hindi mangyari') ||
          question.toLowerCase().contains('maiwasan')) {
        return 'Para maiwasan ang $deficiency deficiency sa iyong mga puno ng saging, sundin ang mga sumusunod na hakbang:\n\n'
            '1. Regular na suriin ang lupa - magsagawa ng soil testing taun-taon\n'
            '2. Gumamit ng balanced na pataba na may sapat na $deficiency\n'
            '3. Panatilihin ang tamang pH ng lupa para sa mas mahusay na pagsipsip ng sustansya\n'
            '4. I-monitor ang mga dahon para sa maagang palatandaan ng kakulangan\n'
            '5. Magpatubig nang maayos dahil nakakaapekto ang stress sa tubig sa pagsipsip ng sustansya\n\n'
            'Tandaan na ang pag-iwas ay mas madali kaysa sa paggamot ng mga kakulangan kapag lumala na ang mga ito.';
      }

      // If it's about the cause
      if (question.toLowerCase().contains('bakit') ||
          question.toLowerCase().contains('sanhi') ||
          question.toLowerCase().contains('dahilan')) {
        switch (deficiency) {
          case 'Sulphur':
            return 'Ang kakulangan ng Sulphur sa mga puno ng saging ay kadalasang dulot ng mga sumusunod na kadahilanan:\n\n'
                '1. Mababang antas ng organic matter sa lupa\n'
                '2. Mataas na pH ng lupa (higit sa 7.5) na nagpapababa sa availability ng sulphur\n'
                '3. Labis na pag-ulan na naghuhugas ng sulphur mula sa lupa\n'
                '4. Hindi balanseng paggamit ng mga pataba na mataas ang nitrogen\n'
                '5. Lupa na may mababang katangiang mag-hold ng nutrients\n\n'
                'Ang Sulphur ay mahalaga para sa pagsasanthesis ng protina at paggana ng enzyme. Kapag kulang sa sulphur, ang mga dahon ay nagiging dilaw at ang halaman ay hindi nakakagawa ng sapat na protina para sa maayos na paglaki.';
          case 'Potassium':
            return 'Ang kakulangan ng Potassium sa mga puno ng saging ay kadalasang dulot ng mga sumusunod na kadahilanan:\n\n'
                '1. Lupa na likas na mababa ang potassium\n'
                '2. Labis na aplikasyon ng calcium o magnesium na nakikipag-compete sa potassium\n'
                '3. Malakas na pag-ulan na naghuhugas ng potassium mula sa lupa\n'
                '4. Mataas na yield ng pananim na kumukonsume ng maraming potassium\n'
                '5. Hindi sapat na replacement ng nutrients pagkatapos ng mga ani\n\n'
                'Ang Potassium ay mahalaga para sa regulasyon ng tubig, pagsasalin ng carbohydrates, at pagbuo ng bunga. Kapag kulang sa potassium, ang mga dahon ay magpapakita ng pagdilaw at pagkasunog sa mga gilid, nagsisimula sa mas matatandang dahon.';
          default:
            return 'Ang kakulangan ng $deficiency sa mga puno ng saging ay maaaring dulot ng iba\'t ibang mga kadahilanan tulad ng:\n\n'
                '1. Hindi sapat na dami ng $deficiency sa lupa\n'
                '2. Hindi tamang pH ng lupa na nakaka-apekto sa pagsipsip ng sustansya\n'
                '3. Hindi balanseng paggamit ng iba pang pataba\n'
                '4. Labis na pag-ulan na naghuhugas ng nutrients mula sa lupa\n'
                '5. Mga problema sa sistema ng ugat na nakakaapekto sa pagsipsip ng sustansya\n\n'
                'Ang mga regular na pagsusuri ng lupa ay makakatulong na matukoy ang eksaktong sanhi at magbigay ng tamang solusyon.';
        }
      }

      // Default response in Tagalog with context awareness
      return _generateTagalogAnswer(deficiency, question);
    } else {
      // English responses with context awareness

      // If it's related to treatment but not a simple action question
      if (question.toLowerCase().contains('how') ||
          question.toLowerCase().contains('treatment') ||
          question.toLowerCase().contains('fix') ||
          question.toLowerCase().contains('remedy')) {
        return _generateAnswer(deficiency, 'how to treat', isTagalog: false);
      }

      // If it's about prevention
      if (question.toLowerCase().contains('prevent') ||
          question.toLowerCase().contains('avoid') ||
          question.toLowerCase().contains('stop') ||
          question.toLowerCase().contains('future')) {
        return 'To prevent $deficiency deficiency in your banana plants, follow these steps:\n\n'
            '1. Conduct regular soil testing - annual or bi-annual testing is recommended\n'
            '2. Use balanced fertilizers with adequate $deficiency content\n'
            '3. Maintain proper soil pH for optimal nutrient absorption\n'
            '4. Monitor leaves for early signs of deficiency\n'
            '5. Ensure proper irrigation as water stress affects nutrient uptake\n\n'
            'Remember that prevention is easier than treating deficiencies once they become severe.';
      }

      // If it's about the cause
      if (question.toLowerCase().contains('why') ||
          question.toLowerCase().contains('cause') ||
          question.toLowerCase().contains('reason')) {
        switch (deficiency) {
          case 'Sulphur':
            return 'Sulphur deficiency in banana plants is typically caused by:\n\n'
                '1. Low organic matter in soil\n'
                '2. High soil pH (above 7.5) that reduces sulphur availability\n'
                '3. Excessive rainfall leaching sulphur from soil\n'
                '4. Imbalanced use of high-nitrogen fertilizers\n'
                '5. Soils with poor nutrient-holding capacity\n\n'
                'Sulphur is essential for protein synthesis and enzyme function. When deficient, leaves become yellow and the plant cannot produce enough protein for proper growth.';
          case 'Potassium':
            return 'Potassium deficiency in banana plants is typically caused by:\n\n'
                '1. Soils naturally low in potassium\n'
                '2. Excessive application of calcium or magnesium that compete with potassium\n'
                '3. Heavy rainfall leaching potassium from soil\n'
                '4. High crop yields consuming large amounts of potassium\n'
                '5. Inadequate nutrient replacement after harvests\n\n'
                'Potassium is crucial for water regulation, carbohydrate translocation, and fruit development. When deficient, leaves show yellowing and scorching at the margins, starting with older leaves.';
          default:
            return '$deficiency deficiency in banana plants can be caused by various factors such as:\n\n'
                '1. Insufficient $deficiency levels in the soil\n'
                '2. Improper soil pH affecting nutrient uptake\n'
                '3. Imbalanced application of other fertilizers\n'
                '4. Excessive rainfall leaching nutrients from soil\n'
                '5. Root system issues affecting nutrient absorption\n\n'
                'Regular soil testing can help identify the exact cause and provide the appropriate solution.';
        }
      }

      // Default response in English with context awareness
      return _generateAnswer(deficiency, question, isTagalog: false);
    }
  }

  // Check if the question is a simple action question like "what should I do?" or "how to fix?"
  bool _isSimpleActionQuestion(String question, bool isTagalog) {
    question = question.toLowerCase().trim();

    // Extremely simple questions are likely asking for action
    if (question.length < 15) {
      return true;
    }

    if (isTagalog) {
      // Common Tagalog action questions
      final List<String> actionPatterns = [
        'anong gagawin',
        'paano gamutin',
        'ano dapat gawin',
        'paano ayusin',
        'anong solusyon',
        'paano ko gagawin',
        'paano ko masosolusyonan',
        'ano ang lunas',
        'pano ko iiwasan',
        'ano ang paraan',
        'paano ito',
        'ano ang dapat',
        'para ma',
        'gagawin ko',
        'gawin ko',
        'ano po',
        'paano po',
        'tulungan',
        'help'
      ];

      for (String pattern in actionPatterns) {
        if (question.contains(pattern)) {
          return true;
        }
      }
    } else {
      // Common English action questions
      final List<String> actionPatterns = [
        'what should i do',
        'how to fix',
        'how to treat',
        'what is the treatment',
        'what is the solution',
        'what to do',
        'how do i',
        'how can i',
        'what steps',
        'how to address',
        'what now',
        'now what',
        'next steps',
        'help me'
      ];

      for (String pattern in actionPatterns) {
        if (question.contains(pattern)) {
          return true;
        }
      }
    }

    return false;
  }

  // Generates specific treatment answers for simple action questions
  String _generateSpecificTreatmentAnswer(String deficiency, bool isTagalog) {
    if (isTagalog) {
      switch (deficiency) {
        case 'Sulphur':
          return 'Para sa kakulangan ng Sulphur na nakita sa iyong saging, narito ang mga hakbang na dapat gawin:\n\n'
              '1. **Mag-apply ng elemental sulphur** sa lupa, 20-30 kg kada ektarya. Haluin ito sa ibabaw na parte ng lupa.\n\n'
              '2. **Gumamit ng ammonium sulphate** bilang pataba (24% sulphur). Ito ay magbibigay din ng nitrogen sa iyong halaman.\n\n'
              '3. **Mag-apply ng gypsum o calcium sulphate** sa rate na 200-300 kg kada ektarya.\n\n'
              '4. **Dagdag na organikong solusyon:**\n'
              '   - Magdagdag ng compost na mayaman sa organikong bagay\n'
              '   - Gumamit ng dumi ng hayop, lalo na mula sa mga hayop na pinakain ng protinang pagkain\n\n'
              '5. **Pagsubaybay:** Tingnan ang pagbabago sa mga bagong dahon sa loob ng 4-6 na linggo. Kung ang pH ng lupa ay mas mataas sa 7.5, maaaring kailangang baguhin ang pH ng lupa upang maging mas available ang sulphur.\n\n'
              'Tandaan: Mas mainam na gawin ang paggamot na ito sa umaga o sa hapon, at siguraduhing may sapat na tubig ang halaman pagkatapos ng application.';

        case 'Potassium':
          return 'Para sa kakulangan ng Potassium na nakita sa iyong saging, narito ang mga hakbang na dapat gawin:\n\n'
              '1. **Mag-apply ng potassium sulphate** (sulphate of potash) sa rate na 300-500 kg kada ektarya.\n\n'
              '2. **Gumamit ng potassium chloride** (muriate of potash) sa rate na 250-400 kg kada ektarya.\n\n'
              '3. **Mag-spray ng foliar** na may potassium nitrate (1-2% solution) para sa mabilis na pagpasok ng sustansya.\n\n'
              '4. **Dagdag na organikong solusyon:**\n'
              '   - Maglagay ng abo ng kahoy (mayaman sa potassium)\n'
              '   - Gumamit ng mga balat ng saging o compost na may labi ng saging\n'
              '   - Mag-apply ng seaweed extract\n\n'
              '5. **Pag-iwas:** Iwasan ang sobrang paglalagay ng magnesium dahil nagkokompetensya ito sa pagsipsip ng potassium.\n\n'
              'Tandaan: Importante na isabay ang paglalagay ng potassium sa wastong dami ng tubig para sa mas epektibong pagsipsip ng sustansya.';

        // Add other deficiencies as needed
        default:
          return _generateTagalogAnswer(deficiency, "anong gagawin ko");
      }
    } else {
      switch (deficiency) {
        case 'Sulphur':
          return 'For the Sulphur deficiency detected in your banana plants, here are the specific steps you should take:\n\n'
              '1. **Apply elemental sulphur** to the soil at 20-30 kg per hectare. Work it into the top layer of soil.\n\n'
              '2. **Use ammonium sulphate** as fertilizer (24% sulphur). This will also provide nitrogen to your plants.\n\n'
              '3. **Apply gypsum or calcium sulphate** at a rate of 200-300 kg per hectare.\n\n'
              '4. **Additional organic solutions:**\n'
              '   - Add compost rich in organic matter\n'
              '   - Use manures from animals fed high-protein diets\n\n'
              '5. **Monitoring:** Look for improvement in new leaves within 4-6 weeks. Soil pH above 7.5 can reduce sulphur availability, so consider pH adjustments if needed.\n\n'
              'Note: It is best to apply these treatments in the morning or evening, and ensure the plants have adequate water after application.';

        case 'Potassium':
          return 'For the Potassium deficiency detected in your banana plants, here are the specific steps you should take:\n\n'
              '1. **Apply potassium sulphate** (sulphate of potash) at a rate of 300-500 kg per hectare.\n\n'
              '2. **Use potassium chloride** (muriate of potash) at a rate of 250-400 kg per hectare.\n\n'
              '3. **Apply foliar spray** with potassium nitrate (1-2% solution) for quick absorption.\n\n'
              '4. **Additional organic solutions:**\n'
              '   - Apply wood ash (rich in potassium)\n'
              '   - Use banana peels or compost with banana residues\n'
              '   - Apply seaweed extract\n\n'
              '5. **Caution:** Avoid excessive magnesium application as it competes with potassium uptake.\n\n'
              'Note: It is important to coordinate potassium application with proper irrigation for more effective nutrient absorption.';

        // Add other deficiencies as needed
        default:
          return _generateAnswer(deficiency, "what should I do",
              isTagalog: false);
      }
    }
  }

  // Simple Tagalog detection based on common words and markers
  bool _detectTagalog(String text) {
    // First, check the current locale
    if (currentLocale?.languageCode == 'tl') {
      return true;
    }

    // For very short texts (1-3 words), we need special handling
    final trimmedText = text.trim();
    final wordCount = trimmedText.split(RegExp(r'\s+')).length;

    // Common very short Tagalog phrases that might be queries
    if (wordCount <= 3) {
      final shortTagalogPhrases = [
        'ano',
        'paano',
        'saan',
        'kailan',
        'bakit',
        'sino',
        'ganito',
        'ganyan',
        'ito',
        'iyan',
        'anong gagawin',
        'paano ito',
        'ano po',
        'tulungan mo',
        'salamat po',
        'mabuti po',
        'pasensya na',
        'hindi ko',
        'oo nga',
        'sige po',
        'tama po',
        'magkano',
        'kailangan ko',
        'gusto ko',
        'ayoko',
      ];

      for (var phrase in shortTagalogPhrases) {
        if (trimmedText.toLowerCase() == phrase ||
            trimmedText.toLowerCase().startsWith('$phrase ') ||
            trimmedText.toLowerCase().endsWith(' $phrase') ||
            trimmedText.toLowerCase().contains(' $phrase ')) {
          return true;
        }
      }
    }

    // For longer texts, use our standard word matching approach
    final tagalogMarkers = [
      'ano',
      'paano',
      'bakit',
      'kailan',
      'saan',
      'sino',
      'alin',
      'ko',
      'mo',
      'niya',
      'namin',
      'natin',
      'nila',
      'nang',
      'ng',
      'sa',
      'ang',
      'mga',
      'ito',
      'yan',
      'yun',
      'na',
      'pa',
      'ba',
      'po',
      'hindi',
      'oo',
      'hindi',
      'salamat',
      'kamusta',
      'mabuti',
      'gagawin',
      'ginagawa',
      'ginawa',
      'gagamitin',
      'gaano'
    ];

    final lowerText = text.toLowerCase();

    // Count how many Tagalog markers appear in the text
    int tagalogWordCount = 0;
    for (var word in tagalogMarkers) {
      // Check for whole word matches, not just substrings
      RegExp wordRegex = RegExp(r'\b' + word + r'\b', caseSensitive: false);
      if (wordRegex.hasMatch(lowerText)) {
        tagalogWordCount++;
      }
    }

    // If more than 2 Tagalog markers detected, consider it Tagalog
    // For shorter texts (less than 10 words), even 1 marker might be enough
    if (wordCount < 10) {
      return tagalogWordCount >= 1;
    } else {
      return tagalogWordCount > 2;
    }
  }

  // Simulated responses for prototype
  String _generateDeficiencyExplanation(String deficiency, double confidence) {
    final String confidenceStr = (confidence * 100).toStringAsFixed(0);

    // Check if we should use Filipino
    bool useFilipino = currentLocale?.languageCode == 'tl';

    final explanationsEnglish = {
      'Sulphur':
          'Your banana plants are showing signs of Sulphur deficiency ($confidenceStr% confidence). Sulphur is essential for protein synthesis and enzyme function. When deficient, younger leaves show uniform yellowing. The plant\'s growth becomes stunted, and fruiting may be delayed.',
      'Potassium':
          'Your banana plants are showing signs of Potassium deficiency ($confidenceStr% confidence). Potassium plays a key role in water regulation and sugar transport. Deficient plants show yellowing and scorching along leaf margins, starting with older leaves. Fruits may be smaller and have irregular ripening.',
      'Magnesium':
          'Your banana plants are showing signs of Magnesium deficiency ($confidenceStr% confidence). Magnesium is central to chlorophyll production. When deficient, leaves show interveinal chlorosis (yellowing between veins) while veins remain green, often with a Christmas tree pattern.',
      'Boron':
          'Your banana plants are showing signs of Boron deficiency ($confidenceStr% confidence). Boron affects cell wall structure and new growth. Deficiency causes deformed, bunched leaves and stunted growth at the top of the plant. Fruits may be deformed with "hard core" symptoms.',
      'Calcium':
          'Your banana plants are showing signs of Calcium deficiency ($confidenceStr% confidence). Calcium is crucial for cell wall development. Deficiency shows as chlorosis of leaf margins, distorted growth, and weakened structural integrity. Fruits may show premature ripening.',
      'Iron':
          'Your banana plants are showing signs of Iron deficiency ($confidenceStr% confidence). Iron is essential for chlorophyll synthesis. Deficient plants show distinct yellowing of young leaves with green veins. Severe cases can lead to completely pale or white young leaves.',
      'Manganese':
          'Your banana plants are showing signs of Manganese deficiency ($confidenceStr% confidence). Manganese affects photosynthesis and nitrogen metabolism. Symptoms appear as interveinal chlorosis on younger leaves, often with a fishbone or comb-like pattern.',
      'Zinc':
          'Your banana plants are showing signs of Zinc deficiency ($confidenceStr% confidence). Zinc is needed for growth hormone production. Deficiency causes small, narrow leaves clustered at shoot tips, creating a "rosette" appearance. Leaf veins often remain darker while leaf tissues yellow.',
      'Healthy':
          'Good news! Your banana plants appear healthy ($confidenceStr% confidence). The leaves show good coloration and no signs of nutrient deficiencies. Continue with your current management practices to maintain plant health.',
    };

    final explanationsFilipino = {
      'Sulphur':
          'Ang iyong mga puno ng saging ay nagpapakita ng palatandaan ng kakulangan sa Sulphur ($confidenceStr% kumpiyansa). Ang Sulphur ay mahalaga para sa pagsasanth-esis ng protina at paggana ng enzymes. Kapag may kakulangan, ang mga nakakabatang dahon ay nagpapakita ng pantay na pagdilaw. Ang paglaki ng halaman ay nagiging mabagal, at maaaring maantala ang pamumulaklak.',
      'Potassium':
          'Ang iyong mga puno ng saging ay nagpapakita ng palatandaan ng kakulangan sa Potassium ($confidenceStr% kumpiyansa). Ang Potassium ay may mahalagang papel sa regulasyon ng tubig at transportasyon ng asukal. Ang mga halamang may kakulangan ay nagpapakita ng pagdilaw at pagkasunog sa gilid ng dahon, nagsisimula sa mas matatandang dahon. Ang mga bunga ay maaaring mas maliit at may hindi pantay na paghinog.',
      'Magnesium':
          'Ang iyong mga puno ng saging ay nagpapakita ng palatandaan ng kakulangan sa Magnesium ($confidenceStr% kumpiyansa). Ang Magnesium ay mahalaga para sa produksyon ng chlorophyll. Kapag may kakulangan, ang mga dahon ay nagpapakita ng interveinal chlorosis (pagdilaw sa pagitan ng mga ugat) habang ang mga ugat ay nananatiling berde, kadalasang may pattern na parang Christmas tree.',
      'Boron':
          'Ang iyong mga puno ng saging ay nagpapakita ng palatandaan ng kakulangan sa Boron ($confidenceStr% kumpiyansa). Nakakaapekto ang Boron sa istraktura ng cell wall at bagong paglaki. Ang kakulangan ay nagiging sanhi ng deformado at nagbubukol na mga dahon at mabagal na paglaki sa tuktok ng halaman. Ang mga bunga ay maaaring deformado na may sintomas ng "hard core".',
      'Calcium':
          'Ang iyong mga puno ng saging ay nagpapakita ng palatandaan ng kakulangan sa Calcium ($confidenceStr% kumpiyansa). Ang Calcium ay mahalaga para sa pagbuo ng cell wall. Ang kakulangan ay nagpapakita bilang chlorosis ng mga gilid ng dahon, distorted growth, at mahinang structural integrity. Ang mga bunga ay maaaring magpakita ng maagang paghinog.',
      'Iron':
          'Ang iyong mga puno ng saging ay nagpapakita ng palatandaan ng kakulangan sa Iron ($confidenceStr% kumpiyansa). Ang Iron ay mahalaga para sa synthesis ng chlorophyll. Ang mga halamang may kakulangan ay nagpapakita ng malinaw na pagdilaw ng mga batang dahon na may berdeng ugat. Ang matinding kaso ay maaaring magresulta sa mga dahon na maputla o puting mga batang dahon.',
      'Manganese':
          'Ang iyong mga puno ng saging ay nagpapakita ng palatandaan ng kakulangan sa Manganese ($confidenceStr% kumpiyansa). Nakakaapekto ang Manganese sa photosynthesis at metabolismo ng nitrogen. Ang mga sintomas ay lumalabas bilang interveinal chlorosis sa mga nakakabatang dahon, kadalasang may pattern na parang fishbone o suklay.',
      'Zinc':
          'Ang iyong mga puno ng saging ay nagpapakita ng palatandaan ng kakulangan sa Zinc ($confidenceStr% kumpiyansa). Ang Zinc ay kailangan para sa produksyon ng growth hormone. Ang kakulangan ay nagdudulot ng maliliit, makikitid na dahon na nakagrupo sa dulo ng shoot, na lumilikha ng "rosette" na hitsura. Ang mga ugat ng dahon ay kadalasang nananatiling mas maitim habang ang tisyu ng dahon ay dumidilaw.',
      'Healthy':
          'Mabuting balita! Ang iyong mga puno ng saging ay mukhang malusog ($confidenceStr% kumpiyansa). Ang mga dahon ay nagpapakita ng magandang kulay at walang palatandaan ng kakulangan sa sustansya. Ipagpatuloy ang iyong kasalukuyang mga gawain sa pamamahala upang mapanatili ang kalusugan ng halaman.',
    };

    final explanations =
        useFilipino ? explanationsFilipino : explanationsEnglish;

    if (explanations.containsKey(deficiency)) {
      return explanations[deficiency]!;
    } else {
      if (useFilipino) {
        return 'Ang iyong mga puno ng saging ay nagpapakita ng palatandaan ng kakulangan sa $deficiency. Nakita ito ng aming sistema na may $confidenceStr% kumpiyansa. Upang mapabuti ang kalusugan ng halaman, isaalang-alang ang pag-test ng lupa at target na pataba.';
      } else {
        return 'Your banana plants show signs of $deficiency deficiency. Our system detected this with $confidenceStr% confidence. To improve plant health, consider soil testing and targeted fertilization.';
      }
    }
  }

  String _generateTreatmentRecommendation(String deficiency) {
    // Check if we should use Filipino
    bool useFilipino = currentLocale?.languageCode == 'tl';

    final recommendationsEnglish = {
      'Sulphur': '**Treatment options:**\n\n'
          '1. **Apply elemental sulphur** at 20-30 kg/hectare worked into the soil\n'
          '2. **Use ammonium sulphate** as a nitrogen source (24% sulphur)\n'
          '3. **Apply gypsum (calcium sulphate)** at 200-300 kg/hectare\n\n'
          '**Organic options:**\n'
          '- Incorporate compost rich in organic matter\n'
          '- Use manures from animals fed high-protein diets\n\n'
          '**Monitoring:**\n'
          'Improvement should be visible in new leaves within 4-6 weeks. Soil pH above 7.5 can reduce sulphur availability, so consider pH adjustments if needed.',
      'Potassium': '**Treatment options:**\n\n'
          '1. **Apply potassium sulphate** (sulphate of potash) at 300-500 kg/hectare\n'
          '2. **Use potassium chloride** (muriate of potash) at 250-400 kg/hectare\n'
          '3. **Foliar spray** with potassium nitrate (1-2%) for quick absorption\n\n'
          '**Organic options:**\n'
          '- Apply wood ash (rich in potassium)\n'
          '- Use banana peels or compost with banana residues\n'
          '- Apply seaweed extract\n\n'
          '**Caution:**\n'
          'Avoid excessive magnesium, which can compete with potassium uptake.',
      'Magnesium': '**Treatment options:**\n\n'
          '1. **Apply magnesium sulphate (Epsom salt)** at 20-40 kg/hectare\n'
          '2. **Use dolomitic limestone** if soil is also acidic\n'
          '3. **Foliar spray** with 2% magnesium sulphate solution for quick results\n\n'
          '**Application timing:**\n'
          'Best applied during early growth stages or after harvest before next cycle\n\n'
          '**Monitoring:**\n'
          'Symptoms should improve within 3-4 weeks with foliar application. Soil applications may take longer to show results.',
      'Healthy': 'Your banana plants appear healthy! Continue your current management practices:\n\n'
          '1. **Maintain balanced fertilization** following local recommendations\n'
          '2. **Monitor soil moisture** and provide adequate irrigation\n'
          '3. **Practice proper weed control** to reduce competition\n'
          '4. **Scout regularly** for early signs of pest, disease, or nutrient issues\n\n'
          'Consider conducting annual soil tests to ensure optimal nutrient levels are maintained.',
    };

    final recommendationsFilipino = {
      'Sulphur': '**Mga opsyon sa paggamot:**\n\n'
          '1. **Maglagay ng elemental sulphur** sa 20-30 kg/ektarya na isasama sa lupa\n'
          '2. **Gumamit ng ammonium sulphate** bilang pinagkukunan ng nitrogen (24% sulphur)\n'
          '3. **Maglagay ng gypsum (calcium sulphate)** sa 200-300 kg/ektarya\n\n'
          '**Mga organikong opsyon:**\n'
          '- Isama ang compost na mayaman sa organikong materyal\n'
          '- Gumamit ng dumi ng hayop na pinakain ng pagkaing mataas sa protina\n\n'
          '**Pagsubaybay:**\n'
          'Dapat makita ang pagbuti sa mga bagong dahon sa loob ng 4-6 na linggo. Ang pH ng lupa na higit sa 7.5 ay maaaring magpababa sa availability ng sulphur, kaya\'t isaalang-alang ang mga pagsasaayos ng pH kung kinakailangan.',
      'Potassium': '**Mga opsyon sa paggamot:**\n\n'
          '1. **Maglagay ng potassium sulphate** (sulphate of potash) sa 300-500 kg/ektarya\n'
          '2. **Gumamit ng potassium chloride** (muriate of potash) sa 250-400 kg/ektarya\n'
          '3. **Foliar spray** gamit ang potassium nitrate (1-2%) para sa mabilis na pagsipsip\n\n'
          '**Mga organikong opsyon:**\n'
          '- Maglagay ng abo ng kahoy (mayaman sa potassium)\n'
          '- Gumamit ng mga balat ng saging o compost na may mga labi ng saging\n'
          '- Maglagay ng seaweed extract\n\n'
          '**Babala:**\n'
          'Iwasan ang labis na magnesium, na maaaring makipagkompetensya sa pagsipsip ng potassium.',
      'Magnesium': '**Mga opsyon sa paggamot:**\n\n'
          '1. **Maglagay ng magnesium sulphate (Epsom salt)** sa 20-40 kg/ektarya\n'
          '2. **Gumamit ng dolomitic limestone** kung ang lupa ay maasim din\n'
          '3. **Foliar spray** gamit ang 2% na solusyon ng magnesium sulphate para sa mabilis na resulta\n\n'
          '**Timing ng aplikasyon:**\n'
          'Pinakamainam na ilapat sa mga maagang yugto ng paglaki o pagkatapos ng ani bago ang susunod na cycle\n\n'
          '**Pagsubaybay:**\n'
          'Dapat bumuti ang mga sintomas sa loob ng 3-4 na linggo ng foliar application. Ang mga aplikasyon sa lupa ay maaaring tumagal pa bago makitang ang mga resulta.',
      'Healthy': 'Ang iyong mga saging ay mukhang malusog! Ipagpatuloy ang iyong kasalukuyang mga gawain sa pamamahala:\n\n'
          '1. **Panatilihin ang balanced na fertilization** ayon sa mga lokal na rekomendasyon\n'
          '2. **Subaybayan ang kahalumigmigan ng lupa** at magbigay ng sapat na patubig\n'
          '3. **Magsagawa ng tamang kontrol sa damo** para mabawasan ang kompetisyon\n'
          '4. **Regular na suriin** para sa mga maagang senyales ng peste, sakit, o mga isyu sa sustansya\n\n'
          'Isaalang-alang ang pagsasagawa ng taunang pagsusuri ng lupa para matiyak na napapanatili ang pinakamainam na antas ng sustansya.',
    };

    final recommendations =
        useFilipino ? recommendationsFilipino : recommendationsEnglish;

    // Default recommendation if specific one not found
    if (recommendations.containsKey(deficiency)) {
      return recommendations[deficiency]!;
    } else {
      if (useFilipino) {
        return '**Pangkalahatang rekomendasyon para sa kakulangan ng $deficiency:**\n\n'
            '1. **Magsagawa ng pagsusuri ng lupa** upang kumpirmahin ang kakulangan at suriin ang mga kaugnay na kawalan ng balanse\n'
            '2. **Maglagay ng angkop na mga pataba** na naglalaman ng $deficiency batay sa mga resulta ng pagsusuri ng lupa\n'
            '3. **Isaalang-alang ang foliar application** para sa mas mabilis na mga resulta sa maikling panahon\n'
            '4. **Magpatupad ng balanseng programa sa nutrisyon** upang maiwasan ang mga kakulangan sa hinaharap\n\n'
            'Kumunsulta sa lokal na ahente ng agricultural extension para sa mga partikular na rate at mga produktong available sa iyong lugar.';
      } else {
        return '**General recommendation for $deficiency deficiency:**\n\n'
            '1. **Conduct a soil test** to confirm deficiency and check for related imbalances\n'
            '2. **Apply appropriate fertilizers** containing $deficiency based on soil test results\n'
            '3. **Consider foliar application** for quicker short-term results\n'
            '4. **Implement a balanced nutrition program** to prevent future deficiencies\n\n'
            'Consult with a local agricultural extension agent for specific rates and products available in your area.';
      }
    }
  }

  String _generateAnswer(String deficiency, String question,
      {bool isTagalog = false}) {
    // If response should be in Tagalog
    if (isTagalog) {
      return _generateTagalogAnswer(deficiency, question);
    }

    // Simple keyword matching for English responses
    // In production, this would be replaced with a real LLM call
    if (question.toLowerCase().contains('organic') ||
        question.toLowerCase().contains('natural')) {
      return 'For organic management of $deficiency deficiency, consider:\n\n'
          '- Adding compost rich in the specific nutrient\n'
          '- Using approved organic amendments like:\n'
          '  • Rock phosphate for phosphorus\n'
          '  • Kelp meal for potassium and micronutrients\n'
          '  • Blood meal for nitrogen\n'
          '- Improving soil biology with beneficial microorganisms\n'
          '- Using cover crops that can help mobilize specific nutrients';
    }

    if (question.toLowerCase().contains('cost') ||
        question.toLowerCase().contains('expensive') ||
        question.toLowerCase().contains('price')) {
      return 'The cost of treating $deficiency deficiency varies based on::\n\n'
          '1. Severity of the deficiency\n'
          '2. Size of your plantation\n'
          '3. Local availability of products\n\n'
          'For a small farm (1-2 hectares), budget approximately \$100-200 per hectare for amendments. Foliar sprays tend to be more cost-effective short-term, while soil amendments provide better long-term results.';
    }

    if (question.toLowerCase().contains('time') ||
        question.toLowerCase().contains('how long') ||
        question.toLowerCase().contains('quick')) {
      return 'Recovery time from $deficiency deficiency depends on severity and treatment method:\n\n'
          '- **Foliar applications:** Visible improvement within 1-2 weeks\n'
          '- **Soil amendments:** May take 1-2 months to see full response\n'
          '- **Severe deficiencies:** Complete recovery may require a full growth cycle\n\n'
          'New leaves will show improvement first, while existing damaged leaves won\'t recover completely.';
    }

    if (question.toLowerCase().contains('prevent') ||
        question.toLowerCase().contains('avoid') ||
        question.toLowerCase().contains('future')) {
      return 'To prevent future $deficiency deficiencies:\n\n'
          '1. **Regular soil testing** (annually or bi-annually)\n'
          '2. **Balanced fertilization program** based on crop removal rates\n'
          '3. **Proper pH management** as nutrient availability is pH-dependent\n'
          '4. **Adequate organic matter** to improve nutrient retention\n'
          '5. **Proper irrigation management** as water stress affects nutrient uptake\n'
          '6. **Crop rotation** where applicable to balance soil nutrient use';
    }

    // For questions about how to apply treatments
    if (question.toLowerCase().contains('how') &&
        (question.toLowerCase().contains('apply') ||
            question.toLowerCase().contains('do') ||
            question.toLowerCase().contains('use') ||
            question.toLowerCase().contains('implement'))) {
      return 'To apply $deficiency treatments effectively:\n\n'
          '1. **For soil applications:**\n'
          '   - Apply fertilizers in a circle around the plant, about 30-50cm from the trunk\n'
          '   - Work the fertilizer into the top 5-10cm of soil\n'
          '   - Water thoroughly after application\n\n'
          '2. **For foliar sprays:**\n'
          '   - Mix the recommended solution in clean water\n'
          '   - Apply during early morning or late afternoon (avoid hot midday sun)\n'
          '   - Ensure good coverage of leaf surfaces, especially undersides\n'
          '   - Repeat application as recommended (usually every 2-4 weeks)\n\n'
          'Always follow specific product instructions and wear appropriate protective gear when handling fertilizers.';
    }

    // Default response if no keywords match
    return 'For $deficiency deficiency treatment, follow these steps:\n\n'
        '1. Apply the recommended fertilizer at the correct rate for your banana plants\n'
        '2. Ensure proper watering after application to help nutrients dissolve\n'
        '3. Monitor your plants for improvement - look for healthy new leaf growth\n'
        '4. Consider foliar sprays for faster results in severe cases\n\n'
        'Remember that consistency is key when treating nutrient deficiencies. A balanced fertilization program will help prevent future issues.';
  }

  // Tagalog responses for common questions
  String _generateTagalogAnswer(String deficiency, String question) {
    // Simplistic approach - in production would use a proper LLM

    // For questions about how to apply treatments
    if (question.toLowerCase().contains('paano') ||
        question.toLowerCase().contains('gawin') ||
        question.toLowerCase().contains('gagawin')) {
      switch (deficiency) {
        case 'Potassium':
          return 'Para gamutin ang Potassium deficiency sa iyong saging:\n\n'
              '1. **Para sa lupa:**\n'
              '   - Mag-apply ng potassium sulfate (300-500 kg bawat ektarya)\n'
              '   - Ilagay ang pataba sa palibot ng puno, mga 30-50cm mula sa ugat\n'
              '   - Haluin sa ibabaw ng lupa (5-10cm ang lalim)\n'
              '   - Diligan nang mabuti pagkatapos\n\n'
              '2. **Para sa foliar spray:**\n'
              '   - Gumamit ng 1-2% potassium nitrate solution\n'
              '   - I-spray sa umaga o hapon (iwasan ang tanghaling tapat)\n'
              '   - Tiyaking matakpan ang lahat ng dahon, lalo na ang ilalim\n\n'
              '3. **Organic na paraan:**\n'
              '   - Gumamit ng abo ng kahoy (mayaman sa potassium)\n'
              '   - Balat ng saging o compost na may mga tirang saging\n'
              '   - Seaweed extract\n\n'
              'Iwasan ang sobrang magnesium dahil maaari itong makipag-compete sa potassium.';

        case 'Sulphur':
          return 'Para gamutin ang Sulphur deficiency sa iyong saging:\n\n'
              '1. **Para sa lupa:**\n'
              '   - Mag-apply ng elemental sulphur (20-30 kg bawat ektarya)\n'
              '   - Gumamit ng ammonium sulphate kung kailangan din ng nitrogen\n'
              '   - Maglagay ng gypsum o calcium sulphate (200-300 kg bawat ektarya)\n\n'
              '2. **Organic na paraan:**\n'
              '   - Magdagdag ng compost na mayaman sa organic matter\n'
              '   - Gumamit ng pataba mula sa hayop na pinakain ng protina\n\n'
              'Makikita ang pagbabago sa mga bagong dahon pagkalipas ng 4-6 na linggo. Kung ang pH ng lupa ay mas mataas sa 7.5, maaaring kailanganin mong i-adjust ito.';

        default:
          return 'Para gamutin ang $deficiency deficiency sa iyong saging:\n\n'
              '1. **Para sa lupa:**\n'
              '   - Maglagay ng angkop na pataba sa palibot ng puno\n'
              '   - Haluin nang maayos sa ibabaw ng lupa\n'
              '   - Diligan pagkatapos ng paglalagay\n\n'
              '2. **Para sa foliar spray:**\n'
              '   - Gumamit ng angkop na solution para sa $deficiency\n'
              '   - I-spray sa umaga o hapon\n'
              '   - Siguraduhing pantay ang pagkakalat sa mga dahon\n\n'
              'Bantayan ang mga bagong dahon para makita kung may pagbabago. Kadalasan, nakikita ang resulta sa loob ng 2-4 na linggo para sa foliar spray at 1-2 buwan para sa soil application.';
      }
    }

    // For questions about cost
    if (question.toLowerCase().contains('magkano') ||
        question.toLowerCase().contains('presyo') ||
        question.toLowerCase().contains('halaga') ||
        question.toLowerCase().contains('gastos')) {
      return 'Ang halaga ng paggamot ng $deficiency deficiency ay depende sa:\n\n'
          '1. Kalubhaan ng kakulangan\n'
          '2. Laki ng iyong sakahan\n'
          '3. Availability ng produkto sa inyong lugar\n\n'
          'Para sa maliit na sakahan (1-2 ektarya), mag-budget ng humigit-kumulang P5,000-10,000 kada ektarya para sa mga pataba. Ang foliar spray ay mas cost-effective sa maikling panahon, habang ang soil amendments ay nagbibigay ng mas matagal na resulta.';
    }

    // Default Tagalog response
    return 'Para sa $deficiency deficiency sa iyong saging, sundin ang mga hakbang na ito:\n\n'
        '1. Mag-apply ng angkop na pataba sa tamang dami para sa iyong mga puno ng saging\n'
        '2. Siguraduhing diligan nang maayos pagkatapos para matunaw ang mga sustansya\n'
        '3. Bantayan ang mga halaman para sa pagbabago - tingnan ang malusog na bagong dahon\n'
        '4. Isaalang-alang ang foliar spray para sa mas mabilis na resulta kung malubha ang problema\n\n'
        'Tandaan na ang consistency ay mahalaga sa paggamot ng nutrient deficiencies. Ang balanced na fertilization program ay makakatulong para maiwasan ang mga problema sa hinaharap.';
  }

  // New method to detect if a question is a follow-up to a previous conversation
  bool _isFollowUpQuestion(String question, bool isTagalog) {
    question = question.toLowerCase().trim();

    // Very short questions are almost always follow-ups in context
    if (question.length < 10) {
      return true;
    }

    // Tagalog follow-up patterns
    if (isTagalog) {
      final List<String> followUpPatterns = [
        'so ano',
        'so anong',
        'so paano',
        'ano pa',
        'ano ulit',
        'paano ulit',
        'ganun ba',
        'talaga',
        'tapos',
        'sige',
        'oo',
        'hindi',
        'eh paano',
        'eh ano',
        'at ano',
        'at paano',
        'ano ang',
        'paano ang',
        'pano',
        'ano na',
        'e di'
      ];

      for (String pattern in followUpPatterns) {
        if (question.startsWith(pattern) ||
            question.contains(' $pattern ') ||
            question == pattern) {
          return true;
        }
      }
    } else {
      // English follow-up patterns
      final List<String> followUpPatterns = [
        'so what',
        'so how',
        'and then',
        'what else',
        'how else',
        'really',
        'ok',
        'okay',
        'yes',
        'no',
        'just',
        'but',
        'and',
        'so',
        'then',
        'now',
        'next',
        'what now',
        'what about',
        'how about',
        'is that all',
        'that\'s it'
      ];

      for (String pattern in followUpPatterns) {
        if (question.startsWith(pattern) ||
            question.contains(' $pattern ') ||
            question == pattern) {
          return true;
        }
      }
    }

    return false;
  }
}
