const isAdmin = session?.role === 'Admin';
document.getElementById('welcome-section').hidden = isAdmin;
document.getElementById('admin-content').hidden = !isAdmin;

const STATUS_META = {
  Pending: { label: t('status.pending'), cls: 'pending' },
  Waiting: { label: t('status.waiting'), cls: 'waiting' },
  Success: { label: t('status.success'), cls: 'success' },
  Failed: { label: t('status.failed'), cls: 'failed' }
};

const statsSection = document.getElementById('stats-section');
const statsLoading = document.getElementById('stats-loading');
const statsError = document.getElementById('stats-error');
const statTotal = document.getElementById('stat-total');
const statSuccess = document.getElementById('stat-success');
const statSuccessPct = document.getElementById('stat-success-pct');
const statFailed = document.getElementById('stat-failed');
const statFailedPct = document.getElementById('stat-failed-pct');
const referralBody = document.getElementById('referral-stats-body');
const employeeBody = document.getElementById('employee-stats-body');
const employeeModal = document.getElementById('employee-modal');
const employeeModalTitle = document.getElementById('employee-modal-title');
const employeeModalBody = document.getElementById('employee-modal-body');

let employeeStats = [];

const casesListEl = document.getElementById('admin-cases-list');
const casesLoading = document.getElementById('admin-cases-loading');
const casesEmpty = document.getElementById('admin-cases-empty');
const casesError = document.getElementById('admin-cases-error');
const searchInput = document.getElementById('admin-search');
const userFilter = document.getElementById('admin-user-filter');
const todayCheckbox = document.getElementById('admin-today-only');

let allCases = [];

// ─── Utilities ────────────────────────────────────────────────────────────────

function statusMeta(status) {
  return STATUS_META[status] || { label: status, cls: 'pending' };
}

function formatDate(value) {
  return value ? new Date(value).toLocaleDateString() : '—';
}

function isToday(dateStr) {
  const d = new Date(dateStr);
  const now = new Date();
  return d.getFullYear() === now.getFullYear() &&
         d.getMonth() === now.getMonth() &&
         d.getDate() === now.getDate();
}

function setError(el, message) {
  if (!message) { el.hidden = true; el.textContent = ''; return; }
  el.hidden = false;
  el.textContent = message;
}

// ─── Stats ────────────────────────────────────────────────────────────────────

async function loadStats() {
  statsLoading.hidden = false;
  statsSection.hidden = true;
  setError(statsError, null);

  try {
    const stats = await apiGetAdminStats();
    renderStats(stats);
    statsSection.hidden = false;
  } catch (err) {
    setError(statsError, err.message);
  } finally {
    statsLoading.hidden = true;
  }
}

function renderStats(stats) {
  statTotal.textContent = stats.totalCases;
  statSuccess.textContent = stats.successCount;
  statSuccessPct.textContent = t('stat.ofTotal', { n: stats.successPercent });
  statFailed.textContent = stats.failedCount;
  statFailedPct.textContent = t('stat.ofTotal', { n: stats.failedPercent });

  if (!stats.referralSources.length) {
    referralBody.innerHTML = `<tr><td colspan="3" style="text-align:center;color:var(--muted);padding:24px;">${t('admin.noData')}</td></tr>`;
  } else {
    referralBody.innerHTML = stats.referralSources.map((r) => `
      <tr>
        <td data-label="${t('col.source')}">${escapeHtml(r.name)}</td>
        <td data-label="${t('col.cases')}">${r.count}</td>
        <td data-label="${t('col.shareOfTotal')}">
          <div class="ref-bar">
            <div class="ref-bar__fill" style="width: ${r.percent}%"></div>
            <span class="ref-bar__label">${r.percent}%</span>
          </div>
        </td>
      </tr>`).join('');
  }

  employeeStats = stats.employees || [];
  if (!employeeStats.length) {
    employeeBody.innerHTML = `<tr><td colspan="3" style="text-align:center;color:var(--muted);padding:24px;">${t('admin.noData')}</td></tr>`;
  } else {
    employeeBody.innerHTML = employeeStats.map((e) => `
      <tr class="emp-stat-row" data-user-id="${e.userId}" style="cursor:pointer;" title="Click for details">
        <td data-label="${t('col.employee')}">${escapeHtml(e.username)}</td>
        <td data-label="${t('col.casesCreated')}">${e.totalCreated}</td>
        <td data-label="${t('col.shareOfTotal')}">
          <div class="ref-bar">
            <div class="ref-bar__fill" style="width: ${e.percent}%"></div>
            <span class="ref-bar__label">${e.percent}%</span>
          </div>
        </td>
      </tr>`).join('');
  }
}

// ─── Cases ────────────────────────────────────────────────────────────────────

async function loadCases() {
  casesLoading.hidden = false;
  casesEmpty.hidden = true;
  casesListEl.innerHTML = '';
  setError(casesError, null);

  try {
    allCases = await apiGetAdminCases();
    renderCases();
  } catch (err) {
    setError(casesError, err.message);
  } finally {
    casesLoading.hidden = true;
  }
}

function filterCases() {
  const term = searchInput.value.trim().toLowerCase();
  const userId = userFilter.value ? Number(userFilter.value) : null;
  const todayOnly = todayCheckbox.checked;

  return allCases.filter((c) => {
    if (term) {
      const nameMatch = c.name.toLowerCase().includes(term);
      const phoneMatch = `${c.phoneCountryCode}${c.phoneNumber}`.includes(term) ||
                         c.phoneNumber.includes(term);
      if (!nameMatch && !phoneMatch) return false;
    }
    if (userId !== null && c.assignedToUserId !== undefined) {
      // We don't have assignedToUserId in CaseDto, so filter by username
    }
    if (todayOnly && !isToday(c.createdAt)) return false;
    return true;
  });
}

