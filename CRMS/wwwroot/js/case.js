const caseSession = getSession();
const caseId = Number(new URLSearchParams(window.location.search).get('id'));

const STATUS_META = {
  Pending: { label: t('status.pending'), cls: 'pending' },
  Waiting: { label: t('status.waiting'), cls: 'waiting' },
  Success: { label: t('status.success'), cls: 'success' },
  Failed: { label: t('status.failed'), cls: 'failed' }
};
const FOLLOW_UP_STATUSES = ['Success', 'Waiting', 'Failed', 'Pending'];

const loadingEl = document.getElementById('case-loading');
const errorEl = document.getElementById('case-error');
const detailEl = document.getElementById('case-detail');
const nameEl = document.getElementById('case-name');
const statusEl = document.getElementById('case-status');
const fieldsEl = document.getElementById('case-fields');
const actionsEl = document.getElementById('case-actions');
const timelineEl = document.getElementById('case-timeline');

let currentCase = null;
let departments = [];
let doctors = [];


function statusMeta(status) {
  return STATUS_META[status] || { label: status, cls: 'pending' };
}

function formatDate(value) {
  return value ? new Date(value).toLocaleDateString() : '';
}

function setError(message) {
  if (!message) { errorEl.hidden = true; errorEl.textContent = ''; return; }
  errorEl.hidden = false;
  errorEl.textContent = message;
}

// Back link: return to wherever the user came from (any of our list pages).
(function wireBackLink() {
  const link = document.getElementById('back-link');
  const ref = document.referrer;
  if (ref && /(cases-mine|adminDashboard|dashboard)\.html/.test(ref)) {
    link.setAttribute('href', ref);
  }
})();

async function loadCase() {
  if (!caseId) {
    loadingEl.hidden = true;
    setError(t('case.noId'));
    return;
  }

  loadingEl.hidden = false;
  detailEl.hidden = true;
  setError(null);

  try {
    currentCase = await apiGetCaseDetail(caseId);
    renderCase();
    detailEl.hidden = false;
  } catch (err) {
    setError(err.message);
  } finally {
    loadingEl.hidden = true;
  }
}

function detailRow(label, value, full = false) {
  return `
    <div class="detail-item ${full ? 'detail-item--full' : ''}">
      <span class="detail-item__label">${label}</span>
      <span class="detail-item__value">${escapeHtml(value || '—')}</span>
    </div>`;
}

function renderCase() {
  const c = currentCase;
  const meta = statusMeta(c.status);

  nameEl.textContent = c.name;
  statusEl.className = `status-pill status-pill--${meta.cls}`;
  statusEl.textContent = meta.label;

  const rows = [
    detailRow(t('case.phone'), formatPhone(c.phoneCountryCode, c.phoneNumber)),
    detailRow(t('case.referralSource'), c.referralSource),
    detailRow(t('case.procedure'), c.procedure),
    detailRow(t('case.department'), c.department),
    detailRow(t('case.doctor'), c.doctor),
    detailRow(t('case.appointment'), c.appointmentDate ? formatDate(c.appointmentDate) : null),
    detailRow(t('case.createdBy'), c.createdByUsername),
    detailRow(t('case.assignedTo'), c.assignedToUsername || t('case.unassigned')),
    c.forwardedToUsername ? detailRow(t('case.pendingForwardTo'), c.forwardedToUsername) : '',
    detailRow(t('case.created'), new Date(c.createdAt).toLocaleString()),
    detailRow(t('case.description'), c.description, true)
  ];

  const signatureHtml = c.clinicSignature
    ? `<div class="detail-item detail-item--full">
        <span class="detail-item__label">${t('case.signature')}</span>
        <img src="${escapeHtml(c.clinicSignature)}" style="display:block;max-width:300px;max-height:200px;margin-top:8px;border:1px solid var(--border);border-radius:8px;" />
      </div>`
    : '';

  fieldsEl.innerHTML = rows.join('') + signatureHtml;

  renderActions();
  renderTimeline();
}

