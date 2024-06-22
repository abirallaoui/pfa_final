const express=require('express');
const router=express.Router();
var db=require('./db.js');
const connection = require('./db.js');

router.route('/login').post((req, res) => {
  var email = req.body.email;
  var password = req.body.password;
  var deviceId = req.body.deviceId;

  var sql = "SELECT * FROM user WHERE email=? AND password=?";

  if (email != "" && password != "" && deviceId != "") {
    db.query(sql, [email, password], function(err, data, fields) {
      if (err) {
        res.send(JSON.stringify({success: false, message: err}));
      } else {
        if (data.length > 0) {
          const user = data[0];
          if (user.role === 'student') {
            // Vérifier le temps écoulé depuis la dernière déconnexion pour cet appareil
            const checkLogoutSql = "SELECT logout_time FROM logout_timestamps WHERE device_id = ? ORDER BY logout_time DESC LIMIT 1";
            db.query(checkLogoutSql, [deviceId], function(err, logoutData) {
              if (err) {
                res.send(JSON.stringify({success: false, message: err}));
              } else {
                if (logoutData.length > 0) {
                  const logoutTime = new Date(logoutData[0].logout_time);
                  const currentTime = new Date();
                  const timeDiff = (currentTime - logoutTime) / 1000 / 60; // différence en minutes

                  if (timeDiff < 1) {
                    res.send(JSON.stringify({success: false, message: 'Veuillez attendre 10 minutes avant de vous reconnecter sur cet appareil'}));
                  } else {
                    res.send(JSON.stringify({success: true, user: data}));
                  }
                } else {
                  res.send(JSON.stringify({success: true, user: data}));
                }
              }
            });
          } else {
            res.send(JSON.stringify({success: true, user: data}));
          }
        } else {
          res.send(JSON.stringify({success: false, message: 'Email ou mot de passe incorrect'}));
        }
      }
    });
  } else {
    res.send(JSON.stringify({success: false, message: 'Email, mot de passe et ID de l\'appareil sont requis !'}));
  }
});
router.route('/logout').post((req, res) => {
  const userId = req.body.userId;
  const deviceId = req.body.deviceId;
  console.log(`Received logout request for userId: ${userId}, deviceId: ${deviceId}`);

  const sql = "REPLACE INTO logout_timestamps (user_id, device_id, logout_time) VALUES (?, ?, NOW())";
  
  db.query(sql, [userId, deviceId], function(err, result) {
    if (err) {
      console.error(`Error executing query: ${err}`);
      res.send(JSON.stringify({success: false, message: err}));
    } else {
      console.log(`Logout timestamp recorded for userId: ${userId}, deviceId: ${deviceId}`);
      res.send(JSON.stringify({success: true, message: 'Déconnexion enregistrée'}));
    }
  });
});
// Nouvelle route pour vérifier l'association de l'appareil
router.route('/check-device-association').post((req, res) => {
  const userId = req.body.userId;
  const deviceId = req.body.deviceId;

  const sql = "SELECT * FROM user_devices WHERE user_id = ? AND device_id = ?";

  db.query(sql, [userId, deviceId], (err, data) => {
      if (err) {
          res.json({success: false, message: err.message});
      } else {
          res.json({success: true, isAssociated: data.length > 0});
      }
  });
});

// Nouvelle route pour associer un appareil à un compte
router.route('/associate-device').post((req, res) => {
  const userId = req.body.userId;
  const deviceId = req.body.deviceId;

  const sql = "INSERT INTO user_devices (user_id, device_id) VALUES (?, ?)";

  db.query(sql, [userId, deviceId], (err) => {
      if (err) {
          res.json({success: false, message: err.message});
      } else {
          res.json({success: true, message: 'Device associated successfully'});
      }
  });
});

