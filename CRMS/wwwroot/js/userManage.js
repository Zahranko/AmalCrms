if (session && session.role !== 'Admin') {
  window.location.href = 'dashboard.html';
}

// ---------- Users table ----------

let usersCache = [];
let editingUserId = null;

const usersTable = document.getElementById('users-table');
const usersTableBody = document.getElementById('users-table-body');
const usersLoading = document.getElementById('users-loading');
const usersEmpty = document.getElementById('users-empty');
const usersError = document.getElementById('users-error');

async function loadUsers() {
  usersLoading.hidden = false;
  usersTable.hidden = true;
  usersEmpty.hidden = true;
  setUsersError(null);

  try {
    usersCache = await apiGetUsers();
    renderUsersTable(usersCache);
  } catch (err) {
    setUsersError(err.message);
  } finally {
    usersLoading.hidden = true;
  }
}

function setUsersError(message) {
  if (!message) {
    usersError.hidden = true;
    usersError.textContent = '';
    return;
  }
  usersError.hidden = false;
  usersError.textContent = message;
}

function renderUsersTable(users) {
  if (!users.length) {
    usersTable.hidden = true;
    usersEmpty.hidden = false;
    usersEmpty.innerHTML = emptyStateHtml('users', t('users.empty'));
    return;
  }

  usersTable.hidden = false;
  usersEmpty.hidden = true;
  usersTableBody.innerHTML = users.map(rowTemplate).join('');

  usersTableBody.querySelectorAll('[data-action="edit"]').forEach((btn) =>
    btn.addEventListener('click', () => openUserModal(findUser(btn.dataset.id)))
  );
  usersTableBody.querySelectorAll('[data-action="reset-password"]').forEach((btn) =>
    btn.addEventListener('click', () => openPasswordModal(findUser(btn.dataset.id)))
  );
  usersTableBody.querySelectorAll('[data-action="toggle-status"]').forEach((btn) =>
    btn.addEventListener('click', () => handleToggleStatus(findUser(btn.dataset.id)))
  );
}

function findUser(id) {
  return usersCache.find((u) => String(u.id) === String(id));
}

function rowTemplate(user) {
  const createdAt = new Date(user.createdAt).toLocaleDateString();
  const statusClass = user.isActive ? 'status-pill--active' : 'status-pill--inactive';
  const statusLabel = user.isActive ? t('state.active') : t('state.disabled');
  const isSelf = session.username === user.username;
  const toggleLabel = user.isActive ? t('action.disable') : t('action.enable');
  const toggleClass = user.isActive ? 'btn-action btn-action--danger' : 'btn-action';

  return `
    <tr>
      <td data-label="${t('col.username')}">${escapeHtml(user.username)}</td>
      <td data-label="${t('col.role')}">${escapeHtml(roleLabel(user.role))}</td>
      <td data-label="${t('col.status')}"><span class="status-pill ${statusClass}">${statusLabel}</span></td>
      <td data-label="${t('col.created')}">${createdAt}</td>
      <td data-label="Actions">
        <div class="row-actions">
          <button type="button" class="btn-action" data-action="edit" data-id="${user.id}">${t('action.edit')}</button>
          <button type="button" class="btn-action" data-action="reset-password" data-id="${user.id}">${t('action.resetPassword')}</button>
          <button type="button" class="${toggleClass}" data-action="toggle-status" data-id="${user.id}" ${isSelf && user.isActive ? `disabled title="${t('users.selfDisableTooltip')}"` : ''}>${toggleLabel}</button>
        </div>
      </td>
    </tr>
  `;
}

// ---------- User create/edit modal ----------

const userModal = document.getElementById('user-modal');
const userForm = document.getElementById('user-form');
const userModalTitle = document.getElementById('user-modal-title');
const userUsernameInput = document.getElementById('user-username');
const userPasswordField = document.getElementById('user-password-field');
const userPasswordInput = document.getElementById('user-password');
const userRoleInput = document.getElementById('user-role');
const userNotifyField = document.getElementById('user-notify-field');
const userNotifyInput = document.getElementById('user-notify-new-case');
const userWebsitesField = document.getElementById('user-websites-field');
const userWebsitesList = document.getElementById('user-websites-list');
const userWebsitesAdminNote = document.getElementById('user-websites-admin-note');
const userWebsitesEmpty = document.getElementById('user-websites-empty');
const userFormError = document.getElementById('user-form-error');
const userFormSubmit = document.getElementById('user-form-submit');

// All websites the admin can assign access to (Admin sees every website).
let allWebsites = [];

// Render one checkbox per website, pre-checking the given ids.
function renderWebsiteCheckboxes(selectedIds) {
  const selected = new Set((selectedIds || []).map(Number));
  userWebsitesEmpty.hidden = allWebsites.length > 0;
  userWebsitesList.innerHTML = allWebsites
    .map(
      (w) => `
      <label class="checkbox-label">
        <input type="checkbox" class="user-website-cb" value="${w.id}" ${selected.has(w.id) ? 'checked' : ''} />
        <span>${escapeHtml(websiteName(w))}</span>
      </label>`
    )
    .join('');
}

