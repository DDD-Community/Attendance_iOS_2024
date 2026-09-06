/**
 * PR 테스트 결과(xcresult)를 읽어 마크다운 리포트를 만들고 PR 에 코멘트로 남긴다.
 * actions/github-script 스텝에서 require 해서 호출한다.
 *
 * 환경변수
 *   RESULT_BUNDLE_DIR — xcodebuild -resultBundlePath 에 넘긴 경로
 *   TEST_OUTCOME      — 테스트 스텝의 outcome (success | failure | cancelled)
 */

const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");

// 새 코멘트를 달지 않고 이 마커로 기존 리포트를 찾아 갱신한다
const MARKER = "<!-- pr-test-report -->";

// GitHub 코멘트 본문 상한(65,536자)에 걸리지 않도록 자른다
const MAX_FAILURES = 40;
const MAX_FAILURE_TEXT = 600;
const MAX_BUILD_ERRORS = 20;

// 커버리지 막대 칸 수 (한 칸 = 5%)
const BAR_WIDTH = 20;

function findProjectManifests(root) {
  if (!fs.existsSync(root)) return [];

  const manifests = [];
  const walk = (directory) => {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;

      const child = path.join(directory, entry.name);

      const manifest = path.join(child, "Project.swift");
      if (fs.existsSync(manifest)) manifests.push(manifest);
      else walk(child);
    }
  };

  walk(root);
  return manifests;
}

// xccov는 테스트 스킴에 링크된 외부 패키지까지 반환한다.
// Projects 아래 Tuist 모듈 이름을 기준으로 앱이 소유한 제품만 커버리지에 포함한다.
function internalCoverageTargetNames(projectsRoot = path.join(process.cwd(), "Projects")) {
  const names = new Set([process.env.COVERAGE_APP_TARGET || "DDDAttendance"]);

  for (const manifest of findProjectManifests(projectsRoot)) {
    const source = fs.readFileSync(manifest, "utf8");
    const moduleName = /Project\.makeModule\s*\([\s\S]*?\bname:\s*"([^"]+)"/.exec(source)?.[1];
    if (!moduleName) continue;

    names.add(moduleName);
    names.add(`${moduleName}Interface`);
  }

  return names;
}

function xcrun(args) {
  return execFileSync("xcrun", args, {
    encoding: "utf8",
    maxBuffer: 256 * 1024 * 1024,
    stdio: ["ignore", "pipe", "pipe"],
  });
}

function findResultBundles(root) {
  if (!root || !fs.existsSync(root)) return [];

  // 과거 tuist test는 <path>.xcresult를 만들고 <path> 심볼릭 링크를 걸었다.
  // 이전 실행 결과도 읽을 수 있도록 실제 경로를 해석한다.
  root = fs.realpathSync(root);

  const found = [];
  const walk = (dir, depth) => {
    if (depth > 3) return;
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      const child = path.join(dir, entry.name);
      if (entry.name.endsWith(".xcresult")) found.push(child);
      else walk(child, depth + 1);
    }
  };

  if (root.endsWith(".xcresult")) return [root];
  walk(root, 0);
  // 번들이 확장자 없이 지정 경로 그대로 만들어진 경우
  return found.length > 0 ? found : [root];
}

function readSummary(bundle) {
  try {
    return JSON.parse(
      xcrun(["xcresulttool", "get", "test-results", "summary", "--path", bundle, "--format", "json"]),
    );
  } catch {
    return null;
  }
}

function readCoverage(bundle) {
  try {
    return JSON.parse(xcrun(["xccov", "view", "--report", "--json", "--only-targets", bundle]));
  } catch {
    // 커버리지 미수집 번들이면 xccov 가 에러를 낸다
    return [];
  }
}

function findFilesByExtension(root, extension) {
  if (!fs.existsSync(root)) return [];
  const xcodeCoverageSuffix = {
    ".xccovarchive": "_CoverageArchive",
    ".xccovreport": "_CoverageReport",
  }[extension];
  const matches = (candidate) =>
    candidate.endsWith(extension) || (xcodeCoverageSuffix && candidate.endsWith(xcodeCoverageSuffix));

  if (matches(root)) return [root];
  if (!fs.statSync(root).isDirectory()) return [];

  return fs.readdirSync(root, { withFileTypes: true }).flatMap((entry) => {
    const child = path.join(root, entry.name);
    return entry.isDirectory() ? findFilesByExtension(child, extension) : matches(child) ? [child] : [];
  });
}