function renderActions() {
  const isMyCase = caseSession && currentCase.assignedToUsername === caseSession.username;
  const isPendingRecipient = caseSession && currentCase.forwardedToUsername === caseSession.username;

  let buttons = `<button type="button" class="btn-action btn-action--primary" data-action="follow-up">${t('action.followUp')}</button>`;

  if (isPendingRecipient) {
    buttons += `<button type="button" class="btn-action btn-action--success" data-action="accept-forward">${t('action.accept')}</button>`;
    buttons += `<button type="button" class="btn-action btn-action--danger" data-action="decline-forward">${t('action.decline')}</button>`;
  }

  if (!isMyCase && !isPendingRecipient) {
    buttons += `<button type="button" class="btn-action" data-action="claim">${t('action.assignToMe')}</button>`;
  }

  if (isMyCase && !currentCase.forwardedToUsername) {
    buttons += `<button type="button" class="btn-action" data-action="forward">${t('action.forward')}</button>`;
  }

  const isCompleted = currentCase.status === 'Success' || currentCase.status === 'Failed';
  if (isCompleted && caseSession && caseSession.role === 'Admin') {
    buttons += `<button type="button" class="btn-action btn-action--primary" data-action="reopen">${t('action.reopen')}</button>`;
  }

  actionsEl.innerHTML = buttons;
}

function renderTimeline() {
  const history = currentCase.history || [];
  if (!history.length) {
    timelineEl.innerHTML = `<li class="timeline__empty">${t('case.noHistory')}</li>`;
    return;
  }
  timelineEl.innerHTML = history.map(timelineItem).join('');
}

function timelineItem(a) {
  let title;
  const actor = `<strong>${escapeHtml(a.actorUsername)}</strong>`;
  if (a.type === 'Created') {
    title = t('timeline.created', { actor });
  } else if (a.type === 'Forwarded') {
    title = t('timeline.forwarded', { actor, target: `<strong>${escapeHtml(a.targetUsername)}</strong>` });
  } else if (a.type === 'ForwardAccepted') {
    title = t('timeline.forwardAccepted', { actor });
  } else if (a.type === 'ForwardDeclined') {
    title = t('timeline.forwardDeclined', { actor });
  } else if (a.type === 'Claimed') {
    title = t('timeline.claimed', { actor });
  } else if (a.type === 'Reopened') {
    title = t('timeline.reopened', { actor });
  } else {
    const sm = statusMeta(a.resultingStatus);
    const statusLabel = t('status.' + (a.resultingStatus || '').toLowerCase()) || sm.label;
    title = t('timeline.followUp', { actor, status: `<span class="status-pill status-pill--${sm.cls}">${statusLabel}</span>` });
  }

  const meta = [];
  if (a.departmentName) meta.push(t('timeline.dept', { name: escapeHtml(a.departmentName) }));
  if (a.doctorName) meta.push(t('timeline.doctor', { name: escapeHtml(a.doctorName) }));
  if (a.actionDate) meta.push(t('timeline.date', { date: escapeHtml(formatDate(a.actionDate)) }));

  return `
    <li class="timeline-item">
      <div class="timeline-item__dot"></div>
      <div class="timeline-item__body">
        <div class="timeline-item__title">${title}</div>
        ${meta.length ? `<div class="timeline-item__meta">${meta.join(' · ')}</div>` : ''}
        ${a.note ? `<p class="timeline-item__note">${escapeHtml(a.note)}</p>` : ''}
        <div class="timeline-item__time">${new Date(a.createdAt).toLocaleString()}</div>
      </div>
    </li>`;
}

actionsEl.addEventListener('click', async (e) => {
  const button = e.target.closest('button[data-action]');
  if (!button) return;
  const action = button.dataset.action;

  if (action === 'claim') {
    button.disabled = true;
    try {
      currentCase = await apiClaimCase(caseId);
      renderCase();
    } catch (err) {
      setError(err.message);
      button.disabled = false;
    }
  } else if (action === 'follow-up') {
    openFollowUpModal();
  } else if (action === 'forward') {
    openForwardModal();
  } else if (action === 'accept-forward') {
    button.disabled = true;
    try {
      currentCase = await apiAcceptForward(caseId);
      renderCase();
    } catch (err) {
      setError(err.message);
      button.disabled = false;
    }
  } else if (action === 'decline-forward') {
    button.disabled = true;
    try {
      currentCase = await apiDeclineForward(caseId);
      renderCase();
    } catch (err) {
      setError(err.message);
      button.disabled = false;
    }
  } else if (action === 'reopen') {
    button.disabled = true;
    try {
      currentCase = await apiReopenCase(caseId);
      renderCase();
    } catch (err) {
      setError(err.message);
      button.disabled = false;
    }
  }
});

// ---------- Follow-up modal ----------

