const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");

const {
  findFilesByExtension,
  internalCoverageTargetNames,
  mergeCoverage,
  readBundleInsights,
  readDashboardURL,
  renderBundleInsights,
} =
  require("./ios-test-report.js").__test__;

test("xccov package 디렉터리를 coverage 병합 입력으로 찾는다", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "xccov-packages-"));
  const archive = path.join(directory, "0.xccovarchive");
  const report = path.join(directory, "0.xccovreport");
  fs.mkdirSync(archive);
  fs.writeFileSync(report, "report");

  assert.deepEqual(findFilesByExtension(directory, ".xccovarchive"), [archive]);
  assert.deepEqual(findFilesByExtension(directory, ".xccovreport"), [report]);
});

test("Xcode 26 coverage export 이름을 coverage 병합 입력으로 찾는다", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "xcode-26-coverage-"));
  const archive = path.join(directory, "0_Test_iPhone 17 Pro_CoverageArchive");
  const report = path.join(directory, "0_Test_iPhone 17 Pro_CoverageReport");
  fs.mkdirSync(archive);
  fs.writeFileSync(report, "report");

  assert.deepEqual(findFilesByExtension(directory, ".xccovarchive"), [archive]);
  assert.deepEqual(findFilesByExtension(directory, ".xccovreport"), [report]);
});

test("프로젝트 매니페스트에서 자사 커버리지 대상을 구성한다", () => {
  const targets = internalCoverageTargetNames();

  assert.equal(targets.has("DDDAttendance"), true);
  assert.equal(targets.has("APIEndpoint"), true);
  assert.equal(targets.has("DDDNetworkInterface"), true);
  assert.equal(targets.has("Alamofire"), false);
  assert.equal(targets.has("SwiftUIX"), false);
});

test("커버리지 리포트는 내부 모듈만 집계한다", () => {
  const allowedTargets = new Set(["API", "DDDNetwork", "DDDNetworkInterface"]);
  const coverage = mergeCoverage(
    [
      [
        { name: "API.framework", coveredLines: 10, executableLines: 100 },
        { name: "DDDNetwork", coveredLines: 20, executableLines: 200 },
        { name: "DDDNetworkInterface", coveredLines: 5, executableLines: 50 },
        { name: "Alamofire", coveredLines: 500, executableLines: 10_000 },
        { name: "SwiftUIX", coveredLines: 1_000, executableLines: 30_000 },
        { name: "APITests.xctest", coveredLines: 10, executableLines: 10 },
      ],
    ],
    allowedTargets,
  );

  assert.deepEqual(
    coverage.targets.map((target) => target.name).sort(),
    ["API", "DDDNetwork", "DDDNetworkInterface"],
  );
  assert.equal(coverage.coveredLines, 35);
  assert.equal(coverage.executableLines, 350);
});

test("Tuist run report에서 테스트와 빌드 dashboard URL을 찾는다", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "tuist-run-report-"));
  const reportPath = path.join(directory, "run-report.json");
  fs.writeFileSync(
    reportPath,
    JSON.stringify({
      test: { url: "https://tuist.dev/DDD2026/attendance/tests/test-runs/test-id" },
      build: { nested: ["https://tuist.dev/DDD2026/attendance/builds/build-runs/build-id"] },
    }),
  );

  assert.equal(
    readDashboardURL(reportPath, "/tests/test-runs/"),
    "https://tuist.dev/DDD2026/attendance/tests/test-runs/test-id",
  );
  assert.equal(
    readDashboardURL(reportPath, "/builds/build-runs/"),
    "https://tuist.dev/DDD2026/attendance/builds/build-runs/build-id",
  );
});

test("shard별 Tuist run report 디렉터리에서도 dashboard URL을 찾는다", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "tuist-shard-reports-"));
  fs.mkdirSync(path.join(directory, "shard-0"));
  fs.mkdirSync(path.join(directory, "shard-1"));
  fs.writeFileSync(
    path.join(directory, "shard-0", "TestRunReport-0.json"),
    JSON.stringify({ message: "첫 shard" }),
  );
  fs.writeFileSync(
    path.join(directory, "shard-1", "TestRunReport-1.json"),
    JSON.stringify({ url: "https://tuist.dev/DDD2026/attendance/tests/test-runs/shard-id" }),
  );

  assert.equal(
    readDashboardURL(directory, "/tests/test-runs/"),
    "https://tuist.dev/DDD2026/attendance/tests/test-runs/shard-id",
  );
});

test("Tuist IPA bundle JSON에서 install/download size를 읽는다", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "tuist-bundle-report-"));
  const reportPath = path.join(directory, "bundle-report.json");
  fs.writeFileSync(
    reportPath,
    JSON.stringify({
      name: "DDD 출석",
      bundleId: "io.DDD.Attendance",
      type: "ipa",
      installSize: 120_600_000,
      downloadSize: 31_276_999,
    }),
  );

  assert.deepEqual(readBundleInsights(reportPath), {
    name: "DDD 출석",
    installSize: 120_600_000,
    downloadSize: 31_276_999,
    installSizeDelta: null,
    downloadSizeDelta: null,
    baselineInstallSize: null,
    baselineDownloadSize: null,
  });
});

test("기준 bundle JSON이 있으면 install/download delta를 계산해 표시한다", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "tuist-bundle-comparison-"));
  const reportPath = path.join(directory, "bundle-report.json");
  fs.writeFileSync(
    reportPath,
    JSON.stringify({
      current: {
        name: "DDD 출석",
        installSize: 120_600_000,
        downloadSize: 31_000_000,
      },
      baseline: {
        installSize: 104_600_000,
        downloadSize: 30_000_000,
      },
    }),
  );

  const bundle = readBundleInsights(reportPath);
  assert.equal(bundle.installSizeDelta, 16_000_000);
  assert.equal(bundle.downloadSizeDelta, 1_000_000);
  assert.deepEqual(renderBundleInsights(bundle), [
    "### 📦 Bundle 크기",
    "",
    "| Bundle | Install size | Download size |",
    "| --- | ---: | ---: |",
    "| DDD 출석 | 120.6 MB<br><sub>Δ +16.0 MB (+15.30%)</sub> | 31.0 MB<br><sub>Δ +1.0 MB (+3.33%)</sub> |",
    "",
  ]);
});
