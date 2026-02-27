# VoiceDo — Claude Code Build Plan

## Development Phases

### Phase 1: Project Setup & Foundation
- Create a new Xcode project with SwiftUI lifecycle (iOS 17+)
- Set up folder structure:
  ```
  VoiceDo/
  ├── App/              (App entry point, app-level config)
  ├── Models/           (SwiftData models)
  ├── ViewModels/       (MVVM view models)
  ├── Views/
  │   ├── Home/         (List of lists)
  │   ├── ListView/     (Tasks within a list)
  │   ├── TaskDetail/   (Single task view)
  │   ├── Voice/        (Voice input overlay & review cards)
  │   ├── Settings/     (Settings screen)
  │   └── Components/   (Reusable UI components)
  ├── Services/
  │   ├── SpeechService.swift       (Apple Speech framework wrapper)
  │   ├── ClaudeAPIService.swift    (Anthropic API client)
  │   └── NotificationService.swift (Local notifications)
  ├── Utilities/        (Extensions, helpers, constants)
  └── Resources/        (Assets, colors, fonts)
  ```
- Configure SwiftData with the `ModelContainer`
- Create the `TaskList` and `Task` SwiftData models with all attributes and relationships
- Seed a default "Inbox" list on first launch
- Build the basic app shell: tab bar with Lists and Settings tabs

**You'll need:** Xcode 15+, iOS 17 Simulator or device

---

### Phase 2: Core Data & Task Management
- Build the Home screen: list of TaskLists with task counts
- Build the List View: display tasks with nesting (indentation + vertical connector line)
- Implement task CRUD: create, edit, complete, delete tasks
- Implement list CRUD: create, rename, delete lists (with "move tasks to Inbox" prompt)
- Add drag-to-reorder for tasks within a list
- Add drag-to-nest: drop a task on another task to make it a child
- Implement task completion animation (checkbox fill, strikethrough, slide to Done section)
- Add manual task creation (+ button → inline text field or sheet)

**Key implementation notes:**
- Use SwiftData `@Query` with sort descriptors for ordering
- Nesting via the self-referential `parent` relationship on Task
- Limit nesting depth to 5 in the ViewModel (check before allowing nest operations)
- "Done" section at bottom of list view should be collapsible

---

### Phase 3: Voice Input & Speech Recognition
- Create `SpeechService` wrapping Apple's `SFSpeechRecognizer` and `SFSpeechAudioBufferRecognitionRequest`
- Request microphone and speech recognition permissions
- Build the floating mic button (visible on Home and List View)
- Build the Voice Input Overlay (half-sheet):
  - Live transcript display during recording
  - Stop button + auto-stop after 3 seconds of silence
  - 2-minute maximum recording duration
- Wire up the mic button → overlay → speech recognition pipeline
- Store the raw transcript for fallback use

**Key implementation notes:**
- Use `AVAudioSession` with `.record` category
- `SFSpeechRecognizer` provides partial results — display them in real-time
- Detect silence by monitoring the audio buffer levels or using a timer after the last partial result
- Handle permission denial gracefully: show explanation and link to Settings

---

### Phase 4: Claude API Integration & Task Parsing
- Create `ClaudeAPIService` with a method: `parseTranscript(_ text: String) async throws -> [ParsedTask]`
- Define `ParsedTask` struct: `title: String`, `dueDate: Date?`, `listName: String?`
- Implement the API call to Claude (see PRD Section 10 for exact request format)
- Parse the JSON response, handle malformed responses gracefully
- Build the Review Cards screen:
  - Display each parsed task as an editable card (title, list picker, date picker)
  - "Confirm All" button to create all tasks
  - Individual delete buttons per card
  - Option to discard and fall back to transcript editing
- Implement the smart editing fallback:
  - Show raw transcript with text selection enabled
  - Long-press selected text → "Create Task" context menu action
  - Selecting "Create Task" opens a mini-form pre-filled with the selected text
- Wire the full pipeline: mic → transcript → Claude API → review cards → task creation

**Key implementation notes:**
- API key: store in a `Config.swift` file (gitignored) or Xcode build configuration
- Create a `.env.example` documenting the required `ANTHROPIC_API_KEY`
- Network timeout: 10 seconds
- Fallback on any error: show transcript with smart editing
- Date inference: the system prompt tells Claude to use ISO 8601 dates. Parse with `ISO8601DateFormatter`.
- List matching: if Claude returns a `listName`, try to match it to an existing list (case-insensitive). If no match, assign to Inbox and include the suggested name as a note.

**You'll need:** A Claude API key from [console.anthropic.com](https://console.anthropic.com)

---

### Phase 5: Reminders & Notifications
- Create `NotificationService` wrapping `UNUserNotificationCenter`
- Request notification permission (trigger on first voice input, not on launch)
- Schedule local notifications when a reminder is set on a task
- Cancel notifications when a task is completed or reminder is removed
- Build the reminder UI in Task Detail: date/time picker for setting reminders
- Display reminder indicator (subtle clock icon) on task rows
- Implement inferred reminders from Claude API parsing:
  - When a parsed task has a `dueDate`, auto-suggest it as the reminder time
  - Show as a pre-filled suggestion the user can accept or change
- Notification content: gentle, encouraging copy (see PRD Section 6.3)
- Handle overdue tasks: soft amber indicator, "Still on your list" language

