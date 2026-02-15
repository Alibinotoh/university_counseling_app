# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware #
# from routes.guidance import router as guidance_router
# from routes.admin import router as admin_router

# app = FastAPI(title="MSU Guidance System")

# # --- CORS Configuration ---
# # This allows your Flutter Chrome app to talk to this API
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # Permits all websites (like localhost:43443) to connect
#     allow_credentials=True,
#     allow_methods=["*"],  # Permits all actions (GET, POST, etc.)
#     allow_headers=["*"],  # Permits all headers
# )

# # We "include" the routes we built
# app.include_router(guidance_router, prefix="/api/v1")

# @app.get("/")
# def root():
#     return {"message": "API is online"}

# # Include admin routes with a clear prefix
# app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import os

from routes.guidance import router as guidance_router
from routes.admin import router as admin_router

app = FastAPI(title="MSU Guidance System")

# --- CORS Configuration ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 1. API Routes (Always keep these at the top)
app.include_router(guidance_router, prefix="/api/v1")
app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

@app.get("/api/v1/health")
def health_check():
    return {"status": "API is online"}

# 2. Corrected Path Logic for Render
# This gets the directory where main.py lives (backend/)
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
# This goes up one level to the root, then into the frontend build
FRONTEND_DIR = os.path.join(os.path.dirname(CURRENT_DIR), "frontend", "build", "web")

# 3. Serving Static Files
# We mount this to the root so your Flutter app loads immediately
if os.path.exists(FRONTEND_DIR):
    app.mount("/assets", StaticFiles(directory=os.path.join(FRONTEND_DIR, "assets")), name="assets")
    # Also mount the top-level static files (js, manifest, etc.)
    app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

# 4. The SPA Handler (Crucial for Flutter Routing)
@app.get("/{full_path:path}")
async def serve_spa(full_path: str):
    # Ignore API calls so they don't get caught here
    if full_path.startswith("api/"):
        return {"detail": "Not Found"}, 404
        
    index_file = os.path.join(FRONTEND_DIR, "index.html")
    if os.path.exists(index_file):
        return FileResponse(index_file)
    
    return {"error": f"Frontend not found at {FRONTEND_DIR}. Check your folder structure."}