router.route('/niveau').get((req, res) => {

    const sql = "SELECT * FROM niveau";

    db.query(sql, (err, result) => {
      if (err) {
        console.error("Error getting user cards:", err);
        return res.status(500).json({ error: 'Error getting user cards' });
      }

      res.json(result);
    });
});

//
router.post('/addNiveau', (req, res) => {
    var NomNiveau = req.body.NomNiveau;
    var listEtd = req.body.listEtd;


    // Add your logic to insert a new card into the 'cards' table with the user_id as a foreign key
    const sql = 'INSERT INTO niveau (nom,listestudent) VALUES (?,?)';
    db.query(sql, [NomNiveau, listEtd], (err, result) => {
      if (err) {
        console.error(err);
        res.status(500).json({ message: 'Error adding card' });
        return;
      }

      res.status(201).json({ message: 'niveau added successfully', cardId: result.insertId });
    });
  });


 router.delete('/niveau/:niveauId', (req, res) => {

    const niveauId = req.params.niveauId;

    // Delete the card with the given cardId for the user with the given userId
    const sql = 'DELETE FROM niveau WHERE id = ?';

    db.query(sql, [niveauId], (err, result) => {
      if (err) {
        console.error("Error deleting niveau:", err);
        return res.status(500).json({ error: 'Error deleting niveau' });
      }

      if (result.affectedRows > 0) {
        res.json({ success: true, message: 'niveau deleted successfully' });
      } else {
        res.status(404).json({ error: 'niveau not found' });
      }
    });
  });

router.put('/niveau/:niveauId/update',async (req, res) => {
    const niveauId = req.params.niveauId;
    var newNom = req.body.newNom;
    var newListStd = req.body.newListStd;

    // Check if NomNiveau and listEtd are not empty
    // if (!newNom || !newListStd) {
    //     return res.status(400).json({ error: 'newNom and newListStd are required' });
    // }

    const sql = 'UPDATE niveau SET nom = ?, listestudent = ? WHERE id = ?';

    db.query(sql, [newNom, newListStd, niveauId], (err,data,fields) => {
      if (err) {
        console.error("Error updating card name:", err);
        return res.status(500).json({ error: 'Error updating card name' });
      }

      res.status(201).json({ success: true, message: 'Card name updated successfully' });
    });
  });


  router.get('/niveaux', async (req, res) => {
    const sql = 'SELECT nom FROM niveau'; // Sélectionnez tous les niveaux de la table 'niveau'

    db.query(sql, (err, data, fields) => {
        if (err) {
            console.error("Error fetching niveaux:", err);
            return res.status(500).json({ error: 'Error fetching niveaux' });
        }

        res.status(200).json({ niveaux: data }); // Renvoie les niveaux récupérés au format JSON
    });
});


//partie:prof

  
 // Ajout d'un professeur
 router.post('/addProfessor', (req, res) => {
  const { nom, prenom, email, password } = req.body;
  const role = 'prof';

  const userSql = 'INSERT INTO user (nom, prenom, email, password, role) VALUES (?, ?, ?, ?, ?)';
  db.query(userSql, [nom, prenom, email, password, role], (err, userResult) => {
      if (err) {
          console.error(err);
          res.status(500).send('Erreur lors de l\'ajout du professeur');
      } else {
          const userId = userResult.insertId;
          const profSql = 'INSERT INTO prof (id, nom, prenom, email, password) VALUES (?, ?, ?, ?, ?)';
          db.query(profSql, [userId, nom, prenom, email, password], (err, profResult) => {
              if (err) {
                  console.error(err);
                  res.status(500).send('Erreur lors de l\'ajout du professeur');
              } else {
                  res.status(200).send('Professeur ajouté avec succès');
              }
          });
      }
  });
});

// Récupération de tous les professeurs
router.get('/professors', (req, res) => {
  const sql = 'SELECT * FROM prof';
  db.query(sql, (err, result) => {
      if (err) {
          console.error(err);
          res.status(500).send('Erreur lors de la récupération des professeurs');
      } else {
          res.status(200).json(result);
      }
  });
});

