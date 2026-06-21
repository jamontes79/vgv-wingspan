#!/bin/bash
# Tests for recommend-plugins-codex.sh
#
# Usage: bash hooks/test_recommend_plugins_codex.sh
#
# Creates a temporary plugin root and project root so the Codex hook can be
# tested against its package-relative recommendation data and cwd input.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_SCRIPT="$SCRIPT_DIR/recommend-plugins-codex.sh"

PASS=0
FAIL=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

setup() {
  TEST_DIR=$(mktemp -d)
  PLUGIN_HOOKS_DIR="$TEST_DIR/plugin/hooks"
  RECOMMENDATIONS_DIR="$PLUGIN_HOOKS_DIR/recommendations"
  PROJECT_DIR="$TEST_DIR/project"
  mkdir -p "$RECOMMENDATIONS_DIR" "$PROJECT_DIR"

  # Copy hook script so SCRIPT_DIR resolves to the temp plugin hooks dir.
  WRAPPER="$PLUGIN_HOOKS_DIR/recommend-plugins-codex.sh"
  cp "$HOOK_SCRIPT" "$WRAPPER"
  chmod +x "$WRAPPER"

  PROJECT_HASH=$(echo "$PROJECT_DIR" | shasum | cut -d' ' -f1)
  MARKER="/tmp/wingspan-codex-recommend-plugins-$PROJECT_HASH"
  rm -f "$MARKER"
}

teardown() {
  rm -f "$MARKER" 2>/dev/null || true
  rm -rf "$TEST_DIR" 2>/dev/null || true
}

run_hook() {
  jq -n --arg cwd "$PROJECT_DIR" \
    '{hook_event_name: "UserPromptSubmit", cwd: $cwd}' |
    bash "$WRAPPER" 2>/dev/null || true
}

run_hook_with_event() {
  local event="$1"
  jq -n --arg cwd "$PROJECT_DIR" --arg event "$event" \
    '{hook_event_name: $event, cwd: $cwd}' |
    bash "$WRAPPER" 2>/dev/null || true
}

add_recommendation() {
  local name="$1"
  local content="$2"
  echo "$content" > "$RECOMMENDATIONS_DIR/$name.json"
}

add_project_file() {
  local path="$1"
  local content="$2"
  mkdir -p "$PROJECT_DIR/$(dirname "$path")"
  echo "$content" > "$PROJECT_DIR/$path"
}

assert_contains() {
  local output="$1"
  local expected="$2"
  local msg="$3"
  if echo "$output" | grep -q "$expected"; then
    PASS=$((PASS + 1))
    echo "  PASS: $msg"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $msg"
    echo "    expected to contain: $expected"
    echo "    got: $output"
  fi
}

assert_empty() {
  local output="$1"
  local msg="$2"
  if [[ -z "$output" ]]; then
    PASS=$((PASS + 1))
    echo "  PASS: $msg"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $msg"
    echo "    expected empty output, got: $output"
  fi
}

assert_file_exists() {
  local path="$1"
  local msg="$2"
  if [[ -f "$path" ]]; then
    PASS=$((PASS + 1))
    echo "  PASS: $msg"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $msg"
    echo "    file does not exist: $path"
  fi
}

assert_file_not_exists() {
  local path="$1"
  local msg="$2"
  if [[ ! -f "$path" ]]; then
    PASS=$((PASS + 1))
    echo "  PASS: $msg"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $msg"
    echo "    file should not exist: $path"
  fi
}

assert_json_field_equals() {
  local output="$1"
  local filter="$2"
  local expected="$3"
  local msg="$4"
  local actual
  actual=$(echo "$output" | jq -r "$filter" 2>/dev/null || true)
  if [[ "$actual" == "$expected" ]]; then
    PASS=$((PASS + 1))
    echo "  PASS: $msg"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $msg"
    echo "    expected: $expected"
    echo "    got: $actual"
  fi
}

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

test_no_recommendations_dir() {
  echo "test: exits silently when recommendations dir is missing"
  setup
  rm -rf "$RECOMMENDATIONS_DIR"
  local output
  output=$(run_hook)
  assert_empty "$output" "no output when recommendations dir missing"
  assert_file_not_exists "$MARKER" "no marker written"
  teardown
}

test_no_recommendation_files() {
  echo "test: exits silently when recommendations dir is empty"
  setup
  local output
  output=$(run_hook)
  assert_empty "$output" "no output when no recommendation files"
  assert_file_not_exists "$MARKER" "no marker written"
  teardown
}

test_file_detection_matches_using_cwd() {
  echo "test: recommends plugin when 'file' detection matches in cwd"
  setup
  add_recommendation "test-plugin" '{
    "plugin": "test-plugin",
    "detect": { "file": "pubspec.yaml", "pattern": "flutter" },
    "marketplace": "Org/repo",
    "description": "Test plugin."
  }'
  add_project_file "pubspec.yaml" "dependencies:
  flutter:
    sdk: flutter"
  local output
  output=$(run_hook)
  assert_contains "$output" "test-plugin" "plugin name in output"
  assert_contains "$output" "codex plugin add test-plugin@<marketplace-name>" "Codex install command in output"
  assert_contains "$output" "Org/repo" "Claude marketplace source in output"
  assert_file_exists "$MARKER" "marker file created for cwd"
  teardown
}

