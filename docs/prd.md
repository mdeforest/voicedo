# VoiceDo — Product Requirements Document

## 1. Executive Summary

VoiceDo is a voice-first task management app for iOS, designed specifically for people with ADHD and Autism. Instead of typing into rigid forms, users talk through their day naturally — and the app turns their words into organized, actionable tasks. The interface is calm and minimal, inspired by Things 3, with gentle reminders and a flat task list per list. Voice input is powered by Apple's Speech framework, and natural language parsing is handled by the Claude API.

v1 is a fully on-device experience (no backend, no auth) with one exception: LLM calls to the Claude API for parsing voice input into structured tasks.

---

## 2. Problem Statement

Most todo apps are designed for neurotypical workflows — they require manual data entry, rigid categorization, and consistent executive function to maintain. For people with ADHD, this creates friction at exactly the wrong moment: the point of capture. When an idea or task strikes, the overhead of opening an app, choosing a list, typing a title, setting a date, and assigning a priority is enough to lose the thought entirely.

VoiceDo removes that friction. You press a button, say what's on your mind, and the app handles the rest. It meets ADHD brains where they are — in the messy, non-linear, stream-of-consciousness flow of real thought.

---

## 3. Goals & Success Criteria

### Primary Goals
- Reduce task capture time to under 10 seconds (press button → speak → done)
- Make task management feel conversational, not administrative
- Provide an ADHD-friendly experience: low clutter, gentle nudges, easy reordering

### Key Metrics
- Task capture rate: % of voice inputs that successfully create at least one task
- Daily active usage: users opening the app and adding tasks at least once per day
- Task completion rate: % of created tasks that get marked done

### Out of Scope for v1
- User authentication and accounts
- Cloud sync or multi-device support
- Third-party integrations (iOS Shortcuts, Home Assistant, calendar sync)
- AI proactive features (automatic prioritization, task breakdown suggestions, daily planning)
- Collaboration or shared lists
- Android or web versions

---

## 4. Target Users

### Persona 1: Alex — The ADHD Professional
- **Age:** 28, software engineer
- **Needs:** Captures tasks throughout the day but forgets them within minutes. Existing apps feel like too much work to maintain.
- **Pain points:** Executive function fatigue, task paralysis from long lists, guilt from overdue tasks in traditional apps.
- **How VoiceDo helps:** Brain-dumps tasks by voice during commute, between meetings, or when an idea strikes. The app organizes them without judgment.

### Persona 2: Sam — The Autistic Parent
- **Age:** 35, stay-at-home parent
- **Needs:** Manages household tasks, kids' schedules, and personal projects. Prefers structured systems but gets overwhelmed by complex apps.
- **Pain points:** Sensory overload from busy UIs, difficulty switching between contexts, needs gentle (not aggressive) reminders.
- **How VoiceDo helps:** Calm, minimal interface. Voice input means tasks get captured even with hands full. Multiple lists mirror how they naturally categorize their world.

### Persona 3: Jordan — The Tinkerer
- **Age:** 22, college student and automation enthusiast
- **Needs:** Wants a todo system that plays well with their smart home and automation workflows. Loves iOS Shortcuts.
- **Pain points:** Most todo apps have closed ecosystems. Wants extensibility.
- **How VoiceDo helps:** v1 captures tasks beautifully; future versions will offer the integrations Jordan craves. The voice-first approach appeals to their "talk to my house" lifestyle.

---

## 5. User Stories

### Voice Input
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| V1 | As a user, I want to press a button and speak my tasks so that I can capture them without typing. | Tapping the mic button activates speech recognition. The transcript appears in real-time. Recognition stops when the user taps the stop button or pauses for 3+ seconds. |
| V2 | As a user, I want the app to parse my natural speech into individual tasks so that I don't have to dictate one task at a time. | Input like "I need to buy groceries tomorrow, call the dentist this week, and fix the kitchen light" creates three separate tasks with appropriate due dates inferred. |
| V3 | As a user, I want to see the raw transcript and be able to edit it before confirming, so I can fix mistakes. | After voice input, a transcript view appears. The user can edit text, confirm, or re-record. |
| V4 | As a user, I want to highlight a phrase in the transcript and promote it to a task, so I can manually organize a messy brain-dump. | Long-pressing and selecting text in the transcript shows a "Create Task" action. Tapping it creates a new task from the selected text. |

