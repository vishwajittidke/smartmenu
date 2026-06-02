/* ═══════════════════════════════════════════════════════════════════════
   SmartMenu Web App — Connects to Salesforce REST API (OrderApi)
   ═══════════════════════════════════════════════════════════════════════ */

// ─── State ──────────────────────────────────────────────────────────────
const state = {
    connected: false,
    orgUrl: '',
    accessToken: '',
    orders: [],
    menuItems: [],
    reviews: [],
    insights: {},
    isFetching: false
};

// ─── Demo Data ──────────────────────────────────────────────────────────
const DEMO = {
    orders: [
        {
            Id: 'demo-100001',
            Name: 'ORD-20260602-120001',
            Status__c: 'Completed',
            Total__c: 38.97,
            Customer__c: 'Jane Doe',
            CreatedDate: new Date(Date.now() - 3600000 * 2).toISOString()
        },
        {
            Id: 'demo-100002',
            Name: 'ORD-20260602-121522',
            Status__c: 'In Progress',
            Total__c: 25.98,
            Customer__c: 'Alex Rivera',
            CreatedDate: new Date(Date.now() - 3600000 * 0.5).toISOString()
        },
        {
            Id: 'demo-100003',
            Name: 'ORD-20260602-124509',
            Status__c: 'New',
            Total__c: 12.99,
            Customer__c: 'Marcus Sterling',
            CreatedDate: new Date().toISOString()
        }
    ],
    menuItems: [
        {
            Id: 'demo-m1',
            Name: 'Paneer Tikka Wrap',
            Price__c: 12.99,
            Category__c: 'Main Course',
            Description__c: 'Spiced cottage cheese cubes marinated in yogurt, tandoor-grilled with peppers and wrapped in a warm tortilla with mint chutney.',
            Is_Available__c: true
        },
        {
            Id: 'demo-m2',
            Name: 'Truffle Mushroom Pasta',
            Price__c: 18.99,
            Category__c: 'Main Course',
            Description__c: 'Artisanal pasta tossed in an exquisite black truffle cream sauce with sautéed wild mushrooms and shaved parmesan.',
            Is_Available__c: true
        },
        {
            Id: 'demo-m3',
            Name: 'Hummus & Pita Platter',
            Price__c: 9.99,
            Category__c: 'Appetizer',
            Description__c: 'Creamy house-made chickpeas tahini spread topped with organic olive oil, served with warm tandoori-baked pita bread.',
            Is_Available__c: true
        },
        {
            Id: 'demo-m4',
            Name: 'Crispy Falafel Salad',
            Price__c: 11.99,
            Category__c: 'Appetizer',
            Description__c: 'Deep-fried spiced herb chickpea balls served over mixed salad greens, cucumber, cherry tomatoes, and tahini drizzle.',
            Is_Available__c: true
        },
        {
            Id: 'demo-m5',
            Name: 'Mango Coconut Panna Cotta',
            Price__c: 7.99,
            Category__c: 'Dessert',
            Description__c: 'Silky eggless vanilla panna cotta infused with fresh Alphonso mango purée and topped with toasted coconut flakes.',
            Is_Available__c: true
        },
        {
            Id: 'demo-m6',
            Name: 'Fresh Ginger Lemonade',
            Price__c: 4.50,
            Category__c: 'Beverage',
            Description__c: 'Zesty and refreshing house-brewed lemonade with freshly squeezed ginger, fresh mint leaves, and organic honey.',
            Is_Available__c: true
        }
    ],
    reviews: [
        {
            Id: 'demo-r1',
            Rating__c: 5.0,
            Comment__c: 'The Truffle Mushroom Pasta is absolutely out of this world! Perfect balance of rich earthy flavors.',
            CreatedDate: new Date(Date.now() - 3600000 * 3).toISOString(),
            Customer__r: { FirstName: 'Jane', LastName: 'Doe' }
        },
        {
            Id: 'demo-r2',
            Rating__c: 4.5,
            Comment__c: 'Extremely fresh Paneer Tikka Wrap! The mint chutney adds an amazing kick. Will definitely order again.',
            CreatedDate: new Date(Date.now() - 3600000 * 1.5).toISOString(),
            Customer__r: { FirstName: 'Alex', LastName: 'Rivera' }
        }
    ],
    insights: {
        totalRevenue: 77.94,
        completedOrders: 1,
        averageOrderValue: 25.98,
        reviewSummary: { averageRating: 4.75, totalReviews: 2 },
        ordersByStatus: { 'New': 1, 'In Progress': 1, 'Completed': 1, 'Cancelled': 0 }
    }
};

