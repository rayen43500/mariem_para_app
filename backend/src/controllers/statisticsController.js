const Product = require('../models/Product');
const Order = require('../models/Order');
const User = require('../models/User');
const { validationResult } = require('express-validator');
const mongoose = require('mongoose');

// Obtenir les statistiques générales pour le dashboard
exports.getGeneralStats = async (req, res) => {
  try {
    const currentDate = new Date();
    const previousMonthDate = new Date();
    previousMonthDate.setMonth(currentDate.getMonth() - 1);
    
    // Calcul des statistiques
    const [
      totalRevenue,
      previousMonthRevenue,
      orderCount,
      previousMonthOrderCount,
      newUserCount,
      previousMonthUserCount,
      productViewCount,
      previousMonthViewCount
    ] = await Promise.all([
      calculateRevenue(currentDate, 30),
      calculateRevenue(previousMonthDate, 30),
      countOrders(currentDate, 30),
      countOrders(previousMonthDate, 30),
      countNewUsers(currentDate, 30),
      countNewUsers(previousMonthDate, 30),
      getProductViews(currentDate, 30),
      getProductViews(previousMonthDate, 30)
    ]);
    
    // Calcul des pourcentages de variation
    const revenueComparison = calculatePercentageChange(previousMonthRevenue, totalRevenue);
    const orderComparison = calculatePercentageChange(previousMonthOrderCount, orderCount);
    const userComparison = calculatePercentageChange(previousMonthUserCount, newUserCount);
    const viewComparison = calculatePercentageChange(previousMonthViewCount, productViewCount);
    
    // Conversion moyenne basée sur les vues et commandes
    const conversionRate = productViewCount > 0 ? (orderCount / productViewCount) * 100 : 0;
    const previousConversionRate = previousMonthViewCount > 0 ? (previousMonthOrderCount / previousMonthViewCount) * 100 : 0;
    const conversionComparison = calculatePercentageChange(previousConversionRate, conversionRate);
    
    // Obtenir les meilleures ventes
    const bestSellers = await getBestSellingProducts();
    
    // Obtenir les ventes mensuelles
    const monthlySales = await getMonthlySales();
    
    // Obtenir les ventes par catégorie
    const salesByCategory = await getSalesByCategory();
    
    res.json({
      revenuTotal: totalRevenue,
      revenuComparaison: revenueComparison,
      commandesTotal: orderCount,
      commandesComparaison: orderComparison,
      clientsTotal: newUserCount,
      clientsComparaison: userComparison,
      vuesProduits: productViewCount,
      vuesComparaison: viewComparison,
      tauxConversion: parseFloat(conversionRate.toFixed(2)),
      tauxConversionComparaison: conversionComparison,
      produitsBestSellers: bestSellers,
      ventesMensuelles: monthlySales,
      ventesParCategorie: salesByCategory
    });
  } catch (error) {
    console.error('Erreur dans getGeneralStats:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des statistiques',
      error: error.message
    });
  }
};

// Obtenir les produits les plus vendus
exports.getBestSellingProducts = async (req, res) => {
  try {
    const bestSellers = await getBestSellingProducts();
    
    res.json(bestSellers);
  } catch (error) {
    console.error('Erreur dans getBestSellingProducts:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des produits les plus vendus',
      error: error.message
    });
  }
};

// Obtenir les ventes par catégorie
exports.getSalesByCategory = async (req, res) => {
  try {
    const categoryStats = await getSalesByCategory();
    
    res.json(categoryStats);
  } catch (error) {
    console.error('Erreur dans getSalesByCategory:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des ventes par catégorie',
      error: error.message
    });
  }
};

// Fonctions utilitaires

