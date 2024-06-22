const express=require('express');
const router=express.Router();
var db=require('./db.js');



// Insertion dans la table scanner
// router.post('/insertscanQR', (req, res) => {
//     const { id_student, id_codeqr, statut, date } = req.body;
  
//     console.log('Données de scanner reçues :', req.body);
  
//     if (!id_student || !id_codeqr || !statut || !date) {
//       console.log('Tous les champs sont requis');
//       return res.status(400).send('Tous les champs sont requis');
//     }
  
//     const query = 'INSERT INTO scanner (id_student, id_codeqr, statut, date) VALUES (?, ?, ?, ?)';
//     const values = [id_student, id_codeqr, statut, date];
  
//     db.query(query, values, (err, result) => {
//       if (err) {
//         console.error('Erreur lors de l\'insertion DE SCAN dans la base de données :', err);
//         return res.status(500).send('Erreur serveur');
//       }
  
//       console.log('Insertion DE SCCAN réussie, ID :', result.insertId);
//       res.status(201).send({
//         message: 'Scan inséré avec succès',
//         scanId: result.insertId
//       });
//     });
//   });


// router.post('/scanner', (req, res) => {
//     const { id_student, id_codeqr, statut, date } = req.body;
//     const query = 'INSERT INTO scanner (id_student, id_codeqr, statut, date) VALUES (?, ?, ?, ?)';
//     db.query(query, [id_student, id_codeqr, statut, date], (err, result) => {
//       if (err) {
//         console.error('Error inserting data: ', err);
//         res.status(500).send('Failed to store QR code');
//       } else {
//         res.status(200).send('QR code stored successfully');
//       }
//     });
//   });
  

// router.post('/scanner', (req, res) => {
//     const { id_student, codeqr_details, statut, date } = req.body;
  
//     // Extract id_codeqr from codeqr_details
//     const queryCodeqr = 'SELECT id FROM codeqr WHERE CONCAT("Module: ", id_module, "\\nNiveau: ", id_niveau, "\\nSalle: ", salle, "\\nDate et heure: ", date) = ?';
    
//     db.query(queryCodeqr, [codeqr_details], (err, results) => {
//       if (err) {
//         console.error('Error checking codeqr: ', err);
//         return res.status(500).send('Failed to check QR code');
//       }
  
//       if (results.length === 0) {
//         return res.status(400).send('QR code does not exist');
//       }
  
//       const id_codeqr = results[0].id;
  
//       // Insert into scanner
//       const query = 'INSERT INTO scanner (id_student, id_codeqr, statut, date) VALUES (?, ?, ?, ?)';
//       db.query(query, [id_student, id_codeqr, statut, date], (err, result) => {
//         if (err) {
//           console.error('Error inserting data: ', err);
//           return res.status(500).send('Failed to store QR code');
//         }
//         res.status(200).send('QR code stored successfully');
//       });
//     });
//   });

// router.post('/scanner', (req, res) => {
//     const { id_student, codeqr_details, statut, date } = req.body;

//     // Vérifier si les données nécessaires sont présentes
//     if (!id_student || !codeqr_details || !statut || !date) {
//         res.status(400).send('Toutes les données requises ne sont pas fournies');
//         return;
//     }

//     // Extraire les informations du code QR scanné
//     const detailsRegex = /Module:\s*(\w+)\s*Niveau:\s*(\w+)\s*Salle:\s*(\w+)\s*Date et heure:\s*(.*)/;
//     const match = codeqr_details.match(detailsRegex);

//     if (!match) {
//         res.status(400).send('Format de code QR invalide');
//         return;
//     }

//     const module = match[1];
//     const niveau = match[2];
//     const salle = match[3];
//     const dateHeure = match[4];

//     // Requête SQL pour trouver le code QR correspondant
//     const query = `SELECT id FROM codeqr WHERE id_module = ? AND id_niveau = ? AND salle = ? AND date = ?`;

//     db.query(query, [module, niveau, salle, dateHeure], (err, results) => {
//         if (err) {
//             console.error('Erreur lors de la récupération des détails du code QR:', err);
//             res.status(500).send('Erreur serveur');
//             return;
//         }