// ─── Toast Notification ─────────────────────────────────────────────
function showToast(message, type = 'success') {
    let toast = document.querySelector('.toast');
    if (!toast) {
        toast = document.createElement('div');
        toast.className = 'toast';
        document.body.appendChild(toast);
    }
    toast.textContent = message;
    toast.className = `toast ${type}`;
    requestAnimationFrame(() => toast.classList.add('show'));
    setTimeout(() => toast.classList.remove('show'), 3000);
}

// ─── Real-Time Integration Logger ─────────────────────────────────────
function logEvent(message, type = 'api-info') {
    const body = document.getElementById('consoleBody');
    if (!body) return;
    const line = document.createElement('div');
    line.className = `console-log-line ${type}`;
    const time = new Date().toTimeString().split(' ')[0];
    line.innerHTML = `<span class="timestamp">[${time}]</span> <span class="message">${message}</span>`;
    body.appendChild(line);
    body.scrollTop = body.scrollHeight;
}

// ─── API Helpers ────────────────────────────────────────────────────────
async function sfFetch(endpoint) {
    if (!state.connected) return null;
    try {
        logEvent(`[API GET] Querying Apex REST resource: /services/apexrest${endpoint}`, 'api-info');
        const res = await fetch(`${state.orgUrl}/services/apexrest${endpoint}`, {
            headers: {
                'Authorization': `Bearer ${state.accessToken}`,
                'Content-Type': 'application/json'
            }
        });
        if (res.status === 401) {
            logEvent(`[API 401] Access Token Expired or Invalid! Session terminated.`, 'api-error');
            showToast('Salesforce session expired. Please reconnect.', 'error');
            state.connected = false;
            localStorage.setItem('smartmenu_connected', 'false');
            document.getElementById('btnConnect').classList.remove('connected');
            document.getElementById('btnConnect').innerHTML = 'Connect Org';
            loadDemoData();
            return null;
        }
        if (!res.ok) {
            logEvent(`[API ERROR] HTTP Failure ${res.status} returned for ${endpoint}`, 'api-error');
            throw new Error(`HTTP ${res.status}`);
        }
        const data = await res.json();
        logEvent(`[API SUCCESS] Retrieved telemetry payload successfully for ${endpoint}`, 'api-success');
        return data;
    } catch (e) {
        logEvent(`[API EXCEPTION] Network request failed for ${endpoint}: ${e.message}`, 'api-error');
        console.error('API Error:', e);
        return null;
    }
}

// ─── Render Functions ───────────────────────────────────────────────────
function getStatusClass(status) {
    if (!status) return '';
    return 'status-' + status.toLowerCase().replace(/\s+/g, '-');
}

