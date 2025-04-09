const rateLimit = require('express-rate-limit');

// Limite pour les tentatives de connexion
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 tentatives maximum
  message: 'Trop de tentatives de connexion. Veuillez réessayer plus tard.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Limite pour les inscriptions
const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 heure
  max: 3, // 3 inscriptions maximum par heure
  message: 'Trop de tentatives d\'inscription. Veuillez réessayer plus tard.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Limite pour les demandes de réinitialisation de mot de passe
const resetPasswordLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 heure
  max: 3, // 3 demandes maximum par heure
  message: 'Trop de demandes de réinitialisation. Veuillez réessayer plus tard.',
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = {
  loginLimiter,
  registerLimiter,
  resetPasswordLimiter
}; 