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

# 1. Include your API routes FIRST
app.include_router(guidance_router, prefix="/api/v1")
app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

@app.get("/api/v1/health")
def health_check():
    return {"status": "API is online"}

# 2. Define the path to your Flutter build
# When deployed on Render, the path needs to point to the frontend build folder
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FRONTEND_DIR = os.path.join(BASE_DIR, "frontend", "build", "web")

# 3. Mount the static files (images, JS, CSS)
# This allows the browser to find the assets Flutter needs to run
if os.path.exists(FRONTEND_DIR):
    app.mount("/main", StaticFiles(directory=FRONTEND_DIR, html=True), name="frontend")

# 4. Catch-all route to serve index.html for Flutter's SPA routing
@app.get("/{full_path:path}")
async def serve_spa(full_path: str):
    # Check if the request is trying to hit an API route that doesn't exist
    if full_path.startswith("api/"):
        return {"error": "API route not found"}, 404
    
    index_file = os.path.join(FRONTEND_DIR, "index.html")
    if os.path.exists(index_file):
        return FileResponse(index_file)
    
    return {"message": "Frontend build not found. Did you run 'flutter build web'?"}