### Task Management
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| T1 | As a user, I want to create, edit, and delete tasks so I can manage my todo list. | Tasks have a title (required), optional notes, optional due date/time, and a completion state. Swipe-to-delete with undo. |
| T2 | As a user, I want to organize tasks into lists so I can separate different areas of my life. | Users can create named lists (e.g., "Home," "Work," "Errands"). Tasks belong to exactly one list. A default "Inbox" list catches un-categorized tasks. |
| T4 | As a user, I want to reorder tasks by dragging so I can prioritize easily. | Long-press and drag to reorder within a list. |
| T5 | As a user, I want to complete a task with a single tap so it feels effortless. | Tapping the checkbox marks it complete with a subtle animation. Completed tasks move to a "Done" section at the bottom (collapsible). |

### Reminders
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| R1 | As a user, I want the app to infer reminder times from my speech so I don't have to set them manually. | "Buy milk tomorrow morning" sets a reminder for 9:00 AM the next day. "Call dentist this week" sets a reminder for the next weekday at 10:00 AM. Inferred times appear as suggestions the user can adjust. |
| R2 | As a user, I want to set reminders manually on any task so I'm nudged at the right time. | Tapping a task reveals a date/time picker for reminders. Reminders fire as local notifications. |
| R3 | As a user, I want reminders to be gentle and non-judgmental so I don't feel guilt about overdue tasks. | Notification copy uses encouraging language (e.g., "Whenever you're ready: Buy groceries" not "OVERDUE: Buy groceries"). No red badges or aggressive visual indicators for overdue items. |

### Lists
| ID | Story | Acceptance Criteria |
|----|-------|-------------------|
| L1 | As a user, I want to create, rename, and delete lists so I can organize my tasks by context. | Lists have a name and optional color/icon. Deleting a list asks what to do with its tasks (move to Inbox or delete). |
| L2 | As a user, I want a default Inbox list so tasks always have somewhere to land. | The Inbox list cannot be deleted or renamed. New tasks without an explicit list go here. The LLM can assign tasks to lists if the user mentions context ("add milk to my grocery list"). |

---

## 6. Feature Specification

### 6.1 Voice Input & Parsing

**Description:** The core interaction. User presses a mic button, speaks naturally, and the app converts speech to structured tasks.

**User Flow:**
1. User taps the floating mic button (prominent, always visible)
2. Speech recognition activates — live transcript appears on screen
3. User speaks naturally (e.g., "I need to pick up my prescription today and also schedule a haircut sometime this week")
4. User taps stop, or recognition auto-stops after 3 seconds of silence
5. Transcript is sent to Claude API for parsing
6. App displays parsed tasks in a review card:
   - Each extracted task shown as a card with title, inferred list, inferred due date
   - User can edit any field, delete a task, or add the raw transcript as a note
7. User confirms → tasks are created and added to their respective lists
8. If parsing fails, the full transcript is shown with smart editing (highlight-to-task)

**UI/UX Notes:**
- Mic button: large, centered at bottom of screen, with a subtle pulse animation while recording
- Live transcript: appears in a half-sheet overlay, scrolling as the user speaks
- Review cards: clean, card-based layout. Each task is editable inline.
- Smart editing: long-press to select text → contextual menu includes "Create Task"

**Business Rules:**
- Maximum recording duration: 2 minutes (prevents runaway API costs)
- If the Claude API is unreachable, fall back to creating a single task with the full transcript as the title
- Inferred due dates use reasonable defaults: "tomorrow" = next day 9 AM, "this week" = next weekday 10 AM, "today" = 1 hour from now (or next morning if late evening)

**Edge Cases:**
- Empty transcript (user taps mic then immediately stops): dismiss without action
- Very long transcript (>500 words): warn user, still attempt parsing, truncate if needed
- Ambiguous speech ("do the thing"): create the task as-is without inferring metadata
- Multiple languages: v1 supports English only. Show a note if non-English is detected.

### 6.2 Task Management

**Description:** CRUD operations for tasks with drag-to-reorder. Tasks are flat within a list — no subtask nesting.

**User Flow (manual task creation):**
1. Tap "+" button → inline text field appears at top of list
2. Type task title; press Return to chain another task, or tap "Done" to close
3. Tap a task row to inline-edit its title; tap ">" to open Task Detail for title, notes, and due date

**UI/UX Notes:**
- Task rows: minimal — checkbox, title, subtle due date indicator. No priority badges, no tags, no avatars.
- Tapping the checkbox area toggles completion; tapping the title/whitespace area enables inline editing.
- Reorder: tap the EditButton in the toolbar to enter drag mode.
- Completion animation: checkbox fills with a symbol morph, task text gets a strikethrough, row moves to a collapsible "Done" section at the bottom.
- "Done" section header shows a count badge and a "Clear All" button to bulk-delete completed tasks.

### 6.3 Reminders & Notifications

**Description:** Time-based reminders via local notifications, with both inferred and manual setting.

**User Flow (manual):**
1. Tap a task → task detail view
2. Tap "Remind me" → date/time picker appears
3. Select date/time → reminder is scheduled
4. At the scheduled time, a local notification fires

