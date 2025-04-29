const TestStatistic = require('../models/TestStatistic');
const { validationResult } = require('express-validator');

// Créer une nouvelle statistique de test
exports.createTestStatistic = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      testName,
      testType,
      duration,
      success,
      errorCount,
      warningCount,
      module,
      environment,
      executedBy,
      details,
      notes
    } = req.body;

    // Créer la nouvelle statistique
    const testStatistic = new TestStatistic({
      testName,
      testType,
      duration,
      success,
      errorCount,
      warningCount,
      module,
      environment,
      executedBy,
      details,
      notes
    });

    await testStatistic.save();

    res.status(201).json({
      success: true,
      data: testStatistic
    });
  } catch (error) {
    console.error('Erreur lors de la création de la statistique:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la création de la statistique de test',
      error: error.message
    });
  }
};

// Récupérer toutes les statistiques avec possibilité de filtrage
exports.getAllTestStatistics = async (req, res) => {
  try {
    const {
      testName,
      testType,
      module,
      environment,
      success,
      startDate,
      endDate,
      sort = '-executionDate',
      limit = 50,
      page = 1
    } = req.query;

    // Construire le filtre
    const filter = {};
    if (testName) filter.testName = testName;
    if (testType) filter.testType = testType;
    if (module) filter.module = module;
    if (environment) filter.environment = environment;
    if (success !== undefined) filter.success = success === 'true';

    // Filtrage par date
    if (startDate || endDate) {
      filter.executionDate = {};
      if (startDate) filter.executionDate.$gte = new Date(startDate);
      if (endDate) filter.executionDate.$lte = new Date(endDate);
    }

    // Pagination
    const skip = (page - 1) * limit;

    // Exécuter la requête
    const statistics = await TestStatistic.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(parseInt(limit))
      .populate('executedBy', 'nom email');

    // Compter le nombre total de documents pour la pagination
    const total = await TestStatistic.countDocuments(filter);

    res.json({
      success: true,
      count: statistics.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: parseInt(page),
      data: statistics
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des statistiques:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération des statistiques de test',
      error: error.message
    });
  }
};

// Récupérer une statistique spécifique par ID
exports.getTestStatisticById = async (req, res) => {
  try {
    const statistic = await TestStatistic.findById(req.params.id)
      .populate('executedBy', 'nom email');
    
    if (!statistic) {
      return res.status(404).json({
        success: false,
        message: 'Statistique de test non trouvée'
      });
    }

    res.json({
      success: true,
      data: statistic
    });
  } catch (error) {
    console.error('Erreur lors de la récupération de la statistique:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la récupération de la statistique de test',
      error: error.message
    });
  }
};

// Mettre à jour une statistique
exports.updateTestStatistic = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      testName,
      testType,
      duration,
      success,
      errorCount,
      warningCount,
      module,
      environment,
      executedBy,
      details,
      notes
    } = req.body;

    const statistic = await TestStatistic.findById(req.params.id);
    if (!statistic) {
      return res.status(404).json({
        success: false,
        message: 'Statistique de test non trouvée'
      });
    }

    // Mise à jour des champs
    if (testName) statistic.testName = testName;
    if (testType) statistic.testType = testType;
    if (duration !== undefined) statistic.duration = duration;
    if (success !== undefined) statistic.success = success;
    if (errorCount !== undefined) statistic.errorCount = errorCount;
    if (warningCount !== undefined) statistic.warningCount = warningCount;
    if (module) statistic.module = module;
    if (environment) statistic.environment = environment;
    if (executedBy) statistic.executedBy = executedBy;
    if (details) statistic.details = details;
    if (notes) statistic.notes = notes;

    await statistic.save();

    res.json({
      success: true,
      data: statistic
    });
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la statistique:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour de la statistique de test',
      error: error.message
    });
  }
};

// Supprimer une statistique
exports.deleteTestStatistic = async (req, res) => {
  try {
    const statistic = await TestStatistic.findById(req.params.id);
    if (!statistic) {
      return res.status(404).json({
        success: false,
        message: 'Statistique de test non trouvée'
      });
    }

    await TestStatistic.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Statistique de test supprimée avec succès'
    });
  } catch (error) {
    console.error('Erreur lors de la suppression de la statistique:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la suppression de la statistique de test',
      error: error.message
    });
  }
};

// Obtenir des rapports agrégés
exports.getTestStatisticsReports = async (req, res) => {
  try {
    const { module, startDate, endDate, groupBy = 'testName' } = req.query;

    // Construire le filtre
    const filter = {};
    if (module) filter.module = module;

    // Filtrage par date
    if (startDate || endDate) {
      filter.executionDate = {};
      if (startDate) filter.executionDate.$gte = new Date(startDate);
      if (endDate) filter.executionDate.$lte = new Date(endDate);
    }

    // Définir le champ de regroupement
    let groupField;
    switch(groupBy) {
      case 'testType':
        groupField = '$testType';
        break;
      case 'module':
        groupField = '$module';
        break;
      case 'environment':
        groupField = '$environment';
        break;
      case 'daily':
        groupField = { 
          $dateToString: { format: '%Y-%m-%d', date: '$executionDate' } 
        };
        break;
      case 'weekly':
        groupField = { 
          $dateToString: { format: '%Y-%U', date: '$executionDate' } 
        };
        break;
      case 'monthly':
        groupField = { 
          $dateToString: { format: '%Y-%m', date: '$executionDate' } 
        };
        break;
      default: // testName
        groupField = '$testName';
    }

    // Exécuter l'agrégation
    const reports = await TestStatistic.aggregate([
      { $match: filter },
      { $group: {
        _id: groupField,
        count: { $sum: 1 },
        successCount: { $sum: { $cond: [{ $eq: ['$success', true] }, 1, 0] } },
        failureCount: { $sum: { $cond: [{ $eq: ['$success', false] }, 1, 0] } },
        avgDuration: { $avg: '$duration' },
        totalDuration: { $sum: '$duration' },
        totalErrors: { $sum: '$errorCount' },
        totalWarnings: { $sum: '$warningCount' }
      }},
      { $project: {
        _id: 0,
        name: '$_id',
        count: 1,
        successCount: 1,
        failureCount: 1,
        successRate: { 
          $multiply: [
            { $divide: ['$successCount', '$count'] },
            100
          ]
        },
        avgDuration: 1,
        totalDuration: 1,
        totalErrors: 1,
        totalWarnings: 1
      }},
      { $sort: { name: 1 } }
    ]);

    res.json({
      success: true,
      count: reports.length,
      data: reports
    });
  } catch (error) {
    console.error('Erreur lors de la génération des rapports:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la génération des rapports de statistiques',
      error: error.message
    });
  }
};

