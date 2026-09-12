from flask import Flask, jsonify, request

app = Flask(__name__)

equipment = [
   {"id": 1, "name": "Production-PC-01", "status": "running"},
   {"id": 2, "name": "Router-01", "status": "running"},
   {"id": 3, "name": "Printer-02", "status": "failed"},
]

@app.get("/health")
def health():
    return jsonify({"status": "ok"}), 200
@app.get("/")
def list_equipment():
    return jsonify(equipment)

@app.post("/equipment")
def add_equipment():
    data = request.get_json()
    new_item = {
        "id": len(equipment) + 1,
        "name": data["name"],
        "status": data.get("status", "running"),
    }
    equipment.append(new_item)
    return jsonify(new_item), 201

@app.patch("/equipment/<int:item_id>")
def update_equipment(item_id):
    for item in equipment:
        if item["id"] == item_id:
            data = request.get_json()
            item["status"] = data.get("status", item["status"])
            return jsonify(item)

    return jsonify({"error": "not found"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