// Récupération d'un professeur par son ID
router.get('/professor/:id', (req, res) => {
  const id = req.params.id;
  const sql = 'SELECT * FROM prof WHERE id = ?';
  db.query(sql, [id], (err, result) => {
      if (err) {
          console.error(err);
          res.status(500).send('Erreur lors de la récupération du professeur');
      } else {
          res.status(200).json(result[0]);
      }
  });
});

// Mise à jour d'un professeur
router.put('/updateProfessor/:id', (req, res) => {
  const id = req.params.id;
  const { nom, prenom, email } = req.body;

  // Récupération de l'ancien mot de passe
  const getPasswordSql = 'SELECT password FROM user WHERE id = ?';
  db.query(getPasswordSql, [id], (err, getPasswordResult) => {
      if (err) {
          console.error(err);
          res.status(500).send('Erreur lors de la récupération du mot de passe');
          return;
      }

      // Ancien mot de passe
      const oldPassword = getPasswordResult[0].password;

      // Mise à jour du professeur
      const updateProfSql = 'UPDATE prof SET nom = ?, prenom = ?, email = ? WHERE id = ?';
      db.query(updateProfSql, [nom, prenom, email, id], (err, result) => {
          if (err) {
              console.error(err);
              res.status(500).send('Erreur lors de la mise à jour du professeur');
          } else {
              // Mise à jour de l'utilisateur avec l'ancien mot de passe
              const updateUserSql = 'UPDATE user SET nom = ?, prenom = ?, email = ?, password = ? WHERE id = ?';
              db.query(updateUserSql, [nom, prenom, email, oldPassword, id], (err, userResult) => {
                  if (err) {
                      console.error(err);
                      res.status(500).send('Erreur lors de la mise à jour de l\'utilisateur');
                  } else {
                      res.status(200).send('Professeur mis à jour avec succès');
                  }
              });
          }
      });
  });
});


// Suppression d'un professeur
router.delete('/deleteProfessor/:id', (req, res) => {
  const id = req.params.id;
  const sql = 'DELETE FROM prof WHERE id = ?';
  db.query(sql, [id], (err, result) => {
      if (err) {
          console.error(err);
          res.status(500).send('Erreur lors de la suppression du professeur');
      } else {
          const userSql = 'DELETE FROM user WHERE id = ?';
          db.query(userSql, [id], (err, userResult) => {
              if (err) {
                  console.error(err);
                  res.status(500).send('Erreur lors de la suppression de l\'utilisateur');
              } else {
                  res.status(200).send('Professeur supprimé avec succès');
              }
          });
      }
  });
});







// recuperation des modules :

router.get('/modules/:niveauId', (req, res) => {
    const niveauId = req.params.niveauId;

    // Query the database to retrieve modules for the given niveauId
    const sql = 'SELECT * FROM module WHERE id_niveau = ?';

    db.query(sql, [niveauId], (err, result) => {
        if (err) {
            console.error("Error fetching modules:", err);
            return res.status(500).json({ error: 'Error fetching modules' });
        }

        // Check if modules are found
        if (result.length > 0) {
            res.json(result); // Return the modules found
        } else {
            res.status(404).json({ error: 'Modules not found' });
        }
    });
});



// ajout des modules :
router.post('/ajoutModule', (req, res) => {
    var nomModule = req.body.nomModule;
    var emailProf = req.body.emailProf;
    var salle = req.body.salle ;
   var description = req.body.description ;
    var niveauId = req.body.niveauId;

      // Add your logic to insert a new card into the 'cards' table with the user_id as a foreign key
    const sql = 'INSERT INTO module (nom  , salle , description , email_prof , id_niveau ) VALUES (?,? , ? , ? , ? )';
    db.query(sql, [nomModule,salle,description , emailProf , niveauId ], (err, result) => {
      if (err) {
        console.error(err);
        res.status(500).json({ message: 'Error adding module' });
        return;
      }

      res.status(201).json({ message: 'module added successfully', cardId: result.insertId });
    });
  });



