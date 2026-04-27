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

# 1. MIME TYPE ENFORCEMENT
mimetypes.init()
mimetypes.add_type("application/javascript", ".js")
mimetypes.add_type("application/javascript", ".mjs")
mimetypes.add_type("image/png", ".png")

app = FastAPI(title="MSU Guidance System")

# 2. CORS CONFIGURATION
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. API ROUTES
app.include_router(guidance_router, prefix="/api/v1")
app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

@app.get("/api/v1/health")
def health_check():
    return {"status": "API is online"}

# 4. RENDER-READY PATH LOGIC (The "White Screen" Killer)
# We use absolute paths to ensure the server doesn't get lost
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__)) # This is /backend
BASE_DIR = os.path.dirname(CURRENT_DIR) # This is the project root

# Path 1: Standard structure (root/frontend/build/web)
FRONTEND_DIR = os.path.join(BASE_DIR, "frontend", "build", "web")

# Path 2: Fallback (sometimes Render flat-packs or uses different workdirs)
if not os.path.exists(os.path.join(FRONTEND_DIR, "index.html")):
    FRONTEND_DIR = os.path.join(CURRENT_DIR, "..", "frontend", "build", "web")

print(f"--- LOG: Searching for frontend at: {FRONTEND_DIR} ---")

# 5. STATIC FILES MOUNT
# We point this to the /assets folder specifically to help Flutter find images
ASSETS_DIR = os.path.join(FRONTEND_DIR, "assets")
if os.path.exists(ASSETS_DIR):
    app.mount("/assets", StaticFiles(directory=ASSETS_DIR), name="assets")

# 6. SPA & ASSET HANDLER
@app.get("/{full_path:path}")
async def serve_spa(full_path: str):
    if full_path.startswith("api/"):
        return {"detail": "Not Found"}, 404
        
    # --- LOGO INTERCEPTOR ---
    if "msu_logo" in full_path.lower():
        # Look in the double-nested assets folder
        logo_path = os.path.join(FRONTEND_DIR, "assets", "assets", "msu_logo.png")
        if os.path.isfile(logo_path):
            return FileResponse(logo_path, media_type="image/png")

    file_path = os.path.join(FRONTEND_DIR, full_path)

    # 7. SERVE ACTUAL FILES (JS, CSS, etc.)
    if os.path.isfile(file_path):
        if file_path.endswith(".js") or file_path.endswith(".mjs"):
            return FileResponse(file_path, media_type="application/javascript")
        return FileResponse(file_path)
    
    # 8. FLUTTER DOUBLE-ASSET FALLBACK
    nested_path = os.path.join(FRONTEND_DIR, full_path.replace("assets/", "assets/assets/", 1))
    if "assets/" in full_path and os.path.isfile(nested_path):
        return FileResponse(nested_path)

    # 9. SPA FALLBACK
    index_file = os.path.join(FRONTEND_DIR, "index.html")
    if os.path.isfile(index_file):
        return FileResponse(index_file)
    
    return {"error": f"Frontend build not found at {FRONTEND_DIR}"}