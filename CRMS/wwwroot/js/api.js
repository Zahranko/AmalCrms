const API_BASE_URL = '/api';

async function apiLogin(username, password) {
  const response = await fetch(`${API_BASE_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password })
  });

  const data = await response.json().catch(() => null);

  if (!response.ok) {
    const message = data?.message || 'Invalid username or password.';
    throw new Error(message);
  }

  return data;
}

function saveSession(session) {
  localStorage.setItem('crms.token', session.token);
  localStorage.setItem('crms.username', session.username);
  localStorage.setItem('crms.role', session.role);
  localStorage.setItem('crms.expiresAt', session.expiresAt);
  localStorage.setItem('crms.websites', JSON.stringify(session.websites || []));
}

function getSession() {
  const token = localStorage.getItem('crms.token');
  if (!token) return null;

  let websites = [];
  try {
    websites = JSON.parse(localStorage.getItem('crms.websites') || '[]');
  } catch {
    websites = [];
  }

  return {
    token,
    username: localStorage.getItem('crms.username'),
    role: localStorage.getItem('crms.role'),
    expiresAt: localStorage.getItem('crms.expiresAt'),
    websites
  };
}

function clearSession() {
  ['crms.token', 'crms.username', 'crms.role', 'crms.expiresAt', 'crms.websites', 'crms.activeWebsite']
    .forEach((k) => localStorage.removeItem(k));
}

// ---------- Active website (multi-website) ----------
// The websites a user may enter come back in the login response; the one they're
// currently working in is stored separately and sent as X-Website-Id on every
// API call so the backend scopes data to it.

function getAccessibleWebsites() {
  const session = getSession();
  return session ? session.websites || [] : [];
}

function getActiveWebsite() {
  try {
    const raw = localStorage.getItem('crms.activeWebsite');
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function setActiveWebsite(website) {
  localStorage.setItem('crms.activeWebsite', JSON.stringify(website));
}

function getActiveWebsiteKey() {
  const w = getActiveWebsite();
  return w ? w.key : null;
}

// Localized display name for a website (falls back across languages). getLang is
// provided by i18n.js, which loads before api.js on every page.
function websiteName(website) {
  if (!website) return '';
  const ar = typeof getLang === 'function' && getLang() === 'ar';
  return ar ? website.nameAr || website.nameEn : website.nameEn || website.nameAr;
}

// Where to land inside the active website: Contact is a placeholder page; the
// CRM routes by role. No active website yet → the picker.
function homePage() {
  const w = getActiveWebsite();
  if (!w) return 'websitePicker.html';
  if (w.key === 'contact') return 'contact.html';
  const role = localStorage.getItem('crms.role');
  return role === 'HospitalManager' ? 'hospitalManagerDashboard.html' : 'dashboard.html';
}

// Post-login / post-picker routing. Returns the URL to go to, or null if the
// user has no website access at all (caller should show a message).
function routeIntoApp(session) {
  const websites = (session && session.websites) || [];
  if (websites.length === 0) return null;
  if (websites.length === 1) {
    setActiveWebsite(websites[0]);
    return homePage();
  }
  const active = getActiveWebsite();
  if (active && websites.some((w) => w.id === active.id)) return homePage();
  return 'websitePicker.html';
}

function extractErrorMessage(data, fallback) {
  if (!data) return fallback;
  if (data.message) return data.message;
  if (data.errors) {
    const messages = Object.values(data.errors).flat();
    if (messages.length) return messages.join(' ');
  }
  return fallback;
}

async function apiRequest(path, options = {}) {
  const session = getSession();
  const activeWebsite = getActiveWebsite();

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(session ? { Authorization: `Bearer ${session.token}` } : {}),
      ...(activeWebsite ? { 'X-Website-Id': String(activeWebsite.id) } : {}),
      ...(options.headers || {})
    }
  });

  if (response.status === 401) {
    clearSession();
    window.location.href = 'index.html';
    throw new Error('Your session has expired. Please sign in again.');
  }

  if (response.status === 204) {
    return null;
  }

  const data = await response.json().catch(() => null);

  if (!response.ok) {
    throw new Error(extractErrorMessage(data, 'Something went wrong. Please try again.'));
  }

  return data;
}

function formatPhone(countryCode, number) {
  if (countryCode === '+962') {
    return number.startsWith('0') ? number : `0${number}`;
  }
  return `${countryCode} ${number}`;
}

// ---------- Shared DOM helpers ----------
// One definition for every page — do not redeclare these per-file (classic
// scripts share one global scope; duplicate consts are fatal SyntaxErrors).

function escapeHtml(value) {
  const div = document.createElement('div');
  div.textContent = value ?? '';
  return div.innerHTML;
}

// Delays fn until the user pauses — use for search inputs so the list isn't
// re-rendered on every keystroke.
function debounce(fn, delayMs = 250) {
  let timer = null;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), delayMs);
  };
}

// First letters of the first two words — works for Arabic too (toUpperCase is
// a no-op there).
function nameInitials(name) {
  const parts = (name || '').trim().split(/\s+/).filter(Boolean);
  if (!parts.length) return '؟';
  const first = [...parts[0]][0] || '';
  const second = parts.length > 1 ? [...parts[1]][0] || '' : '';
  return `${first}${second}`.toUpperCase();
}

// Friendly empty-list placeholder (icon disc + title), mirroring the mobile
// app's EmptyState widget. `kind` picks the icon.
const EMPTY_STATE_ICONS = {
  search: '<path d="M10 2a8 8 0 1 0 4.9 14.3l4.4 4.4 1.4-1.4-4.4-4.4A8 8 0 0 0 10 2Zm0 2a6 6 0 1 1 0 12 6 6 0 0 1 0-12Z"/><path d="M7.5 9h5v2h-5z"/>',
  inbox: '<path d="M4 4h16a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1Zm1 2v8h3.6a3.4 3.4 0 0 0 6.8 0H19V6H5Zm0 12h14v-2h-5.2a5.4 5.4 0 0 1-3.6 0H5v2Z"/>',
  bell: '<path d="M12 2a6 6 0 0 0-6 6v3.6l-1.7 3.4A1 1 0 0 0 5.2 16.5h13.6a1 1 0 0 0 .9-1.5L18 11.6V8a6 6 0 0 0-6-6Zm-2.4 16a2.5 2.5 0 0 0 4.8 0H9.6Z"/>',
  list: '<path d="M4 5h2v2H4V5Zm4 0h12v2H8V5ZM4 11h2v2H4v-2Zm4 0h12v2H8v-2ZM4 17h2v2H4v-2Zm4 0h12v2H8v-2Z"/>',
  users: '<path d="M9 4a4 4 0 1 0 0 8 4 4 0 0 0 0-8ZM3 20a6 6 0 0 1 12 0v1H3v-1Zm14.5-9.5a3.5 3.5 0 1 0-2.2-6.2 6 6 0 0 1 .5 5.9c.5.2 1.1.3 1.7.3ZM16 20c0-1.8-.6-3.5-1.6-4.9a6 6 0 0 1 6.6 6V21H16v-1Z"/>'
};

function emptyStateHtml(kind, title, hint) {
  const icon = EMPTY_STATE_ICONS[kind] || EMPTY_STATE_ICONS.list;
  return `
    <div class="empty-state">
      <span class="empty-state__icon"><svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">${icon}</svg></span>
      <span class="empty-state__title">${escapeHtml(title)}</span>
      ${hint ? `<span class="empty-state__hint">${escapeHtml(hint)}</span>` : ''}
    </div>`;
}

function apiGetUsers() {
  return apiRequest('/users');
}

function apiCreateUser(payload) {
  return apiRequest('/users', { method: 'POST', body: JSON.stringify(payload) });
}

function apiUpdateUser(id, payload) {
  return apiRequest(`/users/${id}`, { method: 'PUT', body: JSON.stringify(payload) });
}

function apiResetPassword(id, newPassword) {
  return apiRequest(`/users/${id}/password`, {
    method: 'PUT',
    body: JSON.stringify({ newPassword })
  });
}

function apiSetUserStatus(id, isActive) {
  return apiRequest(`/users/${id}/status`, {
    method: 'PATCH',
    body: JSON.stringify({ isActive })
  });
}

// ---------- Websites ----------

function apiGetMyWebsites() {
  return apiRequest('/websites/mine');
}

function apiGetWebsiteSettings() {
  return apiRequest('/websites/settings');
}

function apiSaveWebsiteSettings(settings) {
  return apiRequest('/websites/settings', { method: 'PUT', body: JSON.stringify({ settings }) });
}

// ---------- Departments ----------

function apiGetDepartments() {
  return apiRequest('/departments');
}

function apiGetDepartmentsManage() {
  return apiRequest('/departments/manage');
}

function apiCreateDepartment(payload) {
  return apiRequest('/departments', { method: 'POST', body: JSON.stringify(payload) });
}

function apiUpdateDepartment(id, payload) {
  return apiRequest(`/departments/${id}`, { method: 'PUT', body: JSON.stringify(payload) });
}

function apiSetDepartmentStatus(id, isActive) {
  return apiRequest(`/departments/${id}/status`, {
    method: 'PATCH',
    body: JSON.stringify({ isActive })
  });
}

// ---------- Referral sources ----------

function apiGetReferralSources() {
  return apiRequest('/referral-sources');
}

function apiGetReferralSourcesManage() {
  return apiRequest('/referral-sources/manage');
}

function apiCreateReferralSource(payload) {
  return apiRequest('/referral-sources', { method: 'POST', body: JSON.stringify(payload) });
}

function apiUpdateReferralSource(id, payload) {
  return apiRequest(`/referral-sources/${id}`, { method: 'PUT', body: JSON.stringify(payload) });
}

function apiSetReferralSourceStatus(id, isActive) {
  return apiRequest(`/referral-sources/${id}/status`, {
    method: 'PATCH',
    body: JSON.stringify({ isActive })
  });
}

// ---------- Procedures ----------

function apiGetProcedures() {
  return apiRequest('/procedures');
}

function apiGetProceduresManage() {
  return apiRequest('/procedures/manage');
}

function apiCreateProcedure(payload) {
  return apiRequest('/procedures', { method: 'POST', body: JSON.stringify(payload) });
}

function apiUpdateProcedure(id, payload) {
  return apiRequest(`/procedures/${id}`, { method: 'PUT', body: JSON.stringify(payload) });
}

function apiSetProcedureStatus(id, isActive) {
  return apiRequest(`/procedures/${id}/status`, {
    method: 'PATCH',
    body: JSON.stringify({ isActive })
  });
}

// ---------- Doctors ----------

function apiGetDoctors() {
  return apiRequest('/doctors');
}

function apiGetDoctorsManage() {
  return apiRequest('/doctors/manage');
}

function apiCreateDoctor(payload) {
  return apiRequest('/doctors', { method: 'POST', body: JSON.stringify(payload) });
}

function apiUpdateDoctor(id, payload) {
  return apiRequest(`/doctors/${id}`, { method: 'PUT', body: JSON.stringify(payload) });
}

function apiSetDoctorStatus(id, isActive) {
  return apiRequest(`/doctors/${id}/status`, {
    method: 'PATCH',
    body: JSON.stringify({ isActive })
  });
}

// ---------- Cases ----------

function apiCreateCase(payload) {
  return apiRequest('/cases', { method: 'POST', body: JSON.stringify(payload) });
}

function apiGetAllCases() {
  return apiRequest('/cases/all');
}

function apiGetMyCases() {
  return apiRequest('/cases/mine');
}

function apiGetCaseDetail(id) {
  return apiRequest(`/cases/${id}`);
}

function apiClaimCase(id) {
  return apiRequest(`/cases/${id}/claim`, { method: 'POST' });
}

function apiGetForwardTargets() {
  return apiRequest('/cases/forward-targets');
}

function apiForwardCase(id, payload) {
  return apiRequest(`/cases/${id}/forward`, { method: 'POST', body: JSON.stringify(payload) });
}

function apiAcceptForward(id) {
  return apiRequest(`/cases/${id}/accept-forward`, { method: 'POST' });
}

function apiDeclineForward(id) {
  return apiRequest(`/cases/${id}/decline-forward`, { method: 'POST' });
}

function apiGetForwardedToMe() {
  return apiRequest('/cases/forwarded-to-me');
}

function apiGetForwardedByMe() {
  return apiRequest('/cases/forwarded-by-me');
}

function apiReopenCase(id) {
  return apiRequest(`/cases/${id}/reopen`, { method: 'POST' });
}

function apiFollowUpCase(id, payload) {
  return apiRequest(`/cases/${id}/follow-up`, { method: 'POST', body: JSON.stringify(payload) });
}

// ---------- Admin ----------

function apiGetAdminStats() {
  return apiRequest('/admin/stats');
}

function apiGetAdminCases() {
  return apiRequest('/admin/cases');
}

function apiAdminFollowUpCase(id, payload) {
  return apiRequest(`/admin/cases/${id}/follow-up`, { method: 'POST', body: JSON.stringify(payload) });
}

// ---------- Hospital Manager ----------

function hmQueryString(from, to) {
  const params = new URLSearchParams();
  if (from) params.set('from', from);
  if (to) params.set('to', to);
  return params.toString();
}

function apiGetHospitalManagerStats(from, to) {
  return apiRequest(`/hospital-manager/stats?${hmQueryString(from, to)}`);
}

// File download, not JSON — auth is a Bearer token (not a cookie), so a plain
// <a href> to this endpoint would 401 silently. Fetch as a blob instead.
async function apiExportHospitalManagerStats(from, to) {
  const session = getSession();
  const activeWebsite = getActiveWebsite();
  const response = await fetch(`${API_BASE_URL}/hospital-manager/stats/export?${hmQueryString(from, to)}`, {
    headers: {
      Authorization: `Bearer ${session.token}`,
      ...(activeWebsite ? { 'X-Website-Id': String(activeWebsite.id) } : {})
    }
  });
  if (!response.ok) throw new Error('Failed to generate the report.');
  const blob = await response.blob();
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `hospital-report-${new Date().toISOString().slice(0, 10)}.xlsx`;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

// ---------- Notifications ----------

function apiGetNotifications() {
  return apiRequest('/notifications');
}

function apiGetUnreadCount() {
  return apiRequest('/notifications/unread-count');
}

function apiMarkNotificationRead(id) {
  return apiRequest(`/notifications/${id}/read`, { method: 'POST' });
}

function apiMarkAllNotificationsRead() {
  return apiRequest('/notifications/read-all', { method: 'POST' });
}

function apiDeleteNotification(id) {
  return apiRequest(`/notifications/${id}`, { method: 'DELETE' });
}
