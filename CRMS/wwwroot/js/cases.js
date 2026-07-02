const CASE_VIEW = window.CASE_VIEW || 'all';
const caseListSession = getSession();

const VIEW_CONFIG = {
  all: {
    fetch: apiGetAllCases,
    emptyKey: 'cases.empty.all',
    showAssignedTo: true
  },
  mine: {
    fetch: apiGetMyCases,
    emptyKey: 'cases.empty.mine',
    showAssignedTo: false
  },
  in: {
    fetch: apiGetForwardedToMe,
    emptyKey: 'forwardedIn.empty',
    showAssignedTo: true
  },
  out: {
    fetch: apiGetForwardedByMe,
    emptyKey: 'forwardedOut.empty',
    showAssignedTo: true
  }
};

const STATUS_META = {
  Pending: { label: t('status.pending'), cls: 'pending' },
  Waiting: { label: t('status.waiting'), cls: 'waiting' },
  Success: { label: t('status.success'), cls: 'success' },
  Failed: { label: t('status.failed'), cls: 'failed' }
};

const listEl = document.getElementById('cases-list');
const loading = document.getElementById('cases-loading');
const emptyState = document.getElementById('cases-empty');
const errorBox = document.getElementById('cases-error');

let currentView = CASE_VIEW === 'in' || CASE_VIEW === 'out' ? CASE_VIEW : 'all';
let currentCases = [];
let searchTerm = '';

function escapeHtml(value) {
  const div = document.createElement('div');
  div.textContent = value ?? '';
  return div.innerHTML;
}

function setError(message) {
  if (!message) { errorBox.hidden = true; errorBox.textContent = ''; return; }
  errorBox.hidden = false;
  errorBox.textContent = message;
}

function statusMeta(status) {
  return STATUS_META[status] || { label: status, cls: 'pending' };
}

function filterCases(cases) {
  const term = searchTerm.trim().toLowerCase();
  if (!term) return cases;
  return cases.filter((c) => {
    const name = c.name.toLowerCase();
    const phoneSpaced = `${c.phoneCountryCode} ${c.phoneNumber}`.toLowerCase();
    const phoneJoined = `${c.phoneCountryCode}${c.phoneNumber}`.toLowerCase();
    return name.includes(term) || phoneSpaced.includes(term) || phoneJoined.includes(term);
  });
}

async function loadCases() {
  loading.hidden = false;
  emptyState.hidden = true;
  listEl.innerHTML = '';
  setError(null);

  try {
    currentCases = await VIEW_CONFIG[currentView].fetch();
    renderList();
  } catch (err) {
    setError(err.message);
  } finally {
    loading.hidden = true;
  }
}

function renderList() {
  const config = VIEW_CONFIG[currentView];
  const filtered = filterCases(currentCases);

  if (!filtered.length) {
    listEl.innerHTML = '';
    emptyState.hidden = false;
    emptyState.textContent = currentCases.length ? t('cases.empty.search') : t(config.emptyKey);
    return;
  }

  emptyState.hidden = true;
  const assignedCol = config.showAssignedTo ? `<th>${t('col.assignedTo')}</th>` : '';
  listEl.innerHTML = `
    <div class="users-table-wrap">
      <table class="users-table">
        <thead>
          <tr>
            <th>${t('col.name')}</th>
            <th>${t('col.department')}</th>
            <th>${t('col.phone')}</th>
            ${assignedCol}
            <th>${t('col.status')}</th>
            <th></th>
          </tr>
        </thead>
        <tbody>${filtered.map((c) => rowTemplate(c, config)).join('')}</tbody>
      </table>
    </div>`;

  // Accept / Decline on the "forwarded to me" view (pending cases only)
  listEl.querySelectorAll('button[data-action]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const id = Number(btn.dataset.id);
      const action = btn.dataset.action;
      btn.disabled = true;
      try {
        if (action === 'accept') {
          await apiAcceptForward(id);
          window.location.href = `case.html?id=${id}`;
        } else if (action === 'decline') {
          await apiDeclineForward(id);
          await loadCases();
        }
      } catch (err) {
        setError(err.message);
        btn.disabled = false;
      }
    });
  });
}

