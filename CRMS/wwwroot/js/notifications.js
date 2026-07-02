// Notification center. Loaded on every authenticated page; injects a bell +
// dropdown into the topbar so the markup lives in one place instead of being
// duplicated across pages.
(function () {
  const session = typeof getSession === 'function' ? getSession() : null;
  if (!session) return;

  const host = document.querySelector('.topbar__user');
  if (!host) return;

  const wrap = document.createElement('div');
  wrap.className = 'notif';
  wrap.innerHTML = `
    <button type="button" class="notif__bell" id="notif-bell" aria-label="Notifications" aria-expanded="false">
      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
        <path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9" />
        <path d="M13.73 21a2 2 0 0 1-3.46 0" />
      </svg>
      <span class="notif__badge" id="notif-badge" hidden>0</span>
    </button>
    <div class="notif__panel" id="notif-panel" hidden>
      <div class="notif__header">
        <span>${t('notifications.title')}</span>
        <button type="button" class="notif__mark" id="notif-mark-all">${t('notifications.markAllRead')}</button>
      </div>
      <ul class="notif__list" id="notif-list">
        <li class="notif__empty">${t('notifications.loading')}</li>
      </ul>
    </div>`;
  host.insertBefore(wrap, host.firstChild);

  const bell = wrap.querySelector('#notif-bell');
  const badge = wrap.querySelector('#notif-badge');
  const panel = wrap.querySelector('#notif-panel');
  const list = wrap.querySelector('#notif-list');
  const markAllBtn = wrap.querySelector('#notif-mark-all');

  const TYPE_TARGET = {
    CaseForwarded: 'cases-forwarded-in.html',
    FollowUpReminder: 'cases-mine.html'
  };


  function setBadge(count) {
    if (!count) {
      badge.hidden = true;
      return;
    }
    badge.hidden = false;
    badge.textContent = count > 9 ? '9+' : String(count);
  }

  async function refreshCount() {
    try {
      const result = await apiGetUnreadCount();
      setBadge(result.count);
    } catch {
      /* silently ignore polling errors */
    }
  }

  function notificationTemplate(n) {
    const when = new Date(n.createdAt).toLocaleString();
    return `
      <li class="notif__row ${n.isRead ? '' : 'notif__row--unread'}">
        <button type="button" class="notif__item" data-id="${n.id}" data-type="${n.type}">
          <span class="notif__msg">${escapeHtml(n.message)}</span>
          <span class="notif__time">${when}</span>
        </button>
        <button type="button" class="notif__delete" data-delete-id="${n.id}" aria-label="${t('notifications.delete')}" title="${t('notifications.delete')}">
          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M3 6h18" />
            <path d="M8 6V4a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2" />
            <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6" />
            <path d="M10 11v6" /><path d="M14 11v6" />
          </svg>
        </button>
      </li>`;
  }

  async function loadList() {
    list.innerHTML = `<li class="notif__empty">${t('notifications.loading')}</li>`;
    try {
      const notifications = await apiGetNotifications();
      if (!notifications.length) {
        list.innerHTML = `<li class="notif__empty">${t('notifications.empty')}</li>`;
      } else {
        list.innerHTML = notifications.map(notificationTemplate).join('');
      }
      setBadge(notifications.filter((n) => !n.isRead).length);
    } catch (err) {
      list.innerHTML = `<li class="notif__empty">${escapeHtml(err.message)}</li>`;
    }
  }

  function openPanel() {
    panel.hidden = false;
    bell.setAttribute('aria-expanded', 'true');
    loadList();
  }

  function closePanel() {
    panel.hidden = true;
    bell.setAttribute('aria-expanded', 'false');
  }

  bell.addEventListener('click', (e) => {
    e.stopPropagation();
    if (panel.hidden) openPanel();
    else closePanel();
  });

  document.addEventListener('click', (e) => {
    if (!panel.hidden && !wrap.contains(e.target)) closePanel();
  });

  list.addEventListener('click', async (e) => {
    const deleteBtn = e.target.closest('[data-delete-id]');
    if (deleteBtn) {
      const id = Number(deleteBtn.dataset.deleteId);
      try {
        await apiDeleteNotification(id);
        await loadList();
      } catch {
        /* ignore */
      }
      return;
    }

    const item = e.target.closest('[data-id]');
    if (!item) return;
    const id = Number(item.dataset.id);
    const target = TYPE_TARGET[item.dataset.type];
    try {
      await apiMarkNotificationRead(id);
    } catch {
      /* navigate regardless */
    }
    if (target) window.location.href = target;
  });

  markAllBtn.addEventListener('click', async () => {
    try {
      await apiMarkAllNotificationsRead();
      await loadList();
      setBadge(0);
    } catch {
      /* ignore */
    }
  });

  // ── Real-time updates via SignalR ──────────────────────────────────────────
  // Load the SignalR client JS (served from our own wwwroot so no internet
  // dependency) then open a WebSocket connection to the hub. If the hub is
  // unreachable — at load or permanently later — we fall back to the old
  // 30-second poll.
  let pollTimer = null;
  function startPolling() {
    if (!pollTimer) pollTimer = setInterval(refreshCount, 30000);
  }

  function startSignalR() {
    const connection = new signalR.HubConnectionBuilder()
      .withUrl('/hubs/notifications', {
        accessTokenFactory: () => session.token
      })
      .withAutomaticReconnect([0, 2000, 5000, 10000, 30000])
      .configureLogging(signalR.LogLevel.Warning)
      .build();

    // Re-fetch the count rather than incrementing locally so the badge also
    // self-corrects after reads/deletes made from another tab or the mobile app.
    connection.on('NewNotification', () => {
      refreshCount();
      if (!panel.hidden) loadList();
    });

    // Pushes sent while the socket was down are not replayed — catch up.
    connection.onreconnected(() => {
      refreshCount();
      if (!panel.hidden) loadList();
    });

    // Fires once automatic reconnect gives up — without this the bell would
    // freeze until a full page reload.
    connection.onclose(() => startPolling());

    connection.start().catch(() => startPolling());
  }

  const signalRScript = document.createElement('script');
  // Loaded as a module so the bundle's top-level `var t, e` (webpack UMD
  // bootstrap vars) stay scoped to the module instead of clobbering the
  // app's global `t()` i18n helper on window. It still does `self.signalR = …`
  // explicitly, so window.signalR is unaffected.
  signalRScript.type = 'module';
  signalRScript.src = '/js/signalr.min.js';
  signalRScript.onload = startSignalR;
  signalRScript.onerror = () => startPolling();
  document.head.appendChild(signalRScript);

  // Initial badge count (immediate, before SignalR connects).
  refreshCount();
})();
