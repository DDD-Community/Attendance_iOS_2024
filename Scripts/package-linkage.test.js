const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const test = require("node:test");

const packageManifest = readFileSync("Tuist/Package.swift", "utf8");
const projectTemplate = readFileSync(
  "Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Project+Templete/Project+Template.swift",
  "utf8"
);
const projectSettings = readFileSync(
  "Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Setting/Project+Settings.swift",
  "utf8"
);

test("Point-Free Sharing은 Apple private module과 다른 이름으로 한 번만 로드한다", () => {
  assert.match(packageManifest, /"Sharing": \.framework/);
  assert.match(packageManifest, /"Sharing1": \.staticFramework/);
  assert.match(packageManifest, /"Sharing2": \.staticFramework/);
  assert.match(packageManifest, /"SQLiteData": \.framework/);
  assert.match(packageManifest, /"Sharing": \.settings\([\s\S]*?"PRODUCT_NAME": "DDDPointFreeSharing"/);
  assert.match(packageManifest, /-module-alias Sharing=DDDPointFreeSharing/);
  assert.match(projectTemplate, /-module-alias Sharing=DDDPointFreeSharing/);
  assert.match(projectSettings, /-module-alias Sharing=DDDPointFreeSharing/);
});
