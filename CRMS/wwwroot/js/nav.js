const session = getSession();

if (!session) {
  window.location.href = 'index.html';
}

// Single source of truth for the drawer. Add new sections here as they're built —
// set `roles` to restrict an item to specific roles, omit it to show to everyone.
const NAV_ITEMS = [
  { href: 'dashboard.html', label: 'Dashboard', labelKey: 'nav.dashboard' },
  { href: 'newCase.html', label: 'New Case', labelKey: 'nav.newCase' },
  { href: 'cases-mine.html', label: 'Cases', labelKey: 'nav.cases' },
  { href: 'cases-forwarded-in.html', label: 'Forwarded to Me', labelKey: 'nav.forwardedToMe' },
  { href: 'cases-forwarded-out.html', label: 'Forwarded by Me', labelKey: 'nav.forwardedByMe' },
  { href: 'manageLists.html', label: 'Manage Lists', labelKey: 'nav.manageLists', roles: ['Admin'] },
  { href: 'userManage.html', label: 'User Management', labelKey: 'nav.userManagement', roles: ['Admin'] }
];

function currentPage() {
  return window.location.pathname.split('/').pop() || 'dashboard.html';
}

function renderDrawerNav() {
  const list = document.getElementById('drawer-nav-list');
  if (!list) return;

  const page = currentPage();
  list.innerHTML = NAV_ITEMS.filter((item) => !item.roles || item.roles.includes(session.role))
    .map(
      (item) =>
        `<li><a href="${item.href}" class="${item.href === page ? 'active' : ''}">${t(item.labelKey)}</a></li>`
    )
    .join('');
}

function openDrawer() {
  document.getElementById('drawer').classList.add('drawer--open');
  document.getElementById('drawer-overlay').classList.add('drawer-overlay--visible');
  document.getElementById('menu-toggle').setAttribute('aria-expanded', 'true');
}

function closeDrawer() {
  document.getElementById('drawer').classList.remove('drawer--open');
  document.getElementById('drawer-overlay').classList.remove('drawer-overlay--visible');
  document.getElementById('menu-toggle').setAttribute('aria-expanded', 'false');
}

if (session) {
  document.getElementById('welcome-name').textContent = t('topbar.hi', { name: session.username });
  document.getElementById('welcome-role').textContent = session.role;

  document.getElementById('logout-btn').addEventListener('click', () => {
    clearSession();
    window.location.href = 'index.html';
  });

  document.getElementById('menu-toggle').addEventListener('click', openDrawer);
  document.getElementById('drawer-close').addEventListener('click', closeDrawer);
  document.getElementById('drawer-overlay').addEventListener('click', closeDrawer);
  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') closeDrawer();
  });

  renderDrawerNav();
  renderDrawerUser();
}

// Show the signed-in user inside the drawer too — on mobile the topbar greeting
// is hidden to keep the header on one row, so this is where identity lives there.
function renderDrawerUser() {
  const navList = document.getElementById('drawer-nav-list');
  if (!navList || document.getElementById('drawer-user')) return;

  const userEl = document.createElement('div');
  userEl.id = 'drawer-user';
  userEl.className = 'drawer__user';
  userEl.innerHTML = '<span class="drawer__user-name"></span><span class="badge"></span>';
  userEl.querySelector('.drawer__user-name').textContent = t('topbar.hi', { name: session.username });
  userEl.querySelector('.badge').textContent = session.role;
  navList.parentNode.insertBefore(userEl, navList);
}
