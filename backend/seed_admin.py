from database import driver

def seed_admin():
    query = """
    MERGE (c:Counselor {id: "admin_001"})
    ON CREATE SET 
        c.name = "Doc. Jay",
        c.email = "doc.jay@msu.edu",
        c.specialty = "Clinical Psychology & Mental Health",
        c.password = "admin123",
        c.role = "Admin"
    RETURN c.name
    """
    with driver.session() as session:
        result = session.run(query)
        admin = result.single()
        if admin:
            print(f"✅ Admin account '{admin[0]}' is ready.")
        else:
            print("❌ Seeding failed.")

if __name__ == "__main__":
    seed_admin()