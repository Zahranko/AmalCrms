if (session && session.role !== 'Admin') {
  window.location.href = 'dashboard.html';
}

const RESOURCES = {
  department: {
    label: 'Department',
    subtitleKey: 'manageLists.desc.departments',
    emptyKey: 'manageLists.empty.departments',
    addKey: 'listItem.addDept',
    editKey: 'listItem.editDept',
    getAll: apiGetDepartmentsManage,
    create: apiCreateDepartment,
    update: apiUpdateDepartment,
    setStatus: apiSetDepartmentStatus,
    cache: [],
    loaded: false
  },
  referral: {
    label: 'Referral Source',
    subtitleKey: 'manageLists.desc.referralSources',
    emptyKey: 'manageLists.empty.referralSources',
    addKey: 'listItem.addRef',
    editKey: 'listItem.editRef',
    getAll: apiGetReferralSourcesManage,
    create: apiCreateReferralSource,
    update: apiUpdateReferralSource,
    setStatus: apiSetReferralSourceStatus,
    cache: [],
    loaded: false
  },
  doctor: {
    label: 'Doctor',
    subtitleKey: 'manageLists.desc.doctors',
    emptyKey: 'manageLists.empty.doctors',
    addKey: 'listItem.addDoctor',
    editKey: 'listItem.editDoctor',
    getAll: apiGetDoctorsManage,
    create: apiCreateDoctor,
    update: apiUpdateDoctor,
    setStatus: apiSetDoctorStatus,
    cache: [],
    loaded: false
  },
  procedure: {
    label: 'Procedure',
    subtitleKey: 'manageLists.desc.procedures',
    emptyKey: 'manageLists.empty.procedures',
    addKey: 'listItem.addProc',
    editKey: 'listItem.editProc',
    getAll: apiGetProceduresManage,
    create: apiCreateProcedure,
    update: apiUpdateProcedure,
    setStatus: apiSetProcedureStatus,
    cache: [],
    loaded: false
  }
};

let activeTab = 'department';
let searchTerm = '';

const tabsEl = document.getElementById('lists-tabs');
const subtitleEl = document.getElementById('lists-subtitle');
const searchInput = document.getElementById('lists-search');
const tableEl = document.getElementById('lists-table');
const theadEl = document.getElementById('lists-thead');
const tbodyEl = document.getElementById('lists-table-body');
const loadingEl = document.getElementById('lists-loading');
const emptyEl = document.getElementById('lists-empty');
const errorEl = document.getElementById('lists-error');
const countEl = document.getElementById('lists-count');
const addBtn = document.getElementById('add-btn');

function activeResource() {
  return RESOURCES[activeTab];
}

function escapeHtml(value) {
  const div = document.createElement('div');
  div.textContent = value ?? '';
  return div.innerHTML;
}

function setError(message) {
  if (!message) {
    errorEl.hidden = true;
    errorEl.textContent = '';
    return;
  }
  errorEl.hidden = false;
  errorEl.textContent = message;
}

async function loadActive() {
  const r = activeResource();
  subtitleEl.textContent = t(r.subtitleKey);
  setError(null);

  if (r.loaded) {
    render();
    return;
  }

  loadingEl.hidden = false;
  tableEl.hidden = true;
  emptyEl.hidden = true;
  countEl.textContent = '';

  try {
    r.cache = await r.getAll();
    r.loaded = true;
    render();
  } catch (err) {
    setError(err.message);
  } finally {
    loadingEl.hidden = true;
  }
}

function filterItems(items) {
  const term = searchTerm.trim().toLowerCase();
  if (!term) return items;
  return items.filter((i) => (i.name || '').toLowerCase().includes(term));
}

function render() {
  const r = activeResource();
  loadingEl.hidden = true;

  theadEl.innerHTML = `
    <tr>
      <th>${t('manageLists.colName')}</th>
      <th>${t('manageLists.colStatus')}</th>
      <th></th>
    </tr>`;

  const filtered = filterItems(r.cache);

  if (!filtered.length) {
    tableEl.hidden = true;
    emptyEl.hidden = false;
    emptyEl.textContent = r.cache.length
      ? t('manageLists.empty.search')
      : t(r.emptyKey);
    countEl.textContent = '';
    return;
  }

  emptyEl.hidden = true;
  tableEl.hidden = false;
  tbodyEl.innerHTML = filtered.map((item) => itemRowTemplate(item)).join('');
  countEl.textContent = t('manageLists.showing', { n: filtered.length, total: r.cache.length });

  tbodyEl.querySelectorAll('[data-action="edit"]').forEach((btn) =>
    btn.addEventListener('click', () => openItemModal(activeTab, findItem(btn.dataset.id)))
  );
  tbodyEl.querySelectorAll('[data-action="toggle-status"]').forEach((btn) =>
    btn.addEventListener('click', () => handleToggleStatus(findItem(btn.dataset.id)))
  );
}

function findItem(id) {
  return activeResource().cache.find((i) => String(i.id) === String(id));
}