**Key implementation notes:**
- Use `UNMutableNotificationContent` and `UNCalendarNotificationTrigger`
- Store the notification identifier on the Task model so you can cancel it later
- If reminder is in the past, schedule for same time next day

---

### Phase 6: UI Polish & ADHD-Friendly UX
- Apply the calm, minimal design language throughout:
  - Soft, muted color palette (light grays, whites, subtle accent color)
  - Clean typography (SF Pro, comfortable sizing)
  - Generous whitespace and padding
  - No red indicators — use soft amber for overdue, gentle blue for due today
- Task completion: subtle, satisfying animation (not over-the-top)
- Overdue tasks: no guilt — "Still on your list" label, soft styling
- Notification copy review: ensure all notification text is encouraging
- Empty states: friendly messages ("Nothing here yet — tap the mic to get started")
- Loading states: subtle spinner during API calls, skeleton views where appropriate
- Error states: calm, non-alarming messages
- Settings screen: notification preferences, default reminder times
- App icon and launch screen

---

### Phase 7: Accessibility & Testing
- VoiceOver audit: ensure all interactive elements have accessibility labels
- Dynamic Type: verify all text scales correctly with system font size settings
- Minimum touch targets: verify all buttons/controls are ≥44×44pt
- Color contrast check (WCAG AA compliance)
- Reduce Motion: disable animations when the system accessibility setting is on
- Test on multiple device sizes (iPhone SE through iPhone 15 Pro Max)
- Test offline behavior: voice recognition without internet, API error fallback
- Test edge cases: very long transcripts, empty input, rapid consecutive inputs
- Memory and performance profiling for large task lists (500+ tasks)

---

### Phase 8: Deployment Prep
- Configure App Store Connect
- Create App Store screenshots and description
- Set up TestFlight for beta testing
- Write privacy policy (voice data sent to Claude API, all other data on-device)
- Configure App Transport Security for Claude API domain
- Final QA pass on a physical device

**Manual steps (you'll need to do these yourself):**
- Create an Apple Developer account ($99/year) if you don't have one
- Create the App ID and provisioning profiles in the Apple Developer portal
- Set up the app in App Store Connect
- Get a Claude API key and add funds to your Anthropic account

---

## Environment Variables / Configuration

| Key | Description | Where to get it |
|-----|-------------|-----------------|
| `ANTHROPIC_API_KEY` | Claude API key for task parsing | [console.anthropic.com](https://console.anthropic.com) |

---

## Dependencies Summary

| Dependency | Type | Purpose |
|------------|------|---------|
| SwiftUI | Apple Framework | UI |
| SwiftData | Apple Framework | Local persistence |
| Speech | Apple Framework | Voice-to-text |
| UserNotifications | Apple Framework | Local reminders |
| AVFoundation | Apple Framework | Audio session for recording |
| Foundation (URLSession) | Apple Framework | Claude API networking |

No third-party dependencies. 🎉

---
---

# Claude Code Prompt — Phase 1 Kickoff

Copy and paste the following into Claude Code to start building. Provide the PRD file as context.

---

```
I'm building VoiceDo — a voice-first todo app for iOS, designed for people with ADHD. Users press a button, speak their tasks naturally, and the app uses the Claude API to parse their speech into structured tasks.

I have a full PRD attached — please read it carefully before starting.

Let's start with Phase 1: Project Setup & Foundation.

Please:
1. Create a new SwiftUI iOS app project structure (iOS 17+, Swift 5.9+)
2. Set up the folder structure as described in the build plan:
   - App/, Models/, ViewModels/, Views/ (with subfolders: Home/, ListView/, TaskDetail/, Voice/, Settings/, Components/), Services/, Utilities/, Resources/
3. Create the SwiftData models:
   - TaskList: id (UUID), name (String), color (String?), icon (String?), sortOrder (Int), isInbox (Bool), createdAt (Date)
   - Task: id (UUID), title (String), notes (String?), isComplete (Bool), dueDate (Date?), reminderDate (Date?), sortOrder (Int), createdAt (Date), completedAt (Date?)
   - Relationships: Task belongs to TaskList (many-to-one), Task has optional parent Task and children Tasks (self-referential)
4. Configure the ModelContainer in the App entry point
5. Seed a default "Inbox" list on first launch (check if it exists before creating)
6. Build the basic app shell:
   - Tab bar with "Lists" and "Settings" tabs
   - Home screen showing all TaskLists with task counts
   - Empty Settings screen (placeholder)
   - Navigation from Home → List View (placeholder)

Technical guidelines:
- Use SwiftUI with MVVM architecture
- Use SwiftData for persistence (not Core Data directly)
- Add clear comments for complex logic
- Use SF Symbols for icons
- Keep the UI minimal and clean — we're going for a Things 3 aesthetic
- Create a Config.swift file (with a note that it should be gitignored) for the API key

After completing Phase 1, stop and show me what you've built so I can review before moving to Phase 2.
```

---

## Continuing After Phase 1

After reviewing Phase 1, you can prompt Claude Code with subsequent phases. Here's the pattern:

```
Phase 1 looks good. Let's move to Phase 2: Core Data & Task Management.

Please refer to the PRD and build plan for details. Key deliverables:
- [List the main items from the relevant phase]

Keep the same code style and architecture. Stop after this phase for review.
```

Repeat for each phase until the app is complete. This iterative approach lets you review and course-correct between each phase, which works much better than trying to build everything at once.
