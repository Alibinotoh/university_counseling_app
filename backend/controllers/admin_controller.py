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

    # @staticmethod
    # def get_stress_stats():
    #     query = """
    #     MATCH (a:Assessment)
    #     RETURN a.stress_level as level, count(a) as count
    #     """
    #     with driver.session() as session:
    #         result = session.run(query)
    #         stats = {"High": 0, "Moderate": 0, "Low": 0}
    #         for record in result:
    #             stats[record["level"]] = record["count"]
    #         return stats

    @staticmethod
    def get_stress_stats():
        # Query 1: Get the current overall totals (Current logic)
        totals_query = """
        MATCH (a:Assessment)
        RETURN a.stress_level as level, count(a) as count
        """
        
        # Query 2: Get all 3 trends for the last 6 months
        trend_query = """
        UNWIND range(5, 0, -1) AS i
        WITH datetime() - duration({months: i}) AS month_dt
        WITH month_dt.year AS y, month_dt.month AS m
        OPTIONAL MATCH (a:Assessment)
        WHERE a.timestamp.year = y AND a.timestamp.month = m
        RETURN 
            y, m,
            count(CASE WHEN a.stress_level = 'High' THEN 1 END) AS high_count,
            count(CASE WHEN a.stress_level = 'Moderate' THEN 1 END) AS mod_count,
            count(CASE WHEN a.stress_level = 'Low' THEN 1 END) AS low_count
        ORDER BY y, m
        """

        with driver.session() as session:
            # Execute Totals
            totals_result = list(session.run(totals_query))
            stats = {"High": 0, "Moderate": 0, "Low": 0}
            for record in totals_result:
                if record["level"] in stats:
                    stats[record["level"]] = record["count"]
            
            # Execute Trends
            trend_result = list(session.run(trend_query))
            
            # Combine into separate lists for Flutter
            stats["trend_high"] = [r["high_count"] for r in trend_result]
            stats["trend_mod"] = [r["mod_count"] for r in trend_result]
            stats["trend_low"] = [r["low_count"] for r in trend_result]
            
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

    # @staticmethod
    # def create_manual_slot(c_id, date, start_time, end_time):
    #     query = """
    #     MATCH (c:Counselor {id: $c_id})
    #     CREATE (ts:TimeSlot {
    #         id: randomUUID(),
    #         date: $date,
    #         start_time: $start_time,
    #         end_time: $end_time,
    #         is_available: true
    #     })
    #     CREATE (c)-[:HAS_SLOT]->(ts)
    #     RETURN ts.id as id
    #     """
    #     with driver.session() as session:
    #         result = session.run(query, c_id=c_id, date=date, 
    #                              start_time=start_time, end_time=end_time)
    #         return {"status": "success", "id": result.single()["id"]}

    @staticmethod
    def create_manual_slot(c_id, date, start_time, end_time):
        query = """
        MATCH (c:Counselor {id: $c_id})
        CREATE (ts:TimeSlot {
            id: randomUUID(),
            date: $date,
            start_time: $start_time,
            end_time: $end_time,
            is_available: true,
            counselor_id: $c_id  // ADD THIS LINE
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
            ap.timestamp as timestamp,  // <--- ADD THIS LINE
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

    @staticmethod
    def create_bulk_slots(c_id, date, start_time, end_time, duration):
        # 1. Parsing logic (remains the same)
        fmt = "%I:%M %p"
        try:
            current_dt = datetime.strptime(start_time, fmt)
            end_dt = datetime.strptime(end_time, fmt)
        except ValueError:
            current_dt = datetime.strptime(start_time, "%H:%M")
            end_dt = datetime.strptime(end_time, "%H:%M")

        slots_to_create = []
        while current_dt + timedelta(minutes=duration) <= end_dt:
            s_time = current_dt.strftime("%I:%M %p")
            current_dt += timedelta(minutes=duration)
            e_time = current_dt.strftime("%I:%M %p")
            slots_to_create.append({"start": s_time, "end": e_time})

        # 2. UPDATED QUERY:
        # We ensure counselor_id is part of the node property
        query = """
        MATCH (c:Counselor {id: $c_id})
        UNWIND $slots as slot
        MERGE (ts:TimeSlot {
            date: $date,
            start_time: slot.start,
            end_time: slot.end,
            counselor_id: $c_id  // Adding this to the MERGE key prevents duplicates
        })
        ON CREATE SET 
            ts.id = randomUUID(), 
            ts.is_available = true
        MERGE (c)-[:HAS_SLOT]->(ts)
        RETURN count(ts) as created_count
        """
        
        try:
            with driver.session() as session:
                def _do_bulk(tx):
                    result = tx.run(query, c_id=c_id, date=date, slots=slots_to_create)
                    return result.single()["created_count"]

                count = session.execute_write(_do_bulk)
                return {"status": "success", "message": f"Created {count} slots"}
        except Exception as e:
            print(f"BULK ERROR: {e}")
            return {"status": "error", "message": str(e)}

    @staticmethod
    def clear_day_slots(counselor_id, date):
        # NEW STRATEGY: Only match slots where is_available is true
        # This prevents deleting slots that have been booked by students.
        query = """
        MATCH (c:Counselor {id: $c_id})-[:HAS_SLOT]->(ts:TimeSlot {date: $date})
        WHERE ts.is_available = true
        DETACH DELETE ts
        RETURN count(*) as deleted_count
        """
        
        try:
            with driver.session() as session:
                def _do_delete(tx):
                    res = tx.run(query, c_id=str(counselor_id), date=date)
                    record = res.single()
                    return record["deleted_count"] if record else 0

                count = session.execute_write(_do_delete)
                print(f"--- [CLEANUP] Counselor: {counselor_id} | Removed: {count} available slots ---")
                
                return {
                    "status": "success", 
                    "deleted_count": count,
                    "message": f"Cleared {count} available slots. Booked slots were preserved."
                }
        except Exception as e:
            print(f"--- [ERROR] {e} ---")
            return {"status": "error", "message": str(e), "deleted_count": 0}