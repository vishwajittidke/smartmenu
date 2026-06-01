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
    insights: {}
};

// ─── Demo Data ──────────────────────────────────────────────────────────
const DEMO = {
    orders: [
        { Id: '001', Name: 'ORD-2024-001', Status__c: 'New', Total__c: 89.99, Customer__c: 'John Doe', Restaurant__c: 'The Gourmet Hub', CreatedDate: '2026-06-01T10:30:00Z' },
        { Id: '002', Name: 'ORD-2024-002', Status__c: 'In Progress', Total__c: 145.50, Customer__c: 'Jane Smith', Restaurant__c: 'The Gourmet Hub', CreatedDate: '2026-06-01T11:15:00Z' },
        { Id: '003', Name: 'ORD-2024-003', Status__c: 'Completed', Total__c: 67.00, Customer__c: 'Bob Wilson', Restaurant__c: 'The Gourmet Hub', CreatedDate: '2026-06-01T09:45:00Z' },
        { Id: '004', Name: 'ORD-2024-004', Status__c: 'New', Total__c: 234.75, Customer__c: 'Alice Brown', Restaurant__c: 'Spice Garden', CreatedDate: '2026-06-01T12:00:00Z' },
        { Id: '005', Name: 'ORD-2024-005', Status__c: 'Completed', Total__c: 178.25, Customer__c: 'Charlie Lee', Restaurant__c: 'The Gourmet Hub', CreatedDate: '2026-05-31T18:30:00Z' },
        { Id: '006', Name: 'ORD-2024-006', Status__c: 'Cancelled', Total__c: 45.00, Customer__c: 'Diana Prince', Restaurant__c: 'Spice Garden', CreatedDate: '2026-05-31T20:15:00Z' },
    ],
    menuItems: [
        { Id: 'm1', Name: 'Truffle Risotto', Price__c: 28.99, Category__c: 'Main Course', Description__c: 'Creamy arborio rice with black truffle shavings and parmesan', Is_Available__c: true },
        { Id: 'm2', Name: 'Wagyu Burger', Price__c: 34.99, Category__c: 'Main Course', Description__c: 'Premium wagyu beef patty with aged cheddar and caramelized onions', Is_Available__c: true },
        { Id: 'm3', Name: 'Burrata Salad', Price__c: 18.50, Category__c: 'Appetizer', Description__c: 'Fresh burrata with heirloom tomatoes, basil, and balsamic glaze', Is_Available__c: true },
        { Id: 'm4', Name: 'Lobster Bisque', Price__c: 16.99, Category__c: 'Appetizer', Description__c: 'Rich and creamy lobster bisque with a touch of cognac', Is_Available__c: true },
        { Id: 'm5', Name: 'Tiramisu', Price__c: 14.99, Category__c: 'Dessert', Description__c: 'Classic Italian tiramisu with mascarpone and espresso-soaked ladyfingers', Is_Available__c: true },
        { Id: 'm6', Name: 'Craft Lemonade', Price__c: 8.50, Category__c: 'Beverage', Description__c: 'Fresh-squeezed lemonade with lavender and mint', Is_Available__c: true },
        { Id: 'm7', Name: 'Garlic Bread', Price__c: 9.99, Category__c: 'Side', Description__c: 'Toasted sourdough with roasted garlic butter and herbs', Is_Available__c: true },
        { Id: 'm8', Name: 'Molten Lava Cake', Price__c: 16.50, Category__c: 'Dessert', Description__c: 'Dark chocolate fondant with vanilla bean ice cream', Is_Available__c: false },
    ],
    reviews: [
        { Id: 'r1', Rating__c: 5, Comment__c: 'Absolutely incredible! The truffle risotto was the best I\'ve ever had. Service was impeccable.', CreatedDate: '2026-05-30T14:00:00Z', Customer__r: { FirstName: 'Sarah', LastName: 'Johnson' } },
        { Id: 'r2', Rating__c: 4.5, Comment__c: 'Great food and atmosphere. The wagyu burger is a must-try. Will definitely come back!', CreatedDate: '2026-05-29T19:30:00Z', Customer__r: { FirstName: 'Mike', LastName: 'Chen' } },
        { Id: 'r3', Rating__c: 4, Comment__c: 'Lovely evening. The desserts are phenomenal. Slightly long wait for the main course.', CreatedDate: '2026-05-28T21:00:00Z', Customer__r: { FirstName: 'Emma', LastName: 'Williams' } },
        { Id: 'r4', Rating__c: 5, Comment__c: 'The AI ordering assistant made everything so smooth. Future of dining!', CreatedDate: '2026-05-27T12:15:00Z', Customer__r: { FirstName: 'Alex', LastName: 'Rivera' } },
    ],
    insights: {
        totalRevenue: 4567.89,
        completedOrders: 42,
        averageOrderValue: 108.76,
        reviewSummary: { averageRating: 4.6, totalReviews: 127 },
        ordersByStatus: { 'New': 8, 'In Progress': 5, 'Completed': 42, 'Cancelled': 3 }
    }
};