//         if (results.length > 0) {
//             const id_codeqr = results[0].id;

//             // Insérer les détails dans la table scanner
//             const insertQuery = `INSERT INTO scanner (id_student, id_codeqr, statut, date) VALUES (?, ?, ?, ?)`;

//             db.query(insertQuery, [id_student, id_codeqr, statut, date], (err, result) => {
//                 if (err) {
//                     console.error('Erreur lors de l\'insertion dans la table scanner:', err);
//                     res.status(500).send('Erreur serveur');
//                     return;
//                 }

//                 res.status(200).send('Détails du QR Code stockés avec succès');
//             });
//         } else {
//             res.status(404).send('Détails du QR Code non trouvés');
//         }
//     });
// });

// Route pour recevoir les données scannées KHDAM M3A LI KHDAM F BLOCNOTES
router.post('/scanner', (req, res) => {
  const { scannedCode, userId } = req.body;

  // Décomposer le code QR scanné en ses différentes parties
  const [idModule, idNiveau, salle, date] = scannedCode.split('|');

  // Récupérer l'id du codeqr correspondant au code scanné
  const query = 'SELECT id FROM codeqr WHERE id_module = ? AND id_niveau = ? AND salle = ? AND date = ?';
  db.query(query, [idModule, idNiveau, salle, date], (err, results) => {
    if (err) {
      console.error('Erreur lors de la requête SELECT:', err);
      return res.status(500).send('Erreur du serveur');
    }

    if (results.length > 0) {
      const codeqrId = results[0].id;

      // Vérifier si l'entrée existe déjà dans la table scanner
      const checkQuery = 'SELECT * FROM scanner WHERE id_student = ? AND id_codeqr = ?';
      db.query(checkQuery, [userId, codeqrId], (err, checkResults) => {
        if (err) {
          console.error('Erreur lors de la requête de vérification:', err);
          return res.status(500).send('Erreur du serveur');
        }

        if (checkResults.length > 0) {
          console.log('L\'entrée existe déjà.');
          return res.status(409).send('Duplication détectée'); // 409 Conflict
        } else {
          // Insérer les données dans la table scanner
          const insertQuery = 'INSERT INTO scanner (id_student, id_codeqr, statut, date) VALUES (?, ?, ?, NOW())';
          db.query(insertQuery, [userId, codeqrId, 'present(e)'], (err, insertResults) => {
            if (err) {
              console.error('Erreur lors de l\'insertion:', err);
              return res.status(500).send('Erreur du serveur');
            }

            res.sendStatus(200);
          });
        }
      });
    } else {
      res.sendStatus(404); // Code QR non trouvé dans la base de données
    }
  });
});

  
// router.post('/scanner', (req, res) => {
//   const { scannedCode, userId } = req.body;

//   // Vérifier si scannedCode est défini et est une chaîne de caractères
//   if (!scannedCode || typeof scannedCode !== 'string') {
//     return res.status(400).json({ error: 'Code QR invalide ou manquant' });
//   }

//   try {
//     // Décomposer le code QR scanné en ses différentes parties
//     const [idModule, idNiveau, salle, date] = scannedCode.split('|');

//     // Récupérer l'id du codeqr correspondant au code scanné
//     const query = 'SELECT id FROM codeqr WHERE id_module = ? AND id_niveau = ? AND salle = ? AND date = ?';
//     db.query(query, [idModule, idNiveau, salle, date], (err, results) => {
//       if (err) throw err;

//       if (results.length > 0) {
//         const codeqrId = results[0].id;

//         // Insérer les données dans la table scanner
//         const insertQuery = 'INSERT INTO scanner (id_student, id_codeqr, statut, date) VALUES (?, ?, ?, NOW())';
//         db.query(insertQuery, [userId, codeqrId, 'present(e)'], (err, results) => {
//           if (err) throw err;
//           res.sendStatus(200);
//         });
//       } else {
//         res.status(404).json({ error: 'Code QR non trouvé dans la base de données' });
//       }
//     });
//   } catch (err) {
//     console.error('Erreur lors du traitement du code QR :', err);
//     res.status(500).json({ error: 'Une erreur est survenue lors du traitement du code QR' });
//   }
// });
  

module.exports = router; 
