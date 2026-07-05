// Per-website "system parameters" editor (Admin only). Edits the settings of the
// currently-active website — switching website in the topbar re-scopes this page.

const spSession = getSession();

const spErrorEl = document.getElementById('sp-error');
const spLoadingEl = document.getElementById('sp-loading');
const spEditorEl = document.getElementById('sp-editor');
const spRowsEl = document.getElementById('sp-rows');
const spEmptyEl = document.getElementById('sp-empty');
const spSaveBtn = document.getElementById('sp-save-btn');
const spSavedEl = document.getElementById('sp-saved');

function spSetError(message) {
  if (!message) {
    spErrorEl.hidden = true;
    spErrorEl.textContent = '';
    return;
  }
  spErrorEl.hidden = false;
  spErrorEl.textContent = message;
}

function spRowHtml(key = '', value = '') {
  return `
    <tr class="sp-row">
      <td><div class="field__control"><input type="text" class="sp-key" value="${escapeHtml(key)}" placeholder="${t('systemParams.keyPlaceholder')}" autocomplete="off" /></div></td>
      <td><div class="field__control"><input type="text" class="sp-value" value="${escapeHtml(value)}" placeholder="${t('systemParams.valuePlaceholder')}" autocomplete="off" /></div></td>
      <td><button type="button" class="btn-icon sp-remove" aria-label="${t('action.delete')}">&times;</button></td>
    </tr>`;
}

function spUpdateEmpty() {
  spEmptyEl.hidden = spRowsEl.children.length > 0;
}

function spAddRow(key = '', value = '') {
  spRowsEl.insertAdjacentHTML('beforeend', spRowHtml(key, value));
  const row = spRowsEl.lastElementChild;
  row.querySelector('.sp-remove').addEventListener('click', () => {
    row.remove();
    spUpdateEmpty();
  });
  spUpdateEmpty();
}

function spCollect() {
  return [...spRowsEl.querySelectorAll('.sp-row')]
    .map((row) => ({
      key: row.querySelector('.sp-key').value.trim(),
      value: row.querySelector('.sp-value').value
    }))
    .filter((s) => s.key.length > 0);
}

async function spLoad() {
  spSetError(null);
  const active = getActiveWebsite();
  const nameEl = document.getElementById('sp-website-name');
  if (nameEl && active) nameEl.textContent = websiteName(active);

  try {
    const settings = await apiGetWebsiteSettings();
    spRowsEl.innerHTML = '';
    settings.forEach((s) => spAddRow(s.key, s.value));
    spUpdateEmpty();
    spLoadingEl.hidden = true;
    spEditorEl.hidden = false;
  } catch (err) {
    spLoadingEl.hidden = true;
    spSetError(err.message || t('systemParams.loadError'));
  }
}

function spSetSaving(saving) {
  spSaveBtn.disabled = saving;
  spSaveBtn.querySelector('.btn-submit__spinner').hidden = !saving;
}

async function spSave() {
  spSetError(null);
  spSavedEl.hidden = true;

  const settings = spCollect();
  const keys = settings.map((s) => s.key.toLowerCase());
  if (new Set(keys).size !== keys.length) {
    spSetError(t('systemParams.duplicateKey'));
    return;
  }

  spSetSaving(true);
  try {
    await apiSaveWebsiteSettings(settings);
    spSavedEl.hidden = false;
    setTimeout(() => (spSavedEl.hidden = true), 2500);
  } catch (err) {
    spSetError(err.message || t('systemParams.saveError'));
  } finally {
    spSetSaving(false);
  }
}

document.getElementById('sp-add-btn').addEventListener('click', () => spAddRow());
spSaveBtn.addEventListener('click', spSave);

document.addEventListener('DOMContentLoaded', spLoad);
