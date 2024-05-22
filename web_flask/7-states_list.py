#!/usr/bin/python3
from flask import Flask, render_template
from models import storage
from models.state import State

app = Flask(__name__)

@app.route('/states_list', strict_slashes=False)
def list_states():
    try:
        states = list(storage.all(State).values())
        states.sort(key=lambda state: state.name)
    except Exception as e:
        # Handling exceptions and providing feedback
        print(f"An error occurred: {e}")
        states = []
    return render_template('7-states_list.html', states=states)

@app.teardown_appcontext
def teardown_db(exception=None):
    storage.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)  # Enable debug for development
