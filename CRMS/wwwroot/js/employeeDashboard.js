// Employee dashboard — shown to non-admin roles only.
// adminDashboard.js already hides #welcome-section for admins; we show it here for everyone else.

if (session && session.role !== 'Admin') {
  document.getElementById('welcome-section').hidden = false;
  initEmployeeDashboard();
}

function initEmployeeDashboard() {
  const listEl = document.getElementById('emp-cases-list');
  const loadingEl = document.getElementById('emp-cases-loading');
  const emptyEl = document.getElementById('emp-cases-empty');
  const errorEl = document.getElementById('emp-cases-error');
  const searchInput = document.getElementById('emp-search');
  const filterBtns = document.querySelectorAll('.emp-dash-filters .seg-btn');

  const STATUS_META = {
    Pending: { label: t('status.pending'), cls: 'pending' },
    Waiting: { label: t('status.waiting'), cls: 'waiting' },
    Success: { label: t('status.success'), cls: 'success' },
    Failed: { label: t('status.failed'), cls: 'failed' }
  };

  let allCases = [];
  let activeFilter = 'all';
  let searchTerm = '';

  function escapeHtml(v) {
    const d = document.createElement('div');
    d.textContent = v ?? '';
    return d.innerHTML;
  }

  function setError(msg) {
    if (!msg) { errorEl.hidden = true; errorEl.textContent = ''; return; }
    errorEl.hidden = false;
    errorEl.textContent = msg;
  }

  function isToday(dateStr) {
    const d = new Date(dateStr);
    const n = new Date();
    return d.getFullYear() === n.getFullYear() && d.getMonth() === n.getMonth() && d.getDate() === n.getDate();
  }

  function applyFilters(cases) {
    let result = cases;

    if (activeFilter === 'today') {
      result = result.filter((c) => isToday(c.createdAt));
    } else if (activeFilter === 'mine') {
      result = result.filter((c) => c.assignedToUsername === session.username);
    } else if (activeFilter === 'unassigned') {
      result = result.filter((c) => !c.assignedToUsername);
    }

    const term = searchTerm.trim().toLowerCase();
    if (term) {
      result = result.filter((c) => {
        const phone = `${c.phoneCountryCode}${c.phoneNumber}`.toLowerCase();
        return c.name.toLowerCase().includes(term) || phone.includes(term);
      });
    }

    return result;
  }

  function renderList() {
    const filtered = applyFilters(allCases);

    if (!filtered.length) {
      listEl.innerHTML = '';
      emptyEl.hidden = false;
      const filterLabels = { all: t('dashboard.empty.all'), today: t('dashboard.empty.today'), mine: t('dashboard.empty.mine'), unassigned: t('dashboard.empty.unassigned') };
      emptyEl.textContent = searchTerm ? t('dashboard.empty.search') : (filterLabels[activeFilter] || t('dashboard.empty.all'));
      return;
    }

    emptyEl.hidden = true;
    listEl.innerHTML = `
      <div class="users-table-wrap">
        <table class="users-table">
          <thead>
            <tr>
              <th>${t('col.name')}</th>
              <th>${t('col.procedure')}</th>
              <th>${t('col.department')}</th>
              <th>${t('col.phone')}</th>
              <th>${t('col.createdBy')}</th>
              <th>${t('col.assignedTo')}</th>
              <th>${t('col.status')}</th>
              <th></th>
            </tr>
          </thead>
          <tbody>${filtered.map(rowTemplate).join('')}</tbody>
        </table>
      </div>`;

    listEl.querySelectorAll('[data-action="assign"]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const id = Number(btn.dataset.id);
        btn.disabled = true;
        btn.textContent = t('action.assigning');
        try {
          await apiClaimCase(id);
          await loadCases();
        } catch (err) {
          setError(err.message);
          btn.disabled = false;
          btn.textContent = t('action.assignToMe');
        }
      });
    });
  }

  function rowTemplate(c) {
    const meta = STATUS_META[c.status] || { label: c.status, cls: 'pending' };
    const assignedLabel = c.assignedToUsername
      ? escapeHtml(c.assignedToUsername)
      : '<span style="color:var(--muted)">—</span>';
    const isMyCase = c.assignedToUsername === session.username;
    const assignBtn = isMyCase
      ? ''
      : `<button type="button" class="btn-action" data-action="assign" data-id="${c.id}">${t('action.assignToMe')}</button>`;

    const forwardedBadge = c.forwardedByUsername
      ? `<span class="status-pill status-pill--forwarded" title="${t('badge.forwarded')} ${escapeHtml(c.forwardedByUsername)}">${t('badge.forwarded')}</span> `
      : '';
    return `
      <tr>
        <td data-label="${t('col.name')}">${escapeHtml(c.name)}</td>
        <td data-label="${t('col.procedure')}"><span class="proc-label">${escapeHtml(c.procedure || '—')}</span></td>
        <td data-label="${t('col.department')}">${escapeHtml(c.department || '—')}</td>
        <td data-label="${t('col.phone')}">${escapeHtml(formatPhone(c.phoneCountryCode, c.phoneNumber))}</td>
        <td data-label="${t('col.createdBy')}">${escapeHtml(c.createdByUsername || '—')}</td>
        <td data-label="${t('col.assignedTo')}">${assignedLabel}</td>
        <td data-label="${t('col.status')}">${forwardedBadge}<span class="status-pill status-pill--${meta.cls}">${meta.label}</span></td>
        <td>
          <div class="row-actions">
            <a class="btn-action" href="case.html?id=${c.id}">${t('action.view')}</a>
            ${assignBtn}
          </div>
        </td>
      </tr>`;
  }

  async function loadCases() {
    loadingEl.hidden = false;
    emptyEl.hidden = true;
    listEl.innerHTML = '';
    setError(null);

    try {
      allCases = await apiGetAllCases();
      renderList();
    } catch (err) {
      setError(err.message);
    } finally {
      loadingEl.hidden = true;
    }
  }

  // Filter buttons
  filterBtns.forEach((btn) => {
    btn.addEventListener('click', () => {
      activeFilter = btn.dataset.filter;
      filterBtns.forEach((b) => b.classList.toggle('seg-btn--active', b === btn));
      renderList();
    });
  });

  // Search
  searchInput.addEventListener('input', (e) => {
    searchTerm = e.target.value;
    renderList();
  });

  loadCases();
}