// ─── API Helpers ────────────────────────────────────────────────────────
async function sfFetch(endpoint) {
    if (!state.connected) return null;
    try {
        const res = await fetch(`${state.orgUrl}/services/apexrest${endpoint}`, {
            headers: {
                'Authorization': `Bearer ${state.accessToken}`,
                'Content-Type': 'application/json'
            }
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return await res.json();
    } catch (e) {
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

function renderOrders(orders) {
    const grid = document.getElementById('ordersGrid');
    if (!orders.length) {
        grid.innerHTML = '<div class="order-card"><p style="color:var(--text-muted)">No orders found. Connect to your Salesforce org or use Demo Mode.</p></div>';
        return;
    }
    grid.innerHTML = orders.map((o, i) => `
        <div class="order-card" style="animation-delay: ${i * 0.05}s">
            <div class="order-card-header">
                <span class="order-name">${o.Name}</span>
                <span class="order-status ${getStatusClass(o.Status__c)}">${o.Status__c || 'Unknown'}</span>
            </div>
            <div class="order-details">
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
    `).join('');
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
    const orders = await sfFetch('/orders/');
    if (orders) {
        state.orders = orders;
        renderOrders(orders);
    }
    updateHeroStats();
}

function loadDemoData() {
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
        
        state.orgUrl = orgUrl;
        state.accessToken = token;
        state.connected = true;
        
        document.getElementById('btnConnect').classList.add('connected');
        document.getElementById('btnConnect').innerHTML = '<span class="connect-dot"></span> Connected';
        modal.classList.remove('open');
        
        await loadLiveData();
    });
    
    // Demo mode
    document.getElementById('btnDemoMode').addEventListener('click', () => {
        state.connected = false;
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
    
    // ─── New Order Modal ────────────────────────────────────────────────
    const orderModal = document.getElementById('newOrderModal');
    document.getElementById('btnNewOrder').addEventListener('click', () => orderModal.classList.add('open'));
    document.getElementById('newOrderClose').addEventListener('click', () => orderModal.classList.remove('open'));
    orderModal.addEventListener('click', (e) => { if (e.target === orderModal) orderModal.classList.remove('open'); });
    
    document.getElementById('btnSubmitOrder').addEventListener('click', async () => {
        const name = document.getElementById('orderName').value.trim();
        const customer = document.getElementById('orderCustomer').value.trim();
        const total = parseFloat(document.getElementById('orderTotal').value) || 0;
        const status = document.getElementById('orderStatus').value;
        
        if (!name) { showToast('Order name is required', 'error'); return; }
        if (total <= 0) { showToast('Total must be greater than 0', 'error'); return; }
        
        if (state.connected) {
            // POST to Salesforce REST API
            try {
                const res = await fetch(`${state.orgUrl}/services/apexrest/orders/`, {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${state.accessToken}`,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ name, total })
                });
                if (!res.ok) throw new Error(`HTTP ${res.status}`);
                showToast(`✓ Order "${name}" created in Salesforce!`);
                await loadLiveData();
            } catch (e) {
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
            
            renderOrders(state.orders);
            renderInsights(state.insights);
            updateHeroStats();
            showToast(`✓ Order "${name}" created!`);
        }
        
        // Clear form & close
        document.getElementById('orderName').value = '';
        document.getElementById('orderCustomer').value = '';
        document.getElementById('orderTotal').value = '';
        document.getElementById('orderStatus').value = 'New';
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
        
        // Add locally (demo mode or live — MenuService doesn't have a REST endpoint yet)
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
        
        // Clear form & close
        document.getElementById('menuItemName').value = '';
        document.getElementById('menuItemDesc').value = '';
        document.getElementById('menuItemPrice').value = '';
        document.getElementById('menuItemCategory').value = 'Appetizer';
        menuModal.classList.remove('open');
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
    
    // Auto-load demo data on start
    loadDemoData();
    
    // Navbar scroll effect
    window.addEventListener('scroll', () => {
        document.getElementById('navbar').style.background = 
            window.scrollY > 50 ? 'rgba(10, 10, 15, 0.95)' : 'rgba(10, 10, 15, 0.8)';
    });
});
