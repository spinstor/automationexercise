"""Console step-logging listener for Robot Framework.

Mirrors execution steps to the console in a tree-style format matching the
log.html layout commonly seen in workplace RF setups:

    Test Case Name
    |-- Start New User Signup
    |   |-- [INFO] Typing text 'hello' into text field
    |   \-- [INFO] Clicking element 'css=button'
    \-- Submit Registration Form

Plain Robot Framework writes these messages ONLY to log.html; a listener is
the mechanism that prints them while the test runs.

Usage:
    robot --listener resources/common/console_listener.py tests/...

IMPORTANT: the listener CLASS name must match the FILE name (Robot Framework
loads listeners by finding a class named after the module).

Uses listener API v3 (Robot Framework 6+).
"""

import os
from datetime import datetime

ROBOT_LISTENER_API_VERSION = 3


class console_listener:
    """Listener that mirrors log.html-style tree output to the console."""

    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self):
        self._depth = 0
        self._last_at_depth = [True]
        self._keyword_start = {}

    def _tree_prefix(self, depth):
        parts = []
        for i in range(depth):
            if i < len(self._last_at_depth) - 1 and self._last_at_depth[i]:
                parts.append("   ")
            else:
                parts.append("|  ")
        return "".join(parts)

    def _node_prefix(self, depth, is_last):
        self._last_at_depth[depth:] = [is_last]
        if len(self._last_at_depth) <= depth + 1:
            self._last_at_depth.append(True)
        prefix = self._tree_prefix(depth)
        return prefix + ("\\-- " if is_last else "|-- ")

    def start_suite(self, data, result):
        self._depth = 0
        self._last_at_depth = [True]
        self._print(result.longname)

    def end_suite(self, data, result):
        self._depth = 0
        self._last_at_depth = [True]

    def start_test(self, data, result):
        pass

    def end_test(self, data, result):
        pass

    def start_keyword(self, data, result):
        depth = self._depth
        self._keyword_start[data.lineno] = datetime.now()
        prefix = self._node_prefix(depth, is_last=False)
        self._print("%s%s" % (prefix, data.name))
        self._depth += 1

    def end_keyword(self, data, result):
        self._depth = max(0, self._depth - 1)

    def log_message(self, message):
        level = getattr(message, "level", None)
        if level not in ("INFO", "WARN", "ERROR"):
            return
        # Skip noisy SeleniumLibrary/Robot internal messages
        msg = message.message
        if level == "INFO":
            if msg.startswith("${") and " = " in msg:
                return
            if msg.startswith("Evaluating ") or msg.startswith("Arguments:"):
                return
        prefix = self._node_prefix(self._depth, is_last=True)
        self._print("%s[%s] %s" % (prefix, level, msg))

    def _print(self, text):
        try:
            os.write(1, ("%s\n" % text).encode("utf-8", errors="replace"))
        except OSError:
            pass