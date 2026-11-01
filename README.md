# 🌿 Göod Together

**A mobile app for micro-volunteering in Gothenburg.**

Göod Together connects residents who need a hand with neighbors who have a few free hours to give. Open the app, pick an activity nearby, and make a tangible difference in your own community, whether that's weeding an elderly neighbor's garden, carrying groceries for someone who is ill, or joining a park clean-up.

> Developed as the project for **CLS055** at **Chalmers University of Technology** (Group 1).

---

## 📖 Table of Contents

- [About](#-about)
- [Sustainable Development Goals](#-sustainable-development-goals)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
- [Design Process](#-design-process)
- [Use of AI](#-use-of-ai)
- [Future Work](#-future-work)
- [Team](#-team)
- [License](#-license)

---

## 💡 About

Traditional volunteering often demands long-term commitments, which keeps many well-meaning people from getting involved. Göod Together lowers that barrier by focusing on **short, one-off opportunities that take only a few hours**, and by making them easy to find, join, and organize.

The core objective is to foster community resilience and social cohesion in Gothenburg through peer-to-peer assistance, while helping to reduce everyday struggles and social isolation.

## 🌍 Sustainable Development Goals

The project is rooted in the UN Sustainable Development Goals:

- **SDG 3: Good Health and Well-Being**
- **SDG 11: Sustainable Cities and Communities**

These global goals are translated into local action by strengthening neighborhood networks, building stronger interpersonal bonds, and encouraging people to help one another.

## ✨ Features

- **Discover**: browse available volunteering opportunities in a scrollable list, with filter chips for categories such as *Today*, *Outdoors*, *Social*, *Food*, *Animals*, *Housework*, *Education*, *Culture*, *Sports* and *Other*. Select all categories, or one or more specific ones.
- **Map view**: explore opportunities by location, with colorful category icons to tell activities apart at a glance.
- **Post an opportunity**: any user, whether an organization or a neighbor, can publish an activity with a title, category, date, start/end time, location, number of volunteers, description, and optional picture.
- **My Shifts and My Page**: track upcoming and past shifts, view posted activities and favorites, and switch between agenda and calendar views.
- **Favorites**: save activities you're interested in with the heart icon.
- **Invite friends**: share an opportunity directly with others.
- **Notifications**: get notified when someone joins an activity you posted, or when an activity you joined is updated.
- **Badges and levels**: a gamified reward system that recognizes volunteers' contributions and shows progress toward the next badge.
- **Community impact**: a home-page summary of total volunteer hours and active members in the community.
- **Browse first, log in later**: content is open to everyone, and authentication is only required for interactive or user-specific actions.
- **Image uploads**: attach high-resolution pictures to posts.


## 🛠 Tech Stack

| Area | Technology |
| --- | --- |
| Framework | [Flutter](https://flutter.dev) |
| Authentication, core data, real-time features | [Firebase](https://firebase.google.com) |
| Image / object storage | [Supabase](https://supabase.com) |
| Design | [Figma](https://www.figma.com) / Figma Make |
| Design system | [Material Design 3](https://m3.material.io) |
| Map data | © [OpenStreetMap](https://www.openstreetmap.org) contributors |

## 🏗 Architecture

The app uses a **hybrid backend** that separates data management from asset storage:

- **Firebase** handles user authentication, core application data, real-time post creation, and live data fetching, giving users synchronized and responsive interactions.
- **Supabase** acts as a dedicated object-storage service for high-resolution image uploads.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A [Firebase](https://console.firebase.google.com) project
- A [Supabase](https://supabase.com) project with a storage bucket for images

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/Margarida-Lourenco/Mobile-Computing.git

# 2. Install dependencies
flutter pub get
```

### Configuration

1. **Firebase**: create a project, enable Authentication and your database, and add your platform configuration files (e.g. `google-services.json` for Android, `GoogleService-Info.plist` for iOS) or generate them with the FlutterFire CLI.
2. **Supabase**: create a storage bucket for image uploads and note your project URL and anon key.
3. Add your Supabase credentials wherever the app expects them (e.g. a config file or environment variables). **Never commit secrets to the repository.**

### Run

```bash
flutter run
```

## 🎨 Design Process

The design followed analytical evaluation methods from the course rather than formal user studies:

1. **Paper brainstorming**, then a written concept document.
2. A **high-fidelity first prototype** in Figma Make, based on that document.
3. **Internal review** of the first iteration, which led to larger and more readable text, a complete set of filter categories, a more legible community-impact badge, more colorful map icons, a new Notifications page, and a reworked My Page.
4. **Weekly supervision** feedback guiding further improvements.

The color palette combines **green** (growth, harmony, nature) and **blue** (Gothenburg, trust, friendliness).

## 🤖 Use of AI

AI played a significant role in this project, as allowed by the course description:

- **Figma Make**: a prompt-to-app tool used to generate the initial high-fidelity prototype.
- **ChatGPT (Codex mode)**: used to convert the prototype into code and to iteratively add functionality.
- **ChatGPT** was also used to generate fake accounts and populate the database with sample data.

## 🔭 Future Work

- An optional, skippable onboarding flow for first-time users.
- Large-scale user testing to gather feedback and iterate further.
- Final polish, and moving Firebase to a paid plan to handle more data.

## 👥 Team

| Name | Contact |
| --- | --- |
| Wilma Tholin | https://github.com/WilmaTholin00 |
| Margarida Lourenço | https://github.com/Margarida-Lourenco |
| Asuka Banga | https://github.com/Assie428 |


This project was created for educational purposes as part of the CLS055 course at Chalmers University of Technology.

---

<p align="center">Made with 💚 for Gothenburg</p>
