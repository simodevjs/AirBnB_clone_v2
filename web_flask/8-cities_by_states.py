#!/usr/bin/python3
"""
A simple Flask web application to display states from a database
sorted alphabetically by name.
"""

from flask import Flask, render_template
from models import storage, State

app = Flask(__name__)

@app.route('/states_list', strict_slashes=False)
def states_list():
    """
    Fetches all state objects from the storage, sorts them alphabetically by name,
    and passes them to an HTML template to be rendered.
    """
    states = list(storage.all(State).values())
    states.sort(key=lambda x: x.name)  # Sorting states by name
    return render_template('states_list.html', states=states)

@app.teardown_appcontext
def teardown_db(exception=None):
    """
    Closes the storage session after each request.
    """
    storage.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
