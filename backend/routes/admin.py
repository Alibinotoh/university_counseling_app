from fastapi import APIRouter, HTTPException
from models import LoginRequest, ManualSlotRequest
from controllers.admin_controller import AdminController

router = APIRouter()

@router.post("/login")
async def login(data: LoginRequest):
    result = AdminController.login(data)
    if not result["success"]:
        raise HTTPException(status_code=401, detail=result["message"])
    return result

@router.get("/stats/stress")
async def get_stats():
    return AdminController.get_stress_stats()

@router.get("/slots")
async def get_slots(counselor_id: str, date: str):
    return AdminController.get_slots_by_date(counselor_id, date)

@router.delete("/slots/{slot_id}")
async def delete_slot(slot_id: str):
    return AdminController.delete_slot(slot_id)

@router.post("/slots/manual")
async def create_manual_slot(data: ManualSlotRequest):
    return AdminController.create_manual_slot(
        c_id=data.c_id, 
        date=data.date, 
        start_time=data.start_time, # Updated
        end_time=data.end_time      # Updated
    )

# routes/admin.py
@router.get("/appointments/all")
async def get_all_appointments():
    # Fetch all appointments with their linked time and student info
    return AdminController.get_all_appointments()

# routes/admin.py
@router.post("/appointments/decision")
async def update_appointment_status(
    appointment_id: str, 
    new_status: str, 
    notes: str = "" # Default to empty string if not provided
):
    # This calls the method you updated earlier in AdminController
    success = AdminController.update_status(appointment_id, new_status, notes)
    if not success:
        raise HTTPException(status_code=400, detail="Failed to update status")
    return {"message": f"Appointment {new_status}"}