const express=require('express');
const router=express.Router();
var db=require('./db.js');


//lajout dun etudiant
router.post('/addStudent', (req, res) => {
    const { nom, prenom, email, password,niveau } = req.body;
    const role = 'student';
  
    const userSql = 'INSERT INTO user (nom, prenom, email, password, role) VALUES (?, ?, ?, ?, ?)';
    db.query(userSql, [nom, prenom, email, password, role], (err, userResult) => {
        if (err) {
            console.error(err);
            res.status(500).send('Erreur lors de l\'ajout de l\'étudiant');
        } else {
            const userId = userResult.insertId;
            const studentSql = 'INSERT INTO student (id, nom, prenom, email, password,niveau) VALUES (?, ?, ?, ?, ?,?)';
            db.query(studentSql, [userId, nom, prenom, email, password,niveau], (err, studentResult) => {
                if (err) {
                    console.error(err);
                    res.status(500).send('Erreur lors de l\'ajout de l\'étudiant');
                } else {
                    res.status(200).send('Étudiant ajouté avec succès');
                }
            });
        }
    });
  });

// router.post('/etudiants', (req, res) => {
//     const students = req.body;
//     let responseSent = false; // Variable pour suivre si une réponse a déjà été envoyée

//     // Commencer une transaction
//     db.beginTransaction(function(err) {
//         if (err) { 
//             console.error('Error beginning transaction: ', err);
//             sendErrorResponse(res, 500, 'Failed to add students to the database.');
//             return;
//         }

//         // Insérer chaque étudiant individuellement
//         students.forEach(student => {
//             const { nom, prenom, email, password, niveau } = student;
//             const role = 'student';

//             // Insérer dans la table "user"
//             const userSql = 'INSERT INTO user (nom, prenom, email, password, role) VALUES (?, ?, ?, ?, ?)';
//             db.query(userSql, [nom, prenom, email, password, role], (err, userResult) => {
//                 if (err) { 
//                     console.error('Error inserting user: ', err);
//                     rollbackAndSendErrorResponse(res, 'Failed to add students to the database.');
//                     return;
//                 }

//                 // Récupérer l'ID inséré dans la table "user"
//                 const userId = userResult.insertId;

//                 // Insérer dans la table "student" en utilisant l'ID de la table "user"
//                 const studentSql = 'INSERT INTO student (id, nom, prenom, email, password, niveau) VALUES (?, ?, ?, ?, ?, ?)';
//                 db.query(studentSql, [userId, nom, prenom, email, password, niveau], (err, studentResult) => {
//                     if (err) { 
//                         console.error('Error inserting student: ', err);
//                         rollbackAndSendErrorResponse(res, 'Failed to add students to the database.');
//                         return;
//                     }
//                 });
//             });
//         });

//         // Commit de la transaction
//         db.commit(function(err) {
//             if (err) { 
//                 console.error('Error committing transaction: ', err);
//                 rollbackAndSendErrorResponse(res, 'Failed to add students to the database.');
//                 return;
//             }

//             console.log('Students added successfully.');
//             sendSuccessResponse(res, 'Students added successfully.');
//         });
//     });

//     // Fonction pour envoyer une réponse d'erreur et annuler la transaction
//     function rollbackAndSendErrorResponse(res, message) {
//         if (!responseSent) {
//             responseSent = true;
//             db.rollback(() => {
//                 sendErrorResponse(res, 500, message);
//             });
//         }
//     }

//     // Fonction pour envoyer une réponse d'erreur
//     function sendErrorResponse(res, statusCode, message) {
//         if (!responseSent) {
//             responseSent = true;
//             res.status(statusCode).send(message);
//         }
//     }

//     // Fonction pour envoyer une réponse de succès
//     function sendSuccessResponse(res, message) {
//         if (!responseSent) {
//             responseSent = true;
//             res.status(200).send(message);
//         }
//     }
// });