function readMergedCoverage(bundles) {
  if (bundles.length < 2) return bundles.flatMap(readCoverage);

  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "pr-shard-coverage-"));
  try {
    const coveragePairs = [];
    for (const [index, bundle] of bundles.entries()) {
      try {
        const output = path.join(directory, `shard-${index}`);
        execFileSync("xcrun", [
          "xcresulttool",
          "export",
          "coverage",
          "--path",
          bundle,
          "--output-path",
          output,
        ]);
        const report = findFilesByExtension(output, ".xccovreport")[0];
        const archive = findFilesByExtension(output, ".xccovarchive")[0];
        if (report && archive) coveragePairs.push({ report, archive });
      } catch {
        // build-only xcresult처럼 coverage가 없는 결과 번들은 병합 대상에서 제외한다.
      }
    }

    if (coveragePairs.length === 0) return [];
    if (coveragePairs.length === 1) {
      return JSON.parse(
        xcrun(["xccov", "view", "--json", "--only-targets", coveragePairs[0].report]),
      );
    }

    const mergedReport = path.join(directory, "merged.xccovreport");
    const mergedArchive = path.join(directory, "merged.xccovarchive");
    execFileSync("xcrun", [
      "xccov",
      "merge",
      "--outReport",
      mergedReport,
      "--outArchive",
      mergedArchive,
      ...coveragePairs.flatMap(({ report, archive }) => [report, archive]),
    ]);
    return JSON.parse(
      xcrun(["xccov", "view", "--json", "--only-targets", mergedReport]),
    );
  } catch (error) {
    console.warn(`shard coverage를 병합하지 못했습니다: ${error.message}`);
    return [];
  } finally {
    fs.rmSync(directory, { recursive: true, force: true });
  }
}

function readDashboardURL(reportPath, pathSegment) {
  if (!reportPath || !fs.existsSync(reportPath)) return null;

  const reportPaths = [];
  const collectReports = (candidate) => {
    if (!fs.statSync(candidate).isDirectory()) {
      if (candidate.endsWith(".json")) reportPaths.push(candidate);
      return;
    }
    for (const entry of fs.readdirSync(candidate, { withFileTypes: true })) {
      collectReports(path.join(candidate, entry.name));
    }
  };
  collectReports(reportPath);
  reportPaths.sort();

  for (const candidate of reportPaths) {
    const dashboardURL = readDashboardURLFromFile(candidate, pathSegment);
    if (dashboardURL) return dashboardURL;
  }
  return null;
}

function readDashboardURLFromFile(reportPath, pathSegment) {
  try {
    const report = JSON.parse(fs.readFileSync(reportPath, "utf8"));
    const urls = [];
    const visit = (value) => {
      if (typeof value === "string") {
        if (value.startsWith("https://")) urls.push(value);
        return;
      }
      if (Array.isArray(value)) {
        value.forEach(visit);
        return;
      }
      if (value && typeof value === "object") Object.values(value).forEach(visit);
    };
    visit(report);
    return urls.find((url) => url.includes(pathSegment)) || null;
  } catch {
    return null;
  }
}

// `tuist inspect bundle --json` 결과를 읽는다. IPA를 검사하면 installSize와
// downloadSize가 모두 바이트 단위로 기록된다. 비교 기준이 함께 기록된
// 리포트도 받을 수 있게 해 PR 리포트에서 크기 변화까지 계산한다.
function readBundleInsights(reportPath) {
  if (!reportPath || !fs.existsSync(reportPath)) return null;

  try {
    const report = JSON.parse(fs.readFileSync(reportPath, "utf8"));
    const current = report.current || report.bundle || report;
    const baseline = report.baseline || report.previous || null;
    if (!Number.isFinite(current?.installSize) && !Number.isFinite(current?.downloadSize)) return null;

    const delta = (key) => {
      const explicit = current[`${key}Delta`] ?? report[`${key}Delta`];
      if (Number.isFinite(explicit)) return explicit;
      if (Number.isFinite(baseline?.[key]) && Number.isFinite(current[key])) {
        return current[key] - baseline[key];
      }
      return null;
    };

    return {
      name: current.name || current.bundleId || "App",
      installSize: Number.isFinite(current.installSize) ? current.installSize : null,
      downloadSize: Number.isFinite(current.downloadSize) ? current.downloadSize : null,
      installSizeDelta: delta("installSize"),
      downloadSizeDelta: delta("downloadSize"),
      baselineInstallSize: Number.isFinite(baseline?.installSize) ? baseline.installSize : null,
      baselineDownloadSize: Number.isFinite(baseline?.downloadSize) ? baseline.downloadSize : null,
    };
  } catch {
    return null;
  }
}