**UI/UX Notes:**
- Date/time picker: clean, native iOS style
- Reminder indicator: small, subtle clock icon on the task row
- Notification style: gentle copy, no exclamation marks, encouraging tone
- Overdue tasks: shown with a soft amber indicator (not red), copy reads "Still on your list" not "Overdue"

**Business Rules:**
- Default reminder times for inferred dates: morning = 9 AM, afternoon = 1 PM, evening = 6 PM
- Recurring reminders: not in v1
- Maximum reminders per task: 1 (keeps it simple)
- Notifications require iOS permission — app should request gracefully on first voice input, not on launch

**Edge Cases:**
- Reminder set for a time in the past: schedule for the same time next day
- Task completed before reminder fires: cancel the notification
- App killed/restarted: reminders persist (they're iOS local notifications, not in-app timers)

---

## 7. Information Architecture

### Screen Inventory
1. **Home** — Bento-style card grid of all lists. Inbox is a full-width hero card; user lists are in a 2-column pastel grid. Long-press a card for Edit/Delete. System nav bar is hidden; header is part of the scroll content.
2. **List View** — Flat task list. Toolbar: EditButton (drag-to-reorder), Edit List (non-Inbox), +. Tapping a task row opens Task Detail via the ">" disclosure chevron; tapping the title/whitespace inline-edits the title.
3. **Task Detail** — Editable title, notes, due date. Read-only: created date, completed date, list name. Reminder picker added in Phase 5.
4. **Voice Input Overlay** — Half-sheet with live transcript during recording.
5. **Review Cards** — Parsed tasks displayed for confirmation after voice input.
6. **Settings** — Minimal: notification preferences, default reminder times, about/credits.

### Navigation
- Tab bar with two tabs: **Lists** (home) and **Settings**
- Tapping a list → List View
- Tapping a task → Task Detail (push navigation)
- Mic button is a floating action button, visible on Home and List View
- Voice Input Overlay slides up as a sheet over the current screen

---

## 8. Data Model

### Entities

| Entity | Attribute | Type | Notes |
|--------|-----------|------|-------|
| **TaskList** | id | UUID | Primary key |
| | name | String | Required, user-editable |
| | color | String? | Optional hex color |
| | icon | String? | Optional SF Symbol name |
| | sortOrder | Int | For manual ordering |
| | isInbox | Bool | True for the default Inbox (non-deletable) |
| | createdAt | Date | Auto-set |
| **Task** | id | UUID | Primary key |
| | title | String | Required |
| | notes | String? | Optional |
| | isComplete | Bool | Default false |
| | dueDate | Date? | Optional |
| | reminderDate | Date? | Optional, triggers notification |
| | sortOrder | Int | For manual ordering within parent |
| | createdAt | Date | Auto-set |
| | completedAt | Date? | Set when completed |
| **Relationships** | | | |
| | Task → TaskList | Many-to-one | Every task belongs to one list |
### Relationship Summary
- **TaskList ↔ Task:** One-to-many. A list has many tasks; a task belongs to one list.

---

## 9. Tech Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| **Language** | Swift 5.9+ | Native iOS, best performance and platform API access |
| **UI Framework** | SwiftUI | Declarative, modern, great for building minimal UIs quickly |
| **Local Storage** | SwiftData | Apple's modern persistence framework, built on Core Data. Simpler API, works great with SwiftUI. |
| **Voice Recognition** | Apple Speech Framework | On-device, free, low latency, good accuracy for English |
| **NLP / Parsing** | Claude API (Anthropic) | Parses natural language transcripts into structured task data (title, list, due date). Handles ambiguity well. |
| **Notifications** | UserNotifications framework | Local notifications for reminders. No push server needed. |
| **Networking** | URLSession | Native, lightweight. Only used for Claude API calls. |
| **Architecture** | MVVM | Clean separation for SwiftUI. ViewModels handle business logic. |
| **Minimum iOS** | iOS 17.0 | Required for SwiftData. Acceptable — targets relatively recent devices. |

### Key Libraries / Dependencies
- None beyond Apple frameworks and the Anthropic API. Keeping dependencies minimal for v1.
- Claude API key will be stored in the app bundle for v1. *Recommendation — for production, move to a lightweight backend proxy to protect the API key. Flag for v2.*

---

## 10. API Contracts

VoiceDo v1 has one external API call: sending a voice transcript to the Claude API for parsing.

### Parse Voice Transcript

**Endpoint:** `POST https://api.anthropic.com/v1/messages`

**Request:**
```json
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 1024,
  "system": "You are a task parser for a todo app. Given a voice transcript, extract individual tasks. For each task, infer a title, an optional due date (ISO 8601), and an optional list name if context suggests one. Respond with ONLY valid JSON, no preamble or markdown. Schema: { \"tasks\": [{ \"title\": string, \"dueDate\": string | null, \"listName\": string | null }] }",
  "messages": [
    {
      "role": "user",
      "content": "Here is the voice transcript:\n\n\"I need to pick up my prescription today and schedule a haircut sometime this week and also add milk to my grocery list\""
    }
  ]
}
```

**Expected Response:**
```json
{
  "tasks": [
    {
      "title": "Pick up prescription",
      "dueDate": "2026-02-26T17:00:00Z",
      "listName": null
    },
    {
      "title": "Schedule a haircut",
      "dueDate": "2026-03-02T10:00:00Z",
      "listName": null
    },
    {
      "title": "Add milk",
      "dueDate": null,
      "listName": "Grocery"
    }
  ]
}
```

**Error Handling:**
- HTTP 4xx/5xx: Fall back to creating a single task with the raw transcript
- Malformed JSON response: Fall back to single task with raw transcript
- Network timeout (>10 seconds): Show error, offer retry or manual entry
- Rate limit (429): Queue and retry with exponential backoff (max 3 retries)

---

## 11. Authentication & Authorization

No authentication in v1. The app is entirely local and single-user. All data is stored on-device via SwiftData.

**Future consideration:** When auth is added (v2+), consider Sign in with Apple as the primary method — it's native, privacy-friendly, and aligns with the target audience's likely preferences.

---

## 12. Non-Functional Requirements

### Performance
- Voice recognition should begin within 500ms of tapping the mic button
- Claude API response should complete within 5 seconds for typical inputs (<100 words)
- UI should maintain 60fps during scrolling and drag-to-reorder operations
- App launch to interactive: under 2 seconds

### Security
- Claude API key stored in app bundle for v1 (acceptable for early/beta use)
- *Recommendation: Move to a server-side proxy before public release to avoid key extraction*
- No sensitive user data leaves the device except voice transcripts sent to Claude API
- Transcripts are not stored on Anthropic's servers beyond the API request (per Anthropic's API data policy)

