// Reads the global `session` declared by nav.js — do not redeclare it here
// (a top-level `const session` collision with nav.js is exactly the bug that
// broke cases.js on every case-list page earlier).

const quickFiltersEl = document.getElementById('hm-quick-filters');
const customRangeEl = document.getElementById('hm-custom-range');
const fromInput = document.getElementById('hm-from');
const toInput = document.getElementById('hm-to');
const applyRangeBtn = document.getElementById('hm-apply-range');
const periodLabelEl = document.getElementById('hm-period-label');

const errorEl = document.getElementById('hm-error');
const loadingEl = document.getElementById('hm-loading');
const contentEl = document.getElementById('hm-content');

const statTotalEl = document.getElementById('hm-stat-total');
const statSuccessEl = document.getElementById('hm-stat-success');
const statSuccessPctEl = document.getElementById('hm-stat-success-pct');
const statFailedEl = document.getElementById('hm-stat-failed');
const statFailedPctEl = document.getElementById('hm-stat-failed-pct');

const departmentsEl = document.getElementById('hm-departments');
const departmentsEmptyEl = document.getElementById('hm-departments-empty');
const doctorsEl = document.getElementById('hm-doctors');
const doctorsEmptyEl = document.getElementById('hm-doctors-empty');

const exportBtn = document.getElementById('hm-export-btn');
const printBtn = document.getElementById('hm-print-btn');

let currentFrom = null;
let currentTo = null;

function escapeHtml(value) {
  const div = document.createElement('div');
  div.textContent = value ?? '';
  return div.innerHTML;
}

function formatDateInput(date) {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function rangeForQuickFilter(range) {
  const now = new Date();
  if (range === 'month') {
    return { from: formatDateInput(new Date(now.getFullYear(), now.getMonth(), 1)), to: formatDateInput(now) };
  }
  if (range === 'lastMonth') {
    const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0);
    return { from: formatDateInput(lastMonthStart), to: formatDateInput(lastMonthEnd) };
  }
  return { from: null, to: null }; // all time
}

function setError(message) {
  if (!message) { errorEl.hidden = true; errorEl.textContent = ''; return; }
  errorEl.hidden = false;
  errorEl.textContent = message;
}

function rateBadgeClass(rate) {
  if (rate >= 60) return 'hm-rate-badge--high';
  if (rate >= 30) return 'hm-rate-badge--mid';
  return 'hm-rate-badge--low';
}

function renderPeriodLabel() {
  const label = !currentFrom && !currentTo
    ? t('hospitalManager.allTime')
    : `${currentFrom || t('hospitalManager.allTime')} – ${currentTo || t('hospitalManager.allTime')}`;
  periodLabelEl.textContent = `${t('hospitalManager.reportPeriod')}: ${label}`;
}

function cardTemplate(item) {
  return `
    <div class="hm-card">
      <div class="hm-card__name">${escapeHtml(item.name)}</div>
      <div>
        <div class="hm-card__count">${item.totalCases}</div>
        <div class="hm-card__count-label">${t('hospitalManager.tickets')}</div>
      </div>
      <span class="hm-rate-badge ${rateBadgeClass(item.successRate)}">${item.successRate}%</span>
      <div class="hm-card__breakdown">${t('status.success')}: ${item.successCount} · ${t('status.failed')}: ${item.failedCount}</div>
    </div>`;
}

function renderCardGrid(container, emptyEl, items) {
  if (!items.length) {
    container.innerHTML = '';
    emptyEl.hidden = false;
    return;
  }
  emptyEl.hidden = true;
  container.innerHTML = items.map(cardTemplate).join('');
}

function render(stats) {
  statTotalEl.textContent = stats.totalCases;
  statSuccessEl.textContent = stats.successCount;
  statSuccessPctEl.textContent = t('stat.ofTotal', { n: stats.successPercent });
  statFailedEl.textContent = stats.failedCount;
  statFailedPctEl.textContent = t('stat.ofTotal', { n: stats.failedPercent });

  renderCardGrid(departmentsEl, departmentsEmptyEl, stats.departments);
  renderCardGrid(doctorsEl, doctorsEmptyEl, stats.doctors);
}

async function loadStats() {
  loadingEl.hidden = false;
  contentEl.hidden = true;
  setError(null);
  renderPeriodLabel();

  try {
    const stats = await apiGetHospitalManagerStats(currentFrom, currentTo);
    render(stats);
    contentEl.hidden = false;
  } catch (err) {
    setError(err.message);
  } finally {
    loadingEl.hidden = true;
  }
}

quickFiltersEl.querySelectorAll('.seg-btn').forEach((btn) => {
  btn.addEventListener('click', () => {
    quickFiltersEl.querySelectorAll('.seg-btn').forEach((b) => b.classList.remove('seg-btn--active'));
    btn.classList.add('seg-btn--active');

    const range = btn.dataset.range;
    if (range === 'custom') {
      customRangeEl.hidden = false;
      return;
    }
    customRangeEl.hidden = true;
    const { from, to } = rangeForQuickFilter(range);
    currentFrom = from;
    currentTo = to;
    loadStats();
  });
});

applyRangeBtn.addEventListener('click', () => {
  currentFrom = fromInput.value || null;
  currentTo = toInput.value || null;
  loadStats();
});

exportBtn.addEventListener('click', async () => {
  exportBtn.disabled = true;
  try {
    await apiExportHospitalManagerStats(currentFrom, currentTo);
  } catch (err) {
    setError(err.message);
  } finally {
    exportBtn.disabled = false;
  }
});

printBtn.addEventListener('click', () => window.print());

// Default to "This Month" on load.
const initial = rangeForQuickFilter('month');
currentFrom = initial.from;
currentTo = initial.to;
loadStats();
