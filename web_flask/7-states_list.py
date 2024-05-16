#!/usr/bin/python3
"""
This script starts a Flask web application that lists states from a database.
It listens on 0.0.0.0, port 5000, and displays states sorted by name.
"""

from flask import Flask, render_template
from models import storage, State

app = Flask(__name__)

@app.route('/states_list', strict_slashes=False)
def list_states():
    """
    Fetches all states from the database using the storage engine, sorts them
    alphabetically by name, and renders them in an HTML page.
    """

    states = list(storage.all(State).values())
    states.sort(key=lambda state: state.name)  # Sort states by name
    return render_template('states_list.html', states=states)

@app.teardown_appcontext
def teardown_db(exception=None):
    """
    Ensures the database session is closed after each request.
    This prevents memory leaks and keeps the application clean.
    """
    storage.close()

if __name__ == '__main__':
    # Run the Flask application on all available IPs and port 5000
    app.run(host='0.0.0.0', port=5000)
