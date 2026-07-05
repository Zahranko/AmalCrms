const session = getSession();

if (!session) {
  window.location.href = 'index.html';
}

// A user reached an app page without an active website (e.g. a bookmark, or
// they can access several and haven't picked one). Route them correctly.
let activeWebsite = getActiveWebsite();
if (session && !activeWebsite) {
  window.location.href = routeIntoApp(session) || 'index.html';
}

// Drawer items per website. `crms` is the full CRM; `contact` is the placeholder
// site. Admin control items (Manage Lists / User Management / System Parameters)
// live in ADMIN_CONTROL_NAV and are shown for Admin inside every website — they
// act on whichever website is currently active.
const WEBSITE_NAV = {
  crms: [
    { href: 'dashboard.html', labelKey: 'nav.dashboard', roles: ['Employee', 'Manager', 'Admin'] },
    { href: 'newCase.html', labelKey: 'nav.newCase', roles: ['Employee', 'Manager', 'Admin'] },
    { href: 'cases-mine.html', labelKey: 'nav.cases', roles: ['Employee', 'Manager', 'Admin'] },
    { href: 'cases-forwarded-in.html', labelKey: 'nav.forwardedToMe', roles: ['Employee', 'Manager', 'Admin'] },
    { href: 'cases-forwarded-out.html', labelKey: 'nav.forwardedByMe', roles: ['Employee', 'Manager', 'Admin'] },
    { href: 'hospitalManagerDashboard.html', labelKey: 'nav.dashboard', roles: ['HospitalManager'] },
    { href: 'hospitalManagerDashboard.html', labelKey: 'nav.hospitalReport', roles: ['Admin'] }
  ],
  contact: [
    { href: 'contact.html', labelKey: 'nav.contact', roles: ['Employee', 'Manager', 'Admin', 'HospitalManager'] }
  ]
};

const ADMIN_CONTROL_NAV = [
  { href: 'manageLists.html', labelKey: 'nav.manageLists', roles: ['Admin'] },
  { href: 'userManage.html', labelKey: 'nav.userManagement', roles: ['Admin'] },
  { href: 'systemParams.html', labelKey: 'nav.systemParams', roles: ['Admin'] }
];

// Website-specific pages that aren't drawer items (detail/secondary pages).
const WEBSITE_EXTRA_PAGES = {
  crms: [
    { href: 'case.html', roles: ['Employee', 'Manager', 'Admin'] },
    { href: 'adminDashboard.html', roles: ['Admin'] }
  ],
  contact: []
};

// Flattened access table: { href, website (null = admin/any), roles }.
const PAGE_ACCESS = [];
for (const [wkey, items] of Object.entries(WEBSITE_NAV)) {
  items.forEach((it) => PAGE_ACCESS.push({ href: it.href, website: wkey, roles: it.roles }));
  (WEBSITE_EXTRA_PAGES[wkey] || []).forEach((p) => PAGE_ACCESS.push({ href: p.href, website: wkey, roles: p.roles }));
}
ADMIN_CONTROL_NAV.forEach((it) => PAGE_ACCESS.push({ href: it.href, website: null, roles: it.roles }));

// Human-readable role labels for the topbar/drawer badge.
function roleLabel(role) {
  return role === 'HospitalManager' ? t('role.hospitalManager') : role;
}

function currentPage() {
  return window.location.pathname.split('/').pop() || 'dashboard.html';
}

// Defense-in-depth on top of the backend's role checks. Also handles a deep link
// into a page that belongs to a different website than the active one: if the
// user can access that website, switch context to it; otherwise send them home.
function enforcePageAccess() {
  const page = currentPage();
  const entries = PAGE_ACCESS.filter((e) => e.href === page);
  if (!entries.length) return;

  const roleMatches = entries.filter((e) => !e.roles || e.roles.includes(session.role));
  if (!roleMatches.length) {
    window.location.href = homePage();
    return;
  }

  // Admin-control pages (website === null) work under any active website.
  if (roleMatches.some((e) => e.website === null)) return;

  const activeKey = (getActiveWebsite() || {}).key;
  if (roleMatches.some((e) => e.website === activeKey)) return;

  // Page belongs to another website — switch to it if the user has access.
  const targetKey = roleMatches[0].website;
  const target = getAccessibleWebsites().find((w) => w.key === targetKey);
  if (target) {
    setActiveWebsite(target);
    window.location.reload();
  } else {
    window.location.href = homePage();
  }
}

function renderDrawerNav() {
  const list = document.getElementById('drawer-nav-list');
  if (!list) return;

  const page = currentPage();
  const activeKey = (getActiveWebsite() || {}).key;
  let items = (WEBSITE_NAV[activeKey] || []).filter((item) => !item.roles || item.roles.includes(session.role));
  if (session.role === 'Admin') items = items.concat(ADMIN_CONTROL_NAV);

  list.innerHTML = items
    .map((item) => `<li><a href="${item.href}" class="${item.href === page ? 'active' : ''}">${t(item.labelKey)}</a></li>`)
    .join('');
}

// Website switcher in the topbar — shows the active website; if the user can
// access more than one, it opens the picker to switch.
function renderWebsiteSwitcher() {
  const active = getActiveWebsite();
  const container = document.querySelector('.topbar__user');
  if (!active || !container || document.getElementById('website-switcher')) return;

  const websites = getAccessibleWebsites();
  const multi = websites.length > 1;

  const el = document.createElement('button');
  el.id = 'website-switcher';
  el.type = 'button';
  el.className = 'website-switcher';
  el.title = t('website.current', { name: websiteName(active) });
  el.innerHTML =
    `<span class="website-switcher__label">${escapeHtml(websiteName(active))}</span>` +
    (multi ? '<span class="website-switcher__caret" aria-hidden="true">&#9662;</span>' : '');

  if (multi) {
    el.addEventListener('click', () => {
      window.location.href = 'websitePicker.html';
    });
  } else {
    el.classList.add('website-switcher--single');
  }
  container.insertBefore(el, container.firstChild);
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

if (session && activeWebsite) {
  enforcePageAccess();

  document.getElementById('welcome-name').textContent = t('topbar.hi', { name: session.username });
  document.getElementById('welcome-role').textContent = roleLabel(session.role);

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

  renderWebsiteSwitcher();
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
  userEl.querySelector('.badge').textContent = roleLabel(session.role);
  navList.parentNode.insertBefore(userEl, navList);
}