const modalHost = document.createElement('div');
modalHost.innerHTML = `
  <div id="followup-modal" class="modal-overlay" hidden>
    <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="followup-modal-title">
      <div class="modal-card__header">
        <h2 id="followup-modal-title">${t('followUp.title')}</h2>
        <button type="button" class="modal-close" data-close="followup-modal" aria-label="Close">&times;</button>
      </div>

      <div class="field">
        <label for="followup-status">${t('followUp.newStatus')}</label>
        <div class="field__control field__control--select">
          <select id="followup-status">
            <option value="Success">${t('followUp.statusSuccess')}</option>
            <option value="Waiting">${t('followUp.statusWaiting')}</option>
            <option value="Failed">${t('followUp.statusFailed')}</option>
            <option value="Pending">${t('followUp.statusPending')}</option>
          </select>
        </div>
      </div>

      <div class="field" id="followup-date-field" hidden>
        <label for="followup-date">${t('followUp.appointmentDate')}</label>
        <div class="field__control">
          <input type="date" id="followup-date" />
        </div>
      </div>

      <div class="field" id="followup-department-field" hidden>
        <label for="followup-department">${t('followUp.department')}</label>
        <div class="field__control field__control--select">
          <select id="followup-department"><option value="">${t('followUp.selectDepartment')}</option></select>
        </div>
      </div>

      <div class="field" id="followup-doctor-toggle-field" hidden>
        <label class="checkbox-label">
          <input type="checkbox" id="followup-has-doctor" />
          ${t('followUp.hasDoctor')}
        </label>
      </div>

      <div class="field" id="followup-doctor-field" hidden>
        <label for="followup-doctor">${t('followUp.doctor')}</label>
        <div class="field__control field__control--select">
          <select id="followup-doctor"><option value="">${t('followUp.selectDoctor')}</option></select>
        </div>
      </div>

      <div class="field" id="followup-clinics-field" hidden>
        <label class="checkbox-label">
          <input type="checkbox" id="followup-clinics" />
          ${t('followUp.clinics')}
        </label>
      </div>

      <div class="field" id="followup-clinics-doctor-field" hidden>
        <label for="followup-clinics-doctor">${t('followUp.doctor')}</label>
        <div class="field__control field__control--select">
          <select id="followup-clinics-doctor"><option value="">${t('followUp.selectDoctor')}</option></select>
        </div>
      </div>

      <div class="field" id="followup-signature-field" hidden>
        <label>${t('followUp.signature')} *</label>
        <div class="field__control">
          <label class="btn-secondary signature-upload-btn" style="display:inline-block;cursor:pointer;margin-bottom:8px;">
            ${t('followUp.signatureChoose')}
            <input type="file" id="followup-signature-input" accept="image/*" style="display:none;" />
          </label>
          <img id="followup-signature-preview" hidden style="display:block;max-width:100%;max-height:180px;border:1px solid var(--border);border-radius:8px;margin-top:4px;" />
        </div>
      </div>

      <div class="field" id="followup-notes-field">
        <label for="followup-notes" id="followup-notes-label">${t('followUp.notes')}</label>
        <div class="field__control">
          <textarea id="followup-notes" rows="3" placeholder="${t('followUp.notesPlaceholder')}"></textarea>
        </div>
      </div>

      <div id="followup-error" class="form-error" role="alert" hidden></div>
      <div class="modal-actions">
        <button type="button" class="btn-secondary" data-close="followup-modal">${t('action.cancel')}</button>
        <button type="button" class="btn-primary" id="followup-confirm">${t('action.save')}</button>
      </div>
    </div>
  </div>
`;
document.body.appendChild(modalHost);

const followupModal = document.getElementById('followup-modal');
const followupStatus = document.getElementById('followup-status');
const followupDateField = document.getElementById('followup-date-field');
const followupDate = document.getElementById('followup-date');
const followupDeptField = document.getElementById('followup-department-field');
const followupDept = document.getElementById('followup-department');
const followupDoctorToggleField = document.getElementById('followup-doctor-toggle-field');
const followupHasDoctor = document.getElementById('followup-has-doctor');
const followupDoctorField = document.getElementById('followup-doctor-field');
const followupDoctor = document.getElementById('followup-doctor');
const followupClinicsField = document.getElementById('followup-clinics-field');
const followupClinics = document.getElementById('followup-clinics');
const followupClinicsDoctorField = document.getElementById('followup-clinics-doctor-field');
const followupClinicsDoctor = document.getElementById('followup-clinics-doctor');
const followupSignatureField = document.getElementById('followup-signature-field');
const followupSignatureInput = document.getElementById('followup-signature-input');
const followupSignaturePreview = document.getElementById('followup-signature-preview');
const followupNotesField = document.getElementById('followup-notes-field');
const followupNotes = document.getElementById('followup-notes');
const followupNotesLabel = document.getElementById('followup-notes-label');
const followupConfirm = document.getElementById('followup-confirm');
const followupError = document.getElementById('followup-error');

