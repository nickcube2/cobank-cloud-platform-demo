(async function () {
  const el = document.getElementById('backend-status');
  if (!el) return;

  function set(text, ok) {
    el.textContent = text;
    el.style.color = ok ? '#006747' : '#b00020';
  }

  try {
    set('Checking backend…', true);
    const res = await fetch('/api/health', { cache: 'no-store' });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const data = await res.json();
    set(`Backend: ${data.status} (${data.ts || data.timestamp || 'now'})`, true);
  } catch (e) {
    set('Backend: unreachable', false);
    // eslint-disable-next-line no-console
    console.warn('Backend health check failed', e);
  }
})();
