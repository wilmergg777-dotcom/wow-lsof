// backend/middlewares/validators.js
const { body, param, validationResult } = require('express-validator');

// ─────────────────────────────────────────────
// Helper genérico para recolectar errores
// ─────────────────────────────────────────────
const handleValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

// ═════════════════════════════════════════════
// AUTH
// ═════════════════════════════════════════════

const validateRegister = [
  body('username')
    .isString().trim()
    .isLength({ min: 3, max: 32 }).withMessage('Usuario: 3-32 caracteres')
    .matches(/^[a-zA-Z0-9_]+$/).withMessage('Solo letras, números y guion bajo'),
  body('password')
    .isString()
    .isLength({ min: 8, max: 128 }).withMessage('Contraseña: 8-128 caracteres')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Debe tener mayúscula, minúscula y número'),
  body('email')
    .optional({ values: 'falsy' })
    .isEmail().withMessage('Email inválido')
    .normalizeEmail()
    .isLength({ max: 254 }),
  body('phone')
    .optional({ values: 'falsy' })
    .isString().trim()
    .isLength({ min: 5, max: 30 }),
  body('referred_by')
    .optional({ values: 'falsy' })
    .isInt({ min: 1 }).withMessage('referred_by inválido'),
  handleValidation,
];

// ⚠️ Tu ruta usa `identifier` (username | email | phone), NO `email`.
const validateLogin = [
  body('identifier')
    .isString().trim()
    .isLength({ min: 3, max: 254 })
    .withMessage('Debes ingresar usuario, email o teléfono'),
  body('password')
    .isString()
    .isLength({ min: 1, max: 128 })
    .withMessage('Contraseña inválida'),
  handleValidation,
];

const validateSetEmail = [
  body('email').isEmail().withMessage('Email inválido').normalizeEmail().isLength({ max: 254 }),
  body('temp_token').isString().isLength({ min: 10 }),
  handleValidation,
];

const validateLoginCode = [
  body('identifier').isString().trim().isLength({ min: 3, max: 254 }),
  body('code').isString().isLength({ min: 6, max: 6 }).isNumeric().withMessage('Código de 6 dígitos'),
  handleValidation,
];

// ═════════════════════════════════════════════
// USER
// ═════════════════════════════════════════════

const validateProfileUpdate = [
  body('username')
    .isString().trim()
    .isLength({ min: 3, max: 32 })
    .matches(/^[a-zA-Z0-9_]+$/),
  body('email')
    .optional({ values: 'falsy' })
    .isEmail().normalizeEmail().isLength({ max: 254 }),
  body('phone')
    .optional({ values: 'falsy' })
    .isString().trim().isLength({ min: 5, max: 30 }),
  body('avatar_url')
    .optional({ values: 'falsy' })
    .isString().isLength({ max: 500 }),
  handleValidation,
];

const validatePhoneUpdate = [
  body('phone').isString().trim().isLength({ min: 5, max: 30 }),
  handleValidation,
];

const validatePasswordChange = [
  body('oldPassword').isString().isLength({ min: 1, max: 128 }),
  body('newPassword')
    .isString().isLength({ min: 8, max: 128 })
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Debe tener mayúscula, minúscula y número'),
  handleValidation,
];

const validatePayPin = [
  body('pin').isString().matches(/^\d{4,6}$/).withMessage('El PIN debe tener 4-6 dígitos'),
  handleValidation,
];

const validatePayPinToggle = [
  body('enabled').isBoolean().toBoolean(),
  handleValidation,
];

const validateBankData = [
  body('card_number').isString().trim().isLength({ min: 8, max: 25 }).isNumeric(),
  body('phone').isString().trim().isLength({ min: 5, max: 30 }),
  body('holder_name').isString().trim().isLength({ min: 3, max: 100 }),
  body('bank_name').isString().trim().isLength({ min: 2, max: 100 }),
  handleValidation,
];

// ═════════════════════════════════════════════
// WALLET
// ═════════════════════════════════════════════

const validateDeposit = [
  body('amount_cup').isFloat({ min: 1, max: 1000000 }).withMessage('Monto CUP inválido'),
  body('transaction_id').isString().trim().isLength({ min: 4, max: 100 }),
  handleValidation,
];

