// --- Translations ---
const translations = {
    'pt-BR': {
        'nav-github': 'GitHub',
        'hero-badge': 'v1.x Disponível Agora',
        'hero-title': 'Seu Linux. <br class="hidden sm:block" /> Suas Regras.',
        'hero-desc': 'Transforme uma instalação limpa do Linux em uma workstation completa de desenvolvimento, DevOps e IA. Modular, idempotente e reversível.',
        'btn-copy': 'Copiar Comando',
        'btn-github': 'Ver no GitHub',
        'stat-modules': 'Módulos',
        'stat-profiles': 'Perfis',
        'stat-distros': 'Distros Suportadas',
        'how-title': 'Como Funciona',
        'how-desc': 'O processo para a sua workstation ideal.',
        'how-1-title': 'Detecta',
        'how-1-desc': 'Identifica sua distribuição (Ubuntu, Fedora, Arch, etc) e hardware automaticamente antes de começar.',
        'how-2-title': 'Seleciona',
        'how-2-desc': 'Escolha um perfil pronto ou selecione módulos individualmente via menu interativo no terminal.',
        'how-3-title': 'Instala',
        'how-3-desc': 'Configura repositórios, instala pacotes e aplica configurações de forma modular e idempotente.',
        'profiles-title': 'Perfis Prontos',
        'profiles-desc': 'Escolha um perfil e instale exatamente o que você precisa para o seu workflow. Nada a mais, nada a menos.',
        'feat-1-title': 'Modular & Idempotente',
        'feat-1-desc': 'Escolha exatamente o que quer. Rode várias vezes sem duplicar ou quebrar nada.',
        'feat-2-title': 'Multi-Distro',
        'feat-2-desc': 'Suporte nativo a APT, DNF e Pacman. Ubuntu, Fedora, Pop!_OS, Arch e mais.',
        'feat-3-title': 'Rollback Seguro',
        'feat-3-desc': 'Manifesto de estado embutido. Desinstale módulos revertendo exatamente o que fizeram.',
        'feat-4-title': 'IA & DevOps',
        'feat-4-desc': 'Módulos prontos para Kubernetes, Docker, Ollama, Claude e ecossistema completo.'
    },
    'en': {
        'nav-github': 'GitHub',
        'hero-badge': 'v1.x Available Now',
        'hero-title': 'Your Linux. <br class="hidden sm:block" /> Your Rules.',
        'hero-desc': 'Turn a fresh Linux install into a complete dev, DevOps, and AI workstation. Modular, idempotent, and reversible.',
        'btn-copy': 'Copy Command',
        'btn-github': 'View on GitHub',
        'stat-modules': 'Modules',
        'stat-profiles': 'Profiles',
        'stat-distros': 'Supported Distros',
        'how-title': 'How it Works',
        'how-desc': 'The process for your ideal workstation.',
        'how-1-title': 'Detects',
        'how-1-desc': 'Identifies your distribution (Ubuntu, Fedora, Arch, etc) and hardware automatically before starting.',
        'how-2-title': 'Selects',
        'how-2-desc': 'Choose a ready-made profile or pick modules individually via an interactive terminal menu.',
        'how-3-title': 'Installs',
        'how-3-desc': 'Configures repositories, installs packages, and applies settings modularly and idempotently.',
        'profiles-title': 'Ready Profiles',
        'profiles-desc': 'Choose a profile and install exactly what you need for your workflow. Nothing more, nothing less.',
        'feat-1-title': 'Modular & Idempotent',
        'feat-1-desc': 'Choose exactly what you want. Run multiple times without duplicating or breaking anything.',
        'feat-2-title': 'Multi-Distro',
        'feat-2-desc': 'Native support for APT, DNF, and Pacman. Ubuntu, Fedora, Pop!_OS, Arch, and more.',
        'feat-3-title': 'Safe Rollback',
        'feat-3-desc': 'Built-in state manifest. Uninstall modules by reverting exactly what they did.',
        'feat-4-title': 'AI & DevOps',
        'feat-4-desc': 'Ready-to-use modules for Kubernetes, Docker, Ollama, Claude, and the complete ecosystem.'
    }
};

let currentLang = 'pt-BR';

// --- i18n Toggle ---
const langToggle = document.getElementById('langToggle');
const langLabel = document.getElementById('currentLang');

