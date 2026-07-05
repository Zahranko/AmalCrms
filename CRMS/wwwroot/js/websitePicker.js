// Website picker — shown after login when a user can access more than one
// website, and reused as the in-app switcher (topbar). Selecting a website sets
// it active and enters it.

const session = getSession();
if (!session) {
  window.location.href = 'index.html';
}

const websites = getAccessibleWebsites();

function renderWebsites() {
  const list = document.getElementById('wp-list');
  if (!list) return;

  if (!websites.length) {
    list.innerHTML = `<p class="form-error" style="display:block">${t('login.noWebsiteAccess')}</p>`;
    return;
  }

  const activeId = (getActiveWebsite() || {}).id;
  list.innerHTML = websites
    .map(
      (w, i) => `
      <button type="button" class="wp-item ${w.id === activeId ? 'wp-item--active' : ''}" data-idx="${i}">
        <span class="wp-item__avatar">${escapeHtml(nameInitials(websiteName(w)))}</span>
        <span class="wp-item__text">
          <span class="wp-item__name">${escapeHtml(websiteName(w))}</span>
          <span class="wp-item__key">${escapeHtml(w.key)}</span>
        </span>
        <span class="wp-item__arrow" aria-hidden="true">&rsaquo;</span>
      </button>`
    )
    .join('');

  list.querySelectorAll('.wp-item').forEach((btn) => {
    btn.addEventListener('click', () => {
      const w = websites[Number(btn.dataset.idx)];
      setActiveWebsite(w);
      window.location.href = homePage();
    });
  });
}

document.addEventListener('DOMContentLoaded', () => {
  renderWebsites();
  const logout = document.getElementById('wp-logout');
  if (logout) {
    logout.addEventListener('click', () => {
      clearSession();
      window.location.href = 'index.html';
    });
  }
});
