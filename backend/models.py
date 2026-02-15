from pydantic import BaseModel, EmailStr
from typing import Optional, List

# Anonymous Assessment Model
class AssessmentSubmit(BaseModel):
    user_type: str  # "Student" or "Employee"
    # CHANGE THIS: Use List[List[int]] to accept the 3 sections
    scores: List[List[int]] 

# Identified Appointment Model
class AppointmentBook(BaseModel):
    full_name: str
    user_type: str
    email: EmailStr
    contact: str
    counselor_id: str
    timeslot_id: str
    reason: Optional[str] = "No reason provided"

class LoginRequest(BaseModel):
    email: str
    password: str

class ManualSlotRequest(BaseModel):
    c_id: str
    date: str
    start_time: str # Changed from 'time'
    end_time: str   # Added this

class Token(BaseModel):
    access_token: str
    token_type: str