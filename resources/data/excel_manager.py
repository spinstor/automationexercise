"""Excel read/write library for data-driven Robot Framework tests.

Provides keywords for reading test data from .xlsx files and writing
execution results back, enabling data-driven signup/registration flows.

Import from Robot:

    Library    ../data/excel_manager.py

NOTE: the CLASS name must match the MODULE (file) name when imported
by file path — class is deliberately named ``excel_manager``.
"""

from datetime import datetime
from pathlib import Path

from openpyxl import Workbook, load_workbook
from openpyxl.styles import Font, PatternFill, Alignment


# Expected column headers (order matters for row-based reading)
USER_DATA_COLUMNS = [
    "name",
    "email",
    "password",
    "title",
    "birth_day",
    "birth_month",
    "birth_year",
    "first_name",
    "last_name",
    "company",
    "address1",
    "country",
    "state",
    "city",
    "zipcode",
    "mobile",
]


class excel_manager:
    """Keywords for reading/writing Excel test data."""

    ROBOT_LIBRARY_SCOPE = "SUITE"

    # ------------------------------------------------------------------
    # Reading
    # ------------------------------------------------------------------

    def read_user_data_from_excel(self, file_path, sheet_name="Sheet1"):
        """Reads all data rows from the Excel file and returns them as a
        list of dictionaries (one dict per row, keyed by column header).

        Rows where the ``status`` column is already ``PASS`` are skipped
        (allowing re-runs to pick up only incomplete entries).

        Example (Robot):
            @{users}=    Read User Data From Excel    resources/data/test_users.xlsx
        """
        wb = load_workbook(file_path)
        ws = wb[sheet_name]
        headers = [cell.value for cell in ws[1]]
        rows = []
        for row in ws.iter_rows(min_row=2, values_only=True):
            record = dict(zip(headers, row))
            # Skip rows already marked PASS (idempotent re-run support)
            status = record.get("status")
            if status and str(status).strip().upper() == "PASS":
                continue
            rows.append(record)
        wb.close()
        return rows

    def get_user_count_from_excel(self, file_path, sheet_name="Sheet1"):
        """Returns the number of data rows (excluding header) in the sheet.

        Example (Robot):
            ${count}=    Get User Count From Excel    resources/data/test_users.xlsx
        """
        wb = load_workbook(file_path)
        ws = wb[sheet_name]
        count = ws.max_row - 1
        wb.close()
        return count

    def get_user_by_index(self, file_path, index, sheet_name="Sheet1"):
        """Returns a single row as a dictionary by 0-based index.

        Example (Robot):
            ${user}=    Get User By Index    resources/data/test_users.xlsx    0
        """
        wb = load_workbook(file_path)
        ws = wb[sheet_name]
        headers = [cell.value for cell in ws[1]]
        target_row = index + 2  # +2 because row 1 is header, openpyxl is 1-based
        if target_row > ws.max_row:
            wb.close()
            raise IndexError(f"Row index {index} out of range (max {ws.max_row - 2})")
        row_values = [cell.value for cell in ws[target_row]]
        record = dict(zip(headers, row_values))
        wb.close()
        return record

    # ------------------------------------------------------------------
    # Writing
    # ------------------------------------------------------------------

    def write_registration_status(
        self, file_path, email, status, message="", sheet_name="Sheet1"
    ):
        """Writes execution status back to the Excel row matching *email*.

        Adds/updates the ``status`` column with PASS or FAIL, and appends
        a ``result_message`` column with a timestamped note.

        Example (Robot):
            Write Registration Status    resources/data/test_users.xlsx    ${email}    PASS
            Write Registration Status    resources/data/test_users.xlsx    ${email}    FAIL    ${error_msg}
        """
        wb = load_workbook(file_path)
        ws = wb[sheet_name]
        headers = [cell.value for cell in ws[1]]

        # Ensure status and result_message columns exist
        if "status" not in headers:
            ws.cell(row=1, column=len(headers) + 1, value="status")
            headers.append("status")
        if "result_message" not in headers:
            ws.cell(row=1, column=len(headers) + 1, value="result_message")
            headers.append("result_message")

        status_col = headers.index("status") + 1
        message_col = headers.index("result_message") + 1
        email_col = headers.index("email") + 1

        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        result_msg = f"[{timestamp}] {message}" if message else f"[{timestamp}]"

        for row_idx in range(2, ws.max_row + 1):
            cell_email = ws.cell(row=row_idx, column=email_col).value
            if cell_email and str(cell_email).strip().lower() == str(email).strip().lower():
                ws.cell(row=row_idx, column=status_col, value=status.upper())
                ws.cell(row=row_idx, column=message_col, value=result_msg)
                break

        wb.save(file_path)
        wb.close()

    # ------------------------------------------------------------------
    # Excel creation helper (for seeding sample data)
    # ------------------------------------------------------------------

    def create_sample_user_excel(self, file_path, sheet_name="Sheet1"):
        """Creates a fresh Excel file with the expected column headers
        and a light styling.  Existing files are overwritten.

        Example (Robot):
            Create Sample User Excel    resources/data/test_users.xlsx
        """
        wb = Workbook()
        ws = wb.active
        ws.title = sheet_name

        all_headers = USER_DATA_COLUMNS + ["status", "result_message"]
        header_font = Font(bold=True, color="FFFFFF")
        header_fill = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")

        for col_idx, header in enumerate(all_headers, start=1):
            cell = ws.cell(row=1, column=col_idx, value=header)
            cell.font = header_font
            cell.fill = header_fill
            cell.alignment = Alignment(horizontal="center")

        # Auto-size columns (approximate)
        for col_idx, header in enumerate(all_headers, start=1):
            ws.column_dimensions[chr(64 + col_idx) if col_idx <= 26 else "A"].width = max(len(header) + 2, 14)

        wb.save(file_path)
        wb.close()