// 빌드가 깨지면 테스트가 0개로 끝나 실패 원인이 안 보인다
function readBuildErrors(bundle) {
  try {
    const results = JSON.parse(
      xcrun(["xcresulttool", "get", "build-results", "--path", bundle, "--format", "json"]),
    );
    return results.errors || [];
  } catch {
    return [];
  }
}

function mergeSummaries(summaries) {
  const merged = {
    passed: 0,
    failed: 0,
    skipped: 0,
    expectedFailures: 0,
    failures: [],
    startTime: Infinity,
    finishTime: 0,
    device: null,
  };

  for (const s of summaries) {
    merged.passed += s.passedTests || 0;
    merged.failed += s.failedTests || 0;
    merged.skipped += s.skippedTests || 0;
    merged.expectedFailures += s.expectedFailures || 0;
    merged.failures.push(...(s.testFailures || []));
    if (s.startTime) merged.startTime = Math.min(merged.startTime, s.startTime);
    if (s.finishTime) merged.finishTime = Math.max(merged.finishTime, s.finishTime);
    merged.device ||= s.devicesAndConfigurations?.[0]?.device || null;
  }

  return merged;
}

function mergeCoverage(reports, allowedTargets = internalCoverageTargetNames()) {
  const byName = new Map();

  for (const target of reports.flat()) {
    if (!target?.name || target.name.endsWith(".xctest")) continue;
    if (!target.executableLines) continue;

    const name = target.name.replace(/\.(framework|app|bundle|a|dylib)$/, "");
    if (!allowedTargets.has(name)) continue;

    const acc = byName.get(name) || { name, coveredLines: 0, executableLines: 0 };
    acc.coveredLines += target.coveredLines || 0;
    acc.executableLines += target.executableLines;
    byName.set(name, acc);
  }

  const targets = [...byName.values()].sort(
    (a, b) => a.coveredLines / a.executableLines - b.coveredLines / b.executableLines,
  );
  const coveredLines = targets.reduce((sum, t) => sum + t.coveredLines, 0);
  const executableLines = targets.reduce((sum, t) => sum + t.executableLines, 0);

  return { targets, coveredLines, executableLines };
}

const percent = (covered, total) => (total > 0 ? `${((covered / total) * 100).toFixed(1)}%` : "—");
const comma = (n) => n.toLocaleString("en-US");

function formatDuration(seconds) {
  if (!Number.isFinite(seconds) || seconds <= 0) return null;
  const total = Math.round(seconds);
  const min = Math.floor(total / 60);
  return min > 0 ? `${min}m ${total % 60}s` : `${total}s`;
}