// Définissez la route pour récupérer les adresses e-mail des professeurs et les afficher en drop dow lors de l ajout de module
router.get('/getEmailsProfessors', async (req, res) => {
  try {
    // Récupérez tous les professeurs depuis la base de données
    const professors = await db.query('SELECT email FROM prof'); // Assurez-vous d'attendre la réponse de la requête

    // Vérifiez si des professeurs ont été trouvés
    if (!professors || professors.length === 0) {
      return res.status(404).json({ error: 'Professors emails not found' });
    }

    // Extrayez les adresses e-mail des professeurs
    const professorsEmails = professors.map(professor => professor.email);

    // Renvoyez les adresses e-mail sous forme de réponse JSON
    res.status(200).json(professorsEmails);
  } catch (error) {
    console.error('Error fetching professors emails:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});



// Suppression d'un module
router.delete('/deleteModule/:niveauId/:moduleName', (req, res) => {
    const niveauId = req.params.niveauId;
    const moduleName = req.params.moduleName;
    const query = `DELETE FROM module WHERE id_niveau = ? AND nom = ?`;
    db.query(query, [niveauId, moduleName], (err, result) => {
        if (err) {
            console.error('Erreur lors de la suppression du module :', err);
            res.status(500).send('Erreur lors de la suppression du module.');
            return;
        }
        console.log('Module supprimé avec succès');
        res.status(200).send('Module supprimé avec succès.');
    });
});


    // Route pour récupérer le nom complet du professeur à partir de son email et l afficher dans detail module
    router.get('/professor/:emailProf', (req, res) => {
        const email = req.params.emailProf;
        const query = `SELECT nom FROM prof WHERE email = ?`;
        db.query(query, [email], (error, results) => {
            if (error) {
                res.status(500).json({ error: error.message });
            } else if (results.length > 0) {
                res.json({ fullName: results[0].nom });
            } else {
                res.status(404).json({ error: 'Professor not found' });
            }
        });
    });
//jdiiid
    router.get('/module/:moduleId', (req, res) => {
        const moduleId = req.params.moduleId;
        const query = `
          SELECT p.nom, p.prenom
          FROM module m
          JOIN prof p ON m.email_prof = p.email
          WHERE m.id = ?
        `;
        db.query(query, [moduleId], (error, results) => {
          if (error) {
            res.status(500).json({ error: error.message });
          } else if (results.length > 0) {
            const { nom, prenom } = results[0];
            const fullName = `${prenom} ${nom}`;
            res.json({ fullName });
          } else {
            res.status(404).json({ error: 'Module not found' });
          }
        });
      });
    
    


router.put('/updateModule/:moduleName', (req, res) => {
  const moduleName = req.params.moduleName;
  const { newSalle, newEmailProf, newDescription } = req.body;

  const query = `
    UPDATE module
    SET salle = ?, email_prof = ?, description = ?
    WHERE nom = ?
  `;

  db.query(query, [newSalle, newEmailProf, newDescription, moduleName], (error, results) => {
    if (error) {
      res.status(500).json({ error: error.message });
    } else {
      // Vérifier si la mise à jour a affecté des lignes dans la base de données
      if (results.affectedRows > 0) {
        res.status(200).json({ message: 'Module updated successfully' });
      } else {
        res.status(404).json({ error: 'Module not found' });
      }
    }
  });
});

//hajar prof dashboard

router.route('/cards/:userEmail').get((req, res) => {
  const userEmail = req.params.userEmail;

  const sql = "SELECT * FROM module WHERE email_prof = ?";

  db.query(sql, [userEmail], (err, result) => {
    if (err) {
      console.error("Error getting user cards:", err);
      return res.status(500).json({ error: 'Error getting user cards' });
    }

    res.json(result);
  });
});


//partie nta3 hafsa b student w module f student

router.route('/modules/:userId').get((req, res)=> {
  const userId = req.params.userId;
  console.log('userId :', userId); // Afficher l'ID de l'utilisateur

  const query = "SELECT m.id, m.nom FROM module m INNER JOIN niveau n ON m.id_niveau = n.id INNER JOIN student s ON s.niveau = n.nom WHERE s.id = ?";
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
      res.json(results);
    }
  });
});



//dyal nadia 
router.get('/level/:id', (req, res) => {
  const studentId = req.params.id;
  const query = 'SELECT niveau FROM student WHERE id = ${studentId}';

  db.query(query, (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération du niveau :', err);
      res.status(500).json({ error: 'Erreur lors de la récupération du niveau' });
      return;
    }
    if (results.length === 0) {
      res.status(404).json({ error: 'Étudiant non trouvé' });
      return;
    }

    // Maintenant, nous avons le niveau de l'étudiant dans results[0].niveau
    const niveauEtudiant = results[0].niveau;

    // Requête pour récupérer les modules associés au niveau de l'étudiant
    const moduleQuery = 'SELECT * FROM module WHERE id_niveau IN (SELECT id FROM niveau WHERE nom = ?)';
    db.query(moduleQuery, [niveauEtudiant], (moduleErr, moduleResults) => {
      if (moduleErr) {
        console.error('Erreur lors de la récupération des modules :', moduleErr);
        res.status(500).json({ error: 'Erreur lors de la récupération des modules' });
        return;
      }

      // Création de l'objet JSON contenant à la fois le niveau et les modules associés
      const data = {
        niveau: niveauEtudiant,
        modules: moduleResults
      };

      res.json(data); // Renvoie les données contenant le niveau et les modules associés
    });
  });
});