function rowTemplate(c, config) {
  const meta = statusMeta(c.status);
  const assignedCell = config.showAssignedTo
    ? `<td data-label="${t('col.assignedTo')}">${escapeHtml(c.assignedToUsername || '—')}</td>`
    : '';

  // "Forwarded to Me" view:
  //   - isPending: case has a pending forward (hasPendingForward = true, so current user hasn't accepted yet)
  //   - isReforward: the case was originally MINE before (forwardedByUsername == me) — show actual status, no "Forwarded" badge
  const isPendingIn = currentView === 'in' && c.hasPendingForward;
  const isReforward = isPendingIn && c.forwardedByUsername === caseListSession?.username;

  let actionsCell;
  if (isPendingIn) {
    actionsCell = `<div class="row-actions">
      <a class="btn-action" href="case.html?id=${c.id}">${t('action.view')}</a>
      <button type="button" class="btn-action btn-action--success" data-action="accept" data-id="${c.id}">${t('action.accept')}</button>
      <button type="button" class="btn-action btn-action--danger" data-action="decline" data-id="${c.id}">${t('action.decline')}</button>
    </div>`;
  } else {
    actionsCell = `<div class="row-actions"><a class="btn-action" href="case.html?id=${c.id}">${t('action.view')}</a></div>`;
  }

  // Forward state badge
  let forwardBadge = '';
  if (currentView === 'in' && isPendingIn && !isReforward) {
    // Normal pending forward to me — show "Forwarded" label
    forwardBadge = `<span class="status-pill status-pill--forwarded" title="${t('badge.from')} ${escapeHtml(c.assignedToUsername || '?')}">${t('badge.forwarded')}</span> `;
  } else if (currentView === 'out' && c.forwardedToUsername) {
    forwardBadge = `<span class="status-pill status-pill--forwarded" title="${t('badge.pending')} — ${t('action.forward').toLowerCase()} ${escapeHtml(c.forwardedToUsername)}">${t('badge.pending')}</span> `;
  } else if (currentView === 'out' && c.forwardedByUsername) {
    forwardBadge = `<span class="status-pill status-pill--forwarded" title="${t('badge.transferred')} ${escapeHtml(c.assignedToUsername || '?')}">${t('badge.transferred')}</span> `;
  }

  return `
    <tr data-id="${c.id}">
      <td data-label="${t('col.name')}">${escapeHtml(c.name)}</td>
      <td data-label="${t('col.department')}">${escapeHtml(c.department || '—')}</td>
      <td data-label="${t('col.phone')}">${escapeHtml(formatPhone(c.phoneCountryCode, c.phoneNumber))}</td>
      ${assignedCell}
      <td data-label="${t('col.status')}">${forwardBadge}<span class="status-pill status-pill--${meta.cls}">${meta.label}</span></td>
      <td>${actionsCell}</td>
    </tr>`;
}

// ---------- Toolbar: toggle + search ----------

function setupToolbar() {
  const toolbar = document.createElement('div');
  toolbar.className = 'cases-toolbar';

  const toggleHtml = (CASE_VIEW === 'in' || CASE_VIEW === 'out') ? '' : `
    <div class="cases-view-toggle">
      <button type="button" class="seg-btn seg-btn--active" data-view="all">All Cases</button>
      <button type="button" class="seg-btn" data-view="mine">My Cases</button>
    </div>`;

  toolbar.innerHTML = `
    ${toggleHtml}
    <div class="cases-search field">
      <div class="field__control">
        <input type="search" id="cases-search-input" placeholder="Search by name or phone…" autocomplete="off" />
      </div>
    </div>`;
  listEl.parentNode.insertBefore(toolbar, listEl);

  if (CASE_VIEW !== 'in' && CASE_VIEW !== 'out') {
    toolbar.querySelectorAll('.seg-btn').forEach((btn) => {
      btn.addEventListener('click', () => {
        const view = btn.dataset.view;
        if (view === currentView) return;
        currentView = view;
        toolbar.querySelectorAll('.seg-btn').forEach((b) => b.classList.remove('seg-btn--active'));
        btn.classList.add('seg-btn--active');
        searchTerm = '';
        toolbar.querySelector('#cases-search-input').value = '';
        loadCases();
      });
    });
  }

  toolbar.querySelector('#cases-search-input').addEventListener('input', (e) => {
    searchTerm = e.target.value;
    renderList();
  });
}

setupToolbar();
loadCases();
