# PesaTrack AI MVP Implementation Plan

## Overview
Build five essential MVP features for PesaTrack AI — a smart money companion integrated into the existing Flutter app. The AI is rule-based (no external APIs), understands financial transactions from the database, and provides personalized savings and spending advice.

---

## Key Architecture Decisions

1. **AI Service Pattern**: Extend existing `AIService` with new methods instead of rewriting. The service uses rule-based pattern matching (existing) and will add new methods for financial reports and savings advice.
   - Reasoning: The existing service already has 7 pattern handlers that work well. Adding methods preserves the pattern and avoids breaking existing queries.

2. **Chat History Storage**: Use Hive local box (already in pubspec) to store AIMessage JSON. No Hive TypeAdapter needed—serialize/deserialize via AIMessage.toJson/fromJson.
   - Reasoning: Hive is already a dependency, avoids Firebase complexity mentioned in constraints, and provides fast local persistence.

3. **State Management**: Create a new `PesaTrackAIProvider` (extends ChangeNotifier) to manage chat state (messages list, loading, userId). Provide it alongside existing ThemeProvider in main.dart.
   - Reasoning: Matches the existing Provider pattern in main.dart. Keeps AI state separate from UI presentation.

4. **Voice Integration**: Add `speech_to_text: ^6.3.0` to pubspec. For MVP, implement real speech-to-text on Android/iOS (using plugin's native methods). Show "Voice — Coming Soon" placeholder text on web/desktop platforms.
   - Reasoning: `speech_to_text` is mature and supports Android/iOS speech recognition. Graceful fallback allows MVP to ship on all platforms.

5. **New AI Methods**: Extend `AIService` with:
   - `generateMonthlyReport()` — spending summary by category, trends, top merchants
   - `generateAffordabilityReport()` — savings potential, balance analysis, purchase recommendations
   - `generateSavingsAdvice()` — identify top spending patterns, suggest cuts, recommend goals
   - Reasoning: These are new capabilities beyond existing pattern matching. They focus on pulling real data from transactions/budgets/goals and generating actionable insights.

6. **Navigation**: Add route `/pesatrack-ai` to `AppRouter` for the AI chat screen.
   - Reasoning: Follows existing routing convention.

7. **Currency Formatting**: Use existing `intl` package and format all amounts as "UGX 50000" (no decimal places) based on seed data pattern.
   - Reasoning: UGX has no subdivisions in common use; existing codebase uses toStringAsFixed(0).

---

## Implementation Order (Dependency-Driven)

The work decomposes into **five independent features** that can be developed and tested sequentially. Each feature builds on the previous one's infrastructure (Hive setup → Provider → UI → AI enhancements → Voice). They are **not parallel** because they share the worktree and must build together.

### Feature 1: Chat Infrastructure & Hive Setup
**Goal**: Set up Hive for chat history and create core message persistence.

**Steps**:
1. Create `lib/core/providers/pesatrack_ai_provider.dart` with `PesaTrackAIProvider` (ChangeNotifier):
   - `List<AIMessage> messages` (initially empty)
   - `bool isLoading` (track AI response state)
   - `String userId` (fetch from mock auth; use 'user_001')
   - Methods: `sendMessage(String)`, `clearHistory()`, `loadHistory()`, `_persistMessage(AIMessage)`
   - Uses Hive box 'pesatrack_ai_messages' to load/save chat history on init and after each message.

2. Create `lib/core/constants/pesatrack_ai_constants.dart`:
   - Quick action labels: ['Add an expense', 'Analyse spending', 'Savings advice', 'My financial health']
   - Hive box name: 'pesatrack_ai_messages'
   - Max chat history (for UI): 100 messages

3. Modify `lib/main.dart`:
   - Add import for provider
   - Register `PesaTrackAIProvider` as a second ChangeNotifierProvider in MyApp build (below ThemeProvider)
   - Do NOT change route initialization or other logic.

4. Modify `pubspec.yaml`:
   - No changes needed; `hive`, `hive_flutter`, `provider` already present.

**Verification**:
```bash
flutter pub get
flutter analyze lib/core/providers/ lib/core/constants/pesatrack_ai_constants.dart lib/main.dart
# Verify no errors. Check main.dart compiles.
```

---

### Feature 2: AI Chat Screen UI
**Goal**: Build the chat interface with message bubbles, quick actions, and input area.

**Steps**:
1. Create `lib/screens/pesatrack_ai/widgets/chat_message_bubble.dart`:
   - StatelessWidget `ChatMessageBubble(AIMessage message)`
   - User messages: right-aligned, green (#11BD2E) background, white text, rounded
   - AI messages: left-aligned, light background (#F5F5F3), dark text, rounded
   - Use `borderRadius: BorderRadius.circular(20)` and `padding: EdgeInsets.all(12)`
   - Include timestamp in small grey text below message

2. Create `lib/screens/pesatrack_ai/widgets/quick_action_card.dart`:
   - StatelessWidget `QuickActionCard(String label, VoidCallback onTap)`
   - Card with icon (use Icons.add_rounded, Icons.analytics_outlined, etc.)
   - White card, tap to trigger pre-filled message suggestion

3. Create `lib/screens/pesatrack_ai/widgets/chat_input_area.dart`:
   - StatefulWidget `ChatInputArea(ValueChanged<String> onSendMessage)`
   - TextField with hint "Ask anything about your finances..."
   - Send button (use Icons.send_rounded)
   - Disable button while isLoading (consume from provider)

4. Create `lib/screens/pesatrack_ai/widgets/voice_input_button.dart`:
   - Placeholder for now: show "🎤 Voice — Coming Soon" text/icon button
   - No functionality yet (voice is Feature 5)

5. Create `lib/screens/pesatrack_ai/pesatrack_ai_page.dart`:
   - StatefulWidget `PesaTrackAIPage`
   - AppBar: "PesaTrack AI — Your Smart Money Companion"
   - Body: ScrollView with:
     - Chat message list (consume PesaTrackAIProvider.messages, use ChatMessageBubble)
     - If no messages: show welcome text + 4 quick action cards
   - Bottom: ChatInputArea + VoiceInputButton
   - Connect ChatInputArea.onSendMessage to provider.sendMessage()

6. Add route to `lib/core/routes/app_router.dart`:
   - Add constant: `static const String pesatrackAI = '/pesatrack-ai';`
   - Add case in generateRoute: `case AppRoutes.pesatrackAI: return MaterialPageRoute(builder: (_) => const PesaTrackAIPage(), settings: settings);`

**Verification**:
```bash
flutter pub get
flutter analyze lib/screens/pesatrack_ai/
flutter run -d <device/emulator> # Navigate to /pesatrack-ai route, confirm UI displays, no messages shown initially
```

---

### Feature 3: Text-Based AI Conversations
**Goal**: Wire PesaTrackAIProvider to AIService to process user messages and generate responses.

**Steps**:
1. Modify `lib/core/providers/pesatrack_ai_provider.dart`:
   - Inject repositories: `TransactionRepository`, `BudgetRepository`, `SavingsRepository` (create instance or accept as constructor params; for MVP, create in-memory instances in provider)
   - Inject `AIService` instance
   - In `sendMessage(String query)`:
     - Create AIMessage(id: uuid, userId, message: query, isUser: true, timestamp: now)
     - Add to messages list, call notifyListeners()
     - Set isLoading = true, notifyListeners()
     - Call aiService.processMessage(query, transactions, budgets, goals)
     - Create AIMessage response, add to list, persist both
     - Set isLoading = false, notifyListeners()
   - In `loadHistory()`: read Hive box, deserialize AIMessage.fromJson, sort by timestamp ascending

2. Create `lib/services/pesatrack_ai_service.dart` (new orchestrator, different from AIService):
   - Optional for MVP; can inline logic in provider for simplicity. However, for separation of concerns:
     - Class `PesaTrackAIService` with `Future<String> processUserQuery(String, repositories)`
     - Delegates to `AIService.processMessage()`, handles repository fetching
     - NOT needed for first implementation; AIService is already called by provider

3. Update `lib/services/ai_service.dart` (extend, do NOT rewrite):
   - No changes to existing methods; keep all 7 pattern handlers
   - Will add new methods in Feature 5 (generateMonthlyReport, etc.)

**Verification**:
```bash
flutter pub get
flutter analyze lib/core/providers/ lib/services/ai_service.dart
flutter run -d <device/emulator>
# Send test message: "How much did I spend this month?"
# Confirm AI response appears in chat, message persists after hot reload
```

---

### Feature 4: AI Financial Reports
**Goal**: Extend `AIService` with methods to generate monthly spending reports and affordability analysis.

**Steps**:
1. Modify `lib/services/ai_service.dart`:
   - Add method `String generateMonthlyReport(List<Transaction> transactions)`:
     - Calculate total income and expenses for current month
     - Group expenses by category, calculate percentage of total
     - Identify top 3 spending categories
     - Calculate average daily spend
     - Return formatted report string (e.g., "You spent 400,000 UGX this month...")
     - Pattern: match queries like "give me a report", "monthly summary", "spending report"
   
   - Add method `String generateAffordabilityReport(List<Transaction> transactions, List<Budget> budgets)`:
     - Calculate month-to-date income, expenses, remaining balance
     - Check if any budgets are exceeded (>100% of limit)
     - Suggest purchasing power: "Safe to spend up to X UGX without exceeding budget"
     - Return formatted recommendations
     - Pattern: match "affordability", "can I afford", "how much can I spend"
   
   - Update `processMessage()` to call these new methods when patterns match:
     - Check for "report" or "summary" → call generateMonthlyReport()
     - Check for "afford" or "can I spend" → call generateAffordabilityReport()

2. Add test queries to `processMessage()` detection:
   - Pattern 8 (new): Reports - "report", "summary", "breakdown", "monthly"
   - Update existing Pattern 3 affordability check to also call generateAffordabilityReport()

**Verification**:
```bash
flutter pub get
flutter analyze lib/services/ai_service.dart
flutter run -d <device/emulator>
# Test: "Give me a spending report" → confirm report appears
# Test: "How much can I afford?" → confirm affordability analysis appears
# Test: existing queries still work (no regression)
```

---

### Feature 5: Personalized Savings Advice & Voice Input
**Goal**: Add savings advice generation to AI, enhance voice service stub for Android/iOS, update UI.

**Steps**:
1. Modify `lib/services/ai_service.dart`:
   - Add method `String generateSavingsAdvice(List<Transaction> transactions, List<SavingsGoal> goals)`:
     - Analyze top 3 spending categories
     - Suggest: "Your biggest expense is [category] at X% of spending. Cut by 10% to save Y UGX/month"
     - If goals exist: check progress, suggest monthly savings target
     - If no goals: recommend setting one (20% of income guideline)
     - Return formatted advice (e.g., "To reach your goals, save at least X UGX/month")
     - Pattern: match "tips", "advice", "how to save", "spend less"
   
   - Add method `List<String> identifySpendingPatterns(List<Transaction> transactions)`:
     - Return list of insights: ["Highest expense: Food (35%)", "Weekly spending variance: ±5000", ...]
     - Used internally by generateSavingsAdvice()

2. Modify `lib/services/voice_service.dart`:
   - Replace stub with real implementation for Android/iOS
   - Add `final SpeechToText _speechToText = SpeechToText();`
   - Implement `Future<String> startListening()`:
     - Check availability: `await _speechToText.initialize()`
     - Start listening: `_speechToText.listen(onResult: (result) { ... })`
     - Return transcribed text on completion
     - Gracefully handle errors (unsupported platform, permission denied)
   - Implement `Future<bool> isVoiceRecognitionAvailable()`:
     - Return `_speechToText.isAvailable && _speechToText.isNotListening`
   - Implement `Future<bool> requestMicrophonePermission()`:
     - Use `permission_handler` or request via `speech_to_text` (it requests automatically)
     - For MVP, assume permission; log if unavailable

3. Update `pubspec.yaml`:
   - Add: `speech_to_text: ^6.3.0` (allows native speech recognition on Android/iOS)
   - (Permission handler is typically built into speech_to_text on Android/iOS)

4. Modify `lib/screens/pesatrack_ai/widgets/voice_input_button.dart`:
   - Replace "Coming Soon" placeholder with real recording UI
   - StatefulWidget with recording state (idle, listening, processing)
   - Tap to start listening, visual feedback (animated icon, "Listening...")
   - On web/desktop: show placeholder "🎤 Voice — Not available on this platform"
   - Inject VoiceService, call startListening() on tap
   - On successful transcription: pass result to ChatInputArea or send directly as message

5. Modify `lib/screens/pesatrack_ai/pesatrack_ai_page.dart`:
   - Ensure VoiceInputButton is wired: on voice result, call provider.sendMessage(transcribedText)

**Verification**:
```bash
flutter pub get
flutter pub outdated # Confirm speech_to_text added and compatible
flutter analyze lib/services/voice_service.dart lib/services/ai_service.dart lib/screens/pesatrack_ai/
flutter run -d <android_device/ios_simulator>
# Test savings advice: "Give me savings tips" → confirm personalized advice appears
# Test voice input (Android/iOS only): tap voice button, speak "How much did I spend?", confirm transcription and response
# Test on web: tap voice button, confirm "Coming Soon" placeholder shown
# Verify no regressions: existing chat queries still work
```

---

## File Changes Summary

### New Files Created:
- `lib/core/providers/pesatrack_ai_provider.dart` (Feature 1)
- `lib/core/constants/pesatrack_ai_constants.dart` (Feature 1)
- `lib/screens/pesatrack_ai/pesatrack_ai_page.dart` (Feature 2)
- `lib/screens/pesatrack_ai/widgets/chat_message_bubble.dart` (Feature 2)
- `lib/screens/pesatrack_ai/widgets/quick_action_card.dart` (Feature 2)
- `lib/screens/pesatrack_ai/widgets/chat_input_area.dart` (Feature 2)
- `lib/screens/pesatrack_ai/widgets/voice_input_button.dart` (Feature 2 & 5)

### Files Modified:
- `lib/main.dart` — add PesaTrackAIProvider registration (Feature 1)
- `lib/core/routes/app_router.dart` — add pesatrack_ai route (Feature 2)
- `lib/services/ai_service.dart` — add report and advice methods (Feature 4 & 5)
- `lib/services/voice_service.dart` — implement real speech-to-text (Feature 5)
- `pubspec.yaml` — add speech_to_text dependency (Feature 5)

### Unchanged:
- `lib/services/pesatrack_ai_service.dart` — NOT created for MVP; logic in provider is sufficient
- All model files (AIMessage, Transaction, Budget, SavingsGoal)
- All repository files (TransactionRepository, BudgetRepository, SavingsRepository)
- Theme, constants, other services

---

## Risks & Mitigation

### Risk 1: Hive Serialization
**Risk**: AIMessage.toJson/fromJson may not round-trip correctly if used with Hive box directly.
**Mitigation**: Store AIMessage as JSON strings in Hive. Deserialize on load, serialize on save.

### Risk 2: Voice Permissions on Android/iOS
**Risk**: `speech_to_text` requires microphone permission; may crash if not granted.
**Mitigation**: Check `isVoiceRecognitionAvailable()` before showing voice button. Request permission on first tap. Show error toast if denied.

### Risk 3: AI Response Latency
**Risk**: Rule-based AI processing transactions might be slow if message list grows large.
**Mitigation**: For MVP, limit to last month's transactions (not all history). Cache results if needed.

### Risk 4: Simultaneous Messages
**Risk**: User might send another message while AI is processing (isLoading = true).
**Mitigation**: ChatInputArea disables send button while isLoading is true (already in design).

### Risk 5: Firebase Initialization
**Risk**: Firebase is commented out in main.dart; Hive might conflict if Firebase is later enabled.
**Mitigation**: Hive box initialization is independent. No conflict. When Firebase is enabled, can migrate chat history to Firestore if needed.

---

## Testing Strategy

### Manual Testing (per feature):
1. **Feature 1**: Hot reload after sending message; confirm chat persists in Hive
2. **Feature 2**: UI renders, taps work, quick action cards trigger pre-filled messages
3. **Feature 3**: Send multiple messages, confirm AI responses and context awareness (e.g., "How much did I spend?" then "What about last week?")
4. **Feature 4**: Trigger report and affordability queries, verify calculations (e.g., expected UGX amounts match seed data)
5. **Feature 5**: On Android/iOS, tap voice button, speak, confirm transcription; on web, confirm placeholder

### No Automated Tests Required for MVP
- Existing test suite is minimal; focus on manual verification and code analysis
- AI logic is rule-based and matches existing patterns (lower risk)

---

## Design Considerations (In Scope for MVP)

- **Colours**: Primary green (#11BD2E), background (#F5F5F3), text dark (#111111), muted (#777777)
- **Typography**: Use existing theme (headlineMedium, bodyMedium, etc.)
- **Spacing**: Consistent 16-24px padding, 20px border radius (match home screen)
- **Icons**: Material Icons (Icons.send_rounded, Icons.mic_rounded, etc.)
- **Responsiveness**: Single-column chat, works on phone/tablet/web

---

## Out of Scope (Phase 2 or Later)

- Spoken AI responses (text-to-speech)
- Automatic spending alerts
- Multi-language support (currently English only)
- Cloud backup of chat history
- Real external AI API integration (ChatGPT, Gemini, etc.)
- Voice command parsing for expense recording (voice input only sends messages)
- Chat export or sharing

---

## Build & Test Commands

```bash
# Install dependencies
flutter pub get

# Analyze code
flutter analyze

# Run app
flutter run -d <device>

# Clean and rebuild
flutter clean && flutter pub get && flutter run -d <device>
```

---

## Summary

This plan sequences five features in dependency order:
1. **Hive + Provider infrastructure** (chat persistence, state management)
2. **Chat UI** (screens, widgets, routing)
3. **Text chat** (wire AI service to provider)
4. **Financial reports** (extend AI with report generation)
5. **Savings advice + voice** (extend AI, add speech-to-text)

Each feature is independently verifiable. No feature breaks existing app functionality. The AI remains rule-based and database-driven, never calling external APIs. Voice works on Android/iOS with graceful fallback on web/desktop.