//rapport semeste hafsa
router.get('/rapports/semestriel', async (req, res) => {
  const { email_prof, id_niveau, id_module, start_date, end_date } = req.query;

  // Vérification que tous les paramètres sont présents
  if (!email_prof || !id_niveau || !id_module || !start_date || !end_date) {
      return res.status(400).json({ error: 'Tous les paramètres sont obligatoires' });
  }

  // Convertir les dates en objets JavaScript Date
  const formattedStartDate = moment(start_date, 'YYYY-MM-DD').toDate();
  const formattedEndDate = moment(end_date, 'YYYY-MM-DD').toDate();

  // Requête SQL pour générer le rapport semestriel
  const sql = `
      SELECT
          e.nom AS etudiant,
          e.prenom,
          m.nom AS module,
          COUNT(s.id) AS total_seances,
          SUM(CASE WHEN s.status = 'present(e)' THEN 1 ELSE 0 END) AS total_presences,
          (SUM(CASE WHEN s.status = 'present(e)' THEN 1 ELSE 0 END) / COUNT(s.id)) * 100 AS attendance_percentage
      FROM codeqr c
      JOIN scanner s ON c.id = s.id_codeqr
      JOIN student e ON s.id_student = e.id
      JOIN module m ON c.id_module = m.id
      WHERE c.email_prof = ? AND c.id_niveau = ? AND c.id_module = ?
            AND DATE(c.date) BETWEEN ? AND ?
      GROUP BY e.nom, e.prenom, m.nom
  `;

  try {
      // Exécution de la requête SQL
      const [rows] = await db.query(sql, [email_prof, id_niveau, id_module, formattedStartDate, formattedEndDate]);

      // Vérification des résultats et envoi de la réponse appropriée
      if (rows.length > 0) {
          res.json({
              professor: email_prof,
              niveau: id_niveau,
              module: id_module,
              start_date: start_date,
              end_date: end_date,
              attendance: rows
          });
      } else {
          res.status(404).json({ error: 'Rapport non trouvé' });
      }
  } catch (err) {
      // Gestion des erreurs
      console.error("Erreur lors du téléchargement du rapport semestriel :", err);
      res.status(500).json({ error: 'Erreur lors du téléchargement du rapport semestriel' });
  }
});



 // Fonction pour récupérer les données des étudiants
