import 'dart:math' show max;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class LLMService {
  // Use environment-based configuration
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String get chatEndpoint => '$baseUrl/chat';
  static String get clearContextEndpoint => '$baseUrl/clear-context';

  // Track the current locale
  Locale? currentLocale;

  // For explanations about deficiencies
  Future<String> getDeficiencyExplanation(
      String deficiencyType, double confidence) async {
    try {
      // Add realistic thinking delay for explanation generation
      await _simulateThinkingDelay(
          'deficiency explanation for $deficiencyType');

      // In a real app, you would call your LLM API here
      // For now, let's simulate with static content based on the current locale
      if (currentLocale?.languageCode == 'tl') {
        return _generateTagalogDeficiencyExplanation(
            deficiencyType, confidence);
      } else {
        return _generateDeficiencyExplanation(deficiencyType, confidence);
      }
    } catch (e) {
      debugPrint('Error getting deficiency explanation: $e');
      if (currentLocale?.languageCode == 'tl') {
        return 'Hindi ma-generate ang paliwanag sa ngayon. Pakisubukang muli mamaya.';
      } else {
        return 'Unable to generate explanation. Please try again later.';
      }
    }
  }

  // Generate explanation in English
  String _generateDeficiencyExplanation(
      String deficiencyType, double confidence) {
    final confidencePercent = (confidence * 100).toStringAsFixed(0);

    switch (deficiencyType) {
      case 'Calcium':
        return 'Your banana plants are showing signs of Calcium deficiency ($confidencePercent% confidence). Calcium is crucial for cell wall development. Deficiency shows as chlorosis of leaf margins, distorted growth, and weakened structural integrity. Fruits may show premature ripening.';

      case 'Nitrogen':
        return 'Your banana plants are showing signs of Nitrogen deficiency ($confidencePercent% confidence). Nitrogen is essential for leaf and stem growth. Deficiency appears as yellowing of older leaves, stunted growth, and reduced fruit size and yield.';

      case 'Potassium':
        return 'Your banana plants are showing signs of Potassium deficiency ($confidencePercent% confidence). Potassium is key for fruit development and disease resistance. Symptoms include yellow/orange discoloration along leaf margins, starting with older leaves, and reduced fruit quality.';

      case 'Magnesium':
        return 'Your banana plants are showing signs of Magnesium deficiency ($confidencePercent% confidence). Magnesium is essential for chlorophyll production. Deficiency shows as interveinal chlorosis (yellow between green veins) on older leaves, proceeding to younger leaves as the deficiency worsens.';

      case 'Sulphur':
        return 'Your banana plants are showing signs of Sulphur deficiency ($confidencePercent% confidence). Sulphur is important for protein synthesis and enzyme production. Deficiency appears as uniform yellowing of young leaves, thin stems, and slow growth.';

      default:
        return 'Your banana plants are showing signs of $deficiencyType deficiency ($confidencePercent% confidence). This nutrient is important for overall plant health and productivity. The specific symptoms vary but can impact growth, leaf appearance, and fruit quality.';
    }
  }

  // Generate explanation in Tagalog/Filipino
  String _generateTagalogDeficiencyExplanation(
      String deficiencyType, double confidence) {
    final confidencePercent = (confidence * 100).toStringAsFixed(0);

    switch (deficiencyType) {
      case 'Calcium':
        return 'Ang iyong mga puno ng saging ay nagpapakita ng senyales ng kakulangan sa Calcium ($confidencePercent% kumpiyansa). Ang Calcium ay mahalaga para sa pagbuo ng pader ng selula. Ang kakulangan ay lumalabas bilang chlorosis ng mga gilid ng dahon, abnormal na paglaki, at mahinang istraktura. Ang mga prutas ay maaaring magkaroon ng maagang paghinog.';

      case 'Nitrogen':
        return 'Ang iyong mga puno ng saging ay nagpapakita ng senyales ng kakulangan sa Nitrogen ($confidencePercent% kumpiyansa). Ang Nitrogen ay kinakailangan para sa paglaki ng dahon at tangkay. Ang kakulangan ay lumalabas bilang pagdilaw ng mas lumang mga dahon, pinipigilan ang paglaki, at binabawasan ang laki at dami ng prutas.';

      case 'Potassium':
        return 'Ang iyong mga puno ng saging ay nagpapakita ng senyales ng kakulangan sa Potassium ($confidencePercent% kumpiyansa). Ang Potassium ay susi para sa paglaki ng prutas at resistensya sa sakit. Ang mga sintomas ay kinabibilangan ng dilaw/kulay-kahel na pagkasira sa mga gilid ng dahon, nagsisimula sa mas lumang mga dahon, at pinababang kalidad ng prutas.';

      case 'Magnesium':
        return 'Ang iyong mga puno ng saging ay nagpapakita ng senyales ng kakulangan sa Magnesium ($confidencePercent% kumpiyansa). Ang Magnesium ay mahalaga para sa produksyon ng chlorophyll. Ang kakulangan ay lumalabas bilang interveinal chlorosis (dilaw sa pagitan ng berdeng ugat) sa mas lumang mga dahon, patungo sa mas batang mga dahon habang lumalala ang kakulangan.';

      case 'Sulphur':
        return 'Ang iyong mga puno ng saging ay nagpapakita ng senyales ng kakulangan sa Sulphur ($confidencePercent% kumpiyansa). Ang Sulphur ay mahalaga para sa pagbuo ng protina at produksyon ng enzyme. Ang kakulangan ay lumalabas bilang pantay na pagdilaw ng mga batang dahon, manipis na mga tangkay, at mababagal na paglaki.';

      default:
        return 'Ang iyong mga puno ng saging ay nagpapakita ng senyales ng kakulangan sa $deficiencyType ($confidencePercent% kumpiyansa). Ang sustansyang ito ay mahalaga para sa pangkalahatang kalusugan at produktibidad ng halaman. Ang mga partikular na sintomas ay nagkakaiba ngunit maaaring makaapekto sa paglaki, anyo ng dahon, at kalidad ng prutas.';
    }
  }

  // For treatment recommendations
  Future<String> getTreatmentRecommendation(String deficiencyType) async {
    try {
      debugPrint('Getting treatment recommendation for $deficiencyType');

      // Add realistic thinking delay for treatment generation
      await _simulateThinkingDelay(
          'treatment recommendation for $deficiencyType');

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
      debugPrint('Error getting treatment recommendation: $e');
      if (currentLocale?.languageCode == 'tl') {
        return 'Hindi ko ma-generate ang rekomendasyon sa paggamot ngayon. Pakisubukang muli mamaya.';
      } else {
        return 'Unable to generate treatment recommendation. Please try again later.';
      }
    }
  }

  // Call the backend chat API endpoint
  Future<String?> _callBackendChatAPI(String question, String? context) async {
    try {
      // Prepare headers with API key for authentication
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // Add backend API key if available
      final backendApiKey = AppConfig.backendApiKey;
      if (backendApiKey.isNotEmpty) {
        headers['X-API-Key'] = backendApiKey;
      }

      // Build the query - include context if available
      String fullQuery;
      if (context != null && context.isNotEmpty) {
        // If context already contains the user question (like from homepage chat),
        // use it as-is. Otherwise, append the question.
        if (context.contains('User question:') ||
            context.contains('User\'s question:')) {
          // Context already has the question, use it directly
          fullQuery = context;
        } else {
          // Include context in the query for better responses
          fullQuery = '$context\n\nUser question: $question';
        }
      } else {
        fullQuery = question;
      }

      debugPrint('Calling backend chat API at: $chatEndpoint');
      debugPrint('Query length: ${fullQuery.length}');

      // Make API request with longer timeout for Gemini API calls
      final response = await http
          .post(
            Uri.parse(chatEndpoint),
            headers: headers,
            body: jsonEncode({
              'query': fullQuery,
            }),
          )
          .timeout(const Duration(seconds: 90));

      debugPrint('Backend API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final apiResponse = jsonResponse['response'] as String?;

        if (apiResponse != null && apiResponse.isNotEmpty) {
          debugPrint(
              'Backend API response received (${apiResponse.length} chars)');
          // Log a preview to help debug truncation issues
          if (apiResponse.length > 500) {
            debugPrint(
                'Response preview (first 200 chars): ${apiResponse.substring(0, 200)}...');
            debugPrint(
                'Response preview (last 200 chars): ...${apiResponse.substring(apiResponse.length - 200)}');
          }
          return apiResponse;
        } else {
          debugPrint('Backend API returned empty response');
          return null;
        }
      } else {
        debugPrint(
            'Backend API error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error calling backend chat API: $e');
      rethrow;
    }
  }

  // Clear the backend server's conversation context
  Future<void> clearBackendContext() async {
    try {
      debugPrint('Clearing backend chat context');
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // Add backend API key if available
      final backendApiKey = AppConfig.backendApiKey;
      if (backendApiKey.isNotEmpty) {
        headers['X-API-Key'] = backendApiKey;
      }

      final response = await http
          .post(
            Uri.parse(clearContextEndpoint),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('Backend context cleared successfully');
      } else {
        debugPrint('Failed to clear backend context: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error clearing backend context: $e');
      // Don't throw - this is not critical
    }
  }

  // For answering farmer questions with improved context awareness
  Future<String> answerFarmerQuestion(String deficiencyType, String question,
      {String? context}) async {
    try {
      debugPrint('Deficiency type: $deficiencyType');
      debugPrint('Question: $question');
      debugPrint('Context available: ${context != null && context.isNotEmpty}');

      // Try to call the backend API first
      try {
        final response = await _callBackendChatAPI(question, context);
        if (response != null && response.isNotEmpty) {
          debugPrint('Successfully received response from backend API');
          return response;
        }
      } catch (e) {
        debugPrint(
            'Backend API call failed, falling back to local responses: $e');
        // Fall through to fallback responses
      }

      // Add realistic thinking delay before processing (for fallback)
      await _simulateThinkingDelay(question);

      // Check if question is in Tagalog/Filipino
      bool isTagalog =
          _detectTagalog(question) || currentLocale?.languageCode == 'tl';

      debugPrint('Is Tagalog: $isTagalog');

      // ALWAYS use contextual responses when context is provided
      if (context != null && context.isNotEmpty) {
        debugPrint(
            'Using context-aware response for $deficiencyType with full conversation history');
        debugPrint('Context length: ${context.length}');

        // First check for fertilizer questions (higher priority than timeline)
        if (question.toLowerCase().contains("fertilizer") ||
            question.toLowerCase().contains("what should i use") ||
            question.toLowerCase().contains("what to use") ||
            question.toLowerCase().contains("pataba") ||
            question.toLowerCase().contains("abono") ||
            question.toLowerCase().contains("anong fertilizer") ||
            question.toLowerCase().contains("anong pataba") ||
            question.toLowerCase().contains("ano ang pataba") ||
            (question.toLowerCase().contains("kailangan") &&
                question.toLowerCase().contains("pataba"))) {
          debugPrint('Is follow-up question: true (fertilizer question)');

          switch (deficiencyType) {
            case 'Calcium':
              if (isTagalog) {
                return '🍌 **CALCIUM DEFICIENCY - MGA PATABA/ABONO NA KAILANGAN**\n\n'
                    '**MABILIS NA SOLUSYON (Foliar Spray):**\n'
                    '• **Calcium Chloride (CaCl₂)** - 2-3% solution, spray kada 7-10 araw\n'
                    '• **Calcium Nitrate liquid** - 1-2 tablespoon bawat litro tubig\n'
                    '• **Chelated Calcium** - Sundin ang tagubilin sa packaging\n\n'
                    '**PANGMATAGALANG SOLUSYON (Soil Application):**\n'
                    '• **Gypsum (Calcium Sulfate)** - 500-1,000 kg/ektarya, hindi naman acidic\n'
                    '• **Dolomitic Lime** - 1-3 tonelada/ektarya para sa acidic na lupa\n'
                    '• **Calcium Carbonate (Agricultural Lime)** - 2-4 tonelada/ektarya\n'
                    '• **Calcium Nitrate granules** - 200-400 kg/ektarya\n\n'
                    '**MGA MAKAKABILING BRAND SA PILIPINAS:**\n'
                    '• Atlas Gypsum - Mura at available sa agricultural stores\n'
                    '• Soiltech Calcium - May chelated calcium products\n'
                    '• Haifa Calcium Nitrate - Imported pero mataas ang quality\n'
                    '• PhilAgri Dolomite - Local brand na mabisa\n\n'
                    '**TAMANG PARAAN NG PAG-APPLY:**\n'
                    '1. Para sa foliar: Mag-spray sa umaga o hapon, huwag sa tanghali\n'
                    '2. Para sa soil: I-broadcast sa paligid ng puno, 1-2 metro radius\n'
                    '3. Diligan matapos mag-apply ng granular fertilizer\n'
                    '4. Ulitin ang foliar spray kada linggo hanggang gumaling\n\n'
                    '💡 **TIP:** Mas mabuti kung i-combine ang foliar at soil application para sa mas mabilis na resulta!';
              } else {
                return '🍌 **CALCIUM DEFICIENCY - FERTILIZER RECOMMENDATIONS**\n\n'
                    '**QUICK ACTION (Foliar Applications):**\n'
                    '• **Calcium Chloride (CaCl₂)** - 2-3% solution, spray every 7-10 days\n'
                    '• **Liquid Calcium Nitrate** - 1-2 tbsp per liter of water\n'
                    '• **Chelated Calcium** - Follow package instructions for concentration\n\n'
                    '**LONG-TERM SOLUTION (Soil Applications):**\n'
                    '• **Gypsum (Calcium Sulfate)** - 500-1,000 kg/hectare, pH neutral\n'
                    '• **Dolomitic Lime** - 1-3 tons/hectare for acidic soils\n'
                    '• **Calcium Carbonate (Agricultural Lime)** - 2-4 tons/hectare\n'
                    '• **Granular Calcium Nitrate** - 200-400 kg/hectare\n\n'
                    '**RECOMMENDED BRANDS:**\n'
                    '• Atlas Gypsum - Affordable and widely available\n'
                    '• Haifa Calcium Nitrate - Premium quality, fast-acting\n'
                    '• YaraLiva products - Professional grade calcium fertilizers\n'
                    '• Southern States Gypsum - Good for soil conditioning\n\n'
                    '**APPLICATION GUIDELINES:**\n'
                    '1. Foliar sprays: Apply early morning or late afternoon\n'
                    '2. Soil application: Broadcast around drip line, 3-6 feet from trunk\n'
                    '3. Water thoroughly after granular application\n'
                    '4. Repeat foliar treatments weekly until improvement shows\n\n'
                    '💡 **PRO TIP:** Combine both foliar and soil treatments for fastest results!';
              }
            case 'Potassium':
              return 'Para sa Potassium deficiency, gamitin ang mga sumusunod na uri ng pataba:\n\n'
                  '1. **Potassium sulfate (SOP, 50% K₂O)** - Mas mababang salt index, angkop para sa saging sa 300-500 kg/ektarya\n'
                  '2. **Potassium chloride (MOP, 60% K₂O)** - Mas abot-kayang opsyon, gamitin sa 250-400 kg/ektarya\n'
                  '3. **Potassium nitrate (13% N, 44% K₂O)** - Mabilis na pagsipsip, mainam para sa foliar application sa 2-3% solution\n'
                  '4. **NPK fertilizers na mataas sa K** - Tulad ng 13-0-46 o katulad na ratio\n\n'
                  'Para sa foliar spray, gumamit ng 2-3% potassium nitrate solution. Para sa soil application, mag-apply ng pataba sa paligid ng puno, huwag malapit sa ugat. Diligan pagkatapos ng application para mabilis na dissolve.';
            default:
              return 'Para sa $deficiencyType deficiency, ang mga pinakamagandang pataba na pwedeng gamitin ay:\n\n'
                  '1. **Espesyal na $deficiencyType fertilizers** - Maghanap ng mga produktong partikular na ginawa para sa deficiency na ito\n'
                  '2. **Foliar sprays** - Para sa mabilis na pagwawasto, maghanap ng liquid fertilizer na may $deficiencyType\n'
                  '3. **Organikong opsyon** - Compost na pinagyaman ng mga minerals o partikular na organikong amendments\n\n'
                  'Ang eksaktong rate ng application ay depende sa kalubhaan ng deficiency at sa kondisyon ng inyong lupa. Para sa mas tumpak na rekomendasyon, magsagawa ng soil test at kumonsulta sa lokal na agricultural extension specialist.';
          }
        }

        // Special case for timeline questions which are always follow-ups in a diagnosis context
        if (_isTimelineQuestion(question, isTagalog)) {
          debugPrint('Is follow-up question: true (timeline question)');

          if (isTagalog) {
            return 'Para sa $deficiencyType deficiency na nakita sa iyong saging, makikita mo ang pagbabago sa loob ng 2-4 na linggo kung gumamit ka ng foliar spray. Para naman sa soil application, umaabot ng 1-2 buwan bago makita ang buong epekto. Makikita mo muna ang pagbabago sa mga bagong dahon.';
          } else {
            return 'For the $deficiencyType deficiency detected in your banana plants, you should see improvement within 2-4 weeks if using foliar sprays. For soil applications, expect to wait 1-2 months to see the full effect. New leaves will show improvement first.';
          }
        }

        // Special case for cost questions
        if (question.toLowerCase().contains("cost") ||
            question.toLowerCase().contains("price") ||
            question.toLowerCase().contains("expensive") ||
            question.toLowerCase().contains("cheap") ||
            question.toLowerCase().contains("how much") ||
            question.toLowerCase().contains("magkano") ||
            question.toLowerCase().contains("presyo") ||
            question.toLowerCase().contains("gastos")) {
          debugPrint('Is follow-up question: true (cost question)');

          if (isTagalog) {
            switch (deficiencyType) {
              case 'Calcium':
                return 'Para sa paggamot ng kakulangan sa Calcium, narito ang mga taksang gastos sa Pilipinas:\n\n'
                    '- Calcium nitrate: ₱600-800 bawat 25kg na supot, sapat para sa 0.25-0.5 ektarya\n'
                    '- Agricultural lime: ₱200-400 bawat 40kg na supot para sa pag-adjust ng pH at calcium\n'
                    '- Calcium foliar spray: ₱300-600 bawat litro ng concentrate\n\n'
                    'Para sa maliit na sakahan, ang kabuuang gastos ay ₱1,500-3,000 depende sa kalubhaan at laki ng taniman. Mas mabisa at mura ang agarang paggamot kaysa maghintay hanggang lumala ang mga sintomas.';
              case 'Potassium':
                return 'Para sa paggamot ng kakulangan sa Potassium sa Pilipinas, ang mga gastos ay kabilang:\n\n'
                    '- Potassium sulfate (SOP): ₱800-1,200 bawat 25kg na supot\n'
                    '- Potassium chloride (MOP): ₱600-900 bawat 25kg na supot\n'
                    '- Potassium nitrate foliar spray: ₱400-700 bawat litro\n\n'
                    'Para sa karaniwang taniman ng saging, mag-budget ng ₱2,000-4,000 bawat ektarya para sa paggamot. Ito ay sulit na pamumuhunan dahil ang potassium ay direktang nakakaapekto sa kalidad at dami ng prutas.';
              default:
                return 'Para sa paggamot ng kakulangan sa $deficiencyType sa Pilipinas, ang karaniwang gastos ay:\n\n'
                    '- Commercial fertilizers: ₱500-1,200 bawat supot depende sa formula\n'
                    '- Foliar sprays: ₱300-800 bawat litro ng concentrate\n'
                    '- Organic amendments: ₱200-500 bawat supot\n\n'
                    'Para sa maliit na taniman (0.5-1 ektarya), magtaan ng ₱2,000-5,000 para matugunan ang kakulangan. Makakatipid ka sa mahabang panahon sa pamamagitan ng regular na pagsusuri ng lupa at balanseng pagpapataba.';
            }
          } else {
            switch (deficiencyType) {
              case 'Calcium':
                return 'For treating Calcium deficiency, here\'s a breakdown of approximate costs in the Philippines:\n\n'
                    '- Calcium nitrate: ₱600-800 per 25kg bag, enough for 0.25-0.5 hectare\n'
                    '- Agricultural lime: ₱200-400 per 40kg bag for pH adjustment and calcium\n'
                    '- Calcium foliar spray: ₱300-600 per liter of concentrate\n\n'
                    'For a small farm, total costs would range from ₱1,500-3,000 depending on severity and plantation size. Early treatment is more cost-effective than waiting until deficiency symptoms are severe.';
              case 'Potassium':
                return 'For Potassium deficiency treatment in the Philippines, the costs typically include:\n\n'
                    '- Potassium sulfate (SOP): ₱800-1,200 per 25kg bag\n'
                    '- Potassium chloride (MOP): ₱600-900 per 25kg bag\n'
                    '- Potassium nitrate foliar spray: ₱400-700 per liter\n\n'
                    'For a typical banana plantation, budget around ₱2,000-4,000 per hectare for treatment. This is a worthwhile investment as potassium directly affects fruit quality and yield, providing good return on investment through improved harvest.';
              default:
                return 'For $deficiencyType deficiency treatment in the Philippines, typical costs include:\n\n'
                    '- Commercial fertilizers: ₱500-1,200 per bag depending on formulation\n'
                    '- Foliar sprays: ₱300-800 per liter of concentrate\n'
                    '- Organic amendments: ₱200-500 per bag\n\n'
                    'For a small plantation (0.5-1 hectare), a total budget of ₱2,000-5,000 should address the deficiency. You\'ll save money in the long run by doing regular soil testing and balanced fertilization to prevent deficiencies from occurring.';
            }
          }
        }

        // Special case for fertilizer questions
        if (question.toLowerCase().contains("fertilizer") ||
            question.toLowerCase().contains("what should i use") ||
            question.toLowerCase().contains("what to use") ||
            question.toLowerCase().contains("pataba") ||
            question.toLowerCase().contains("abono") ||
            question.toLowerCase().contains("anong fertilizer") ||
            question.toLowerCase().contains("anong pataba") ||
            question.toLowerCase().contains("ano ang pataba") ||
            question.toLowerCase().contains("kailangan") &&
                question.toLowerCase().contains("pataba")) {
          debugPrint('Is follow-up question: true (fertilizer question)');

          switch (deficiencyType) {
            case 'Calcium':
              return 'Para sa Calcium deficiency, gamitin ang mga sumusunod na uri ng pataba:\n\n'
                  '1. **Calcium nitrate (15.5% N, 19% Ca)** - Mabilis kumilos na source ng calcium, mag-apply ng 2-5 kg bawat ektarya\n'
                  '2. **Calcium sulfate (Gypsum, 22% Ca)** - Mas mabagal na release, mainam para sa soil application sa 500-1000 kg bawat ektarya\n'
                  '3. **Dolomitic lime (Calcium Magnesium Carbonate)** - Para sa acidic na lupa, 1-2 toneladang bawat ektarya depende sa pH ng lupa\n'
                  '4. **Calcium chelate** - Para sa foliar spray, gamitin sa 2-3 g/L concentration\n\n'
                  'Para sa agarang resulta, gumamit ng foliar spray na may calcium chloride (2% solution). Para sa pangmatagalang solusyon, isama ang gypsum o lime sa lupa. Laging sundin ang mga tagubilin sa produkto para sa eksaktong rate ng application.';
            case 'Potassium':
              return 'Para sa Potassium deficiency, gamitin ang mga sumusunod na uri ng pataba:\n\n'
                  '1. **Potassium sulfate (SOP, 50% K₂O)** - Mas mababang salt index, angkop para sa saging sa 300-500 kg/ektarya\n'
                  '2. **Potassium chloride (MOP, 60% K₂O)** - Mas abot-kayang opsyon, gamitin sa 250-400 kg/ektarya\n'
                  '3. **Potassium nitrate (13% N, 44% K₂O)** - Mabilis na pagsipsip, mainam para sa foliar application sa 2-3% solution\n'
                  '4. **NPK fertilizers na mataas sa K** - Tulad ng 13-0-46 o katulad na ratio\n\n'
                  'Para sa agarang resulta, mag-apply ng potassium nitrate bilang foliar spray. Para sa pangmatagalang pangangalaga, gumamit ng potassium sulfate dahil naglalaman din ito ng sulfur. Iwasan ang sobrang paglalagay ng magnesium fertilizer dahil nakikipagkompetensya ito sa pagsipsip ng potassium.';
            case 'Sulphur':
              return 'Para sa Sulphur deficiency, gamitin ang mga sumusunod na uri ng pataba:\n\n'
                  '1. **Elemental sulphur** - Mabagal na release, 90-99% S, mag-apply ng 20-30 kg/ektarya\n'
                  '2. **Ammonium sulphate** - 24% S at 21% N, mag-apply ng 100-200 kg/ektarya\n'
                  '3. **Potassium sulphate** - 18% S at 50% K₂O, mainam kung parehong nutrients ang kailangan\n'
                  '4. **Gypsum (Calcium sulphate)** - 13-18% S at 22% Ca, mag-apply ng 200-300 kg/ektarya\n\n'
                  'Ang elemental sulphur ay nangangailangan ng panahon para maging available sa halaman, kaya ang ammonium sulphate o potassium sulphate ay mas mainam para sa mas mabilis na resulta. Ang foliar sprays na may sulphate ay makakapagbigay ng mabilis na pagwawasto ng mga sintomas.';
            case 'Nitrogen':
              return 'Para sa Nitrogen deficiency, gamitin ang mga sumusunod na uri ng pataba:\n\n'
                  '1. **Urea (46% N)** - Mataas na concentration ng nitrogen, mag-apply ng 100-200 kg/ektarya\n'
                  '2. **Ammonium nitrate (34% N)** - Medyo mabilis na release, gamitin sa 150-250 kg/ektarya\n'
                  '3. **Ammonium sulfate (21% N, 24% S)** - Nagbibigay din ng sulfur, mag-apply ng 200-300 kg/ektarya\n'
                  '4. **NPK fertilizers na mataas sa N** - Tulad ng 20-5-10 o katulad na ratio\n\n'
                  'Para sa organikong opsyon, gumamit ng compost, manure, o blood meal. Ang split application ng nitrogen ay mas maganda para sa saging para iwasan ang nutrient leaching.';
            case 'Magnesium':
              return 'Para sa Magnesium deficiency, gamitin ang mga sumusunod na uri ng pataba:\n\n'
                  '1. **Magnesium sulfate (Epsom salt, 10% Mg, 13% S)** - Mag-apply ng 20-40 kg/ektarya\n'
                  '2. **Dolomitic lime (6-12% Mg)** - Maganda kung acidic din ang lupa, mag-apply base sa soil test\n'
                  '3. **Magnesium oxide (55-60% Mg)** - Para sa mabilis na correction, 10-15 kg/ektarya\n'
                  '4. **Kieserite (15-17% Mg, 20-22% S)** - Medium release rate, 50-100 kg/ektarya\n\n'
                  'Para sa foliar spray, gumamit ng 2% magnesium sulfate solution, i-spray tuwing 2-3 linggo hanggang sa mawala ang mga sintomas. Mag-ingat sa sobrang paglalagay ng potassium dahil maaaring makipag-compete ito sa magnesium.';
            default:
              return 'Para sa $deficiencyType deficiency, ang mga pinakamagandang pataba na pwedeng gamitin ay:\n\n'
                  '1. **Espesyal na $deficiencyType fertilizers** - Maghanap ng mga produktong partikular na ginawa para sa deficiency na ito\n'
                  '2. **Foliar sprays** - Para sa mabilis na pagwawasto, maghanap ng liquid fertilizer na may $deficiencyType\n'
                  '3. **Organikong opsyon** - Compost na pinagyaman ng mga minerals o partikular na organikong amendments\n\n'
                  'Ang eksaktong rate ng application ay depende sa kalubhaan ng deficiency at sa kondisyon ng iyong lupa. Para sa mas tumpak na rekomendasyon, magsagawa ng soil test at kumonsulta sa lokal na agricultural extension specialist.';
          }
        }

        // Determine if this is a follow-up question
        bool isFollowUp = _isFollowUpQuestion(question, isTagalog);
        debugPrint('Is follow-up question: $isFollowUp');

        // Parse conversation to determine what has already been discussed
        // Check what aspects have been discussed for better context
        // Note: These variables could be used for enhanced context awareness in future
        // bool discussedTreatment =
        //     context.toLowerCase().contains('treatment:') ||
        //         context.toLowerCase().contains('treatment recommendations') ||
        //         context.toLowerCase().contains('how to treat');

        // bool discussedPrevention =
        //     context.toLowerCase().contains('prevention:') ||
        //         context.toLowerCase().contains('how to prevent') ||
        //         context.toLowerCase().contains('prevention measures');

        // bool discussedCost = context.toLowerCase().contains('cost') ||
        //     context.toLowerCase().contains('price') ||
        //     context.toLowerCase().contains('expensive');

        // bool discussedTimeline = context.toLowerCase().contains('how long') ||
        //     context.toLowerCase().contains('timeline') ||
        //     context.toLowerCase().contains('when will');

        // For genuine follow-up questions, provide more context-dependent answers
        if (isFollowUp) {
          debugPrint('Handling follow-up with improved context awareness');

          // Special handling for short follow-up questions
          if (question.length < 15) {
            return _generateSupplementalInfo(deficiencyType, isTagalog);
          }

          // Look at the most recent parts of the conversation to provide continuity
          final lines = context.split('\n');
          // String recentContext = ""; // Commented out to avoid unused variable

          // Get the last 10 lines of context (or fewer if there aren't 10)
          // Note: This could be used for enhanced context awareness
          for (int i = max(0, lines.length - 10); i < lines.length; i++) {
            // recentContext += lines[i] + "\n";
          }

          // Note: Enhanced context checking could be implemented here
          // For now, providing general supplemental info for short questions
          if (question.toLowerCase().contains('apply') ||
              question.toLowerCase().contains('how') ||
              question.toLowerCase().contains('step')) {
            if (isTagalog) {
              return 'Para ma-apply ang treatment para sa $deficiencyType deficiency, sundin ang mga sumusunod na hakbang:\n\n'
                  '1. Para sa soil application, ilagay ang recommended fertilizer sa palibot ng puno, mga 30-50cm mula sa ugat\n'
                  '2. Haluin sa ibabaw na parte ng lupa (5-10cm ang lalim)\n'
                  '3. Diligan kaagad pagkatapos para matunaw ang nutrients\n\n'
                  'Para sa foliar spray:\n'
                  '1. I-spray sa umaga o hapon (iwasan ang tanghaling tapat)\n'
                  '2. Tiyaking matakpan ang lahat ng dahon, lalo na ang ilalim\n'
                  '3. Ulitin ang pag-apply ayon sa rekomendasyon (karaniwang tuwing 2-4 na linggo)';
            } else {
              return 'To apply the treatment for $deficiencyType deficiency, follow these steps:\n\n'
                  '1. For soil application, apply the recommended fertilizer around the plant, about 30-50cm from the trunk\n'
                  '2. Work the fertilizer into the top 5-10cm of soil\n'
                  '3. Water thoroughly immediately after application\n\n'
                  'For foliar spray application:\n'
                  '1. Apply during early morning or late afternoon (avoid hot midday sun)\n'
                  '2. Ensure good coverage of all leaf surfaces, especially undersides\n'
                  '3. Repeat application as recommended (usually every 2-4 weeks)';
            }
          }

          // For simple follow-up questions or ones asking for more information
          if (question.toLowerCase().contains('more') ||
              question.toLowerCase().contains('detail') ||
              question.toLowerCase().contains('explain') ||
              question.toLowerCase().contains('what else') ||
              question.length < 10) {
            return _generateSupplementalInfo(deficiencyType, isTagalog);
          }

          // If asking for symptoms after discussing diagnosis
          if (question.toLowerCase().contains('symptom') ||
              question.toLowerCase().contains('sign') ||
              question.toLowerCase().contains('look like') ||
              question.toLowerCase().contains('sintomas') ||
              question.toLowerCase().contains('tanda') ||
              question.toLowerCase().contains('itsura')) {
            if (isTagalog) {
              switch (deficiencyType) {
                case 'Calcium':
                  return 'Mga pangunahing sintomas ng kakulangan sa Calcium sa mga puno ng saging:\n\n'
                      '• Ang mga batang dahon ay nagpapakita ng abnormal na paglaki at maaaring nakatiklop\n'
                      '• Ang mga gilid ng dahon ay maaaring magkaroon ng chlorosis (pagdilaw)\n'
                      '• Ang mga punto ng paglaki ay maaaring maging stunted\n'
                      '• Ang mga prutas ay maaaring magkaroon ng "finger drop" kung saan ang mga indibidwal na saging ay naghihiwalay nang maaga sa bunsi\n'
                      '• Ang kalidad ng loob ng prutas ay maaaring maging mahina na may mataas na pagkakataon na mabulok';
                case 'Potassium':
                  return 'Mga pangunahing sintomas ng kakulangan sa Potassium sa mga puno ng saging:\n\n'
                      '• Pagdilaw at necrosis (pagkakayumanggi) na nagsisimula sa mga gilid ng dahon at papaloob\n'
                      '• Ang mga mas lumang dahon ang naaapektuhan muna, na nagpapakita ng karakteristikong "nasunog" na itsura\n'
                      '• Ang mga dulo ng dahon ay maaaring tumuyo at magtiklop\n'
                      '• Mahinang mga tangkay na madaling mabali\n'
                      '• Mas maliliit na bunsi na may hindi pantay na pagkakabunga';
                default:
                  return 'Ang mga pangunahing sintomas ng kakulangan sa $deficiencyType sa mga puno ng saging ay kinabibilangan ng mga pagbabago sa kulay ng dahon, partikular na mga pattern ng pagdilaw, abnormalidad sa paglaki, at pagbabawas ng lakas ng halaman. Ang tukuyang pattern ng pagbabago ng kulay at kung aling mga dahon ang naaapektuhan muna (mas luma laban sa mas bago) ay makakatulong na makilala ang kakulangang ito sa iba.';
              }
            } else {
              switch (deficiencyType) {
                case 'Calcium':
                  return 'Key symptoms of Calcium deficiency in banana plants include:\n\n'
                      '• Young leaves show distorted growth and may be curled\n'
                      '• Leaf margins may develop chlorosis (yellowing)\n'
                      '• Growing points can become stunted\n'
                      '• Fruits may develop "finger drop" where individual bananas separate from the bunch prematurely\n'
                      '• Internal fruit quality can be poor with increased susceptibility to rot';
                case 'Potassium':
                  return 'Key symptoms of Potassium deficiency in banana plants include:\n\n'
                      '• Yellowing and necrosis (browning) starting from leaf margins and moving inward\n'
                      '• Older leaves are affected first, showing a characteristic "scorched" appearance\n'
                      '• Leaf tips may dry up and curl\n'
                      '• Weak stems that are prone to snapping\n'
                      '• Smaller bunches with irregular fruit filling';
                default:
                  return 'The key symptoms of $deficiencyType deficiency in banana plants include changes in leaf color, specifically yellowing patterns, growth abnormalities, and reduced plant vigor. The specific pattern of discoloration and which leaves are affected first (older vs. newer) can help distinguish this deficiency from others.';
              }
            }
          }
        }

        // For detailed questions about diagnosis, treatment, etc.
        return _generateContextualAnswer(
            deficiencyType, question, context, isTagalog);
      }

      // Fall back to standard responses if no context
      if (deficiencyType.isNotEmpty &&
          _isSimpleActionQuestion(question, isTagalog)) {
        debugPrint(
            'Simple action question detected, providing treatment answer');
        return _generateSpecificTreatmentAnswer(deficiencyType, isTagalog);
      }

      return _generateAnswer(deficiencyType, question, isTagalog: isTagalog);
    } catch (e) {
      debugPrint('Error answering question: $e');
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
    debugPrint(
        'Generating contextual answer for $deficiency question: $question');
    debugPrint('Context length: ${context.length}');

    // Extract key information from the context
    // Note: These variables could be used for enhanced context analysis
    // bool hasAskedAboutTreatment = context.toLowerCase().contains('treatment') ||
    //     context.toLowerCase().contains('paggamot') ||
    //     context.toLowerCase().contains('lunas');

    // bool hasAskedAboutPrevention = context.toLowerCase().contains('prevent') ||
    //     context.toLowerCase().contains('iwas') ||
    //     context.toLowerCase().contains('prevention');

    // bool hasAskedAboutCause = context.toLowerCase().contains('cause') ||
    //     context.toLowerCase().contains('sanhi') ||
    //     context.toLowerCase().contains('bakit');

    // IMPROVED: Check for common follow-up patterns that indicate continuation of a conversation
    bool isFollowUpQuestion = _isFollowUpQuestion(question, isTagalog);
    debugPrint('Is follow-up question: $isFollowUpQuestion');

    // For simple follow-up questions, ensure we maintain reference to the deficiency
    if (isFollowUpQuestion) {
      debugPrint(
          'Handling follow-up question with reinforced context awareness');
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
            '5. Ensure proper irrigation as water stress affects nutrient uptake\n'
            '6. **Crop rotation** where applicable to balance soil nutrient use';
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
        question.toLowerCase().contains('gastos') ||
        question.toLowerCase().contains('budget')) {
      return 'Ang halaga ng paggamot ng $deficiency deficiency ay depende sa:\n\n'
          '1. Kalubhaan ng kakulangan\n'
          '2. Laki ng iyong sakahan\n'
          '3. Availability ng produkto sa inyong lugar\n\n'
          'Para sa maliit na sakahan, mag-budget ng humigit-kumulang P5,000-10,000 kada ektarya para sa mga pataba. Ang foliar spray ay mas cost-effective sa maikling panahon, habang ang soil amendments ay nagbibigay ng mas matagal na resulta.';
    }

    // Default Tagalog response
    return 'Para sa $deficiency deficiency sa iyong saging, sundin ang mga hakbang na ito:\n\n'
        '1. Mag-apply ng angkop na pataba sa tamang dami para sa iyong mga puno ng saging\n'
        '2. Siguraduhing diligan nang maayos pagkatapos para matunaw ang mga sustansya\n'
        '3. Bantayan ang mga halaman para sa pagbabago - tingnan ang malusog na bagong dahon\n'
        '4. Isaalang-alang ang foliar spray para sa mas mabilis na resulta kung malubha ang problema\n\n'
        'Tandaan na ang consistency ay mahalaga sa paggamot ng nutrient deficiencies. Ang balanced na fertilization program ay makakatulong para maiwasan ang mga problema sa hinaharap.';
  }

  // Improved follow-up detection method
  bool _isFollowUpQuestion(String question, bool isTagalog) {
    question = question.toLowerCase().trim();

    // Very short questions are almost always follow-ups in context
    if (question.length < 15) {
      return true;
    }

    // Check for specific question types that are typically follow-ups
    if (_isTimelineQuestion(question, isTagalog) ||
        question.contains("how long") ||
        question.contains("when will") ||
        question.contains("what fertilizer") ||
        question.contains("what should i use") ||
        question.contains("what to do") ||
        question.contains("what is best way") ||
        question.contains("best way") ||
        question.contains("how to fix") ||
        question.contains("how can i treat") ||
        question.contains("how can i fix") ||
        question.contains("what next") ||
        question.contains("next step")) {
      return true;
    }

    // Check for questions asking for more details
    if (question.contains("more") ||
        question.contains("else") ||
        question.contains("another") ||
        question.contains("other") ||
        question.contains("further") ||
        question.contains("additional") ||
        question.contains("explain")) {
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
        'e di',
        'gaano katagal',
        'kailan'
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
        'that\'s it',
        'how long',
        'when will',
        'why',
        'reason',
        'cause',
        'because'
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

  /// Generate supplemental information for follow-up questions
  String _generateSupplementalInfo(String deficiency, bool isTagalog) {
    if (isTagalog) {
      switch (deficiency) {
        case 'Calcium':
          return 'Karagdagang impormasyon tungkol sa Calcium deficiency:\n\n'
              '- Epekto sa ani: Maaaring bumaba ang kalidad ng bunga at bilis ng paglaki\n'
              '- Pinakamainam na oras para mag-apply: Bago ang panahon ng malakas na paglaki\n'
              '- Kaugnayan sa iba pang nutrients: Magkakaroon ng balance problem kung sobra ang potassium o magnesium\n'
              '- Mga warning signs: Pagkagulong ng bagong dahon, pagkahinto ng paglaki ng dulo\n\n'
              'Mahalaga rin na i-monitor ang pH ng lupa dahil nakakaapekto ito sa availability ng calcium.';
        default:
          return 'Karagdagang impormasyon tungkol sa $deficiency deficiency:\n\n'
              '- Epekto sa ani: Maaaring magkaroon ng mas maliit o mababang kalidad na bunga\n'
              '- Pag-monitor: Regular na inspeksyon ng mga dahon para sa maagang detection\n'
              '- Pag-iwas: Balanced na fertilization program\n'
              '- Pagsusuri: Maaaring magpa-soil test taun-taon para sa optimal na pamamahala\n\n'
              'Tandaan na ang mga nutritional requirements ng saging ay nagbabago depende sa yugto ng paglaki nito.';
      }
    } else {
      switch (deficiency) {
        case 'Calcium':
          return 'Additional information about Calcium deficiency:\n\n'
              '- Impact on yield: Can reduce fruit quality and growth rate\n'
              '- Best timing for application: Before periods of rapid growth\n'
              '- Interaction with other nutrients: Can be imbalanced if potassium or magnesium is excessive\n'
              '- Warning signs: Curling of new leaves, stunted growing points\n\n'
              'It\'s also important to monitor soil pH as it affects calcium availability.';
        default:
          return 'Additional information about $deficiency deficiency:\n\n'
              '- Impact on yield: Can result in smaller or lower quality fruit\n'
              '- Monitoring: Regular leaf inspection for early detection\n'
              '- Prevention: Balanced fertilization program\n'
              '- Testing: Consider annual soil tests for optimal management\n\n'
              'Keep in mind that banana nutritional requirements change throughout growth stages.';
      }
    }
  }

  /// Check if a question is asking about timeline or duration
  bool _isTimelineQuestion(String question, bool isTagalog) {
    question = question.toLowerCase().trim();

    if (isTagalog) {
      return question.contains('kailan') ||
          question.contains('gaano katagal') ||
          question.contains('ilang araw') ||
          question.contains('ilang linggo') ||
          question.contains('ilang buwan');
    } else {
      return question.contains('when') ||
          question.contains('how long') ||
          question.contains('timeline') ||
          question.contains('how soon') ||
          question.contains('how many days') ||
          question.contains('how many weeks') ||
          question.contains('how many months');
    }
  }

  /// Simulate realistic AI thinking/processing delay
  Future<void> _simulateThinkingDelay(String question) async {
    // Base delay of 1-2 seconds to simulate AI processing
    int baseDelayMs = 1000 + (question.length * 10).clamp(0, 1000);

    // Add some randomness to make it feel more natural (±500ms)
    int randomVariation = (DateTime.now().millisecondsSinceEpoch % 1000) - 500;
    int totalDelay = (baseDelayMs + randomVariation).clamp(800, 3000);

    // For complex questions (longer text), add a bit more delay
    if (question.length > 50) {
      totalDelay += 500;
    }

    // Questions with multiple parts get extra delay
    if (question.contains('?') && question.split('?').length > 2) {
      totalDelay += 300;
    }

    debugPrint('Simulating AI thinking for ${totalDelay}ms...');
    await Future.delayed(Duration(milliseconds: totalDelay));
  }
}
