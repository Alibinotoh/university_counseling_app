from fastapi import APIRouter, HTTPException
from models import AssessmentSubmit, AppointmentBook
from controllers.guidance import GuidanceController, generate_ref_code
# Pwede mo nang alisin ang 'from database import driver' dito 
# dahil sa Controller na tayo gumagawa ng DB calls.

router = APIRouter()

@router.post("/assessment/submit")
async def submit_assessment(data: AssessmentSubmit):
    return GuidanceController.handle_assessment(data.user_type, data.scores)

@router.post("/appointment/book")
async def book_appointment(data: AppointmentBook):
    ref_code = generate_ref_code()
    result = GuidanceController.handle_booking(data, ref_code)
    if not result:
        raise HTTPException(status_code=400, detail="Booking failed")
    return {"reference_code": ref_code}

# PINAG-ISA NA ROUTE: Heto lang dapat ang matira para sa Status
@router.get("/appointment/status/{ref_code}")
async def get_status(ref_code: str):
    # Tinatawag nito yung logic sa controllers/guidance.py na kumpleto ang data
    status = GuidanceController.get_appointment_status(ref_code)
    if not status:
        raise HTTPException(status_code=404, detail="Reference code not found")
    return status

@router.get("/slots/available")
async def get_available_slots(counselor_id: str, date: str):
    return GuidanceController.get_available_slots(counselor_id, date)

@router.get("/counselors")
async def get_counselors():
    return GuidanceController.get_all_counselors()

@router.post("/appointment/cancel/{ref_code}")
async def cancel_appointment(ref_code: str):
    success = GuidanceController.cancel_appointment(ref_code)
    if not success:
        raise HTTPException(status_code=404, detail="Appointment not found or na-cancel na")
    return {"message": "Appointment cancelled successfully"}