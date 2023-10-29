import sys
from cx_Freeze import setup, Executable


# Dependencies are automatically detected, but it might need fine-tuning.
build_exe_options = {
    # "packages": ["PySide6.QtCore", "PySide6.QtWidgets"],
    "zip_include_packages": ["PySide6"],
    "excludes": [
        "tkinter",
        "numpy",
        "test",
    ],  # Exclude packages that are not needed
    "optimize": 2,  # 0, 1, or 2 representing no optimization, basic optimization, and full optimization
}

base = None
if sys.platform == "win32":
    base = "Win32GUI"  # Use this for GUI applications to not show a console window on Windows

setup(
    name="FNV to FO4",
    version="0.1",
    description="FNV to FO4",
    options={"build_exe": build_exe_options},
    executables=[Executable("app.py", base=base, target_name="fnv-to-fo4.exe")],
)