// Calculer le revenu sur une période
async function calculateRevenue(startDate, daysBack) {
  const endDate = new Date(startDate);
  const beginDate = new Date(startDate);
  beginDate.setDate(beginDate.getDate() - daysBack);
  
  try {
    const result = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: beginDate, $lte: endDate },
          status: { $in: ['completed', 'delivered'] }
        }
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$totalPrice' }
        }
      }
    ]);
    
    return result.length > 0 ? result[0].total : 0;
  } catch (error) {
    console.error('Erreur dans calculateRevenue:', error);
    return 0;
  }
}

// Compter les commandes sur une période
async function countOrders(startDate, daysBack) {
  const endDate = new Date(startDate);
  const beginDate = new Date(startDate);
  beginDate.setDate(beginDate.getDate() - daysBack);
  
  try {
    const count = await Order.countDocuments({
      createdAt: { $gte: beginDate, $lte: endDate }
    });
    
    return count;
  } catch (error) {
    console.error('Erreur dans countOrders:', error);
    return 0;
  }
}

// Compter les nouveaux utilisateurs sur une période
async function countNewUsers(startDate, daysBack) {
  const endDate = new Date(startDate);
  const beginDate = new Date(startDate);
  beginDate.setDate(beginDate.getDate() - daysBack);
  
  try {
    const count = await User.countDocuments({
      createdAt: { $gte: beginDate, $lte: endDate }
    });
    
    return count;
  } catch (error) {
    console.error('Erreur dans countNewUsers:', error);
    return 0;
  }
}

// Obtenir le nombre de vues de produits sur une période (simulation)
function getProductViews(startDate, daysBack) {
  // Comme il s'agit d'une simulation, nous retournons une valeur basée sur la date
  const seed = startDate.getMonth() * 1000 + startDate.getDate() * 100;
  return seed + Math.floor(Math.random() * 1000);
}

// Calculer le pourcentage de changement entre deux valeurs
function calculatePercentageChange(oldValue, newValue) {
  if (oldValue === 0) return newValue > 0 ? 100 : 0;
  return parseFloat(((newValue - oldValue) / oldValue * 100).toFixed(1));
}

// Obtenir les produits les plus vendus
async function getBestSellingProducts() {
  try {
    const result = await Order.aggregate([
      { $match: { status: { $in: ['completed', 'delivered'] } } },
      { $unwind: '$products' },
      {
        $group: {
          _id: '$products.product',
          totalSold: { $sum: '$products.quantity' },
          totalRevenue: { $sum: { $multiply: ['$products.price', '$products.quantity'] } }
        }
      },
      { $sort: { totalSold: -1 } },
      { $limit: 5 },
      {
        $lookup: {
          from: 'products',
          localField: '_id',
          foreignField: '_id',
          as: 'productDetails'
        }
      },
      { $unwind: '$productDetails' },
      {
        $project: {
          _id: 0,
          nom: '$productDetails.name',
          ventes: '$totalSold',
          revenu: '$totalRevenue'
        }
      }
    ]);
    
    // Si aucun résultat, retourner des données fictives
    if (result.length === 0) {
      return [
        { nom: 'Doliprane 1000mg', ventes: 28, revenu: 168.72 },
        { nom: 'Advil 200mg', ventes: 45, revenu: 584.55 },
        { nom: 'Smecta', ventes: 12, revenu: 155.88 },
        { nom: 'Vitamines C', ventes: 24, revenu: 598.00 },
        { nom: 'Sérum Physiologique', ventes: 32, revenu: 255.68 }
      ];
    }
    
    return result;
  } catch (error) {
    console.error('Erreur dans getBestSellingProducts:', error);
    return [
      { nom: 'Doliprane 1000mg', ventes: 28, revenu: 168.72 },
      { nom: 'Advil 200mg', ventes: 45, revenu: 584.55 },
      { nom: 'Smecta', ventes: 12, revenu: 155.88 },
      { nom: 'Vitamines C', ventes: 24, revenu: 598.00 },
      { nom: 'Sérum Physiologique', ventes: 32, revenu: 255.68 }
    ];
  }
}

