# from database import driver
# from jose import jwt
# from datetime import datetime, timedelta

# # Configuration for JWT
# SECRET_KEY = "your_msu_capstone_secret_key" # Change this to a random string
# ALGORITHM = "HS256"
# ACCESS_TOKEN_EXPIRE_MINUTES = 60

# class AdminController:
#     @staticmethod
#     def login(data):
#         # Authenticate counselor
#         query = """
#         MATCH (c:Counselor {email: $email, password: $password})
#         RETURN c.id as id, c.name as name, c.email as email
#         """
#         with driver.session() as session:
#             result = session.run(query, email=data.email, password=data.password)
#             user = result.single()
            
#             if user:
#                 # 1. Generate JWT Token
#                 expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
#                 to_encode = {"sub": user["id"], "exp": expire}
#                 encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
                
#                 # 2. Return user data + token
#                 return {
#                     "success": True, 
#                     "token": encoded_jwt,
#                     "user": {
#                         "id": user["id"], 
#                         "name": user["name"],
#                         "email": user["email"] # Added for your Profile Page
#                     }
#                 }
#             return {"success": False, "message": "Invalid credentials"}

#     @staticmethod
#     def get_stress_stats():
#         query = """
#         MATCH (a:Assessment)
#         RETURN a.stress_level as level, count(a) as count
#         """
#         with driver.session() as session:
#             result = session.run(query)
#             stats = {"High": 0, "Moderate": 0, "Low": 0}
#             for record in result:
#                 stats[record["level"]] = record["count"]
#             return stats

#     @staticmethod
#     def delete_slot(slot_id):
#         query = """
#         MATCH (ts:TimeSlot {id: $slot_id})
#         DETACH DELETE ts
#         """
#         with driver.session() as session:
#             session.run(query, slot_id=slot_id)
#             return {"status": "success", "message": "Slot deleted successfully"}

#     @staticmethod
#     def create_manual_slot(c_id, date, start_time, end_time):
#         query = """
#         MATCH (c:Counselor {id: $c_id})
#         CREATE (ts:TimeSlot {
#             id: randomUUID(),
#             date: $date,
#             start_time: $start_time,
#             end_time: $end_time,
#             is_available: true
#         })
#         CREATE (c)-[:HAS_SLOT]->(ts)
#         RETURN ts.id as id
#         """
#         with driver.session() as session:
#             result = session.run(query, c_id=c_id, date=date, 
#                                  start_time=start_time, end_time=end_time)
#             return {"status": "success", "id": result.single()["id"]}

#     @staticmethod
#     def get_slots_by_date(counselor_id, date):
#         query = """
#         MATCH (c:Counselor {id: $c_id})-[:HAS_SLOT]->(ts:TimeSlot {date: $date})
#         RETURN ts.id as id, 
#                ts.start_time as start_time, 
#                ts.end_time as end_time, 
#                ts.is_available as is_available
#         ORDER BY ts.start_time ASC
#         """
#         with driver.session() as session:
#             result = session.run(query, c_id=counselor_id, date=date)
#             return [dict(record) for record in result]

#             # controllers/admin_controller.py

#     @staticmethod
#     def get_all_appointments():
#         query = """
#         MATCH (ap:Appointment)-[:BOOKED_FOR]->(ts:TimeSlot)
#         MATCH (ap)-[:WITH_COUNSELOR]->(c:Counselor)
#         RETURN ap.id as id, ap.full_name as student_name, ap.user_type as type,
#             ap.status as status, ts.date as date, ts.start_time as time,
#             ap.reference_code as ref_code
#         ORDER BY ap.timestamp DESC
#         """
#         with driver.session() as session:
#             result = session.run(query)
#             return [dict(record) for record in result]

#     @staticmethod
#     def update_status(ap_id, new_status):
#         # Logic: If rejected, set TimeSlot back to available
#         query = """
#         MATCH (ap:Appointment {id: $ap_id})-[:BOOKED_FOR]->(ts:TimeSlot)
#         SET ap.status = $status
#         WITH ap, ts
#         CALL apoc.do.when(
#             $status = 'Rejected',
#             'SET ts.is_available = true RETURN ts',
#             'RETURN ts',
#             {ts:ts}
#         ) YIELD value
#         RETURN ap
#         """
#         with driver.session() as session:
#             result = session.run(query, ap_id=ap_id, status=new_status)
#             return result.single() is not None