function updateLanguage(lang) {
    document.documentElement.lang = lang;
    const elements = document.querySelectorAll('[data-i18n]');
    
    const chavedHtml = new Set(['hero-title']);
    elements.forEach(el => {
        const key = el.getAttribute('data-i18n');
        const val = translations[lang][key];
        if (val === undefined) return;
        if (chavedHtml.has(key)) {
            el.innerHTML = val;
        } else {
            el.textContent = val;
        }
    });
    
    langLabel.textContent = lang === 'pt-BR' ? 'EN' : 'PT';
}

langToggle.addEventListener('click', () => {
    currentLang = currentLang === 'pt-BR' ? 'en' : 'pt-BR';
    updateLanguage(currentLang);
});


// --- Terminal Realista com Loop ---
const typewriterEl = document.getElementById('typewriter');
const terminalContentEl = document.getElementById('terminal-content');
const promptChar = document.getElementById('prompt-char');

// Sintaxe colorida (Bash mock)
const commandTokens = [
    { text: 'bash', cls: 'text-green-400' },
    { text: ' <(', cls: 'text-slate-300' },
    { text: 'curl', cls: 'text-blue-400' },
    { text: ' -fsSL', cls: 'text-purple-400' },
    { text: ' https://raw.githubusercontent.com/BrunoSouzaFarias/brunodev-workstation/main/install.sh', cls: 'text-yellow-300' },
    { text: ')', cls: 'text-slate-300' }
];

const loggerOutput = [
    { text: `→ [${new Date().toLocaleTimeString('en-US', { hour12: false })}] Iniciando instalação...`, cls: 'text-brand-400', delay: 400 },
    { text: '✔ Distribuição suportada detectada (Ubuntu)', cls: 'text-green-400', delay: 300 },
    { text: '✔ Hardware analisado (Memória OK, Espaço OK)', cls: 'text-green-400', delay: 200 },
    { text: '⚠ Alguns pacotes exigem privilégios de sudo', cls: 'text-yellow-400', delay: 500 },
    { text: '→ Baixando dependências principais...', cls: 'text-brand-400', delay: 600 },
    { text: '✔ BrunoDev Workstation pronta.', cls: 'text-green-400 font-bold', delay: 100 }
];

let isTyping = false;

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function typeCommand() {
    promptChar.style.display = 'inline';
    typewriterEl.innerHTML = '';
    terminalContentEl.innerHTML = '';
    
    for (const token of commandTokens) {
        const span = document.createElement('span');
        span.className = token.cls;
        typewriterEl.appendChild(span);
        
        for (let i = 0; i < token.text.length; i++) {
            span.textContent += token.text[i];
            await sleep(15 + Math.random() * 30);
        }
    }
}

async function showOutput() {
    promptChar.style.display = 'none';
    const commandText = typewriterEl.innerHTML;
    
    // Move command up
    terminalContentEl.innerHTML = `<div><span class="text-brand-400 mr-2">❯</span>${commandText}</div>`;
    typewriterEl.innerHTML = '';
    
    await sleep(200);
    
    for (const line of loggerOutput) {
        const div = document.createElement('div');
        div.className = line.cls;
        div.textContent = line.text;
        terminalContentEl.appendChild(div);
        await sleep(line.delay);
    }
}

async function runTerminalLoop() {
    if (isTyping) return;
    isTyping = true;
    
    while (true) {
        await typeCommand();
        await sleep(400);
        await showOutput();
        await sleep(5000); // Wait before restart
    }
}

setTimeout(runTerminalLoop, 1000);

// --- Counters Animation ---
function animateValue(obj, start, end, duration) {
    let startTimestamp = null;
    const step = (timestamp) => {
        if (!startTimestamp) startTimestamp = timestamp;
        const progress = Math.min((timestamp - startTimestamp) / duration, 1);
        obj.innerHTML = Math.floor(progress * (end - start) + start);
        if (progress < 1) {
            window.requestAnimationFrame(step);
        }
    };
    window.requestAnimationFrame(step);
}

// Trigger counters when in view
const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            animateValue(document.getElementById("count-modules"), 0, 44, 2000);
            animateValue(document.getElementById("count-profiles"), 0, 12, 2000);
            animateValue(document.getElementById("count-distros"), 0, 9, 2000);
            observer.disconnect();
        }
    });
}, { threshold: 0.5 });

observer.observe(document.getElementById("count-modules"));