function renderFailures(failures) {
  const shown = failures.slice(0, MAX_FAILURES);

  const byTarget = new Map();
  for (const failure of shown) {
    const target = failure.targetName || "Unknown";
    if (!byTarget.has(target)) byTarget.set(target, []);
    byTarget.get(target).push(failure);
  }

  const lines = [`### ❌ 실패한 테스트 ${failures.length}개`, ""];

  for (const [target, items] of byTarget) {
    lines.push("<details open>", `<summary><code>${target}</code> · ${items.length}개</summary>`, "");

    for (const failure of items) {
      const id = failure.testIdentifierString || failure.testName || "(이름 없음)";
      lines.push(`**\`${id}\`**`);

      // testName 은 @Test("...") 로 붙인 표시 이름 — 식별자와 다를 때만 같이 보여준다
      if (failure.testName && !id.includes(failure.testName)) lines.push(failure.testName);

      const text = (failure.failureText || "").replace(/```/g, "'''").trim();
      if (text) {
        const clipped =
          text.length > MAX_FAILURE_TEXT ? `${text.slice(0, MAX_FAILURE_TEXT)}\n… (생략)` : text;
        lines.push("```text", clipped, "```");
      }
      lines.push("");
    }

    lines.push("</details>", "");
  }

  if (failures.length > shown.length) {
    lines.push(`> 이하 ${failures.length - shown.length}개는 생략했습니다. 전체는 워크플로 로그를 확인하세요.`, "");
  }

  return lines;
}

// file:///...#StartingLineNumber=32 → "Projects/.../File.swift:32"
function errorLocation(sourceURL) {
  if (!sourceURL) return null;

  const [filePart, fragment = ""] = sourceURL.split("#");
  const file = decodeURIComponent(filePart.replace(/^file:\/\//, ""));
  const relative = path.relative(process.cwd(), file);
  const line = /StartingLineNumber=(\d+)/.exec(fragment)?.[1];

  return line ? `${relative}:${line}` : relative;
}

function renderBuildErrors(errors) {
  // 위치 있는 에러가 있으면 "Testing cancelled because the build failed." 같은
  // 위치 없는 래퍼 에러는 노이즈라 걸러낸다
  const located = errors.filter((e) => e.sourceURL);
  const shown = (located.length > 0 ? located : errors).slice(0, MAX_BUILD_ERRORS);

  const lines = [`### 🔨 빌드 에러 ${shown.length}개`, ""];

  for (const error of shown) {
    const location = errorLocation(error.sourceURL);
    lines.push(location ? `**\`${location}\`**` : `**${error.issueType || "Error"}**`);

    const message = (error.message || "").replace(/```/g, "'''").trim();
    if (message) lines.push("```text", message, "```");
    lines.push("");
  }

  return lines;
}

function grade(covered, total) {
  if (total <= 0) return "";
  const ratio = covered / total;
  return ratio >= 0.6 ? "🟢" : ratio >= 0.3 ? "🟡" : "🔴";
}

// 백틱으로 감싸 모노스페이스로 렌더해야 칸 너비가 어긋나지 않는다
function bar(covered, total) {
  if (total <= 0) return "";

  let filled = Math.round((covered / total) * BAR_WIDTH);
  // 반올림 때문에 0% / 100% 가 아닌데 텅 비거나 꽉 차 보이는 것을 막는다
  if (covered > 0) filled = Math.max(filled, 1);
  if (covered < total) filled = Math.min(filled, BAR_WIDTH - 1);

  return `\`${"█".repeat(filled)}${"░".repeat(BAR_WIDTH - filled)}\``;
}

function renderCoverage(coverage) {
  if (coverage.targets.length === 0) {
    return ["### 📊 커버리지", "", "> 커버리지 데이터가 없습니다.", ""];
  }

  const lines = [
    `### 📊 커버리지 ${percent(coverage.coveredLines, coverage.executableLines)} ` +
      `(${comma(coverage.coveredLines)} / ${comma(coverage.executableLines)} 라인)`,
    "",
    `${grade(coverage.coveredLines, coverage.executableLines)} ${bar(coverage.coveredLines, coverage.executableLines)}`,
    "",
    "<details><summary>모듈별 커버리지</summary>",
    "",
    "| 모듈 | 커버리지 | | 라인 |",
    "| --- | --- | ---: | ---: |",
  ];

  for (const t of coverage.targets) {
    lines.push(
      `| ${grade(t.coveredLines, t.executableLines)} ${t.name} | ${bar(t.coveredLines, t.executableLines)} | ${percent(t.coveredLines, t.executableLines)} | ${comma(t.coveredLines)} / ${comma(t.executableLines)} |`,
    );
  }

  lines.push("", "</details>", "");
  return lines;
}

function formatBytes(bytes) {
  if (!Number.isFinite(bytes)) return "—";

  const units = ["B", "KB", "MB", "GB"];
  let value = Math.abs(bytes);
  let unit = 0;
  while (value >= 1000 && unit < units.length - 1) {
    value /= 1000;
    unit += 1;
  }

  const sign = bytes < 0 ? "-" : "";
  const digits = unit === 0 ? 0 : 1;
  return `${sign}${value.toFixed(digits)} ${units[unit]}`;
}

function formatBundleSize(size, delta, baseline) {
  if (!Number.isFinite(size)) return "—";

  const lines = [formatBytes(size)];
  if (Number.isFinite(delta)) {
    const sign = delta > 0 ? "+" : "";
    const percentage = Number.isFinite(baseline) && baseline > 0 ? ` (${sign}${((delta / baseline) * 100).toFixed(2)}%)` : "";
    lines.push(`<sub>Δ ${sign}${formatBytes(delta)}${percentage}</sub>`);
  }
  return lines.join("<br>");
}

function renderBundleInsights(bundle) {
  if (!bundle) return [];

  return [
    "### 📦 Bundle 크기",
    "",
    "| Bundle | Install size | Download size |",
    "| --- | ---: | ---: |",
    `| ${bundle.name} | ${formatBundleSize(bundle.installSize, bundle.installSizeDelta, bundle.baselineInstallSize)} | ${formatBundleSize(bundle.downloadSize, bundle.downloadSizeDelta, bundle.baselineDownloadSize)} |`,
    "",
  ];
}

function renderReport({ summary, coverage, buildErrors, bundleInsights, outcome, runUrl, sha, testRunUrl, buildRunUrl }) {
  const lines = [MARKER, ""];
  const footer = [`\`${sha.slice(0, 7)}\``, `[워크플로 로그](${runUrl})`].join(" · ");

  if (!summary) {
    lines.push(
      "## ⚠️ 테스트 결과를 읽지 못했습니다",
      "",
      `테스트 스텝 결과: \`${outcome}\`. 결과 번들이 만들어지지 않았습니다.`,
      "",
      footer,
    );
    return lines.join("\n");
  }

  const total = summary.passed + summary.failed + summary.skipped;

  if (total === 0 && buildErrors.length > 0) {
    lines.push("## 🔨 빌드 실패", "", "컴파일 에러로 테스트를 실행하지 못했습니다.", "", footer, "");
    lines.push(...renderBuildErrors(buildErrors));
    return lines.join("\n");
  }

  const passing = summary.failed === 0 && outcome === "success";

  lines.push(passing ? "## ✅ 테스트 통과" : "## ❌ 테스트 실패", "");

  const counts = [`**${comma(summary.passed)} passed**`];
  if (summary.failed > 0) counts.push(`**${comma(summary.failed)} failed**`);
  if (summary.skipped > 0) counts.push(`${comma(summary.skipped)} skipped`);
  if (summary.expectedFailures > 0) counts.push(`${comma(summary.expectedFailures)} expected failures`);

  const duration = formatDuration(summary.finishTime - summary.startTime);
  if (duration) counts.push(duration);
  lines.push(`${counts.join(" · ")} · 총 ${comma(total)}개`, "");

  const meta = [];
  if (summary.device) {
    meta.push(`${summary.device.modelName} (${summary.device.platform} ${summary.device.osVersion})`);
  }
  if (testRunUrl) meta.push(`[Tuist 테스트 실행](${testRunUrl})`);
  if (buildRunUrl) meta.push(`[Tuist 빌드 실행](${buildRunUrl})`);
  meta.push(footer);
  lines.push(meta.join(" · "), "");

  if (summary.failures.length > 0) lines.push(...renderFailures(summary.failures));
  lines.push(...renderBundleInsights(bundleInsights));
  lines.push(...renderCoverage(coverage));

  return lines.join("\n");
}

module.exports = async ({ github, context, core }) => {
  const bundles = findResultBundles(process.env.RESULT_BUNDLE_DIR);
  const summaries = bundles.map(readSummary).filter(Boolean);
  const coverage = mergeCoverage([readMergedCoverage(bundles)]);
  const buildErrors = bundles.flatMap(readBuildErrors);
  const testRunUrl = readDashboardURL(process.env.TEST_RUN_REPORT_PATH, "/tests/test-runs/");
  const buildRunUrl = readDashboardURL(process.env.BUILD_RUN_REPORT_PATH, "/builds/build-runs/");
  const bundleInsights = readBundleInsights(process.env.BUNDLE_INSPECT_REPORT_PATH);

  const body = renderReport({
    summary: summaries.length > 0 ? mergeSummaries(summaries) : null,
    coverage,
    buildErrors,
    bundleInsights,
    outcome: process.env.TEST_OUTCOME || "unknown",
    runUrl: `${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`,
    sha: context.payload.pull_request.head.sha,
    testRunUrl,
    buildRunUrl,
  });

  const target = {
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: context.payload.pull_request.number,
  };

  const comments = await github.paginate(github.rest.issues.listComments, { ...target, per_page: 100 });
  const existing = comments.find((c) => c.body?.includes(MARKER));

  if (existing) {
    await github.rest.issues.updateComment({ ...target, comment_id: existing.id, body });
  } else {
    await github.rest.issues.createComment({ ...target, body });
  }

  await core.summary.addRaw(body.replace(MARKER, "")).write();
};

module.exports.__test__ = {
  findFilesByExtension,
  internalCoverageTargetNames,
  mergeCoverage,
  readMergedCoverage,
  readBundleInsights,
  readDashboardURL,
  renderBundleInsights,
};
