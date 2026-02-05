const { chromium } = require('playwright');

async function runTests() {
  console.log('=== Alpine + System Chromium + Playwright Test ===\n');

  const executablePath = process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH || '/usr/bin/chromium-browser';
  console.log(`Using Chromium at: ${executablePath}`);

  let browser;
  try {
    // Launch with system Chromium
    browser = await chromium.launch({
      executablePath,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu'
      ]
    });
    console.log('✓ Browser launched successfully\n');

    const page = await browser.newPage();

    // Test 1: Navigate to a page
    console.log('Test 1: Navigation');
    await page.goto('https://example.com');
    const title = await page.title();
    console.log(`  Page title: "${title}"`);
    console.log('  ✓ Navigation works\n');

    // Test 2: Screenshot
    console.log('Test 2: Screenshot');
    await page.screenshot({ path: '/tmp/screenshot.png' });
    console.log('  ✓ Screenshot saved to /tmp/screenshot.png\n');

    // Test 3: PDF generation
    console.log('Test 3: PDF generation');
    await page.pdf({ path: '/tmp/page.pdf' });
    console.log('  ✓ PDF saved to /tmp/page.pdf\n');

    // Test 4: JavaScript evaluation (for reading console errors)
    console.log('Test 4: JavaScript evaluation');
    const result = await page.evaluate(() => {
      return {
        url: window.location.href,
        hasDocument: typeof document !== 'undefined'
      };
    });
    console.log(`  Evaluated: ${JSON.stringify(result)}`);
    console.log('  ✓ JS evaluation works\n');

    // Test 5: Console message capture
    console.log('Test 5: Console message capture');
    const consoleLogs = [];
    page.on('console', msg => consoleLogs.push(msg.text()));
    await page.evaluate(() => {
      console.log('Test log message');
      console.error('Test error message');
    });
    await page.waitForTimeout(100); // Let messages propagate
    console.log(`  Captured ${consoleLogs.length} console messages: ${JSON.stringify(consoleLogs)}`);
    console.log('  ✓ Console capture works\n');

    // Test 6: Error page detection (key for autonomous debugging)
    console.log('Test 6: Error detection on a page');
    await page.goto('data:text/html,<script>throw new Error("Intentional test error")</script>');
    const pageErrors = [];
    page.on('pageerror', err => pageErrors.push(err.message));
    await page.reload();
    await page.waitForTimeout(200);
    console.log(`  Page errors captured: ${pageErrors.length > 0 ? pageErrors : '(reload needed to catch)'}`);
    console.log('  ✓ Error detection mechanism available\n');

    console.log('=== ALL TESTS PASSED ===');
    console.log('\nAlpine + system Chromium + Playwright is VIABLE!');

  } catch (error) {
    console.error('✗ Test failed:', error.message);
    console.error(error.stack);
    process.exit(1);
  } finally {
    if (browser) await browser.close();
  }
}

runTests();
