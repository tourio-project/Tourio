# Tourio

Tourio is a smart travel companion app that helps users plan and manage their trips. It combines AI-based planning, live data, and safety features to create a smooth and reliable travel experience.

## Features:
### AI Mood-Based Trip Planner

### Trending Now (Backend: Mira)
This microservice automatically scrapes upcoming events from [calendar.jo](https://calendar.jo) every 24 hours.  
It stores the events in Firebase Firestore and provides an API endpoint (`/trending`) using FastAPI for the frontend to fetch and display real-time event data.

### Integrated Public Transport

### Emergency Assistant & Safety Alerts

## Design
[![Figma Design](https://img.shields.io/badge/Figma-Design-blue?logo=figma)](https://www.figma.com/file/Zaen0sR7mtfpdEhu1beEey/Tourio?type=design&node-id=0%3A1&mode=design&t=sjqqiXtqNg2a94RO-1)


## Developers
- Mira Diab — Backend (Trending Now, Emergency Service) & UI Design (Figma)
- Mayar Hasan — UI design (Figma), frontend–backend integration
- Nasser — Database
- Omar Salman — Backend (AI Mood - Based Trip Planner)
- Marwan Shashtari - Frontend