router.post('/etudiants', (req, res) => {
    const students = req.body;

    // Récupérer tous les niveaux existants à partir de la table "niveau"
    const query = 'SELECT nom FROM niveau';
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching levels: ', err);
            res.status(500).send('Failed to add students to the database.');
            return;
        }

        // Extraire les niveaux existants dans un tableau
        const existingLevels = results.map(row => row.nom);

        // Stocker les étudiants invalides
        const invalidStudents = [];

        // Vérifier chaque étudiant
        students.forEach(student => {
            if (!existingLevels.includes(student.niveau)) {
                // Si le niveau de l'étudiant n'existe pas dans la liste des niveaux existants,
                // stockez cet étudiant dans la liste des étudiants invalides
                invalidStudents.push(student);
            }
        });

        if (invalidStudents.length > 0) {
            // Si des étudiants ont des niveaux invalides, renvoyer un message d'erreur avec la liste des étudiants invalides
            const invalidStudentNames = invalidStudents.map(student => `${student.nom} ${student.prenom}`).join(', ');
            res.status(400).json({ message: `Invalid levels for students`, invalidStudents });

            // res.status(400).send(`Invalid levels for students: ${invalidStudentNames}`);
            return;
        }

        // Commencer une transaction
        db.beginTransaction(function(err) {
            if (err) { 
                console.error('Error beginning transaction: ', err);
                res.status(500).send('Failed to add students to the database.');
                return;
            }

            // Insérer chaque étudiant individuellement
            students.forEach(student => {
                const { nom, prenom, email, password, niveau } = student;
                const role = 'student';

                // Insérer dans la table "user"
                const userSql = 'INSERT INTO user (nom, prenom, email, password, role) VALUES (?, ?, ?, ?, ?)';
                db.query(userSql, [nom, prenom, email, password, role], (err, userResult) => {
                    if (err) { 
                        console.error('Error inserting user: ', err);
                        return db.rollback(() => {
                            res.status(500).send('Failed to add students to the database.');
                        });
                    }

                    // Récupérer l'ID inséré dans la table "user"
                    const userId = userResult.insertId;

                    // Insérer dans la table "student" en utilisant l'ID inséré dans la table "user"
                    const studentSql = 'INSERT INTO student (id, nom, prenom, email, password, niveau) VALUES (?, ?, ?, ?, ?, ?)';
                    db.query(studentSql, [userId, nom, prenom, email, password, niveau], (err, studentResult) => {
                        if (err) { 
                            console.error('Error inserting student: ', err);
                            return db.rollback(() => {
                                res.status(500).send('Failed to add students to the database.');
                            });
                        }
                    });
                });
            });

            // Commit de la transaction
            db.commit(function(err) {
                if (err) { 
                    console.error('Error committing transaction: ', err);
                    return db.rollback(() => {
                        res.status(500).send('Failed to add students to the database.');
                    });
                }

                console.log('Students added successfully.');
                res.status(200).send('Students added successfully.');
            });
        });
    });
});

  
  
  // Récupération de tous les students

  router.get('/students', (req, res) => {
    const sql = 'SELECT * FROM student';
    db.query(sql, (err, result) => {
        if (err) {
            console.error(err);
            res.status(500).send('Erreur lors de la récupération des students');
        } else {
            res.status(200).json(result);
        }
    });
  });  

  // Mise à jour d'un étudiant
    router.put('/updateStudent/:id', (req, res) => {
        const id = req.params.id;
        const { nom, prenom, email,niveau } = req.body;
    
        // Mise à jour de l'étudiant
        const updateStudentSql = 'UPDATE student SET nom = ?, prenom = ?, email = ?,niveau = ? WHERE id = ?';
        db.query(updateStudentSql, [nom, prenom, email, niveau,id], (err, studentResult) => {
        if (err) {
            console.error(err);
            res.status(500).send('Erreur lors de la mise à jour de l\'étudiant');
        } else {
            // Mise à jour de l'utilisateur
            const updateUserSql = 'UPDATE user SET nom = ?, prenom = ?, email = ? WHERE id = ?';
            db.query(updateUserSql, [nom, prenom, email, id], (err, userResult) => {
            if (err) {
                console.error(err);
                res.status(500).send('Erreur lors de la mise à jour de l\'utilisateur');
            } else {
                res.status(200).send('Étudiant mis à jour avec succès');
            }
            });
        }
        });
    });


    // Suppression d'un student
    router.delete('/deleteStudent/:id', (req, res) => {
        const id = req.params.id;
        const sql = 'DELETE FROM student WHERE id = ?';
        db.query(sql, [id], (err, result) => {
            if (err) {
                console.error(err);
                res.status(500).send('Erreur lors de la suppression du student');
            } else {
                const userSql = 'DELETE FROM user WHERE id = ?';
                db.query(userSql, [id], (err, userResult) => {
                    if (err) {
                        console.error(err);
                        res.status(500).send('Erreur lors de la suppression de l\'utilisateur');
                    } else {
                        res.status(200).send('student supprimé avec succès');
                    }
                });
            }
        });
    });
  





module.exports =router;