//  router.get('/stud', (req, res) => {
//   const { niveau, module, date } = req.query;

//   const query = `
//     SELECT 
//       e.nom AS Lname, 
//       e.prenom AS Fname,
//       CASE
//         WHEN s.id IS NOT NULL THEN 'present(e)'
//         ELSE 'absent(e)'
//       END AS status
//     FROM 
//       student e
//       JOIN niveau n ON e.niveau = n.id
//       JOIN module m ON m.id_niveau = n.id
//       LEFT JOIN codeqr c ON c.id_niveau = n.id AND c.id_module = m.id
//       LEFT JOIN scanner s ON s.id_student = e.id AND s.id_codeqr = c.id
//         AND s.date BETWEEN ? AND DATE_ADD(?, INTERVAL 5 MINUTE)
//     WHERE 
//       n.nom = ? 
//       AND m.nom = ?
//   `;

//   db.query(query, [date, date, niveau, module], (err, results) => {
//     if (err) {
//       console.error('Erreur lors de la récupération des données des étudiants:', err);
//       res.status(500).json({ message: 'Erreur serveur', error: err.message });
//     } else {
//       if (results && results.length > 0) {
//         res.json(results);
//       } else {
//         res.status(404).json({ message: 'Aucun étudiant trouvé pour ce niveau et ce module' });
//       }
//     }
//   });
// });


// // Fonction pour récupérer les données des étudiants
// router.get('/stud', async (req, res) => {
//   const { niveau, module, date } = req.query;

//   const query = `
//   SELECT e.nom AS Lname, e.prenom AS Fname,
//          COALESCE(
//            (SELECT 'present(e)' FROM scanner s
//             JOIN codeqr c ON s.id_codeqr = c.id
//             WHERE s.id_student = e.id
//             AND s.date BETWEEN ? AND DATE_ADD(?, INTERVAL 5 MINUTE)
//             AND c.id_niveau = n.id AND c.id_module = m.id),
//            'absent(e)'
//          ) AS status
//   FROM student e
//   CROSS JOIN (SELECT id, nom FROM niveau WHERE nom = ?) n
//   CROSS JOIN (SELECT id FROM module WHERE nom = ?) m
//   WHERE e.niveau = n.nom
// `;

//   db.query(query, [date, date, niveau, module], (err, results) => {
//     if (err) {
//       console.error('Erreur lors de la récupération des données des étudiants:', err);
//       res.status(500).json({ message: 'Erreur serveur' });
//     } else {
//       if (results && results.length > 0) {
//         res.json(results);
//       } else {
//         res.status(404).json({ message: 'Aucun résultat trouvé' });
//       }
//     }
//   });
// });



