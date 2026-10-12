"""Cross-platform user configuration paths for renjian-guancha."""
from __future__ import annotations

import os
import sys
import warnings
from pathlib import Path


def config_dir() -> Path:
    override = os.environ.get("RENJIAN_CONFIG_DIR")
    if override:
        return Path(os.path.expandvars(os.path.expanduser(override)))
    if sys.platform == "win32":
        base = os.environ.get("APPDATA") or str(Path.home() / "AppData" / "Roaming")
        return Path(base) / "renjian-guancha"
    if sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support" / "renjian-guancha"
    base = os.environ.get("XDG_CONFIG_HOME") or str(Path.home() / ".config")
    return Path(base) / "renjian-guancha"


def env_file(explicit: str | None = None) -> Path:
    value = explicit or os.environ.get("IMAGEGEN_ENV_FILE") or os.environ.get("OPENCLAW_ENV_FILE")
    if value:
        return Path(os.path.expandvars(os.path.expanduser(value)))
    preferred = config_dir() / "imagegen.env"
    if preferred.exists():
        return preferred
    legacy = Path.home() / ".openclaw" / ".env"
    if legacy.exists():
        warnings.warn(
            f"Using legacy env file {legacy}; migrate to {preferred} or set IMAGEGEN_ENV_FILE",
            RuntimeWarning,
        )
        return legacy
    return preferred


def activate_skill_site_packages() -> Path | None:
    """Reuse compatible packages when a container cannot run the host venv."""
    skill_root = Path(__file__).resolve().parents[1]
    version = f"python{sys.version_info.major}.{sys.version_info.minor}"
    packages = skill_root / ".venv" / "lib" / version / "site-packages"
    if packages.is_dir() and str(packages) not in sys.path:
        sys.path.insert(0, str(packages))
        return packages
    return None
