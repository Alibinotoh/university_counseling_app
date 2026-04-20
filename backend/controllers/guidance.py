import random
import string
from database import driver

def generate_ref_code():
    chars = "".join(random.choices(string.ascii_uppercase, k=4))
    nums = "".join(random.choices(string.digits, k=4))
    return f"{chars}-{nums}"

class GuidanceController:
    @staticmethod
    def handle_assessment(user_type, section_scores, user_name="Anonymous"): # Added user_name
        s1_avg = sum(section_scores[0]) / 10
        s2_avg = sum(section_scores[1]) / 10
        
        s3_data = list(section_scores[2]) 
        s3_data[7] = 6 - s3_data[7] 
        s3_avg = sum(s3_data) / 10
        
        final_score = (s1_avg + s2_avg + s3_avg) / 3
        rounded_score = round(final_score, 2)
        
        # New 3-Tier Classification
        if rounded_score >= 3.5:
            level = "High"
            warning = True
        elif rounded_score >= 2.5:
            level = "Moderate"
            warning = True
        else:
            level = "Low"
            warning = False
        
        # Save to Neo4j with the name field
        with driver.session() as session:
            session.run("""
                CREATE (a:Assessment {
                    id: randomUUID(),
                    user_name: $un,       // Store the user's name
                    user_type: $ut,
                    final_score: $fs, 
                    stress_level: $l, 
                    raw_answers: $answers,
                    timestamp: datetime()
                })
            """, un=user_name, ut=user_type, fs=rounded_score, l=level, answers=str(section_scores))
        
        return {
            "stress_level": level,
            "score": rounded_score,
            "trigger_warning": warning
        }
        
    @staticmethod
    def handle_booking(data, ref_code):
        query = """
        // 1. Match the Counselor and Slot
        MATCH (c:Counselor {id: $c_id})-[:HAS_SLOT]->(ts:TimeSlot {id: $ts_id})
        WHERE ts.is_available = true
        SET ts.is_available = false

        // 2. Create the Appointment
        CREATE (ap:Appointment {
            reference_code: $ref, 
            full_name: $name, 
            user_type: $type,
            email: $email, 
            contact: $contact, 
            reason: $reason,
            status: 'Pending', 
            timestamp: datetime()
        })

        // 3. Link Appointment to Counselor and Slot
        CREATE (ap)-[:BOOKED_FOR]->(ts)
        CREATE (ap)-[:WITH_COUNSELOR]->(c)

        // 4. NEW: Link Appointment to the User's latest Assessment
        WITH ap
        OPTIONAL MATCH (as:Assessment {user_name: $name})
        WITH ap, as
        ORDER BY as.timestamp DESC
        LIMIT 1
        FOREACH (_ IN CASE WHEN as IS NOT NULL THEN [1] ELSE [] END |
            CREATE (as)-[:RESULTED_IN]->(ap)
        )

        RETURN ap.reference_code as ref
        """
        with driver.session() as session:
            result = session.run(query, 
                c_id=data.counselor_id, ts_id=data.timeslot_id, ref=ref_code,
                name=data.full_name, type=data.user_type, email=data.email,
                contact=data.contact, reason=data.reason)
            return result.single()

    @staticmethod
    def get_all_counselors():
        query = "MATCH (c:Counselor) RETURN c.id as id, c.name as name"
        with driver.session() as session:
            result = session.run(query)
            return [dict(record) for record in result]

# controllers/guidance.py
    @staticmethod
    def get_available_slots(counselor_id, date):
        query = """
        MATCH (c:Counselor {id: $c_id})-[:HAS_SLOT]->(ts:TimeSlot {date: $date})
        WHERE ts.is_available = true
        RETURN ts.id as id, ts.start_time as start_time, ts.end_time as end_time
        ORDER BY ts.start_time ASC
        """
        with driver.session() as session:
            result = session.run(query, c_id=counselor_id, date=date)
            return [dict(record) for record in result]

    @staticmethod
    def get_appointment_status(ref_code):
        query = """
        MATCH (ap:Appointment {reference_code: $ref})
        OPTIONAL MATCH (ap)-[:BOOKED_FOR]->(ts:TimeSlot)
        OPTIONAL MATCH (ap)-[:WITH_COUNSELOR]->(c:Counselor)
        RETURN ap.status as status, 
            ap.counselor_notes as notes,
            ts.date as date, 
            ts.start_time as start_time, 
            ts.end_time as end_time,
            c.name as counselor_name
        """
        with driver.session() as session:
            result = session.run(query, ref=ref_code)
            record = result.single()
            if record:
                return {
                    "status": record["status"],
                    "notes": record["notes"], # This will now flow to your Flutter app
                    "date": record["date"],
                    "start_time": record["start_time"],
                    "end_time": record["end_time"],
                    "counselor_name": record["counselor_name"]
                }
            return None

    @staticmethod
    def cancel_appointment(ref_code):
        query = """
        MATCH (ap:Appointment {reference_code: $ref})-[:BOOKED_FOR]->(ts:TimeSlot)
        SET ap.status = 'Cancelled',
            ts.is_available = true
        RETURN ap.reference_code as ref
        """
        with driver.session() as session:
            result = session.run(query, ref=ref_code)
            return result.single() is not None