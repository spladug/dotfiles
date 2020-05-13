import atexit
import os
import readline

from pathlib import Path


try:
    histfile = os.environ["PYTHONHISTFILE"]
except KeyError:
    try:
        histfile = Path(os.environ["XDG_DATA_HOME"]) / "python_history"
    except KeyError:
        histfile = Path.home() / ".python_history"


try:
    readline.read_history_file(histfile)
    start_index = readline.get_current_history_length()
except FileNotFoundError:
    open(histfile, "wb").close()
    start_index = 0


def save_history(start_index, histfile):
    end_index = readline.get_current_history_length()
    readline.set_history_length(1000)
    readline.append_history_file(end_index - start_index, histfile)


atexit.register(save_history, start_index, histfile)
