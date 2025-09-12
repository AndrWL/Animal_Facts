# 🐾 AnimalFacts (iOS, SwiftUI + TCA)

A demo iOS app built with **SwiftUI** and **Composable Architecture (TCA)**.  
The app shows animal fact categories with navigation, alerts, and a detail screen.

---

## ✨ Features
- Categories list with statuses:
  - **Free** → available immediately
  - **Paid** → requires watching a fake ad
  - **Coming Soon** → locked content
- Detail screen with fact cards (image + text)
- Share card with Apple's share sheet.
- Navigation powered by `NavigationStackStore`
- Alert when opening paid content:
  - *Cancel* → dismiss alert
  - *Show Ad* → shows loader for 2 seconds, then unlocks content
- Custom UI:
  - Card with shadow & rounded corners
  - Custom toolbar with back/share buttons
  - Navigation bar shadow line

---

## 🛠 Tech stack
- Swift 6, SwiftUI
- ComposableArchitecture (TCA)
- Async/Await
- DTO → model mapping
- ProgressView overlay for loading

---

## ▶️ Run
- Deployment target: **iOS 16**

---

## 📌 Next steps
- Replace fake ad with real Ad SDK
- Add image caching
- Localize strings
- Add unit tests for reducers
- Extract fixed sizes (card width/height, image height, paddings) into a shared layout config
