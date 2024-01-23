import PySide6.QtWidgets as QtWidgets
import PySide6.QtCore as QtCore


class ProcessingDialog(QtWidgets.QDialog):
    def __init__(self, worker):
        super().__init__()
        self.worker = worker
        self.init_ui()

    def init_ui(self):
        layout = QtWidgets.QVBoxLayout()
        self.label = QtWidgets.QLabel("Processing...")
        self.label.setMinimumWidth(200)
        self.label.setMinimumHeight(100)
        self.label.setWordWrap(True)
        layout.addWidget(self.label)

        # Add Cancel button and connect its slot
        cancel_button = QtWidgets.QPushButton("Cancel")
        cancel_button.clicked.connect(self.cancel_task)
        layout.addWidget(cancel_button)

        self.setLayout(layout)

        # Start the worker thread
        self.worker.task_done.connect(self.on_task_done)
        self.worker.output_received.connect(self.update_output)

        self.worker.start()

    @QtCore.Slot()
    def cancel_task(self):
        self.worker.stop()

    @QtCore.Slot()
    def on_task_done(self):
        self.close()

    @QtCore.Slot(str)
    def update_output(self, text):
        self.label.setText(text)
