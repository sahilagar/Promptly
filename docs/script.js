// Quip typing animation

const demoText = document.getElementById('demo-text');

// Timing configuration
const CHAR_TYPE_DELAY = 80;
const CHAR_DELETE_DELAY = 40;
const EXPANSION_TYPE_DELAY = 20;
const PAUSE_BEFORE_DELETE = 2000;
const PAUSE_BEFORE_NEXT = 400;
const PAUSE_AFTER_TRIGGER = 150;

// Utility functions
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));
const jitter = (base) => base + Math.random() * 30 - 15;

// Type text character by character
async function typeText(text, className = '', delay = CHAR_TYPE_DELAY) {
    for (let i = 0; i < text.length; i++) {
        const char = text[i];
        if (className) {
            demoText.innerHTML += `<span class="${className}">${char}</span>`;
        } else {
            demoText.textContent += char;
        }
        await sleep(jitter(delay));
    }
}

// Delete all characters
async function deleteAll(delay = CHAR_DELETE_DELAY) {
    while (demoText.textContent.length > 0 || demoText.innerHTML.includes('</span>')) {
        const currentText = demoText.innerHTML;
        if (currentText.includes('</span>')) {
            const lastSpanIndex = currentText.lastIndexOf('<span');
            demoText.innerHTML = currentText.substring(0, lastSpanIndex);
        } else {
            demoText.textContent = demoText.textContent.slice(0, -1);
        }
        await sleep(delay);
    }
}

// Delete specific number of characters
async function deleteChars(count, delay = CHAR_DELETE_DELAY) {
    for (let i = 0; i < count; i++) {
        const currentText = demoText.innerHTML;
        if (currentText.includes('</span>')) {
            const lastSpanIndex = currentText.lastIndexOf('<span');
            demoText.innerHTML = currentText.substring(0, lastSpanIndex);
        } else if (demoText.textContent.length > 0) {
            demoText.textContent = demoText.textContent.slice(0, -1);
        }
        await sleep(delay);
    }
}

function clearText() {
    demoText.innerHTML = '';
}

// ============ MAIN DEMO ANIMATION ============
const demos = [
    { trigger: "review", expansion: "Walk me through this code step by step." },
    { trigger: "meet", expansion: "Let's chat! Here's my calendar: ", link: "cal.com/you" },
    { trigger: "debug", expansion: "I'm stuck. Here's the error and what I've tried." },
    { trigger: "lgtm", expansion: "Looks good to me! Approved." },
    { trigger: "eli5", expansion: "Explain this simply, no jargon." }
];

let currentDemo = 0;

async function runDemo(demo) {
    clearText();

    // Type the trigger
    await typeText(';' + demo.trigger, 'trigger-text');
    await sleep(PAUSE_AFTER_TRIGGER);

    // Type space
    await typeText(' ', 'trigger-text');
    await sleep(100);

    // Delete trigger
    const triggerLength = demo.trigger.length + 2;
    await deleteChars(triggerLength);

    // Type expansion
    await typeText(demo.expansion, 'expansion-text', EXPANSION_TYPE_DELAY);

    // If there's a link, add it styled
    if (demo.link) {
        demoText.innerHTML += `<span class="link-text">${demo.link}</span>`;
    }

    // Pause to read
    await sleep(PAUSE_BEFORE_DELETE);

    // Clear
    clearText();
    await sleep(PAUSE_BEFORE_NEXT);
}

async function startDemoLoop() {
    while (true) {
        await runDemo(demos[currentDemo]);
        currentDemo = (currentDemo + 1) % demos.length;
    }
}

// ============ START ============
document.addEventListener('DOMContentLoaded', async () => {
    await sleep(500);
    startDemoLoop();
});
