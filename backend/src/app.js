const cartRoutes = require('./routes/cartRoutes');
const paymentRoutes = require('./routes/paymentRoutes');
const deliveryRoutes = require('./routes/deliveryRoutes');
const adminRoutes = require('./routes/adminRoutes');
const promotionRoutes = require('./routes/promotionRoutes');

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/produits', produitRoutes);
app.use('/api/commandes', commandeRoutes);
app.use('/api/panier', cartRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/delivery', deliveryRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/promotions', promotionRoutes); 