function formatCurrency(val) {
    if (val === null || val === undefined) return '$0.00';
    return '$' + Number(val).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function formatDate(dateStr) {
    if (!dateStr) return '—';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function renderStars(rating) {
    const full = Math.floor(rating);
    const half = rating % 1 >= 0.5;
    let stars = '★'.repeat(full);
    if (half) stars += '½';
    stars += '☆'.repeat(5 - full - (half ? 1 : 0));
    return stars;
}

// Helper to generate deterministic short Order ID in ORD-000000 format
function getFormattedOrderId(id) {
    if (!id) return 'ORD-000000';
    if (id.startsWith('demo-')) {
        const num = id.replace('demo-', '');
        return 'ORD-' + String(parseInt(num) % 1000000).padStart(6, '0');
    }
    let hash = 0;
    for (let i = 0; i < id.length; i++) {
        hash = (hash << 5) - hash + id.charCodeAt(i);
        hash |= 0;
    }
    return 'ORD-' + String(Math.abs(hash) % 1000000).padStart(6, '0');
}

function renderOrders(orders) {
    const grid = document.getElementById('ordersGrid');
    if (!orders.length) {
        grid.innerHTML = '<div class="order-card"><p style="color:var(--text-muted)">No orders found. Connect to your Salesforce org or use Demo Mode.</p></div>';
        return;
    }
    grid.innerHTML = orders.map((o, i) => {
        const customerName = o.Customer__r ? o.Customer__r.Name : (o.Customer__c || '—');
        return `
            <div class="order-card" style="animation-delay: ${i * 0.05}s">
                <div class="order-card-header">
                    <span class="order-name">${getFormattedOrderId(o.Id)}</span>
                    <span class="order-status ${getStatusClass(o.Status__c)}">${o.Status__c || 'Unknown'}</span>
                </div>
                <div class="order-details">
                    <div class="order-detail">
                        <span class="order-detail-label">Customer</span>
                        <span class="order-detail-value">${customerName}</span>
                    </div>
                    <div class="order-detail">
                        <span class="order-detail-label">Total</span>
                        <span class="order-detail-value">${formatCurrency(o.Total__c)}</span>
                    </div>
                    <div class="order-detail">
                        <span class="order-detail-label">Date</span>
                        <span class="order-detail-value">${formatDate(o.CreatedDate)}</span>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}

function renderMenu(items, filter = 'All') {
    const grid = document.getElementById('menuGrid');
    const filtered = filter === 'All' ? items : items.filter(m => m.Category__c === filter);
    
    if (!filtered.length) {
        grid.innerHTML = '<div class="menu-card"><p style="color:var(--text-muted)">No menu items found.</p></div>';
        return;
    }
    
    grid.innerHTML = filtered.map((m, i) => `
        <div class="menu-card" style="animation-delay: ${i * 0.05}s">
            <div class="menu-card-header">
                <span class="menu-item-name">${m.Name}</span>
                <span class="menu-item-price">${formatCurrency(m.Price__c)}</span>
            </div>
            <div class="menu-item-category">${m.Category__c || ''}</div>
            <p class="menu-item-desc">${m.Description__c || ''}</p>
            <div class="menu-item-available">
                <span class="available-dot ${m.Is_Available__c ? 'yes' : 'no'}"></span>
                ${m.Is_Available__c ? 'Available' : 'Unavailable'}
            </div>
        </div>
    `).join('');
    
    // Render category filters
    const categories = ['All', ...new Set(items.map(m => m.Category__c).filter(Boolean))];
    const filtersEl = document.getElementById('categoryFilters');
    filtersEl.innerHTML = categories.map(c => `
        <button class="category-chip ${c === filter ? 'active' : ''}" data-category="${c}">${c}</button>
    `).join('');
    
    filtersEl.querySelectorAll('.category-chip').forEach(chip => {
        chip.addEventListener('click', () => renderMenu(state.menuItems, chip.dataset.category));
    });
}

function renderReviews(reviews) {
    const container = document.getElementById('reviewsContainer');
    if (!reviews.length) {
        container.innerHTML = '<div class="review-card"><p style="color:var(--text-muted)">No reviews yet.</p></div>';
        return;
    }
    container.innerHTML = reviews.map((r, i) => `
        <div class="review-card" style="animation-delay: ${i * 0.05}s">
            <div class="review-header">
                <span class="review-stars">${renderStars(r.Rating__c)}</span>
                <span class="review-date">${formatDate(r.CreatedDate)}</span>
            </div>
            <p class="review-comment">"${r.Comment__c}"</p>
            ${r.Customer__r ? `<div class="review-author">— ${r.Customer__r.FirstName} ${r.Customer__r.LastName}</div>` : ''}
        </div>
    `).join('');
}

function renderInsights(insights) {
    document.getElementById('insightRevenue').textContent = formatCurrency(insights.totalRevenue);
    document.getElementById('insightCompletedOrders').textContent = insights.completedOrders || 0;
    document.getElementById('insightAvgOrder').textContent = formatCurrency(insights.averageOrderValue);
    
    const rating = insights.reviewSummary?.averageRating;
    document.getElementById('insightAvgRating').textContent = rating ? Number(rating).toFixed(1) : '0';
    
    // Bar chart
    const statusData = insights.ordersByStatus || {};
    const maxVal = Math.max(...Object.values(statusData), 1);
    const colors = { 'New': 'var(--status-new)', 'In Progress': 'var(--status-progress)', 'Completed': 'var(--status-completed)', 'Cancelled': 'var(--status-cancelled)' };
    
    const barChart = document.getElementById('barChart');
    barChart.innerHTML = Object.entries(statusData).map(([status, count]) => `
        <div class="bar-item">
            <div class="bar" style="height: ${(count / maxVal) * 100}%; background: ${colors[status] || 'var(--accent-1)'};" data-count="${count}"></div>
            <span class="bar-label">${status}</span>
        </div>
    `).join('');
}

function updateHeroStats() {
    const orders = state.orders;
    const insights = state.insights;
    
    document.getElementById('statOrders').textContent = orders.filter(o => o.Status__c !== 'Completed' && o.Status__c !== 'Cancelled').length;
    document.getElementById('statMenu').textContent = state.menuItems.length;
    document.getElementById('statRevenue').textContent = formatCurrency(insights.totalRevenue);
    document.getElementById('statRating').textContent = insights.reviewSummary?.averageRating ? Number(insights.reviewSummary.averageRating).toFixed(1) + '★' : '—';
}

// ─── Data Loading ───────────────────────────────────────────────────────
async function loadLiveData() {
    if (state.isFetching) return;
    state.isFetching = true;
    logEvent(`[🔄 BACKGROUND POLL] Initiating background telemetry sync...`, 'system');
    try {
        const insights = await sfFetch('/insights/');
        if (insights) {
            state.insights = insights;
            renderInsights(insights);
        }

        const orders = await sfFetch('/orders/');
        if (orders) {
            state.orders = orders;
            renderOrders(orders);
        }

        const menuItems = await sfFetch('/menu/');
        if (menuItems) {
            state.menuItems = menuItems;
            renderMenu(menuItems);
        }

        const reviews = await sfFetch('/reviews/');
        if (reviews) {
            state.reviews = reviews;
            renderReviews(reviews);
        }

        updateHeroStats();
    } finally {
        state.isFetching = false;
    }
}

function loadDemoData() {
    logEvent(`[📊 DEMO DATA] Rendering local offline demo dataset.`, 'system');
    state.orders = DEMO.orders;
    state.menuItems = DEMO.menuItems;
    state.reviews = DEMO.reviews;
    state.insights = DEMO.insights;
    
    renderOrders(state.orders);
    renderMenu(state.menuItems);
    renderReviews(state.reviews);
    renderInsights(state.insights);
    updateHeroStats();
}

// ─── Chat Bot (Local AI) ────────────────────────────────────────────────
function getBotResponse(message) {
    const msg = message.toLowerCase();
    
    if (msg.includes('order') && (msg.includes('status') || msg.includes('track') || msg.includes('where'))) {
        const activeOrders = state.orders.filter(o => o.Status__c !== 'Completed' && o.Status__c !== 'Cancelled');
        if (activeOrders.length) {
            return `You have ${activeOrders.length} active order(s):\n${activeOrders.map(o => `• ${o.Name} — ${o.Status__c} (${formatCurrency(o.Total__c)})`).join('\n')}`;
        }
        return 'No active orders found. All orders are completed or cancelled.';
    }
    
    if (msg.includes('menu') || msg.includes('recommend') || msg.includes('food') || msg.includes('eat')) {
        const available = state.menuItems.filter(m => m.Is_Available__c);
        const top3 = available.slice(0, 3);
        return `Here are our top recommendations:\n${top3.map(m => `• ${m.Name} — ${formatCurrency(m.Price__c)} (${m.Category__c})`).join('\n')}\n\nWe have ${available.length} items available today!`;
    }
    
    if (msg.includes('revenue') || msg.includes('insight') || msg.includes('analytics') || msg.includes('sales')) {
        const ins = state.insights;
        return `📊 Revenue Insights:\n• Total Revenue: ${formatCurrency(ins.totalRevenue)}\n• Completed Orders: ${ins.completedOrders}\n• Avg Order Value: ${formatCurrency(ins.averageOrderValue)}\n• Avg Rating: ${ins.reviewSummary?.averageRating?.toFixed(1) || 'N/A'}★`;
    }
    
    if (msg.includes('review') || msg.includes('rating') || msg.includes('feedback')) {
        const summary = state.insights.reviewSummary;
        return `⭐ Review Summary:\n• Average Rating: ${summary?.averageRating?.toFixed(1) || 'N/A'} / 5.0\n• Total Reviews: ${summary?.totalReviews || 0}\n\nMost recent: "${state.reviews[0]?.Comment__c || 'No reviews yet'}"`;
    }
    
    if (msg.includes('help') || msg.includes('what can you')) {
        return `I can help you with:\n• 📦 Order tracking — "Show my orders"\n• 🍽️ Menu recommendations — "What should I eat?"\n• 📊 Revenue insights — "Show revenue"\n• ⭐ Reviews — "Show reviews"\n\nJust ask me anything!`;
    }
    
    return `I'm SmartMenu AI Assistant! I can help with:\n• Order tracking\n• Menu recommendations\n• Revenue insights\n• Customer reviews\n\nTry asking "Show my orders" or "What's on the menu?"`;
}

function addChatMessage(text, sender) {
    const container = document.getElementById('chatMessages');
    const div = document.createElement('div');
    div.className = `chat-message ${sender}`;
    div.innerHTML = `<div class="message-bubble">${text.replace(/\n/g, '<br>')}</div>`;
    container.appendChild(div);
    container.scrollTop = container.scrollHeight;
}

// ─── Navigation ─────────────────────────────────────────────────────────
function setupNavigation() {
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', (e) => {
            document.querySelectorAll('.nav-link').forEach(l => l.classList.remove('active'));
            link.classList.add('active');
        });
    });
    
    // Scroll spy
    const sections = document.querySelectorAll('section[id], header[id]');
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const id = entry.target.id;
                document.querySelectorAll('.nav-link').forEach(l => {
                    l.classList.toggle('active', l.dataset.section === id);
                });
            }
        });
    }, { threshold: 0.3 });
    
    sections.forEach(s => observer.observe(s));
}

