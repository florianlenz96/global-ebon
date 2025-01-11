<template>
  <footer class="footer">
    <div class="footer-content">
      <p>VAT Number: 123456789</p>
      <p>Address: 123 Main street, EC 12345</p>
      <p>
        Contact:
        <a href="mailto:support@globale-bon.com">support@globale-bon.com</a>
      </p>
      <div class="social-media">
        <a href="#" aria-label="Facebook">FB</a>
        <a href="#" aria-label="Instagram">IG</a>
        <a href="#" aria-label="Twitter">TW</a>
      </div>
    </div>
    <p class="footer-bottom">
      &copy; 2025 Global eCommerce Store. All rights reserved.
    </p>
  </footer>
</template>

<style scoped>
.footer {
  width: 100%;
  padding: 2rem 1rem;
  background-color: var(--background-soft);
  border-top: 1px solid var(--border-color);
  text-align: center;
  animation: fadeIn 1s ease-in-out;
}

.footer-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.footer a {
  color: var(--primary-color);
  text-decoration: none;
  transition: color 0.3s;
}

.footer a:hover {
  color: var(--accent-color);
}

.social-media {
  display: flex;
  gap: 1rem;
  margin-top: 0.5rem;
}

.social-media a {
  display: inline-block;
  width: 30px;
  height: 30px;
  background-color: var(--secondary-color);
  color: var(--background-soft);
  border-radius: 50%;
  line-height: 30px;
  font-weight: bold;
  transition: background-color 0.3s, transform 0.3s;
}

.social-media a:hover {
  background-color: var(--primary-color);
  transform: scale(1.1);
}

.footer-bottom {
  margin-top: 1rem;
  color: var(--text-muted);
  font-size: 0.8rem;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
