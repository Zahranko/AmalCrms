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
}

function getSession() {
  const token = localStorage.getItem('crms.token');
  if (!token) return null;

  return {
    token,
    username: localStorage.getItem('crms.username'),
    role: localStorage.getItem('crms.role'),
    expiresAt: localStorage.getItem('crms.expiresAt')
  };
}

function clearSession() {
  localStorage.removeItem('crms.token');
  localStorage.removeItem('crms.username');
  localStorage.removeItem('crms.role');
  localStorage.removeItem('crms.expiresAt');
}

// Single source of truth for where each role lands after login (used by
// login.js) and where an off-limits page redirects to (nav.js's
// enforcePageAccess) — keep those two in sync by definition.
function homePageForRole(role) {
  return role === 'HospitalManager' ? 'hospitalManagerDashboard.html' : 'dashboard.html';
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

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(session ? { Authorization: `Bearer ${session.token}` } : {}),
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
  const response = await fetch(`${API_BASE_URL}/hospital-manager/stats/export?${hmQueryString(from, to)}`, {
    headers: { Authorization: `Bearer ${session.token}` }
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
