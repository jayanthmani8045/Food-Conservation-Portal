# Food Waste Management Portal

A full‑stack application to manage surplus food collection, distribution, logistics, and quality assessment using Oracle Database, FastAPI, and React.

## Table of Contents

* [Tech Stack](#tech-stack)

  * [Backend](#backend)
  * [Frontend](#frontend)


## Tech Stack

### Backend

* **Language & Framework:** Python 3.11+, [FastAPI](https://fastapi.tiangolo.com/)
* **ASGI Server:** Uvicorn with WatchFiles for live reloading
* **Database:** Oracle Database
* **Driver:** [oracledb](https://oracle.github.io/python-oracledb/)
* **Authentication & Security:**

  * Password hashing: Passlib (bcrypt)
  * Token-based auth: JWTs via python-jose
  * Configuration: pydantic-settings + python-dotenv (.env file)
* **ORM/DB Layer:** Direct PL/SQL calls wrapped in Python services
* **Dependency Management:** `requirements.txt`

### Frontend

* **Library & Tooling:** React (bootstrapped with Vite)
* **HTTP Client:** Axios
* **Routing:** React Router v6
* **State Management:** React Context + Hooks (no Redux)
* **Styling:** Plain CSS or SCSS (Flexbox/CSS Grid for layout)
* **Dev Server:** Vite (powered by Rollup)
