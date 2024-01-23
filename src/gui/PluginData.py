from dataclasses import dataclass
from pathlib import Path


@dataclass
class PluginData:
    name: str
    path: Path
    resources: list[Path]
