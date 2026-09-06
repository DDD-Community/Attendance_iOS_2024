const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");

const repositoryRoot = path.resolve(__dirname, "..");
const actionReference = "uses: ./.github/actions/setup-ios-runner";

function read(relativePath) {
  return fs.readFileSync(path.join(repositoryRoot, relativePath), "utf8");
}

function occurrences(source, fragment) {
  return source.split(fragment).length - 1;
}

function job(source, name, nextName) {
  const start = source.indexOf(`  ${name}:`);
  const end = source.indexOf(`  ${nextName}:`, start + 1);
  assert.notEqual(start, -1, name);
  assert.notEqual(end, -1, nextName);
  return source.slice(start, end);
}

test("iOS workflow는 공통 runner setup action을 사용한다", () => {
  const action = read(".github/actions/setup-ios-runner/action.yml");
  assert.match(action, /using: composite/);
  assert.match(action, /base64 --decode > "\$CONFIG_ARCHIVE"/);
  assert.doesNotMatch(action, /base64 --decode \| tar/);

  const expectedCalls = new Map([
    [".github/workflows/ios-pr-coverage.yml", { setup: 3, checkout: 4 }],
    [".github/workflows/ios-develop-sharded-tests.yml", { setup: 3, checkout: 3 }],
    [".github/workflows/ios-cache-warm.yml", { setup: 1, checkout: 1 }],
    [".github/workflows/ios-deploy.yml", { setup: 1, checkout: 1 }],
  ]);

  for (const [workflow, expectedCount] of expectedCalls) {
    const source = read(workflow);
    assert.equal(occurrences(source, actionReference), expectedCount.setup, workflow);
    assert.equal(occurrences(source, "uses: actions/checkout@v4"), expectedCount.checkout, workflow);
    assert.equal(occurrences(source, "Restore gitignored build config"), 0, workflow);
    assert.equal(occurrences(source, "mise install tuist"), 0, workflow);
  }
});

test("공통화 뒤에도 timeout이 필요한 Tuist service step은 workflow에 남긴다", () => {
  const pr = read(".github/workflows/ios-pr-coverage.yml");
  const develop = read(".github/workflows/ios-develop-sharded-tests.yml");

  assert.equal(occurrences(pr, "timeout-minutes: 3"), 4);
  assert.equal(occurrences(develop, "timeout-minutes: 3"), 3);
});

test("test shard는 build job 산출물을 사용하고 프로젝트를 다시 설치하거나 생성하지 않는다", () => {
  const prShard = job(read(".github/workflows/ios-pr-coverage.yml"), "test-shards", "bundle-insights");
  const developShard = job(read(".github/workflows/ios-develop-sharded-tests.yml"), "test-shards", "warm-module-cache");

  for (const shardJob of [prShard, developShard]) {
    assert.doesNotMatch(shardJob, /Install project dependencies/);
    assert.doesNotMatch(shardJob, /Setup Tuist cache/);
    assert.doesNotMatch(shardJob, /Setup Tuist insights/);
    assert.doesNotMatch(shardJob, /tuist (?:install|generate)/);
  }

  assert.match(prShard, /run-isolated-module-tests\.sh/);
  assert.match(read("Scripts/run-isolated-module-tests.sh"), /--without-building/);
  assert.match(developShard, /--without-building/);
  assert.doesNotMatch(prShard, /Report failed shard build to Tuist/);
});

test("Sharing module alias를 포함한 현재 그래프는 외부 binary cache를 사용한다", () => {
  const pr = read(".github/workflows/ios-pr-coverage.yml");
  const develop = read(".github/workflows/ios-develop-sharded-tests.yml");
  const buildJobs = [
    job(pr, "build-test-shards", "test-shards"),
    job(develop, "build-shards", "test-shards"),
  ];

  for (const workflow of [pr, develop]) {
    const generateCommands = workflow.match(/tuist generate[^\n]+/g) ?? [];
    assert.ok(generateCommands.every((command) => command.includes("--cache-profile none")));
  }

  for (const buildJob of buildJobs) {
    assert.doesNotMatch(buildJob, /tuist generate/);
    assert.match(buildJob, /tuist test[\s\S]*?--build-only/);
    assert.doesNotMatch(buildJob, /--no-binary-cache/);
  }

  assert.doesNotMatch(read("Scripts/run-isolated-module-tests.sh"), /--no-binary-cache/);
  assert.match(read("Tuist.swift"), /profiles:\s*\.profiles\(default:\s*\.onlyExternal\)/);
});

test("단일 self-hosted runner에서는 테스트가 bundle 분석보다 먼저 실행된다", () => {
  const pr = read(".github/workflows/ios-pr-coverage.yml");
  const bundleJob = job(pr, "bundle-insights", "pr-report");

  assert.match(bundleJob, /needs: test-shards/);
  assert.match(bundleJob, /if: always\(\) && needs\.test-shards\.result != 'cancelled'/);
});