// Comparer les performances entre deux périodes
exports.compareTestPerformance = async (req, res) => {
  try {
    const { 
      testName, 
      module,
      firstPeriodStart, 
      firstPeriodEnd, 
      secondPeriodStart, 
      secondPeriodEnd 
    } = req.query;

    if (!firstPeriodStart || !firstPeriodEnd || !secondPeriodStart || !secondPeriodEnd) {
      return res.status(400).json({
        success: false,
        message: 'Les dates des deux périodes sont requises'
      });
    }

    // Construire le filtre de base
    const baseFilter = {};
    if (testName) baseFilter.testName = testName;
    if (module) baseFilter.module = module;

    // Filtre pour la première période
    const firstPeriodFilter = {
      ...baseFilter,
      executionDate: {
        $gte: new Date(firstPeriodStart),
        $lte: new Date(firstPeriodEnd)
      }
    };

    // Filtre pour la seconde période
    const secondPeriodFilter = {
      ...baseFilter,
      executionDate: {
        $gte: new Date(secondPeriodStart),
        $lte: new Date(secondPeriodEnd)
      }
    };

    // Fonction pour obtenir les statistiques agrégées pour une période
    const getStatsForPeriod = async (filter) => {
      const groupBy = testName ? '$testType' : '$testName';
      
      return await TestStatistic.aggregate([
        { $match: filter },
        { $group: {
          _id: groupBy,
          count: { $sum: 1 },
          successCount: { $sum: { $cond: [{ $eq: ['$success', true] }, 1, 0] } },
          avgDuration: { $avg: '$duration' },
          totalErrors: { $sum: '$errorCount' }
        }},
        { $project: {
          _id: 0,
          name: '$_id',
          count: 1,
          successCount: 1,
          successRate: { 
            $multiply: [
              { $divide: ['$successCount', { $max: ['$count', 1] }] },
              100
            ]
          },
          avgDuration: 1,
          totalErrors: 1
        }}
      ]);
    };

    // Obtenir les statistiques pour les deux périodes
    const [firstPeriodStats, secondPeriodStats] = await Promise.all([
      getStatsForPeriod(firstPeriodFilter),
      getStatsForPeriod(secondPeriodFilter)
    ]);

    // Combiner les résultats pour la comparaison
    const comparison = [];
    
    // Map pour stocker temporairement les stats de la première période
    const firstPeriodMap = {};
    firstPeriodStats.forEach(stat => {
      firstPeriodMap[stat.name] = stat;
    });

    // Parcourir les stats de la seconde période et faire la comparaison
    secondPeriodStats.forEach(secondStat => {
      const firstStat = firstPeriodMap[secondStat.name] || {
        name: secondStat.name,
        count: 0,
        successCount: 0,
        successRate: 0,
        avgDuration: 0,
        totalErrors: 0
      };
      
      comparison.push({
        name: secondStat.name,
        firstPeriod: {
          count: firstStat.count,
          successRate: firstStat.successRate,
          avgDuration: firstStat.avgDuration,
          totalErrors: firstStat.totalErrors
        },
        secondPeriod: {
          count: secondStat.count,
          successRate: secondStat.successRate,
          avgDuration: secondStat.avgDuration,
          totalErrors: secondStat.totalErrors
        },
        changes: {
          countChange: secondStat.count - firstStat.count,
          successRateChange: secondStat.successRate - firstStat.successRate,
          durationChange: secondStat.avgDuration - firstStat.avgDuration,
          errorChange: secondStat.totalErrors - firstStat.totalErrors
        }
      });
      
      // Supprimer du map pour identifier les éléments présents uniquement dans la première période
      delete firstPeriodMap[secondStat.name];
    });
    
    // Ajouter les éléments présents uniquement dans la première période
    Object.values(firstPeriodMap).forEach(firstStat => {
      comparison.push({
        name: firstStat.name,
        firstPeriod: {
          count: firstStat.count,
          successRate: firstStat.successRate,
          avgDuration: firstStat.avgDuration,
          totalErrors: firstStat.totalErrors
        },
        secondPeriod: {
          count: 0,
          successRate: 0,
          avgDuration: 0,
          totalErrors: 0
        },
        changes: {
          countChange: -firstStat.count,
          successRateChange: -firstStat.successRate,
          durationChange: -firstStat.avgDuration,
          errorChange: -firstStat.totalErrors
        }
      });
    });

    res.json({
      success: true,
      firstPeriod: {
        start: firstPeriodStart,
        end: firstPeriodEnd
      },
      secondPeriod: {
        start: secondPeriodStart,
        end: secondPeriodEnd
      },
      comparison
    });
  } catch (error) {
    console.error('Erreur lors de la comparaison des performances:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur lors de la comparaison des performances de test',
      error: error.message
    });
  }
}; 