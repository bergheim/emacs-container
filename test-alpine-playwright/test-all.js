const { execSync } = require('child_process');
const { chromium } = require('playwright');

const executablePath = process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH || '/usr/bin/chromium-browser';

async function testPlaywright() {
  console.log('\n=== Test 1: Playwright Direct ===');

  const browser = await chromium.launch({
    executablePath,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage', '--disable-gpu']
  });

  const page = await browser.newPage();
  await page.goto('https://example.com');
  const title = await page.title();
  console.log(`  Page title: "${title}"`);

  await page.screenshot({ path: '/tmp/playwright-screenshot.png' });
  console.log('  ✓ Screenshot saved');

  // Test console capture
  const logs = [];
  page.on('console', msg => logs.push(msg.text()));
  await page.evaluate(() => console.log('test message'));
  await page.waitForTimeout(100);
  console.log(`  ✓ Console capture: ${logs.length} message(s)`);

  await browser.close();
  console.log('  ✓ Playwright works!');
}

async function testAgentBrowser() {
  console.log('\n=== Test 2: agent-browser ===');

  try {
    // agent-browser uses PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH env var
    const result = execSync(
      'npx agent-browser navigate "https://example.com" --describe',
      {
        encoding: 'utf-8',
        timeout: 60000,
        env: {
          ...process.env,
          PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH: executablePath
        }
      }
    );
    console.log(`  Description: ${result.trim().substring(0, 300)}`);
    console.log('  ✓ agent-browser works!');
  } catch (err) {
    console.log(`  ✗ agent-browser failed: ${err.message}`);
    if (err.stdout) console.log(`  stdout: ${err.stdout}`);
    if (err.stderr) console.log(`  stderr: ${err.stderr}`);
    throw err;
  }
}

async function main() {
  console.log('=== Alpine + System Chromium - Browser Tools Test ===');
  console.log(`Using Chromium at: ${executablePath}`);
  console.log('Note: webctl skipped (Python playwright has no musl wheels)');

  let playwrightOk = false;
  let agentBrowserOk = false;

  // Test 1: Playwright
  try {
    await testPlaywright();
    playwrightOk = true;
  } catch (err) {
    console.log(`  ✗ Playwright FAILED: ${err.message}`);
  }

  // Test 2: agent-browser
  try {
    await testAgentBrowser();
    agentBrowserOk = true;
  } catch (err) {
    // already logged
  }

  console.log('\n=== SUMMARY ===');
  console.log('Playwright (Node.js): ' + (playwrightOk ? '✓' : '✗'));
  console.log('agent-browser:        ' + (agentBrowserOk ? '✓' : '✗ (ships glibc binary)'));
  console.log('webctl:               SKIPPED (needs glibc)');

  if (playwrightOk) {
    console.log('\nPlaywright API works on Alpine!');
    console.log('Can do: screenshots, PDFs, console capture, error detection');
  }

  if (!playwrightOk) {
    process.exit(1);
  }
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