router.get('/stud', async (req, res) => {
  const { niveau, module, date } = req.query;

  const query = `
  SELECT e.nom AS Lname, e.prenom AS Fname,
         COALESCE(
           (SELECT 'present(e)' FROM scanner s
            JOIN codeqr c ON s.id_codeqr = c.id
            WHERE s.id_student = e.id
            AND s.date BETWEEN ? AND DATE_ADD(?, INTERVAL 5 MINUTE)
            AND c.id_niveau = n.id AND c.id_module = m.id),
           'absent(e)'
         ) AS status
  FROM student e
  CROSS JOIN (SELECT id, nom FROM niveau WHERE nom = ?) n
  CROSS JOIN (SELECT id FROM module WHERE nom = ?) m
  WHERE e.niveau = n.nom
`;

  db.query(query, [date, date, niveau, module], (err, results) => {
    if (err) {
      console.error('Erreur lors de la récupération des données des étudiants:', err);
      res.status(500).json({ message: 'Erreur serveur' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.status(404).json({ message: 'Aucun résultat trouvé' });
      }
    }
  });
});
//niveau de mod
router.get('/niveauxp/:profEmail', (req, res) => {
         const profEmail = req.params.profEmail;
         console.log('Requête reçue pour profEmail:', profEmail);

         const query = `
           SELECT DISTINCT n.nom
           FROM niveau n
           INNER JOIN module m ON n.id = m.id_niveau
           WHERE m.email_prof = ?
         `;

         db.query(query, [profEmail], (err, results) => {
           if (err) {
             console.error('Erreur lors de la récupération des niveaux du professeur : ', err);
             res.status(500).json({ message: 'Erreur lors de la récupération des niveaux du professeur', error: err.message });
           } else {
             console.log('Résultats de la requête SQL:', results);
             const response = {
               niveaux: results.map(result => {
                 if (typeof result.nom === 'string') {
                   return result.nom;
                 } else {
                   console.error('Le champ nom n\'est pas une chaîne de caractères:', result.nom);
                   // Traitez le cas où le champ nom n'est pas une chaîne de caractères
                   return null; // ou une valeur par défaut appropriée
                 }
               })
             };
             res.json(response);
           }
         });
       });

//module de prof
router.get('/modulep/:profEmail', (req, res) => {
                  const profEmail = req.params.profEmail;
                  console.log('Requête reçue pour profEmail:', profEmail);

                  const query = `
                    SELECT DISTINCT m.nom
                    FROM module m
                    WHERE m.email_prof = ?
                  `;

                  db.query(query, [profEmail], (err, results) => {
                    if (err) {
                      console.error('Erreur lors de la récupération des modules du professeur : ', err);
                      res.status(500).json({ message: 'Erreur lors de la récupération des modules du professeur', error: err.message });
                    } else {
                      console.log('Résultats de la requête SQL:', results);
                      const response = {
                        modules: results.map(result => {
                          if (typeof result.nom === 'string') {
                            return result.nom;
                          } else {
                            console.error('Le champ nom n\'est pas une chaîne de caractères:', result.nom);
                            // Traitez le cas où le champ nom n'est pas une chaîne de caractères
                            return null; // ou une valeur par défaut appropriée
                          }
                        })
                      };
                      res.json(response);
                    }
                  });
                });

//hajar : rapport semeste 
router.get('/report/:niveauName/:moduleName', (req, res) => {
  const { niveauName, moduleName } = req.params;

  // Requête pour obtenir l'ID du niveau à partir du nom
  const getNiveauIdQuery = `
      SELECT id FROM niveau WHERE nom = ?;
  `;

  // Requête pour obtenir l'ID du module à partir du nom
  const getModuleIdQuery = `
      SELECT id FROM module WHERE nom = ?;
  `;

  db.query(getNiveauIdQuery, [niveauName], (err, niveauResult) => {
      if (err) {
          console.error('Error fetching niveau ID:', err);
          return res.status(500).json({ error: err.message });
      }

      const niveauId = niveauResult[0]?.id;
      if (!niveauId) {
          return res.status(404).json({ error: 'Niveau not found' });
      }

      db.query(getModuleIdQuery, [moduleName], (err, moduleResult) => {
          if (err) {
              console.error('Error fetching module ID:', err);
              return res.status(500).json({ error: err.message });
          }

          const moduleId = moduleResult[0]?.id;
          if (!moduleId) {
              return res.status(404).json({ error: 'Module not found' });
          }

          const query = `
              SELECT s.id as student_id, s.nom as student_nom, s.prenom as student_prenom,
                     m.nom as module_nom,
                     COUNT(DISTINCT c.date) as total_classes,
                     COUNT(DISTINCT CASE WHEN sc.statut = 'present(e)' THEN sc.date END) as present_classes,
                     (COUNT(DISTINCT CASE WHEN sc.statut = 'present(e)' THEN sc.date END) / COUNT(DISTINCT c.date)) * 100 as presence_percentage
              FROM student s
              JOIN niveau n ON s.niveau = n.nom
              JOIN module m ON m.id_niveau = n.id
              JOIN codeqr c ON c.id_niveau = n.id AND c.id_module = m.id
              LEFT JOIN scanner sc ON sc.id_codeqr = c.id AND sc.id_student = s.id
              WHERE n.id = ? AND m.id = ?
              GROUP BY s.id, s.nom, s.prenom, m.nom;
          `;

          db.query(query, [niveauId, moduleId], (err, results) => {
              if (err) {
                  console.error('Error executing query:', err);
                  return res.status(500).json({ error: err.message });
              }

              const report = results.map(row => ({
                  student_id: row.student_id,
                  student_nom: row.student_nom,
                  student_prenom: row.student_prenom,
                  module_nom: row.module_nom,
                  total_classes: row.total_classes,
                  present_classes: row.present_classes,
                  presence_percentage: row.presence_percentage || 0
              }));

              res.json({ niveauName, moduleName, report });
          });
      });
  });
});


//code hajar changement de mot de passe apres la premiere connexion 
router.post('/updatepassword', async (req, res) => {
  const { userId, newPassword } = req.body;

  if (!userId || !newPassword) {
    return res.status(400).json({ success: false, message: 'Missing userId or newPassword' });
  }

  try {

      //const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password in 'user' table
    const updateQueryUser = `
      UPDATE user
      SET password = ?,first_login = false
      WHERE id = ?;
    `;
    const updateValuesUser = [newPassword, userId];

    db.query(updateQueryUser, updateValuesUser, (err, results) => {
      if (err) {
        console.error('Error executing query:', err);
        return res.status(500).json({ error: err.message });
      }

      // Check the role of the user
      const roleQuery = `
        SELECT role
        FROM user
        WHERE id = ?;
      `;
      const roleValues = [userId];

      db.query(roleQuery, roleValues, (err, roleResult) => {
        if (err) {
          console.error('Erreur lors de la recherche de l\'ID du user : ', err);
          return res.status(500).json({ message: 'Erreur lors de la recherche de l\'ID du user' });
        }

        if (!roleResult || roleResult.length === 0) {
          return res.status(404).json({ success: false, message: 'User not found' });
        }

        const userRole = roleResult[0].role;
        console.log(userRole);

        // Update password in corresponding table based on user role
        let updateQuery = '';
        const updateValues = [newPassword, userId]; // Common update values

        switch (userRole) {
          case 'prof':
            updateQuery = `
              UPDATE prof
              SET password = ?
              WHERE id = ?;
            `;
            break;
          case 'student':
            updateQuery = `
              UPDATE student
              SET password = ?
              WHERE id = ?;
            `;
            break;
          case 'admin':
            updateQuery = `
              UPDATE admin
              SET password = ?
              WHERE id = ?;
            `;
            break;
          default:
            return res.status(403).json({ success: false, message: 'Unsupported user role' });
        }

        // Perform the update query
        if (updateQuery !== '') {
          db.query(updateQuery, updateValues, (err, results) => {
            if (err) {
              console.error('Error executing query:', err);
              return res.status(500).json({ error: err.message });
            }

            // Select updated user information from the 'user' table
            const selectQuery = `
              SELECT id, email, nom, role
              FROM user
              WHERE id = ?;
            `;
            const selectValues = [userId];

            db.query(selectQuery, selectValues, (err, result) => {
              if (err) {
                console.error('Error executing query:', err);
                return res.status(500).json({ error: err.message });
              }

              if (!result || result.length === 0) {
                return res.status(404).json({ success: false, message: 'User not found' });
              }

              res.json({ success: true, user: result[0] });
            });
          });
        }
      });
    });
  } catch (error) {
    console.error('Error in updatePassword:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});


module.exports =router;