function renderCases() {
  const term = searchInput.value.trim().toLowerCase();
  const selectedUsername = userFilter.options[userFilter.selectedIndex]?.dataset.username || '';
  const todayOnly = todayCheckbox.checked;

  const filtered = allCases.filter((c) => {
    if (term) {
      const nameMatch = c.name.toLowerCase().includes(term);
      const phoneMatch = `${c.phoneCountryCode}${c.phoneNumber}`.includes(term) ||
                         c.phoneNumber.includes(term);
      if (!nameMatch && !phoneMatch) return false;
    }
    if (selectedUsername && c.assignedToUsername !== selectedUsername) return false;
    if (todayOnly && !isToday(c.createdAt)) return false;
    return true;
  });

  if (!filtered.length) {
    casesListEl.innerHTML = '';
    casesEmpty.hidden = false;
    casesEmpty.innerHTML = allCases.length
      ? emptyStateHtml('search', t('admin.empty.cases'))
      : emptyStateHtml('inbox', t('admin.empty.noCases'));
    return;
  }

  casesEmpty.hidden = true;
  casesListEl.innerHTML = `
    <div class="users-table-wrap">
      <table class="users-table">
        <thead>
          <tr>
            <th>${t('col.name')}</th>
            <th>${t('col.phone')}</th>
            <th>${t('col.source')}</th>
            <th>${t('col.status')}</th>
            <th>${t('col.createdBy')}</th>
            <th>${t('col.assignedTo')}</th>
            <th>${t('col.created')}</th>
            <th></th>
          </tr>
        </thead>
        <tbody>${filtered.map(caseRow).join('')}</tbody>
      </table>
    </div>`;
}

function caseRow(c) {
  const meta = statusMeta(c.status);
  return `
    <tr>
      <td data-label="${t('col.name')}"><span class="name-cell"><span class="avatar-initials avatar-initials--${meta.cls}">${escapeHtml(nameInitials(c.name))}</span>${escapeHtml(c.name)}</span></td>
      <td data-label="${t('col.phone')}">${escapeHtml(formatPhone(c.phoneCountryCode, c.phoneNumber))}</td>
      <td data-label="${t('col.source')}">${escapeHtml(c.referralSource || '—')}</td>
      <td data-label="${t('col.status')}"><span class="status-pill status-pill--${meta.cls}">${meta.label}</span></td>
      <td data-label="${t('col.createdBy')}">${escapeHtml(c.createdByUsername || '—')}</td>
      <td data-label="${t('col.assignedTo')}">${escapeHtml(c.assignedToUsername || '—')}</td>
      <td data-label="${t('col.created')}">${formatDate(c.createdAt)}</td>
      <td>
        <div class="row-actions">
          <a class="btn-action" href="case.html?id=${c.id}">${t('action.view')}</a>
        </div>
      </td>
    </tr>`;
}

// ─── User filter dropdown ──────────────────────────────────────────────────────

async function loadUserFilter() {
  try {
    const users = await apiGetUsers();
    users
      .filter((u) => u.isActive)
      .sort((a, b) => a.username.localeCompare(b.username))
      .forEach((u) => {
        const opt = document.createElement('option');
        opt.value = u.id;
        opt.textContent = u.username;
        opt.dataset.username = u.username;
        userFilter.appendChild(opt);
      });
  } catch {
    // Non-critical — filter just won't be populated
  }
}

// ─── Employee modal ───────────────────────────────────────────────────────────

function openEmployeeModal(emp) {
  const pct = (n) => emp.totalCreated > 0 ? Math.round(n / emp.totalCreated * 100) : 0;

  employeeModalTitle.textContent = emp.username;
  employeeModalBody.innerHTML = `
    <div class="emp-stat-grid">
      <div class="emp-stat-item">
        <div class="emp-stat-label">${t('col.casesCreated')}</div>
        <div class="emp-stat-value">${emp.totalCreated}</div>
      </div>
      <div class="emp-stat-item emp-stat-item--success">
        <div class="emp-stat-label">${t('status.success')}</div>
        <div class="emp-stat-value">${emp.successCount}</div>
        <div class="emp-stat-sub">${t('stat.ofCreated', { n: pct(emp.successCount) })}</div>
      </div>
      <div class="emp-stat-item emp-stat-item--failed">
        <div class="emp-stat-label">${t('status.failed')}</div>
        <div class="emp-stat-value">${emp.failedCount}</div>
        <div class="emp-stat-sub">${t('stat.ofCreated', { n: pct(emp.failedCount) })}</div>
      </div>
    </div>`;
  employeeModal.hidden = false;
}

document.getElementById('employee-stats-body').addEventListener('click', (e) => {
  const row = e.target.closest('.emp-stat-row');
  if (!row) return;
  const userId = Number(row.dataset.userId);
  const emp = employeeStats.find((s) => s.userId === userId);
  if (emp) openEmployeeModal(emp);
});

document.addEventListener('click', (e) => {
  if (e.target.dataset.closeModal === 'employee-modal' || e.target === employeeModal) {
    employeeModal.hidden = true;
  }
});

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && !employeeModal.hidden) employeeModal.hidden = true;
});

// ─── Event listeners ──────────────────────────────────────────────────────────

searchInput.addEventListener('input', debounce(renderCases));
userFilter.addEventListener('change', renderCases);
todayCheckbox.addEventListener('change', renderCases);

// ─── Init ─────────────────────────────────────────────────────────────────────

if (isAdmin) {
  loadStats();
  loadCases();
  loadUserFilter();
}
