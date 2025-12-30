// Quip typing animation demo - relatable examples people actually type
const demos = [
    { trigger: "followup", expansion: "Just following up on my last message. Let me know if you have any questions!" },
    { trigger: "lgtm", expansion: "Looks good to me! Approved." },
    { trigger: "fix", expansion: "Fix this code and explain what was wrong" },
    { trigger: "avail", expansion: "I'm available anytime this week. What works for you?" },
    { trigger: "shorter", expansion: "Make this shorter and more direct" },
    { trigger: "thanks", expansion: "Thanks for sending this over! I'll review and get back to you." },
    { trigger: "sync", expansion: "Can we sync on this? I have a few questions." },
    { trigger: "ooo", expansion: "I'm out of office until Monday. I'll respond when I'm back." }
];

const demoText = document.getElementById('demo-text');
let currentDemo = 0;

// Timing configuration (in ms)
const CHAR_TYPE_DELAY = 80;        // Delay between typing each character
const CHAR_DELETE_DELAY = 30;      // Delay between deleting each character
const EXPANSION_TYPE_DELAY = 25;   // Faster typing for expansion
const PAUSE_BEFORE_DELETE = 2500;  // Pause to show expansion
const PAUSE_BEFORE_NEXT = 500;     // Pause before next demo
const PAUSE_AFTER_TRIGGER = 200;   // Brief pause after typing trigger

// Utility function for delays
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Add slight randomness to typing for natural feel
const jitter = (base) => base + Math.random() * 40 - 20;

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

// Delete characters from the display
async function deleteChars(count) {
    for (let i = 0; i < count; i++) {
        const currentText = demoText.innerHTML;
        // Handle both plain text and span-wrapped characters
        if (currentText.includes('</span>')) {
            // Remove last span
            const lastSpanIndex = currentText.lastIndexOf('<span');
            demoText.innerHTML = currentText.substring(0, lastSpanIndex);
        } else {
            demoText.textContent = demoText.textContent.slice(0, -1);
        }
        await sleep(CHAR_DELETE_DELAY);
    }
}

// Clear all text
function clearText() {
    demoText.innerHTML = '';
}

// Run a single demo cycle
async function runDemo(demo) {
    // Clear any existing text
    clearText();

    // Type the trigger: ;trigger
    await typeText(';' + demo.trigger, 'trigger-text');

    // Brief pause
    await sleep(PAUSE_AFTER_TRIGGER);

    // Type space (this triggers the expansion)
    await typeText(' ', 'trigger-text');

    // Quick delete of trigger (simulating the expansion)
    await sleep(100);
    const triggerLength = demo.trigger.length + 2; // +2 for ; and space
    await deleteChars(triggerLength);

    // Type the expansion with a success color
    await typeText(demo.expansion, 'expansion-text', EXPANSION_TYPE_DELAY);

    // Pause to let user read the expansion
    await sleep(PAUSE_BEFORE_DELETE);

    // Clear for next demo
    clearText();
    await sleep(PAUSE_BEFORE_NEXT);
}

// Main animation loop
async function startAnimation() {
    while (true) {
        await runDemo(demos[currentDemo]);
        currentDemo = (currentDemo + 1) % demos.length;
    }
}

// Start animation when page loads
document.addEventListener('DOMContentLoaded', () => {
    // Small delay before starting
    setTimeout(startAnimation, 500);
});