// Admins have implicit all-access, so the per-website checkboxes only apply to
// the other roles.
function syncWebsiteFieldForRole() {
  const isAdmin = userRoleInput.value === 'Admin';
  userWebsitesList.hidden = isAdmin;
  userWebsitesEmpty.hidden = isAdmin || allWebsites.length > 0;
  userWebsitesAdminNote.hidden = !isAdmin;
}

function selectedWebsiteIds() {
  return [...userWebsitesList.querySelectorAll('.user-website-cb:checked')].map((cb) => Number(cb.value));
}

document.getElementById('add-user-btn').addEventListener('click', () => openUserModal(null));
userRoleInput.addEventListener('change', syncWebsiteFieldForRole);
document.getElementById('user-modal-close').addEventListener('click', closeUserModal);
document.getElementById('user-modal-cancel').addEventListener('click', closeUserModal);
userModal.addEventListener('click', (e) => {
  if (e.target === userModal) closeUserModal();
});

function openUserModal(user) {
  editingUserId = user ? user.id : null;
  userForm.reset();
  setFormError(userFormError, null);

  if (user) {
    userModalTitle.textContent = t('userForm.editTitle');
    userUsernameInput.value = user.username;
    userRoleInput.value = user.role;
    userNotifyInput.checked = !!user.notifyOnNewCase;
    userPasswordField.hidden = true;
    userPasswordInput.required = false;
    userNotifyField.hidden = false;
    renderWebsiteCheckboxes(user.websiteIds || []);
  } else {
    userModalTitle.textContent = t('userForm.addTitle');
    userRoleInput.value = 'Employee';
    userNotifyInput.checked = false;
    userPasswordField.hidden = false;
    userPasswordInput.required = true;
    userNotifyField.hidden = true;
    // Default a new user's access to the website the admin is currently in.
    const active = getActiveWebsite();
    renderWebsiteCheckboxes(active ? [active.id] : []);
  }

  syncWebsiteFieldForRole();
  userModal.hidden = false;
  userUsernameInput.focus();
}

function closeUserModal() {
  userModal.hidden = true;
}

userForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setFormError(userFormError, null);

  const username = userUsernameInput.value.trim();
  const role = userRoleInput.value;
  const password = userPasswordInput.value;
  // Admins are all-access, so their explicit membership list is irrelevant.
  const websiteIds = role === 'Admin' ? [] : selectedWebsiteIds();

  setSubmitLoading(userFormSubmit, true, t('action.save'));
  try {
    if (editingUserId) {
      const updated = await apiUpdateUser(editingUserId, { username, role, notifyOnNewCase: userNotifyInput.checked, websiteIds });
      replaceUserInCache(updated);
    } else {
      const created = await apiCreateUser({ username, password, role, websiteIds });
      usersCache.push(created);
    }
    renderUsersTable(usersCache);
    closeUserModal();
  } catch (err) {
    setFormError(userFormError, err.message);
  } finally {
    setSubmitLoading(userFormSubmit, false, t('action.save'));
  }
});

function replaceUserInCache(updated) {
  const index = usersCache.findIndex((u) => u.id === updated.id);
  if (index !== -1) usersCache[index] = updated;
}

// ---------- Reset password modal ----------

const passwordModal = document.getElementById('password-modal');
const passwordForm = document.getElementById('password-form');
const passwordModalUsername = document.getElementById('password-modal-username');
const newPasswordInput = document.getElementById('new-password');
const passwordFormError = document.getElementById('password-form-error');
const passwordFormSubmit = document.getElementById('password-form-submit');
let resettingUserId = null;

document.getElementById('password-modal-close').addEventListener('click', closePasswordModal);
document.getElementById('password-modal-cancel').addEventListener('click', closePasswordModal);
passwordModal.addEventListener('click', (e) => {
  if (e.target === passwordModal) closePasswordModal();
});

function openPasswordModal(user) {
  resettingUserId = user.id;
  passwordForm.reset();
  setFormError(passwordFormError, null);
  passwordModalUsername.textContent = user.username;
  passwordModal.hidden = false;
  newPasswordInput.focus();
}

function closePasswordModal() {
  passwordModal.hidden = true;
}

passwordForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setFormError(passwordFormError, null);

  setSubmitLoading(passwordFormSubmit, true, t('action.resetPassword'));
  try {
    await apiResetPassword(resettingUserId, newPasswordInput.value);
    closePasswordModal();
  } catch (err) {
    setFormError(passwordFormError, err.message);
  } finally {
    setSubmitLoading(passwordFormSubmit, false, t('action.resetPassword'));
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

function handleToggleStatus(user) {
  const nextIsActive = !user.isActive;
  pendingStatusChange = { id: user.id, isActive: nextIsActive };

  confirmModalMessage.textContent = nextIsActive
    ? t('confirmUser.enableMsg', { username: user.username })
    : t('confirmUser.disableMsg', { username: user.username });
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

  try {
    await apiSetUserStatus(pendingStatusChange.id, pendingStatusChange.isActive);
    const user = findUser(pendingStatusChange.id);
    if (user) user.isActive = pendingStatusChange.isActive;
    renderUsersTable(usersCache);
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

async function loadWebsites() {
  try {
    allWebsites = await apiGetMyWebsites();
  } catch {
    allWebsites = getAccessibleWebsites();
  }
}

if (session && session.role === 'Admin') {
  loadWebsites().then(loadUsers);
}