// --- Profile Selector ---
const profiles = {
    'developer': {
        name: 'Developer',
        icon: 'code',
        modules: ['sistema', 'git', 'ssh', 'github-cli', 'shell', 'terminal', 'vscode', 'fonts', 'docker', 'docker-compose', 'nvm', 'node', 'pnpm', 'python']
    },
    'devops': {
        name: 'DevOps',
        icon: 'server',
        modules: ['sistema', 'git', 'ssh', 'github-cli', 'shell', 'terminal', 'vscode', 'docker', 'docker-compose', 'podman', 'kubernetes', 'python', 'uv', 'firewall', 'fail2ban', 'ssh-hardening', 'backup']
    },
    'ai-engineer': {
        name: 'AI Engineer',
        icon: 'brain',
        modules: ['sistema', 'git', 'ssh', 'shell', 'vscode', 'fonts', 'docker', 'docker-compose', 'nvm', 'node', 'python', 'uv', 'ollama', 'open-webui', 'claude-code', 'gemini-cli', 'aider', 'continue']
    },
    'data-science': {
        name: 'Data Science',
        icon: 'database',
        modules: ['sistema', 'git', 'ssh', 'shell', 'vscode', 'python', 'uv', 'docker', 'docker-compose', 'postgresql']
    },
    'fullstack': {
        name: 'Fullstack',
        icon: 'layers',
        modules: ['sistema', 'git', 'ssh', 'github-cli', 'shell', 'terminal', 'vscode', 'fonts', 'docker', 'docker-compose', 'nvm', 'node', 'pnpm', 'bun', 'python', 'uv', 'postgresql', 'redis']
    },
    'minimo': {
        name: 'Mínimo',
        icon: 'feather',
        modules: ['sistema', 'git', 'shell', 'python']
    }
};

const tabsContainer = document.getElementById('profile-tabs');
const modulesContainer = document.getElementById('profile-modules');
const filenameLabel = document.getElementById('profile-filename');

function renderProfile(key) {
    const profile = profiles[key];
    filenameLabel.textContent = `${key}.list`;
    
    // Render modules
    modulesContainer.innerHTML = '';
    profile.modules.forEach(mod => {
        const span = document.createElement('span');
        span.className = 'px-2 py-1 bg-white/5 border border-white/10 rounded text-slate-300';
        span.textContent = mod;
        modulesContainer.appendChild(span);
    });

    // Update active tab styling
    document.querySelectorAll('.profile-tab').forEach(tab => {
        if (tab.dataset.key === key) {
            tab.classList.add('bg-white/10', 'border-white/20');
            tab.classList.remove('border-transparent', 'hover:bg-white/5');
            tab.querySelector('i').classList.add('text-brand-400');
            tab.querySelector('i').classList.remove('text-slate-500');
        } else {
            tab.classList.remove('bg-white/10', 'border-white/20');
            tab.classList.add('border-transparent', 'hover:bg-white/5');
            tab.querySelector('i').classList.remove('text-brand-400');
            tab.querySelector('i').classList.add('text-slate-500');
        }
    });
}

// Generate tabs
Object.entries(profiles).forEach(([key, data]) => {
    const btn = document.createElement('button');
    btn.className = `profile-tab w-full flex items-center gap-3 px-4 py-3 rounded-lg border text-left transition-all`;
    btn.dataset.key = key;
    btn.innerHTML = `<i data-lucide="${data.icon}" class="w-5 h-5 text-slate-500 transition-colors"></i><span class="font-medium text-slate-200">${data.name}</span>`;
    btn.addEventListener('click', () => renderProfile(key));
    tabsContainer.appendChild(btn);
});

// Init
renderProfile('developer');
updateLanguage(currentLang);


// --- Copy Command Button ---
const copyBtn = document.getElementById('copyBtn');
const fullCommand = "bash <(curl -fsSL https://raw.githubusercontent.com/BrunoSouzaFarias/brunodev-workstation/main/install.sh)";
copyBtn.addEventListener('click', async () => {
    try {
        await navigator.clipboard.writeText(fullCommand);
        const originalHtml = copyBtn.innerHTML;
        copyBtn.innerHTML = `<i data-lucide="check" class="w-4 h-4 text-green-600"></i><span class="text-green-600">Copiado!</span>`;
        lucide.createIcons();
        setTimeout(() => {
            copyBtn.innerHTML = originalHtml;
            lucide.createIcons();
        }, 2000);
    } catch (err) {
        console.error('Failed to copy', err);
    }
});