const form = document.getElementById('case-form');
const formError = document.getElementById('case-form-error');
const submitBtn = document.getElementById('case-form-submit');
const dialSelect = document.getElementById('case-dial-code');
const referralSelect = document.getElementById('case-referral');
const deptSelect = document.getElementById('case-department');
const procedureSelect = document.getElementById('case-procedure');
const hasDoctorCheck = document.getElementById('case-has-doctor');
const doctorSelect = document.getElementById('case-doctor');

function setFormError(message) {
  if (!message) { formError.hidden = true; formError.textContent = ''; return; }
  formError.hidden = false;
  formError.textContent = message;
}

function renderDialCodes() {
  dialSelect.innerHTML = COUNTRIES.map(
    (country) => `<option value="${country.dialCode}">${country.dialCode} ${country.name}</option>`
  ).join('');
  dialSelect.value = '+962';
}

async function loadLookups() {
  try {
    const [referralSources, allDepartments, allDoctors, allProcedures] = await Promise.all([
      apiGetReferralSources(),
      apiGetDepartments(),
      apiGetDoctors(),
      apiGetProcedures()
    ]);

    referralSources.forEach((item) => {
      const option = document.createElement('option');
      option.value = item.id;
      option.textContent = item.name;
      referralSelect.appendChild(option);
    });

    deptSelect.innerHTML =
      `<option value="">${t('newCase.selectDepartment')}</option>` +
      allDepartments.map((d) => `<option value="${d.id}">${d.name}</option>`).join('');

    procedureSelect.innerHTML =
      `<option value="">${t('newCase.selectProcedure')}</option>` +
      allProcedures.map((p) => `<option value="${p.id}">${p.name}</option>`).join('');

    doctorSelect.innerHTML =
      `<option value="">${t('newCase.selectDoctor')}</option>` +
      allDoctors.map((d) => `<option value="${d.id}">${d.name}</option>`).join('');
  } catch (err) {
    setFormError(err.message);
  }
}

// Checkbox is a data flag only — no UI show/hide tied to it
hasDoctorCheck.addEventListener('change', () => {});

function setSubmitLoading(isLoading) {
  submitBtn.disabled = isLoading;
  submitBtn.querySelector('.btn-submit__label').textContent = isLoading ? t('newCase.creating') : t('newCase.createCase');
  submitBtn.querySelector('.btn-submit__spinner').hidden = !isLoading;
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  setFormError(null);

  const referralSourceId = Number(referralSelect.value);
  if (!referralSourceId) { setFormError(t('newCase.errorReferral')); return; }

  const departmentId = Number(deptSelect.value);
  if (!departmentId) { setFormError(t('newCase.errorDepartment')); return; }

  const procedureId = Number(procedureSelect.value);
  if (!procedureId) { setFormError(t('newCase.errorProcedure')); return; }

  const payload = {
    name: document.getElementById('case-name').value.trim(),
    phoneCountryCode: dialSelect.value,
    phoneNumber: document.getElementById('case-phone').value.trim(),
    referralSourceId,
    departmentId,
    procedureId,
    hasDoctor: hasDoctorCheck.checked,
    doctorId: doctorSelect.value ? Number(doctorSelect.value) : null,
    description: document.getElementById('case-description').value.trim()
  };

  setSubmitLoading(true);
  try {
    const created = await apiCreateCase(payload);
    window.location.href = `case.html?id=${created.id}`;
  } catch (err) {
    setFormError(err.message);
    setSubmitLoading(false);
  }
});

renderDialCodes();
loadLookups();