test_file_detection_no_match_pattern() {
  echo "test: no recommendation when file exists but pattern does not match"
  setup
  add_recommendation "test-plugin" '{
    "plugin": "test-plugin",
    "detect": { "file": "pubspec.yaml", "pattern": "flutter" },
    "marketplace": "Org/repo",
    "description": "Test plugin."
  }'
  add_project_file "pubspec.yaml" "dependencies:
  react: ^18.0.0"
  local output
  output=$(run_hook)
  assert_empty "$output" "no output when pattern does not match"
  assert_file_not_exists "$MARKER" "no marker written"
  teardown
}

test_files_glob_detection_matches() {
  echo "test: recommends plugin when 'files' glob detection matches"
  setup
  add_recommendation "test-plugin" '{
    "plugin": "test-plugin",
    "detect": { "files": "docs/plan/*.md", "pattern": "flutter|dart" },
    "marketplace": "Org/repo",
    "description": "Glob plugin."
  }'
  add_project_file "docs/plan/my-plan.md" "We will build a dart package."
  local output
  output=$(run_hook)
  assert_contains "$output" "test-plugin" "plugin name in output"
  assert_contains "$output" "Glob plugin." "description in output"
  assert_file_exists "$MARKER" "marker file created"
  teardown
}

test_array_detect_or_logic() {
  echo "test: detect array uses OR logic"
  setup
  add_recommendation "test-plugin" '{
    "plugin": "test-plugin",
    "detect": [
      { "file": "Gemfile", "pattern": "rails" },
      { "file": "pubspec.yaml", "pattern": "." }
    ],
    "marketplace": "Org/repo",
    "description": "Array detect plugin."
  }'
  add_project_file "pubspec.yaml" "name: my_app"
  local output
  output=$(run_hook)
  assert_contains "$output" "test-plugin" "matched via second array entry"
  assert_file_exists "$MARKER" "marker file created"
  teardown
}

test_marker_suppresses_second_run() {
  echo "test: marker file suppresses recommendations on second run"
  setup
  add_recommendation "test-plugin" '{
    "plugin": "test-plugin",
    "detect": { "file": "pubspec.yaml", "pattern": "." },
    "marketplace": "Org/repo",
    "description": "Test plugin."
  }'
  add_project_file "pubspec.yaml" "name: my_app"
  run_hook > /dev/null
  assert_file_exists "$MARKER" "marker created on first run"
  local output
  output=$(run_hook)
  assert_empty "$output" "no output on second run"
  teardown
}

test_multiple_recommendations_single_message() {
  echo "test: multiple matching plugins emitted in a single message"
  setup
  add_recommendation "plugin-a" '{
    "plugin": "plugin-a",
    "detect": { "file": "pubspec.yaml", "pattern": "." },
    "marketplace": "Org/repo-a",
    "description": "Plugin A."
  }'
  add_recommendation "plugin-b" '{
    "plugin": "plugin-b",
    "detect": { "file": "package.json", "pattern": "." },
    "marketplace": "Org/repo-b",
    "description": "Plugin B."
  }'
  add_project_file "pubspec.yaml" "name: my_app"
  add_project_file "package.json" '{"name": "my-app"}'
  local output
  output=$(run_hook)
  assert_contains "$output" "plugin-a" "first plugin in output"
  assert_contains "$output" "plugin-b" "second plugin in output"
  assert_json_field_equals "$output" '.hookSpecificOutput.hookEventName' "UserPromptSubmit" "hook event name preserved"
  teardown
}

test_output_is_valid_hook_json() {
  echo "test: output is valid Codex hook JSON"
  setup
  add_recommendation "test-plugin" '{
    "plugin": "test-plugin",
    "detect": { "file": "pubspec.yaml", "pattern": "." },
    "marketplace": "Org/repo",
    "description": "Test plugin."
  }'
  add_project_file "pubspec.yaml" "name: my_app"
  local output
  output=$(run_hook_with_event "CustomEvent")
  if echo "$output" | jq . > /dev/null 2>&1; then
    PASS=$((PASS + 1))
    echo "  PASS: output is valid JSON"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: output is not valid JSON"
    echo "    got: $output"
  fi
  assert_json_field_equals "$output" '.hookSpecificOutput.hookEventName' "CustomEvent" "custom hook event name preserved"
  assert_contains "$output" "additionalContext" "additionalContext emitted"
  teardown
}

test_detection_is_case_insensitive() {
  echo "test: detection is case-insensitive"
  setup
  add_recommendation "test-plugin" '{
    "plugin": "test-plugin",
    "detect": { "file": "pubspec.yaml", "pattern": "Flutter" },
    "marketplace": "Org/repo",
    "description": "Test plugin."
  }'
  add_project_file "pubspec.yaml" "dependencies:
  flutter:
    sdk: flutter"
  local output
  output=$(run_hook)
  assert_contains "$output" "test-plugin" "case-insensitive match"
  assert_file_exists "$MARKER" "marker file created"
  teardown
}

# ---------------------------------------------------------------------------
# Run all tests
# ---------------------------------------------------------------------------

echo "=== recommend-plugins-codex.sh tests ==="
echo ""

test_no_recommendations_dir
echo ""
test_no_recommendation_files
echo ""
test_file_detection_matches_using_cwd
echo ""
test_file_detection_no_match_pattern
echo ""
test_files_glob_detection_matches
echo ""
test_array_detect_or_logic
echo ""
test_marker_suppresses_second_run
echo ""
test_multiple_recommendations_single_message
echo ""
test_output_is_valid_hook_json
echo ""
test_detection_is_case_insensitive
echo ""

echo "=== Results: $PASS passed, $FAIL failed ==="
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