// ─── Event Listeners ────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    setupNavigation();
    
    // Connection modal
    const modal = document.getElementById('connectionModal');
    document.getElementById('btnConnect').addEventListener('click', () => modal.classList.add('open'));
    document.getElementById('modalClose').addEventListener('click', () => modal.classList.remove('open'));
    modal.addEventListener('click', (e) => { if (e.target === modal) modal.classList.remove('open'); });
    
    // Save connection
    document.getElementById('btnSaveConnection').addEventListener('click', async () => {
        const orgUrl = document.getElementById('orgUrl').value.trim().replace(/\/+$/, '');
        const token = document.getElementById('accessToken').value.trim();
        
        if (!orgUrl || !token) {
            alert('Please enter both Instance URL and Access Token');
            return;
        }
        
        logEvent(`[PLUG] Connecting to Salesforce Instance: ${orgUrl}...`, 'system');
        state.orgUrl = orgUrl;
        state.accessToken = token;
        state.connected = true;

        localStorage.setItem('smartmenu_orgUrl', orgUrl);
        localStorage.setItem('smartmenu_token', token);
        localStorage.setItem('smartmenu_connected', 'true');
        
        document.getElementById('btnConnect').classList.add('connected');
        document.getElementById('btnConnect').innerHTML = '<span class="connect-dot"></span> Connected';
        modal.classList.remove('open');
        
        logEvent(`[SUCCESS] Credentials saved! Establishing dynamic REST session.`, 'api-success');
        await loadLiveData();
    });
    
    // Demo mode
    document.getElementById('btnDemoMode').addEventListener('click', () => {
        logEvent(`[DEMO] Switched to Offline Demo Mode. Sandbox telemetry simulates live data.`, 'system');
        state.connected = false;
        localStorage.setItem('smartmenu_connected', 'false');
        document.getElementById('btnConnect').classList.add('connected');
        document.getElementById('btnConnect').innerHTML = '<span class="connect-dot"></span> Demo Mode';
        modal.classList.remove('open');
        loadDemoData();
    });
    
    // Refresh orders
    document.getElementById('btnRefreshOrders').addEventListener('click', async () => {
        if (state.connected) {
            await loadLiveData();
        } else {
            loadDemoData();
        }
    });
    
    // Toast Notification is now global
    
    // ─── New Order Modal ────────────────────────────────────────────────
    const orderModal = document.getElementById('newOrderModal');
    
    // Recalculates order total on checkbox state changes
    function recalculateOrderTotalInput() {
        let total = 0;
        const container = document.getElementById('orderItemsSelector');
        if (container) {
            container.querySelectorAll('.order-item-checkbox:checked').forEach(cb => {
                const price = parseFloat(cb.dataset.price) || 0;
                const qtyInput = container.querySelector(`.order-item-qty[data-id="${cb.dataset.id}"]`);
                const qty = parseInt(qtyInput ? qtyInput.value : 1) || 1;
                total += price * qty;
            });
        }
        document.getElementById('orderTotal').value = total.toFixed(2);
    }

    document.getElementById('btnNewOrder').addEventListener('click', () => {
        const container = document.getElementById('orderItemsSelector');
        if (container) {
            if (state.menuItems.length === 0) {
                container.innerHTML = '<p style="color:#aaa;font-size:0.9rem;margin:0;">No menu items available. Add some menu items first!</p>';
            } else {
                container.innerHTML = state.menuItems.map(item => `
                    <div style="display:flex;justify-content:space-between;align-items:center;font-size:0.9rem;gap:8px;width:100%;box-sizing:border-box;">
                        <label style="display:flex;align-items:center;gap:8px;cursor:pointer;flex:1;margin:0;color:#fff;">
                            <input type="checkbox" class="order-item-checkbox" data-id="${item.Id}" data-price="${item.Price__c}">
                            <span>${item.Name} (${formatCurrency(item.Price__c)})</span>
                        </label>
                        <input type="number" class="order-item-qty" data-id="${item.Id}" value="1" min="1" style="width:50px;background:rgba(255,255,255,0.08);border:1px solid rgba(255,255,255,0.1);border-radius:4px;color:#fff;padding:2px 4px;font-size:0.85rem;" disabled>
                    </div>
                `).join('');
                
                // Toggle quantity input on check and bind real-time recalculation to quantity changes
                container.querySelectorAll('.order-item-checkbox').forEach(cb => {
                    const qtyInput = container.querySelector(`.order-item-qty[data-id="${cb.dataset.id}"]`);
                    
                    cb.addEventListener('change', () => {
                        if (qtyInput) {
                            qtyInput.disabled = !cb.checked;
                        }
                        recalculateOrderTotalInput();
                    });
                    
                    if (qtyInput) {
                        qtyInput.addEventListener('input', recalculateOrderTotalInput);
                        qtyInput.addEventListener('change', recalculateOrderTotalInput);
                    }
                });
            }
        }
        // Reset fields
        document.getElementById('orderCustomer').value = '';
        document.getElementById('orderTotal').value = '0.00';
        document.getElementById('orderStatus').value = 'New';
        
        orderModal.classList.add('open');
    });

    document.getElementById('newOrderClose').addEventListener('click', () => orderModal.classList.remove('open'));
    orderModal.addEventListener('click', (e) => { if (e.target === orderModal) orderModal.classList.remove('open'); });
    
    document.getElementById('btnSubmitOrder').addEventListener('click', async () => {
        // Automatically generate a unique, clean, timestamped order name
        const now = new Date();
        const pad = (n) => String(n).padStart(2, '0');
        const dateStamp = now.getFullYear() + pad(now.getMonth() + 1) + pad(now.getDate()) + '-' + pad(now.getHours()) + pad(now.getMinutes()) + pad(now.getSeconds());
        const name = 'ORD-' + dateStamp;

        const customer = document.getElementById('orderCustomer').value.trim();
        const total = parseFloat(document.getElementById('orderTotal').value) || 0;
        const status = document.getElementById('orderStatus').value;
        
        // Build items payload
        const selectedItems = [];
        const container = document.getElementById('orderItemsSelector');
        if (container) {
            container.querySelectorAll('.order-item-checkbox:checked').forEach(cb => {
                const menuItemId = cb.dataset.id;
                const qtyInput = container.querySelector(`.order-item-qty[data-id="${menuItemId}"]`);
                const quantity = parseInt(qtyInput ? qtyInput.value : 1) || 1;
                selectedItems.push({ menuItemId, quantity });
            });
        }
        
        if (selectedItems.length === 0) {
            logEvent(`[ACTION REJECTED] Cannot place order: Please select at least one menu item.`, 'user-action');
            showToast('Please select at least one menu item', 'error');
            return;
        }
        logEvent(`[ORDER ACTION] Submitting new order payload. Generating unique key: ${name} (Customer: "${customer || '—'}")`, 'user-action');

        if (state.connected) {
            try {
                logEvent(`[API POST] Sending payload to REST endpoint /services/apexrest/orders/...`, 'api-info');
                const res = await fetch(`${state.orgUrl}/services/apexrest/orders/`, {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${state.accessToken}`,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        name,
                        restaurant: state.insights.restaurantId,
                        customer: customer,
                        items: selectedItems
                    })
                });
                if (!res.ok) {
                    logEvent(`[API ERROR] REST order creation failed with status ${res.status}`, 'api-error');
                    throw new Error(`HTTP ${res.status}`);
                }
                const resData = await res.json();
                logEvent(`[SUCCESS] Order created successfully! Salesforce resolved Customer Contact, calculated pricing, and stamped child line items.`, 'api-success');
                showToast(`✓ Order "${name}" created with child items in Salesforce!`);
                await loadLiveData();
            } catch (e) {
                logEvent(`[EXCEPTION] Order creation failed: ${e.message}`, 'api-error');
                showToast('Failed to create order: ' + e.message, 'error');
            }
        } else {
            // Demo mode — add locally
            const newOrder = {
                Id: 'demo-' + Date.now(),
                Name: name,
                Status__c: status,
                Total__c: total,
                Customer__c: customer || 'Demo Customer',
                CreatedDate: new Date().toISOString()
            };
            state.orders.unshift(newOrder);
            
            // Update insights
            state.insights.ordersByStatus[status] = (state.insights.ordersByStatus[status] || 0) + 1;
            state.insights.totalRevenue = (state.insights.totalRevenue || 0) + total;
            
            renderOrders(state.orders);
            renderInsights(state.insights);
            updateHeroStats();
            showToast(`✓ Order "${name}" created!`);
        }
        
        orderModal.classList.remove('open');
    });
    
    // ─── New Menu Item Modal ────────────────────────────────────────────
    const menuModal = document.getElementById('newMenuModal');
    document.getElementById('btnNewMenuItem').addEventListener('click', () => menuModal.classList.add('open'));
    document.getElementById('newMenuClose').addEventListener('click', () => menuModal.classList.remove('open'));
    menuModal.addEventListener('click', (e) => { if (e.target === menuModal) menuModal.classList.remove('open'); });
    
    document.getElementById('btnSubmitMenuItem').addEventListener('click', async () => {
        const name = document.getElementById('menuItemName').value.trim();
        const desc = document.getElementById('menuItemDesc').value.trim();
        const price = parseFloat(document.getElementById('menuItemPrice').value) || 0;
        const category = document.getElementById('menuItemCategory').value;
        
        if (!name) { showToast('Item name is required', 'error'); return; }
        if (price <= 0) { showToast('Price must be greater than 0', 'error'); return; }
        
        if (state.connected) {
            try {
                const restaurantId = state.insights.restaurantId;
                const res = await fetch(`${state.orgUrl}/services/apexrest/menu/`, {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${state.accessToken}`,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        name,
                        description: desc,
                        price,
                        category,
                        restaurantId
                    })
                });
                if (!res.ok) throw new Error(`HTTP ${res.status}`);
                showToast(`✓ Menu item "${name}" created in Salesforce!`);
                await loadLiveData();
            } catch (e) {
                showToast('Failed to create menu item: ' + e.message, 'error');
            }
        } else {
            // Demo mode — add locally
            const newItem = {
                Id: 'demo-' + Date.now(),
                Name: name,
                Description__c: desc,
                Price__c: price,
                Category__c: category,
                Is_Available__c: true
            };
            state.menuItems.unshift(newItem);
            renderMenu(state.menuItems);
            updateHeroStats();
            showToast(`✓ "${name}" added to menu!`);
        }
        
        // Clear form & close
        document.getElementById('menuItemName').value = '';
        document.getElementById('menuItemDesc').value = '';
        document.getElementById('menuItemPrice').value = '';
        document.getElementById('menuItemCategory').value = 'Appetizer';
        menuModal.classList.remove('open');
    });

    // ─── New Review Modal ───────────────────────────────────────────────
    const reviewModal = document.getElementById('newReviewModal');
    document.getElementById('btnNewReview').addEventListener('click', () => reviewModal.classList.add('open'));
    document.getElementById('newReviewClose').addEventListener('click', () => reviewModal.classList.remove('open'));
    reviewModal.addEventListener('click', (e) => { if (e.target === reviewModal) reviewModal.classList.remove('open'); });

    document.getElementById('btnSubmitReview').addEventListener('click', async () => {
        const rating = parseInt(document.getElementById('reviewRating').value) || 5;
        const comment = document.getElementById('reviewComment').value.trim();

        if (!comment) { showToast('Comment is required', 'error'); return; }

        if (state.connected) {
            try {
                const restaurantId = state.insights.restaurantId;
                const res = await fetch(`${state.orgUrl}/services/apexrest/reviews/`, {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${state.accessToken}`,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        rating,
                        comment,
                        restaurantId
                    })
                });
                if (!res.ok) throw new Error(`HTTP ${res.status}`);
                showToast(`✓ Review submitted to Salesforce!`);
                await loadLiveData();
            } catch (e) {
                showToast('Failed to submit review: ' + e.message, 'error');
            }
        } else {
            // Demo mode
            const newReview = {
                Id: 'demo-' + Date.now(),
                Rating__c: rating,
                Comment__c: comment,
                CreatedDate: new Date().toISOString(),
                Customer__r: { FirstName: 'Demo', LastName: 'Reviewer' }
            };
            state.reviews.unshift(newReview);
            renderReviews(state.reviews);
            
            // Recalculate average rating in insights
            const totalReviews = (state.insights.reviewSummary?.totalReviews || 0) + 1;
            const currentAvg = state.insights.reviewSummary?.averageRating || 4.5;
            const averageRating = ((currentAvg * (totalReviews - 1)) + rating) / totalReviews;
            state.insights.reviewSummary = { averageRating, totalReviews };

            renderInsights(state.insights);
            updateHeroStats();
            showToast(`✓ Review submitted successfully!`);
        }

        // Clear form & close
        document.getElementById('reviewComment').value = '';
        document.getElementById('reviewRating').value = '5';
        reviewModal.classList.remove('open');
    });
    
    // Chat widget
    const chatFab = document.getElementById('chatFab');
    const chatWindow = document.getElementById('chatWindow');
    
    chatFab.addEventListener('click', () => {
        chatWindow.classList.add('open');
        chatFab.classList.add('hidden');
        document.getElementById('chatInput').focus();
    });
    
    document.getElementById('chatClose').addEventListener('click', () => {
        chatWindow.classList.remove('open');
        chatFab.classList.remove('hidden');
    });
    
    // Chat send
    const sendMessage = () => {
        const input = document.getElementById('chatInput');
        const msg = input.value.trim();
        if (!msg) return;
        
        addChatMessage(msg, 'user');
        input.value = '';
        
        // Simulate typing delay
        setTimeout(() => {
            const response = getBotResponse(msg);
            addChatMessage(response, 'bot');
        }, 400 + Math.random() * 400);
    };
    
    document.getElementById('chatSend').addEventListener('click', sendMessage);
    document.getElementById('chatInput').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') sendMessage();
    });
    
    // Auto-load connection from localStorage if present
    const savedOrgUrl = localStorage.getItem('smartmenu_orgUrl') || document.getElementById('orgUrl').value.trim();
    const savedToken = localStorage.getItem('smartmenu_token') || document.getElementById('accessToken').value.trim();
    const savedConnected = localStorage.getItem('smartmenu_connected') !== 'false';

    if (savedOrgUrl && savedToken && savedConnected) {
        state.orgUrl = savedOrgUrl;
        state.accessToken = savedToken;
        state.connected = true;

        document.getElementById('btnConnect').classList.add('connected');
        document.getElementById('btnConnect').innerHTML = '<span class="connect-dot"></span> Connected';
        
        loadLiveData();
    } else {
        loadDemoData();
    }
    
    // Navbar scroll effect
    window.addEventListener('scroll', () => {
        document.getElementById('navbar').style.background = 
            window.scrollY > 50 ? 'rgba(10, 10, 15, 0.95)' : 'rgba(10, 10, 15, 0.8)';
    });

    // Real-Time Console Drawer Toggle & Clear
    const consoleDrawer = document.getElementById('integrationConsole');
    const consoleToggle = document.getElementById('consoleToggle');
    const consoleClear = document.getElementById('btnConsoleClear');

    if (consoleToggle && consoleDrawer) {
        consoleToggle.addEventListener('click', () => {
            consoleDrawer.classList.toggle('expanded');
            if (consoleDrawer.classList.contains('expanded')) {
                consoleToggle.textContent = '▼ Collapse Console Logs';
            } else {
                consoleToggle.textContent = '▲ Expand Console Logs';
            }
        });
    }

    if (consoleClear) {
        consoleClear.addEventListener('click', (e) => {
            e.stopPropagation();
            const body = document.getElementById('consoleBody');
            if (body) {
                body.innerHTML = `<div class="console-log-line system"><span class="timestamp">[SYSTEM]</span><span class="message">Console cleared. Monitoring events...</span></div>`;
            }
        });
    }

    // Background auto-refresh polling: fetch records dynamically without manual page refresh every 8 seconds
    setInterval(async () => {
        if (state.connected) {
            await loadLiveData();
        }
    }, 8000);
});
