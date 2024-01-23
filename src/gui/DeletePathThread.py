import PySide6.QtCore as QtCore
from pathlib import Path
import traceback
from gui_exceptions import InterruptException
import os


class DeletePathThread(QtCore.QThread):
    task_done = QtCore.Signal()
    output_received = QtCore.Signal(str)

    def __init__(self, paths: list[Path]):
        super().__init__()

        self.paths = paths
        self._stop_flag = False
        self.failed = False
        self.interrupted = False
        self.mutex = QtCore.QMutex()

    def run(self):
        try:
            for path in self.paths:
                self.stop_if_requested()

                self.output_received.emit(f"Deleting \"{path}\"...")

                if path.is_file():
                    # noinspection PyBroadException
                    try:
                        path.unlink()
                    except Exception:
                        traceback.print_exc()

                        self.failed = True

                    continue

                self.delete_all_in_directory(path)

                if path.exists():
                    # noinspection PyBroadException
                    try:
                        path.rmdir()
                    except Exception:
                        traceback.print_exc()

                        self.failed = True
        except InterruptException:
            self.interrupted = True

            pass

        self.task_done.emit()

    def stop(self):
        self.mutex.lock()
        self._stop_flag = True
        self.mutex.unlock()

    def stop_if_requested(self):
        self.mutex.lock()

        if self._stop_flag:
            self.mutex.unlock()

            raise InterruptException()

        self.mutex.unlock()

    def delete_all_in_directory(self, root_dir):
        if not Path(root_dir).is_dir():
            return

        # List all files and directories in the current directory
        for item in os.listdir(root_dir):
            self.stop_if_requested()

            item_path = os.path.join(root_dir, item)

            # If it's a directory, recursively delete its contents
            if os.path.isdir(item_path):
                self.delete_all_in_directory(item_path)

                # Once all contents of the directory are deleted, delete the
                # directory itself
                # noinspection PyBroadException
                try:
                    os.rmdir(item_path)
                except Exception:
                    traceback.print_exc()

                    self.failed = True
            else:
                # Delete the file
                # noinspection PyBroadException
                try:
                    os.remove(item_path)
                except Exception:
                    traceback.print_exc()

                    self.failed = True