let signatureDataUrl = null;
followupSignatureInput.addEventListener('change', (e) => {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = (ev) => {
    signatureDataUrl = ev.target.result;
    followupSignaturePreview.src = signatureDataUrl;
    followupSignaturePreview.hidden = false;
  };
  reader.readAsDataURL(file);
});

function openModal(m) { m.hidden = false; }
function closeModal(m) { m.hidden = true; }
function setModalError(box, message) {
  if (!message) { box.hidden = true; box.textContent = ''; return; }
  box.hidden = false;
  box.textContent = message;
}

modalHost.addEventListener('click', (e) => {
  const closeId = e.target.dataset.close;
  if (closeId) { closeModal(document.getElementById(closeId)); return; }
  if (e.target.classList.contains('modal-overlay')) closeModal(e.target);
});

document.addEventListener('keydown', (e) => {
  if (e.key !== 'Escape') return;
  if (!followupModal.hidden) closeModal(followupModal);
});

async function openFollowUpModal() {
  followupStatus.value = 'Success';
  followupDate.value = '';
  followupNotes.value = '';
  followupHasDoctor.checked = false;
  followupClinics.checked = false;
  signatureDataUrl = null;
  followupSignatureInput.value = '';
  followupSignaturePreview.hidden = true;
  setModalError(followupError, null);
  applyFollowUpStatus();
  openModal(followupModal);

  try {
    if (!departments.length) departments = await apiGetDepartments();
    if (!doctors.length) doctors = await apiGetDoctors();
    const doctorOptions =
      `<option value="">${t('followUp.selectDoctor')}</option>` +
      doctors.map((d) => `<option value="${d.id}">${escapeHtml(d.name)}</option>`).join('');
    followupDept.innerHTML =
      `<option value="">${t('followUp.selectDepartment')}</option>` +
      departments.map((d) => `<option value="${d.id}">${escapeHtml(d.name)}</option>`).join('');
    followupDoctor.innerHTML = doctorOptions;
    followupClinicsDoctor.innerHTML = doctorOptions;
  } catch (err) {
    setModalError(followupError, err.message);
  }
}

function applyFollowUpStatus() {
  const status = followupStatus.value;
  const isWaiting = status === 'Waiting';
  const isSuccess = status === 'Success';
  const isClinics = isSuccess && followupClinics.checked;

  // Date only shown for Waiting (appointment date, optional)
  followupDateField.hidden = !isWaiting;

  // Waiting: department + has-doctor + doctor
  followupDeptField.hidden = !isWaiting;
  followupDoctorToggleField.hidden = !isWaiting;
  followupDoctorField.hidden = !isWaiting || !followupHasDoctor.checked;

  // Success: clinics checkbox + conditional doctor
  followupClinicsField.hidden = !isSuccess;
  followupClinicsDoctorField.hidden = !isClinics;

  // When clinics is checked: show signature upload instead of notes
  followupSignatureField.hidden = !isClinics;
  followupNotesField.hidden = isClinics;
  if (!isClinics) {
    followupNotesLabel.textContent = isSuccess ? t('followUp.notesOptional') : t('followUp.notes');
  }
}

followupStatus.addEventListener('change', () => {
  followupHasDoctor.checked = false;
  followupClinics.checked = false;
  applyFollowUpStatus();
});

followupHasDoctor.addEventListener('change', () => {
  followupDoctorField.hidden = !followupHasDoctor.checked;
});

followupClinics.addEventListener('change', () => {
  if (!followupClinics.checked) {
    signatureDataUrl = null;
    followupSignatureInput.value = '';
    followupSignaturePreview.hidden = true;
  }
  applyFollowUpStatus();
});