function itemRowTemplate(item) {
  const statusClass = item.isActive ? 'status-pill--active' : 'status-pill--inactive';
  const statusLabel = item.isActive ? t('state.active') : t('state.disabled');
  const toggleLabel = item.isActive ? t('action.disable') : t('action.enable');
  const toggleClass = item.isActive ? 'btn-action btn-action--danger' : 'btn-action';

  return `
    <tr>
      <td data-label="${t('manageLists.colName')}">${escapeHtml(item.name)}</td>
      <td data-label="${t('manageLists.colStatus')}"><span class="status-pill ${statusClass}">${statusLabel}</span></td>
      <td data-label="Actions">
        <div class="row-actions">
          <button type="button" class="btn-action" data-action="edit" data-id="${item.id}">${t('action.edit')}</button>
          <button type="button" class="${toggleClass}" data-action="toggle-status" data-id="${item.id}">${toggleLabel}</button>
        </div>
      </td>
    </tr>
  `;
}

// ---------- Tabs + search ----------

tabsEl.addEventListener('click', (e) => {
  const button = e.target.closest('.seg');
  if (!button) return;
  activeTab = button.dataset.tab;
  tabsEl.querySelectorAll('.seg').forEach((b) => b.classList.toggle('seg--active', b === button));
  searchTerm = '';
  searchInput.value = '';
  searchInput.placeholder = t('manageLists.searchPlaceholder');
  loadActive();
});

searchInput.addEventListener('input', () => {
  searchTerm = searchInput.value;
  render();
});

addBtn.addEventListener('click', () => openItemModal(activeTab, null));

// ---------- Add/edit modal ----------

const listItemModal = document.getElementById('list-item-modal');
const listItemForm = document.getElementById('list-item-form');
const listItemModalTitle = document.getElementById('list-item-modal-title');
const listItemNameInput = document.getElementById('list-item-name');
const listItemFormError = document.getElementById('list-item-form-error');
const listItemFormSubmit = document.getElementById('list-item-form-submit');

let editingItemId = null;

document.getElementById('list-item-modal-close').addEventListener('click', closeItemModal);
document.getElementById('list-item-modal-cancel').addEventListener('click', closeItemModal);
listItemModal.addEventListener('click', (e) => {
  if (e.target === listItemModal) closeItemModal();
});

function openItemModal(key, item) {
  activeTab = key;
  editingItemId = item ? item.id : null;
  listItemForm.reset();
  setFormError(listItemFormError, null);

  const resource = RESOURCES[key];
  listItemModalTitle.textContent = item ? t(resource.editKey) : t(resource.addKey);
  listItemNameInput.value = item ? item.name : '';

  listItemModal.hidden = false;
  listItemNameInput.focus();
}

function closeItemModal() {
  listItemModal.hidden = true;
}

listItemForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setFormError(listItemFormError, null);

  const name = listItemNameInput.value.trim();
  const r = RESOURCES[activeTab];

  setSubmitLoading(listItemFormSubmit, true, t('action.save'));
  try {
    if (editingItemId) {
      const updated = await r.update(editingItemId, { name });
      const index = r.cache.findIndex((i) => i.id === updated.id);
      if (index !== -1) r.cache[index] = updated;
    } else {
      const created = await r.create({ name });
      r.cache.push(created);
    }
    render();
    closeItemModal();
  } catch (err) {
    setFormError(listItemFormError, err.message);
  } finally {
    setSubmitLoading(listItemFormSubmit, false, t('action.save'));
  }
});

// ---------- Status confirm modal ----------

const confirmModal = document.getElementById('confirm-modal');
const confirmModalMessage = document.getElementById('confirm-modal-message');
const confirmModalError = document.getElementById('confirm-modal-error');
const confirmModalAccept = document.getElementById('confirm-modal-accept');
let pendingStatusChange = null;

document.getElementById('confirm-modal-close').addEventListener('click', closeConfirmModal);
document.getElementById('confirm-modal-cancel').addEventListener('click', closeConfirmModal);
confirmModal.addEventListener('click', (e) => {
  if (e.target === confirmModal) closeConfirmModal();
});

function handleToggleStatus(item) {
  const nextIsActive = !item.isActive;
  pendingStatusChange = { id: item.id, isActive: nextIsActive };

  confirmModalMessage.textContent = nextIsActive
    ? t('confirm.enable', { name: item.name })
    : t('confirm.disable', { name: item.name });
  setFormError(confirmModalError, null);
  confirmModal.hidden = false;
}

function closeConfirmModal() {
  confirmModal.hidden = true;
  pendingStatusChange = null;
}

confirmModalAccept.addEventListener('click', async () => {
  if (!pendingStatusChange) return;
  setFormError(confirmModalError, null);

  const { id, isActive } = pendingStatusChange;
  const r = activeResource();

  try {
    await r.setStatus(id, isActive);
    const item = findItem(id);
    if (item) item.isActive = isActive;
    render();
    closeConfirmModal();
  } catch (err) {
    setFormError(confirmModalError, err.message);
  }
});

// ---------- Shared helpers ----------

function setFormError(element, message) {
  if (!message) {
    element.hidden = true;
    element.textContent = '';
    return;
  }
  element.hidden = false;
  element.textContent = message;
}

function setSubmitLoading(button, isLoading, label) {
  const labelEl = button.querySelector('.btn-submit__label');
  const spinnerEl = button.querySelector('.btn-submit__spinner');
  button.disabled = isLoading;
  labelEl.textContent = isLoading ? t('action.saving') : label;
  spinnerEl.hidden = !isLoading;
}

// ---------- Init ----------

if (session && session.role === 'Admin') {
  searchInput.placeholder = t('manageLists.searchPlaceholder');
  loadActive();
}
