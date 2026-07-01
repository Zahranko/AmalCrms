const form = document.getElementById('login-form');
const usernameInput = document.getElementById('username');
const passwordInput = document.getElementById('password');
const errorBox = document.getElementById('form-error');
const submitBtn = document.getElementById('submit-btn');
const submitLabel = submitBtn.querySelector('.btn-submit__label');
const submitSpinner = submitBtn.querySelector('.btn-submit__spinner');
const togglePasswordBtn = document.getElementById('toggle-password');

const existingSession = getSession();
if (existingSession) {
  window.location.href = 'dashboard.html';
}

togglePasswordBtn.addEventListener('click', () => {
  const isPassword = passwordInput.type === 'password';
  passwordInput.type = isPassword ? 'text' : 'password';
  togglePasswordBtn.setAttribute('aria-label', isPassword ? t('login.hidePassword') : t('login.showPassword'));
});

function setError(message) {
  if (!message) {
    errorBox.hidden = true;
    errorBox.textContent = '';
    return;
  }
  errorBox.hidden = false;
  errorBox.textContent = message;
}

function setLoading(isLoading) {
  submitBtn.disabled = isLoading;
  submitLabel.textContent = isLoading ? t('login.signingIn') : t('login.signIn');
  submitSpinner.hidden = !isLoading;
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  setError(null);

  const username = usernameInput.value.trim();
  const password = passwordInput.value;

  if (!username || !password) {
    setError(t('login.errorEmpty'));
    return;
  }

  setLoading(true);
  try {
    const session = await apiLogin(username, password);
    saveSession(session);
    window.location.href = 'dashboard.html';
  } catch (err) {
    setError(err.message || t('login.errorGeneric'));
  } finally {
    setLoading(false);
  }
});