const validateWithdraw = [
  body('amount_ntx').isFloat({ min: 1, max: 1000000 }).withMessage('Monto NTX inválido'),
  body('card_number').isString().trim().isLength({ min: 8, max: 25 }).isNumeric(),
  body('holder_name').isString().trim().isLength({ min: 3, max: 100 }),
  body('bank_name').isString().trim().isLength({ min: 2, max: 100 }),
  body('pin').isString().matches(/^\d{4,6}$/),
  handleValidation,
];

const validateWithdrawVerify = [
  body('code').isString().isLength({ min: 6, max: 6 }).isNumeric(),
  handleValidation,
];

const validateTransferLegacy = [
  body('receiverUsername').isString().trim().isLength({ min: 3, max: 32 }),
  body('amount').isFloat({ min: 0.01, max: 1000000 }),
  handleValidation,
];

const validateTransferRequest = [
  body('receiverUniqueId').isString().trim().isLength({ min: 1, max: 32 }),
  body('amount').isFloat({ min: 0.01, max: 1000000 }),
  body('pin').isString().matches(/^\d{4,6}$/),
  handleValidation,
];

const validateTransferVerify = [
  body('receiverUniqueId').isString().trim().isLength({ min: 1, max: 32 }),
  body('amount').isFloat({ min: 0.01, max: 1000000 }),
  body('code').isString().isLength({ min: 6, max: 6 }).isNumeric(),
  handleValidation,
];

// ═════════════════════════════════════════════
// ADMIN
// ═════════════════════════════════════════════

const validateRequestId = [
  body('request_id').isInt({ min: 1 }).withMessage('request_id inválido'),
  handleValidation,
];

const validateAdminSettingsToggle = [
  body('setting').isIn([
    'retiros_activos', 'inversiones_activas',
    'bonus_porcentaje', 'bonus_limite_total',
  ]).withMessage('Ajuste inválido'),
  body('value').exists(),
  handleValidation,
];

const validateFundAdmin = [
  body('admin_id').isInt({ min: 1 }),
  body('amount').isFloat({ min: 0.01, max: 1000000 }),
  handleValidation,
];

const validateServerConfig = [
  body('discord_client_id').isString().trim().isLength({ max: 100 }),
  body('discord_client_secret').isString().trim().isLength({ max: 200 }),
  body('discord_redirect_uri').isString().trim().isURL().isLength({ max: 500 }),
  handleValidation,
];

const validateSmtpConfig = [
  body('smtp_host').isString().trim().isLength({ min: 1, max: 255 }),
  body('smtp_port').isInt({ min: 1, max: 65535 }),
  body('smtp_user').isString().trim().isLength({ min: 1, max: 255 }),
  body('smtp_pass').isString().isLength({ min: 1, max: 255 }),
  body('smtp_from_email').isEmail().normalizeEmail(),
  body('smtp_from_name').isString().trim().isLength({ min: 1, max: 100 }),
  body('smtp_secure').optional().isBoolean().toBoolean(),
  handleValidation,
];

const validateSmtpTest = [
  body('test_email').isEmail().normalizeEmail(),
  handleValidation,
];

const validateAnnouncement = [
  body('title').isString().trim().isLength({ min: 1, max: 200 }),
  body('message').isString().trim().isLength({ min: 1, max: 5000 }),
  body('sendToWeb').optional().isBoolean().toBoolean(),
  body('sendToEmail').optional().isBoolean().toBoolean(),
  handleValidation,
];

// ═════════════════════════════════════════════
// CLUBS
// ═════════════════════════════════════════════

const validateClubCreate = [
  body('name').isString().trim().isLength({ min: 1, max: 100 }),
  handleValidation,
];

const validateClubJoin = [
  body('code').isString().trim().isLength({ min: 4, max: 20 }),
  handleValidation,
];

const validateClubUpdate = [
  body('name').isString().trim().isLength({ min: 1, max: 100 }),
  body('description').optional({ values: 'falsy' }).isString().trim().isLength({ max: 1000 }),
  body('avatar_url').optional({ values: 'falsy' }).isString().isLength({ max: 500 }),
  handleValidation,
];

const validateClubDiscord = [
  body('discord_client_id').isString().trim().isLength({ max: 100 }),
  body('discord_client_secret').isString().trim().isLength({ max: 200 }),
  body('discord_redirect_uri').isString().trim().isURL().isLength({ max: 500 }),
  handleValidation,
];

const validateTemplateOrTable = [
  body('title').isString().trim().isLength({ min: 1, max: 200 }),
  body('type').isString().trim().isLength({ min: 1, max: 50 }),
  body('mode').isString().trim().isLength({ min: 1, max: 50 }),
  body('settings').isObject().withMessage('settings debe ser un objeto'),
  handleValidation,
];

