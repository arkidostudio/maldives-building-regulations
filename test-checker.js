const fs = require("fs");
const vm = require("vm");

const source = fs.readFileSync("islands-checker.html", "utf8");
const start = source.indexOf("function calcCityHeight");
const end = source.indexOf("function render()", start);
const context = { SQFT_TO_SQM: 0.092903 };
vm.runInNewContext(source.slice(start, end), context);

function equal(actual, expected, message) {
  if (actual !== expected) throw new Error(`${message}: expected ${expected}, got ${actual}`);
}

function near(actual, expected, message) {
  if (Math.abs(actual - expected) > 0.000001) throw new Error(`${message}: expected ${expected}, got ${actual}`);
}

near(context.calcCityHeight(1250, 4.5, 3).max, 17.214030612245, "Legacy height-calculator scenario");
equal(context.calcCityHeight(700, 10, 1.524).max, 19.2, "1.524 m starts the next road band");
equal(context.calcCityHeight(700, 10, 1.829).max, 25.2, "1.829 m starts the next road band");
equal(context.calcCityHeight(700, 10, 3.048).caps.at(-1).h, 30.48, "3.048 m starts the next road band");
equal(context.calcNonCityHeight(1500, 3, 3).max, 18.5, "Article 8 provisional fallback");
equal(context.calcNonCityHeight(1500, 3, 3).provisional, true, "Article 8 fallback must be labelled provisional");
equal(context.calcNonCityHeight(1500, 3, 4.572).max, 24.5, "Article 8(e) boundary");
equal(context.calcNonCityHeight(2000, 3, 6.096).max, 30.48, "Article 8(f) boundary");

const resultGroups = new Set(source.match(/const R = \{([^}]+)\}/)[1].match(/\w+(?=\s*:)/g));
for (const [, group] of source.matchAll(/R\.(\w+)/g)) {
  if (!resultGroups.has(group)) throw new Error(`Unknown result group: R.${group}`);
}

console.log("Checker boundary tests passed");