### Accessibility
- Full VoiceOver support for all UI elements
- Dynamic Type support (text scales with system settings)
- Minimum touch targets of 44×44pt
- Sufficient color contrast (WCAG AA)
- Reduce Motion support (disable animations when system setting is on)

### Responsive Design
- iPhone-only for v1 (all screen sizes from iPhone SE to iPhone 15 Pro Max)
- iPad support deferred to v2
- Supports portrait orientation; landscape optional

---

## 13. Edge Cases & Error Handling

### Global Strategy
- Errors should be calm, not alarming. Use neutral language: "Something didn't work" not "ERROR!"
- All destructive actions (delete task, delete list) require confirmation with an undo option
- Network errors should be non-blocking — the app works fully offline except for voice parsing

### Specific Edge Cases

| Scenario | Behavior |
|----------|----------|
| No internet during voice input | Speech recognition works (on-device). Show message: "I captured what you said but can't organize it right now. You can edit it manually or try again when you're online." Save transcript as a single task. |
| Claude API returns unexpected format | Create single task with full transcript. Log error for debugging. |
| User speaks in non-English language | Speech framework may produce garbled output. Create task with whatever text was captured. |
| Very short input ("milk") | Create a single task titled "Milk" with no metadata. No error. |
| Duplicate task detection | Not in v1. Users can manually delete duplicates. |
| Device storage full | SwiftData will throw an error. Show message: "Your device is running low on storage. Some tasks may not save." |
| Notification permission denied | App works without reminders. Show a subtle banner: "Turn on notifications in Settings to get reminders." Don't nag repeatedly. |
| Very large task list (500+ tasks) | Performance should be tested. SwiftUI List uses lazy rendering so this should be fine. |

---

## 14. Future Considerations (Post-v1)

### v2 Candidates
- **Authentication:** Sign in with Apple, iCloud sync for multi-device
- **iOS Shortcuts integration:** Create tasks, query lists, trigger voice input from Shortcuts
- **Siri integration:** "Hey Siri, add to my VoiceDo"
- **AI features:** Smart prioritization, task breakdown suggestions, daily planning ("What should I focus on today?"), proactive nudges
- **Home Assistant integration:** Create tasks from home automations

### v3+ Ideas
- Apple Watch companion app (voice input from wrist)
- iPad app with multi-column layout
- Recurring tasks
- Widgets (home screen and lock screen)
- Collaborative lists (shared with family/roommates)
- Android version

### Known Technical Debt
- API key in app bundle needs to move to a server-side proxy
- SwiftData migration strategy needed once schema changes in v2
- Voice parsing prompt may need iteration based on real user transcripts