// ═════════════════════════════════════════════
// GAMES
// ═════════════════════════════════════════════

const validateGameRegister = [
  body('gameId').exists().withMessage('gameId requerido').notEmpty(),
  handleValidation,
];

const validateBuyIn = [
  body('amount').isFloat({ min: 0.01, max: 1000000 }).withMessage('Monto inválido'),
  body('tableId').isString().trim().isLength({ min: 1, max: 100 }),
  handleValidation,
];

const validateCashOut = [
  body('amount').isFloat({ min: 0.01, max: 1000000 }),
  handleValidation,
];

const validateProcessRake = [
  body('rakeAmount').isFloat({ min: 0.01, max: 1000000 }),
  body('playerId').isInt({ min: 1 }),
  handleValidation,
];

// ═════════════════════════════════════════════
// PARAMS REUTILIZABLES
// ═════════════════════════════════════════════

const validateIdParam = [
  param('id').isInt({ min: 1 }).withMessage('ID inválido'),
  handleValidation,
];

const validateUniqueIdParam = [
  param('uniqueId').isString().trim().isLength({ min: 1, max: 32 }),
  handleValidation,
];

// ═════════════════════════════════════════════
// 🔥 TIENDA
// ═════════════════════════════════════════════
const validateShopPurchase = [
  body('itemId').isInt({ min: 1 }).withMessage('Artículo inválido'),
  handleValidation,
];

const validateShopEquip = [
  body('itemId').isInt({ min: 1 }).withMessage('Artículo inválido'),
  handleValidation,
];

// ═════════════════════════════════════════════
// 🔥 CLUBES: niveles, fichas, miembros, torneos
// ═════════════════════════════════════════════
const validateClubTier = [
  body('tier').isInt({ min: 1, max: 3 }).withMessage('Nivel de club inválido (1 a 3)'),
  handleValidation,
];

const validateClubChips = [
  body('amount').isInt({ min: 1, max: 100000 }).withMessage('Cantidad de fichas inválida'),
  body('userId').optional({ nullable: true }).isInt({ min: 1 }).withMessage('Usuario inválido'),
  handleValidation,
];

const validateClubModerator = [
  body('userId').optional({ nullable: true }).isInt({ min: 1 }).withMessage('Usuario inválido'),
  handleValidation,
];

const validateClubKick = [
  body('userId').isInt({ min: 1 }).withMessage('Usuario inválido'),
  handleValidation,
];

const validateClubInvite = [
  body('query').isString().trim().isLength({ min: 1, max: 60 }).withMessage('Indica el usuario o su ID'),
  handleValidation,
];

const validateClubTournament = [
  body('name').isString().trim().isLength({ min: 1, max: 100 }).withMessage('Nombre del torneo inválido'),
  body('type').optional().isString().trim().isLength({ max: 20 }),
  body('mode').optional().isString().trim().isLength({ max: 20 }),
  body('visibility').optional().isIn(['members', 'public']).withMessage('Visibilidad inválida'),
  handleValidation,
];

// ═════════════════════════════════════════════
// EXPORTS
// ═════════════════════════════════════════════

module.exports = {
  handleValidation,

  // Shop (tienda)
  validateShopPurchase,
  validateShopEquip,

  // Auth
  validateRegister,
  validateLogin,
  validateSetEmail,
  validateLoginCode,

  // User
  validateProfileUpdate,
  validatePhoneUpdate,
  validatePasswordChange,
  validatePayPin,
  validatePayPinToggle,
  validateBankData,

  // Wallet
  validateDeposit,
  validateWithdraw,
  validateWithdrawVerify,
  validateTransferLegacy,
  validateTransferRequest,
  validateTransferVerify,

  // Admin
  validateRequestId,
  validateAdminSettingsToggle,
  validateFundAdmin,
  validateServerConfig,
  validateSmtpConfig,
  validateSmtpTest,
  validateAnnouncement,

  // Clubs
  validateClubCreate,
  validateClubJoin,
  validateClubUpdate,
  validateClubDiscord,
  validateTemplateOrTable,
  validateClubTier,
  validateClubChips,
  validateClubModerator,
  validateClubKick,
  validateClubInvite,
  validateClubTournament,

  // Games
  validateGameRegister,
  validateBuyIn,
  validateCashOut,
  validateProcessRake,

  // Params
  validateIdParam,
  validateUniqueIdParam,
};