const cartRoutes = require('./routes/cartRoutes');

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/produits', produitRoutes);
app.use('/api/commandes', commandeRoutes);
app.use('/api/panier', cartRoutes); 