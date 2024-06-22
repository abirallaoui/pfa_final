const express=require('express');
const router=express.Router();
var db=require('./db.js');



// Route pour obtenir les niveaux d'un professeur
router.get('/niveaux', (req, res) => {
    const email = req.query.email?.trim();
  
    if (!email || email === '') {
      res.status(400).send('Email du professeur est requis');
      return;
    }
  
    const sql = 'SELECT DISTINCT niveau.* FROM niveau INNER JOIN module ON niveau.id = module.id_niveau WHERE module.email_prof = ?';
  
    db.query(sql, [email], (err, results) => {
      if (err) {
        console.error('Erreur lors de la récupération des niveaux:', err);
        res.status(500).send('Erreur serveur');
        return;
      }
  
      res.json(results);
    });
  });
  
  // Route pour obtenir les modules d'un niveau pour un professeur
  router.get('/modules', (req, res) => {
    const email = req.query.email?.trim();
    const niveauId = req.query.niveauId;
  
    if (!email || email === '') {
      res.status(400).send('Email du professeur est requis');
      return;
    }
  
    if (!niveauId) {
      res.status(400).send('ID du niveau est requis');
      return;
    }
  
    const sql = 'SELECT * FROM module WHERE email_prof = ? AND id_niveau = ?';
  
    db.query(sql, [email, niveauId], (err, results) => {
      if (err) {
        console.error('Erreur lors de la récupération des modules:', err);
        res.status(500).send('Erreur serveur');
        return;
      }
  
      res.json(results);
    });
  });
  
  // Route pour obtenir la salle d'un module par son identifiant
  router.get('/module/:id/salle', (req, res) => {
    const moduleId = req.params.id;
  
    if (!moduleId) {
      res.status(400).send('L\'identifiant du module est requis');
      return;
    }
  
    const sql = 'SELECT salle FROM module WHERE id = ?';
  
    db.query(sql, [moduleId], (err, results) => {
      if (err) {
        console.error('Erreur lors de la récupération de la salle du module:', err);
        res.status(500).send('Erreur serveur');
        return;
      }
  
      if (results.length === 0) {
        res.status(404).send('Module non trouvé');
        return;
      }
  
      res.json(results[0]);
    });
  });
  

  // //insertion de codeqr
  router.post('/insertQR', (req, res) => {
    const { id_prof, id_module, date, id_niveau, salle } = req.body;
  
    console.log('Données reçues :', req.body);
  
    if (!id_prof || !id_module || !date || !id_niveau || !salle) {
      console.log('Tous les champs sont requis');
      return res.status(400).send('Tous les champs sont requis');
    }
  
    const query = 'INSERT INTO codeqr (id_prof, id_module, date, id_niveau, salle) VALUES (?, ?, ?, ?, ?)';
    const values = [id_prof, id_module, date, id_niveau, salle];
  
    db.query(query, values, (err, result) => {
      if (err) {
        console.error('Erreur lors de l\'insertion dans la base de données :', err);
        return res.status(500).send('Erreur serveur');
      }
  
      console.log('Insertion réussie, ID :', result.insertId);
      res.status(201).send({
        message: 'Code QR inséré avec succès',
        qrId: result.insertId
      });
    });
  });


module.exports = router; 
