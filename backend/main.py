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

import os
import mimetypes
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

from routes.guidance import router as guidance_router
from routes.admin import router as admin_router

# Fix: Explicitly add MIME types for JavaScript files
mimetypes.add_type("application/javascript", ".js")
mimetypes.add_type("application/javascript", ".mjs")

app = FastAPI(title="MSU Guidance System")

# --- CORS Configuration ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 1. API Routes (Must stay at the top)
app.include_router(guidance_router, prefix="/api/v1")
app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

@app.get("/api/v1/health")
def health_check():
    return {"status": "API is online"}

# 2. Path Logic for Render
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
FRONTEND_DIR = os.path.join(os.path.dirname(CURRENT_DIR), "frontend", "build", "web")

# 3. Mount Static Files
# We mount this to the root directory to handle scripts/assets
if os.path.exists(FRONTEND_DIR):
    app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

# 4. Improved SPA Handler
@app.get("/{full_path:path}")
async def serve_spa(full_path: str):
    # Prevent catching API calls
    if full_path.startswith("api/"):
        return {"detail": "Not Found"}, 404
        
    # Check if the requested path is an actual file (like main.dart.js)
    file_path = os.path.join(FRONTEND_DIR, full_path)
    if os.path.isfile(file_path):
        return FileResponse(file_path)
    
    # If file doesn't exist, return index.html (Standard SPA behavior)
    index_file = os.path.join(FRONTEND_DIR, "index.html")
    if os.path.exists(index_file):
        return FileResponse(index_file)
    
    return {"error": "Frontend build not found."}