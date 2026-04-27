# import os
# import mimetypes
# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from fastapi.staticfiles import StaticFiles
# from fastapi.responses import FileResponse

# from routes.guidance import router as guidance_router
# from routes.admin import router as admin_router

# # Fix: Explicitly add MIME types for JavaScript files
# mimetypes.add_type("application/javascript", ".js")
# mimetypes.add_type("application/javascript", ".mjs")

# app = FastAPI(title="MSU Guidance System")

# # --- CORS Configuration ---
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # 1. API Routes (Must stay at the top)
# app.include_router(guidance_router, prefix="/api/v1")
# app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

# @app.get("/api/v1/health")
# def health_check():
#     return {"status": "API is online"}

# # 2. Path Logic for Render
# CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
# FRONTEND_DIR = os.path.join(os.path.dirname(CURRENT_DIR), "frontend", "build", "web")

# # 3. Mount Static Files
# # We mount this to the root directory to handle scripts/assets
# if os.path.exists(FRONTEND_DIR):
#     app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

# # 4. Improved SPA Handler
# @app.get("/{full_path:path}")
# async def serve_spa(full_path: str):
#     # Prevent catching API calls
#     if full_path.startswith("api/"):
#         return {"detail": "Not Found"}, 404
        
#     # Check if the requested path is an actual file (like main.dart.js)
#     file_path = os.path.join(FRONTEND_DIR, full_path)
#     if os.path.isfile(file_path):
#         return FileResponse(file_path)
    
#     # If file doesn't exist, return index.html (Standard SPA behavior)
#     index_file = os.path.join(FRONTEND_DIR, "index.html")
#     if os.path.exists(index_file):
#         return FileResponse(index_file)
    
#     return {"error": "Frontend build not found."}
import os
import mimetypes
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

from routes.guidance import router as guidance_router
from routes.admin import router as admin_router

# 1. FIX MIME TYPES
# Ensures the browser treats JavaScript and modules correctly to avoid white screens
mimetypes.add_type("application/javascript", ".js")
mimetypes.add_type("application/javascript", ".mjs")

app = FastAPI(title="MSU Guidance System")

# 2. CORS CONFIGURATION
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. API ROUTES (Must remain above the SPA handler)
app.include_router(guidance_router, prefix="/api/v1")
app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

@app.get("/api/v1/health")
def health_check():
    return {"status": "API is online"}

# 4. PATH LOGIC
# Locates the frontend build directory relative to this main.py file
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
FRONTEND_DIR = os.path.normpath(os.path.join(CURRENT_DIR, "..", "frontend", "build", "web"))

# 5. STATIC FILES MOUNT
if os.path.exists(FRONTEND_DIR):
    app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

# 6. SPA & ASSET HANDLER
@app.get("/{full_path:path}")
async def serve_spa(full_path: str):
    # Prevent API routes from being handled as static files
    if full_path.startswith("api/"):
        return {"detail": "Not Found"}, 404
        
    # Attempt 1: Check the standard path (main.dart.js, index.html, etc.)
    file_path = os.path.join(FRONTEND_DIR, full_path)
    
    # Attempt 2: Handle the Flutter 'Double Assets' folder quirk
    # Flutter Web often places assets in /assets/assets/ instead of just /assets/
    if not os.path.exists(file_path) and "assets/" in full_path:
        # If full_path is 'assets/msu_logo.png', try 'assets/assets/msu_logo.png'
        relative_asset_path = full_path.replace("assets/", "assets/assets/", 1)
        file_path = os.path.join(FRONTEND_DIR, relative_asset_path)

    # If the file exists after both attempts, serve it
    if os.path.isfile(file_path):
        return FileResponse(file_path)
    
    # Fallback: Serve index.html for Single Page App (SPA) routing
    index_file = os.path.join(FRONTEND_DIR, "index.html")
    if os.path.exists(index_file):
        return FileResponse(index_file)
    
    return {"error": "File not found. Verify your frontend build exists."}