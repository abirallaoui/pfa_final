const express=require('express');
const router=express.Router();
var db=require('./db.js');
const connection = require('./db.js');



router.route('/modules/:userId').get((req, res)=> {
    const userId = req.params.userId;
    console.log('userId :', userId); // Afficher l'ID de l'utilisateur
  
    const query = "SELECT m.id, m.nom, m.description, p.nom AS nom_prof FROM module m INNER JOIN niveau n ON m.id_niveau = n.id INNER JOIN student s ON s.niveau = n.nom INNER JOIN prof p ON m.email_prof = p.email WHERE s.id = ?";
    console.log('query :', query); // Afficher la requête SQL
  
    db.query(query, [userId], (err, results) => {
      if (err) {
        console.error('Erreur lors de la récupération des modules :', err);
        res.status(500).json({ error: 'Une erreur est survenue' });
        return;
      }
  
      console.log('results :', results); // Afficher les résultats de la requête
  
      if (results.length === 0) {
        res.status(404).json({ error: 'Modules not found' });
      } else {
        // Envoyer les résultats avec le nom du professeur
        const modulesWithProfNames = results.map(module => ({
          id: module.id,
          nom: module.nom,
          description: module.description,
          nom_prof: module.nom_prof
        }));
        res.json(modulesWithProfNames);
      }
    });
});



router.route('/info/:userId').get((req, res) => {
    const userId = req.params.userId;
    console.log('userId:', userId); // Afficher l'ID de l'utilisateur
  
    const query = "SELECT s.id, s.nom, s.prenom, s.email, s.niveau FROM student s WHERE s.id = ?";
    console.log('query:', query); // Afficher la requête SQL
  
    db.query(query, [userId], (err, results) => {
      if (err) {
        console.error('Erreur lors de la récupération des informations de l\'étudiant:', err);
        res.status(500).json({ error: 'Une erreur est survenue' });
        return;
      }
  
      console.log('results:', results); // Afficher les résultats de la requête
  
      if (results.length === 0) {
        res.status(404).json({ error: 'Étudiant non trouvé' });
      } else {
        const student = results[0];
        res.json({
          id: student.id,
          nom: student.nom,
          prenom: student.prenom,
          email: student.email,
          niveau: student.niveau // Renvoyer également le niveau de l'étudiant
        });
      }
    });
  });
  
  
module.exports =router;