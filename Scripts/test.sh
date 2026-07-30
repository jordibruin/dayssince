#!/bin/bash
#
# Runs the DaysSince test suites against a pinned simulator.
#
#   Scripts/test.sh                 both targets
#   Scripts/test.sh --unit-only     299 unit tests, ~5 seconds
#   Scripts/test.sh --ui-only       54 UI tests, ~8 minutes across 4 simulator clones
#
# Overrides: DEVICE_NAME, OS_VERSION, SIMULATOR_ID, WORKER_COUNT, UI_PARALLEL.

set -euo pipefail

cd "$(dirname "$0")/.."

DEVICE_NAME="${DEVICE_NAME:-iPhone 17 Pro}"
# Deliberately unpinned: CI runners carry whatever runtimes their Xcode ships (26.2/26.4/26.5 at
# time of writing), so a hardcoded version fails there. Unset means "newest installed".
OS_VERSION="${OS_VERSION:-}"

# Parallel testing clones the simulator, taking the UI suite from ~19 to ~8 minutes. Clones are
# separate devices with their own app containers, so the launch-time state reset stays isolated.
# It is applied to the UI target *only*: under a clone the unit target's
# `isSimulatorOrTestFlightUnderTest` fails, because `Bundle.main.appStoreReceiptURL` differs there.
UI_PARALLEL="${UI_PARALLEL:-YES}"
WORKER_COUNT="${WORKER_COUNT:-4}"

TARGETS=(DaysSinceTests DaysSinceUITests)
case "${1:-}" in
    --unit-only) TARGETS=(DaysSinceTests) ;;
    --ui-only) TARGETS=(DaysSinceUITests) ;;
    "") ;;
    *) echo "unknown option: $1" >&2; exit 64 ;;
esac

DEVICE_LIST=$(xcrun simctl list devices available)

# The destination is always an explicit udid: `name` plus `OS=latest` is ambiguous whenever two iOS
# runtimes are installed, and resolves to whichever xcodebuild feels like.
# Every lookup ends in `|| true`, because a non-matching grep under `set -o pipefail` would abort
# the script and swallow the diagnostic below.
udid_for_os() {
    printf '%s\n' "$DEVICE_LIST" \
        | sed -n "/^-- iOS $1 --/,/^-- /p" \
        | grep -m1 "^ *${DEVICE_NAME} (" \
        | grep -oE "[0-9A-Fa-f-]{36}" \
        | head -1 || true
}

if [[ -n "${SIMULATOR_ID:-}" ]]; then
    DESTINATION_LABEL="$SIMULATOR_ID"
elif [[ -n "$OS_VERSION" ]]; then
    SIMULATOR_ID=$(udid_for_os "$OS_VERSION")
    DESTINATION_LABEL="${DEVICE_NAME} / iOS ${OS_VERSION}"
else
    INSTALLED=$(printf '%s\n' "$DEVICE_LIST" | sed -n 's/^-- iOS \(.*\) --$/\1/p' | sort -t. -k1,1nr -k2,2nr)
    for candidate in $INSTALLED; do
        SIMULATOR_ID=$(udid_for_os "$candidate")
        if [[ -n "$SIMULATOR_ID" ]]; then
            OS_VERSION="$candidate"
            break
        fi
    done
    DESTINATION_LABEL="${DEVICE_NAME} / iOS ${OS_VERSION:-none}"
fi

if [[ -z "${SIMULATOR_ID:-}" ]]; then
    echo "No available simulator named '${DEVICE_NAME}'${OS_VERSION:+ on iOS $OS_VERSION}." >&2
    echo "Available:" >&2
    printf '%s\n' "$DEVICE_LIST" >&2
    exit 1
fi

RESULT_DIR="build/TestResults/$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$RESULT_DIR"

run_target() {
    local target="$1" parallel="$2"
    local bundle="${RESULT_DIR}/${target}.xcresult"

    echo "Testing ${target} on ${DESTINATION_LABEL} (${SIMULATOR_ID}), parallel=${parallel}"

    set +e
    xcodebuild test \
        -scheme DaysSince \
        -destination "platform=iOS Simulator,id=${SIMULATOR_ID}" \
        -onlyUsePackageVersionsFromResolvedFile \
        -parallel-testing-enabled "$parallel" \
        -parallel-testing-worker-count "$WORKER_COUNT" \
        -enableCodeCoverage YES \
        -resultBundlePath "$bundle" \
        "-only-testing:${target}" \
        CODE_SIGNING_ALLOWED=NO
    local status=$?
    set -e

    if [[ $status -ne 0 ]]; then
        echo
        echo "=== Failures in ${target} ==="
        # Parallel runs interleave and report as "passed on 'Clone N of ...'", so the readable
        # summary comes from the result bundle rather than from the streamed log.
        xcrun xcresulttool get test-report tests --path "$bundle" 2>/dev/null || true
        echo
        echo "Result bundle: $bundle"
        return $status
    fi

    echo
    echo "=== Coverage: ${target} ==="
    xcrun xccov view --report --only-targets "$bundle" 2>/dev/null || true
}

for target in "${TARGETS[@]}"; do
    if [[ "$target" == "DaysSinceUITests" ]]; then
        run_target "$target" "$UI_PARALLEL"
    else
        run_target "$target" NO
    fi
done