followupConfirm.addEventListener('click', async () => {
  setModalError(followupError, null);
  const status = followupStatus.value;
  const notes = followupNotes.value.trim();
  const isWaiting = status === 'Waiting';
  const isClinics = status === 'Success' && followupClinics.checked;

  if (isWaiting && !followupDept.value) {
    setModalError(followupError, t('followUp.errorDepartment')); return;
  }
  if (!isClinics && status !== 'Success' && !notes) {
    setModalError(followupError, t('followUp.errorNotes')); return;
  }
  if (isClinics && !signatureDataUrl) {
    setModalError(followupError, t('followUp.signatureRequired')); return;
  }

  const payload = {
    status,
    date: isWaiting && followupDate.value ? followupDate.value : null,
    notes: isClinics ? null : (notes || null),
    departmentId: isWaiting ? Number(followupDept.value) : null,
    hasDoctor: isWaiting ? followupHasDoctor.checked : (status === 'Success' ? followupClinics.checked : null),
    doctorId: isWaiting && followupDoctor.value ? Number(followupDoctor.value) :
              (isClinics && followupClinicsDoctor.value ? Number(followupClinicsDoctor.value) : null),
    signatureData: isClinics ? signatureDataUrl : null
  };

  followupConfirm.disabled = true;
  try {
    currentCase = await apiFollowUpCase(caseId, payload);
    closeModal(followupModal);
    renderCase();
  } catch (err) {
    setModalError(followupError, err.message);
  } finally {
    followupConfirm.disabled = false;
  }
});

// ---------- Forward modal ----------

const forwardModalHost = document.createElement('div');
forwardModalHost.innerHTML = `
  <div id="forward-modal" class="modal-overlay" hidden>
    <div class="modal-card" role="dialog" aria-modal="true" aria-labelledby="forward-modal-title">
      <div class="modal-card__header">
        <h2 id="forward-modal-title">${t('forward.title')}</h2>
        <button type="button" class="modal-close" data-close="forward-modal" aria-label="Close">&times;</button>
      </div>

      <div class="field">
        <label for="forward-user">${t('forward.forwardTo')}</label>
        <div class="field__control field__control--select">
          <select id="forward-user"><option value="">${t('forward.selectColleague')}</option></select>
        </div>
      </div>

      <div class="field">
        <label for="forward-note">${t('forward.note')}</label>
        <div class="field__control">
          <textarea id="forward-note" rows="3" placeholder="${t('forward.notePlaceholder')}"></textarea>
        </div>
      </div>

      <div id="forward-error" class="form-error" role="alert" hidden></div>
      <div class="modal-actions">
        <button type="button" class="btn-secondary" data-close="forward-modal">${t('action.cancel')}</button>
        <button type="button" class="btn-primary" id="forward-confirm">${t('action.forward')}</button>
      </div>
    </div>
  </div>
`;
document.body.appendChild(forwardModalHost);

const forwardModal = document.getElementById('forward-modal');
const forwardUserSelect = document.getElementById('forward-user');
const forwardNote = document.getElementById('forward-note');
const forwardConfirm = document.getElementById('forward-confirm');
const forwardError = document.getElementById('forward-error');

let allUsers = [];

forwardModalHost.addEventListener('click', (e) => {
  const closeId = e.target.dataset.close;
  if (closeId) { closeModal(document.getElementById(closeId)); return; }
  if (e.target.classList.contains('modal-overlay')) closeModal(e.target);
});

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape' && !forwardModal.hidden) closeModal(forwardModal);
});

async function openForwardModal() {
  forwardUserSelect.innerHTML = `<option value="">${t('forward.selectColleague')}</option>`;
  forwardNote.value = '';
  setModalError(forwardError, null);
  openModal(forwardModal);

  try {
    // Website-scoped colleagues (active members of the current website, minus
    // me) — keeps forwards inside the website so the recipient can accept.
    if (!allUsers.length) allUsers = await apiGetForwardTargets();
    forwardUserSelect.innerHTML =
      `<option value="">${t('forward.selectColleague')}</option>` +
      allUsers.map((u) => `<option value="${u.id}">${escapeHtml(u.username)}</option>`).join('');
  } catch (err) {
    setModalError(forwardError, err.message);
  }
}

forwardConfirm.addEventListener('click', async () => {
  setModalError(forwardError, null);
  const toUserId = Number(forwardUserSelect.value);
  if (!toUserId) { setModalError(forwardError, t('forward.errorColleague')); return; }

  forwardConfirm.disabled = true;
  try {
    currentCase = await apiForwardCase(caseId, {
      toUserId,
      note: forwardNote.value.trim() || null
    });
    closeModal(forwardModal);
    renderCase();
  } catch (err) {
    setModalError(forwardError, err.message);
  } finally {
    forwardConfirm.disabled = false;
  }
});

loadCase();