from database import driver
from jose import jwt
from datetime import datetime, timedelta

# Configuration for JWT
SECRET_KEY = "your_msu_capstone_secret_key" 
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

class AdminController:
    @staticmethod
    def login(data):
        # Authenticate counselor
        query = """
        MATCH (c:Counselor {email: $email, password: $password})
        RETURN c.id as id, c.name as name, c.email as email
        """
        with driver.session() as session:
            result = session.run(query, email=data.email, password=data.password)
            user = result.single()
            
            if user:
                # 1. Generate JWT Token
                expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
                to_encode = {"sub": user["id"], "exp": expire}
                encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
                
                # 2. Return user data + token
                return {
                    "success": True, 
                    "token": encoded_jwt,
                    "user": {
                        "id": user["id"], 
                        "name": user["name"],
                        "email": user["email"]
                    }
                }
            return {"success": False, "message": "Invalid credentials"}

    @staticmethod
    def get_stress_stats():
        query = """
        MATCH (a:Assessment)
        RETURN a.stress_level as level, count(a) as count
        """
        with driver.session() as session:
            result = session.run(query)
            stats = {"High": 0, "Moderate": 0, "Low": 0}
            for record in result:
                stats[record["level"]] = record["count"]
            return stats

    @staticmethod
    def delete_slot(slot_id):
        query = """
        MATCH (ts:TimeSlot {id: $slot_id})
        DETACH DELETE ts
        """
        with driver.session() as session:
            session.run(query, slot_id=slot_id)
            return {"status": "success", "message": "Slot deleted successfully"}

    @staticmethod
    def create_manual_slot(c_id, date, start_time, end_time):
        query = """
        MATCH (c:Counselor {id: $c_id})
        CREATE (ts:TimeSlot {
            id: randomUUID(),
            date: $date,
            start_time: $start_time,
            end_time: $end_time,
            is_available: true
        })
        CREATE (c)-[:HAS_SLOT]->(ts)
        RETURN ts.id as id
        """
        with driver.session() as session:
            result = session.run(query, c_id=c_id, date=date, 
                                 start_time=start_time, end_time=end_time)
            return {"status": "success", "id": result.single()["id"]}

    @staticmethod
    def get_slots_by_date(counselor_id, date):
        query = """
        MATCH (c:Counselor {id: $c_id})-[:HAS_SLOT]->(ts:TimeSlot {date: $date})
        RETURN ts.id as id, 
               ts.start_time as start_time, 
               ts.end_time as end_time, 
               ts.is_available as is_available
        ORDER BY ts.start_time ASC
        """
        with driver.session() as session:
            result = session.run(query, c_id=counselor_id, date=date)
            return [dict(record) for record in result]

    @staticmethod
    def get_all_appointments():
        query = """
        MATCH (ap:Appointment)-[:BOOKED_FOR]->(ts:TimeSlot)
        RETURN elementId(ap) as id, 
            ap.full_name as student_name, 
            ap.user_type as type,
            ap.email as email,      // Added credential
            ap.contact as contact,  // Added credential
            ap.reason as reason,    // Added credential
            ap.status as status, 
            ap.counselor_notes as notes, // Retrieve notes
            ts.date as date, 
            ts.start_time as time,
            ap.reference_code as ref_code
        ORDER BY ap.timestamp DESC
        """
        with driver.session() as session:
            result = session.run(query)
            return [dict(record) for record in result]

    @staticmethod
    def update_status(ap_id, new_status, notes=""): # Added notes parameter
        query = """
        MATCH (ap:Appointment)
        WHERE elementId(ap) = $ap_id
        MATCH (ap)-[:BOOKED_FOR]->(ts:TimeSlot)
        SET ap.status = $status,
            ap.counselor_notes = $notes  // Save the notes here
        WITH ap, ts
        CALL apoc.do.when(
            $status = 'Rejected',
            'SET ts.is_available = true RETURN ts',
            'RETURN ts',
            {ts:ts}
        ) YIELD value
        RETURN ap
        """
        with driver.session() as session:
            result = session.run(query, ap_id=ap_id, status=new_status, notes=notes)
            return result.single() is not None