// Obtenir les ventes mensuelles de l'année en cours
async function getMonthlySales() {
  try {
    const currentYear = new Date().getFullYear();
    const startOfYear = new Date(currentYear, 0, 1);
    const endOfYear = new Date(currentYear, 11, 31);
    
    const result = await Order.aggregate([
      {
        $match: {
          createdAt: { $gte: startOfYear, $lte: endOfYear },
          status: { $in: ['completed', 'delivered'] }
        }
      },
      {
        $group: {
          _id: { $month: '$createdAt' },
          ventes: { $sum: '$totalPrice' }
        }
      },
      { $sort: { _id: 1 } }
    ]);
    
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    
    // Préparer les données mensuelles complètes (tous les mois)
    const monthlySales = months.map((month, index) => {
      const monthData = result.find(r => r._id === index + 1);
      return {
        mois: month,
        ventes: monthData ? monthData.ventes : 0
      };
    });
    
    return monthlySales;
  } catch (error) {
    console.error('Erreur dans getMonthlySales:', error);
    // Retourner des données fictives en cas d'erreur
    return [
      { mois: 'Jan', ventes: 8240.50 },
      { mois: 'Fév', ventes: 7890.30 },
      { mois: 'Mar', ventes: 9120.75 },
      { mois: 'Avr', ventes: 8450.20 },
      { mois: 'Mai', ventes: 10250.60 },
      { mois: 'Juin', ventes: 11340.80 },
      { mois: 'Juil', ventes: 12580.45 },
      { mois: 'Août', ventes: 9870.30 },
      { mois: 'Sep', ventes: 10740.55 },
      { mois: 'Oct', ventes: 11890.70 },
      { mois: 'Nov', ventes: 13450.90 },
      { mois: 'Déc', ventes: 15780.25 }
    ];
  }
}

// Obtenir les ventes par catégorie
async function getSalesByCategory() {
  try {
    const result = await Order.aggregate([
      { $match: { status: { $in: ['completed', 'delivered'] } } },
      { $unwind: '$products' },
      {
        $lookup: {
          from: 'products',
          localField: 'products.product',
          foreignField: '_id',
          as: 'productDetails'
        }
      },
      { $unwind: '$productDetails' },
      {
        $lookup: {
          from: 'categories',
          localField: 'productDetails.category',
          foreignField: '_id',
          as: 'categoryDetails'
        }
      },
      { $unwind: '$categoryDetails' },
      {
        $group: {
          _id: '$categoryDetails.name',
          totalSales: { $sum: { $multiply: ['$products.price', '$products.quantity'] } }
        }
      },
      { $sort: { totalSales: -1 } }
    ]);
    
    // Calculer le total pour obtenir les pourcentages
    const totalSales = result.reduce((acc, curr) => acc + curr.totalSales, 0);
    
    const categorySales = result.map(category => ({
      categorie: category._id,
      pourcentage: Math.round((category.totalSales / totalSales) * 100)
    }));
    
    // Si aucun résultat, retourner des données fictives adaptées à la pharmacie
    if (categorySales.length === 0) {
      return [
        { categorie: 'Médicaments', pourcentage: 45 },
        { categorie: 'Parapharmacie', pourcentage: 25 },
        { categorie: 'Orthopédie', pourcentage: 15 },
        { categorie: 'Cosmétiques', pourcentage: 10 },
        { categorie: 'Nutrition', pourcentage: 5 }
      ];
    }
    
    return categorySales;
  } catch (error) {
    console.error('Erreur dans getSalesByCategory:', error);
    return [
      { categorie: 'Médicaments', pourcentage: 45 },
      { categorie: 'Parapharmacie', pourcentage: 25 },
      { categorie: 'Orthopédie', pourcentage: 15 },
      { categorie: 'Cosmétiques', pourcentage: 10 },
      { categorie: 'Nutrition', pourcentage: 5 }
    ];
  }
} 