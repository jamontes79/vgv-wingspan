#!/usr/bin/env python3
"""Validate the repo's generated Codex plugin package in CI."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Any


SEMVER_RE = re.compile(
    r"^(0|[1-9]\d*)\."
    r"(0|[1-9]\d*)\."
    r"(0|[1-9]\d*)"
    r"(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?"
    r"(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$"
)

ALLOWED_MANIFEST_KEYS = {
    "id",
    "name",
    "version",
    "description",
    "skills",
    "apps",
    "mcpServers",
    "interface",
    "author",
    "homepage",
    "repository",
    "license",
    "keywords",
}


def main() -> int:
    plugin_root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    errors: list[str] = []

    manifest_path = plugin_root / ".codex-plugin" / "plugin.json"
    manifest = load_json(manifest_path, errors)
    if manifest is not None:
        validate_manifest(plugin_root, manifest, errors)

    root_manifest = plugin_root / "plugin.json"
    if root_manifest.exists() and manifest_path.exists():
        if root_manifest.read_text() != manifest_path.read_text():
            errors.append("root plugin.json must match .codex-plugin/plugin.json")

    validate_skills(plugin_root / "skills", errors)
    validate_packaged_references(plugin_root, errors)

    if errors:
        print("Codex plugin validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"Codex plugin validation passed: {plugin_root}")
    return 0


def load_json(path: Path, errors: list[str]) -> dict[str, Any] | None:
    if not path.is_file():
        errors.append(f"missing {path}")
        return None
    try:
        payload = json.loads(path.read_text())
    except json.JSONDecodeError as err:
        errors.append(f"{path} is invalid JSON: {err}")
        return None
    if not isinstance(payload, dict):
        errors.append(f"{path} must contain a JSON object")
        return None
    return payload


def validate_manifest(
    plugin_root: Path,
    manifest: dict[str, Any],
    errors: list[str],
) -> None:
    unknown = sorted(set(manifest) - ALLOWED_MANIFEST_KEYS)
    for key in unknown:
        errors.append(f"unsupported manifest field: {key}")

    for key in ("name", "version", "description"):
        if not isinstance(manifest.get(key), str) or not manifest[key].strip():
            errors.append(f"manifest field {key} must be a non-empty string")

    version = manifest.get("version")
    if isinstance(version, str) and SEMVER_RE.fullmatch(version) is None:
        errors.append("manifest version must be strict semver")

    if manifest.get("skills") != "skills":
        errors.append("manifest field skills must be `skills`")

    interface = manifest.get("interface")
    if not isinstance(interface, dict):
        errors.append("manifest field interface must be an object")
    else:
        for key in (
            "displayName",
            "shortDescription",
            "longDescription",
            "developerName",
            "category",
        ):
            if not isinstance(interface.get(key), str) or not interface[key].strip():
                errors.append(f"interface field {key} must be a non-empty string")
        capabilities = interface.get("capabilities")
        if not isinstance(capabilities, list) or not all(
            isinstance(item, str) and item.strip() for item in capabilities
        ):
            errors.append("interface capabilities must be an array of strings")
        if "defaultPrompt" not in interface and "default_prompt" not in interface:
            errors.append("interface defaultPrompt is required")

    for companion, filename in (("apps", ".app.json"), ("mcpServers", ".mcp.json")):
        if companion in manifest and not (plugin_root / filename).is_file():
            errors.append(f"{filename} is required when manifest declares {companion}")


def validate_skills(skills_root: Path, errors: list[str]) -> None:
    if not skills_root.is_dir():
        errors.append("missing skills directory")
        return

    for skill_root in sorted(path for path in skills_root.iterdir() if path.is_dir()):
        skill_md = skill_root / "SKILL.md"
        if not skill_md.is_file():
            errors.append(f"skill {skill_root.name} is missing SKILL.md")
            continue
        contents = skill_md.read_text()
        if not contents.startswith("---\n"):
            errors.append(f"skill {skill_root.name} must start with YAML frontmatter")
            continue
        end = contents.find("\n---", 4)
        if end == -1:
            errors.append(f"skill {skill_root.name} frontmatter is not closed")
            continue
        frontmatter = contents[4:end]
        if not has_frontmatter_string(frontmatter, "name"):
            errors.append(f"skill {skill_root.name} frontmatter needs name")
        if not has_frontmatter_string(frontmatter, "description"):
            errors.append(f"skill {skill_root.name} frontmatter needs description")
        if re.search(r"^disable[-_]model[-_]invocation:\s*true\s*$", frontmatter, re.M):
            errors.append(
                f"skill {skill_root.name} disable-model-invocation must be absent or false"
            )


def validate_packaged_references(plugin_root: Path, errors: list[str]) -> None:
    skills_root = plugin_root / "skills"
    if not skills_root.is_dir():
        return

    references_recommendations = any(
        "hooks/recommendations/" in path.read_text()
        for path in skills_root.glob("*/SKILL.md")
    )
    if not references_recommendations:
        return

    recommendations_root = plugin_root / "hooks" / "recommendations"
    if not recommendations_root.is_dir():
        errors.append("skills reference hooks/recommendations/ but package is missing it")
        return

    recommendation_files = sorted(recommendations_root.glob("*.json"))
    if not recommendation_files:
        errors.append("hooks/recommendations/ must contain at least one JSON file")
        return

    for recommendation_file in recommendation_files:
        load_json(recommendation_file, errors)


def has_frontmatter_string(frontmatter: str, key: str) -> bool:
    match = re.search(rf"^{re.escape(key)}:\s*(.+)$", frontmatter, re.M)
    return bool(match and match.group(1).strip())


if __name__ == "__main__":
    raise SystemExit(main())
