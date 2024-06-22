const express=require('express');
const router=express.Router();
var db=require('./db.js');

router.put('/:userId/update', (req, res) => {
  const userId = req.params.userId;
  const nom = req.body.nom;
  const prenom = req.body.prenom;
  const email = req.body.email;
  const password = req.body.password;

  // Mettre à jour les données de l'utilisateur dans la table user
  const updateUserSql = `
    UPDATE user
    SET nom = ?, prenom = ?, email = ?, password = ?
    WHERE id = ?
  `;

  db.query(updateUserSql, [nom, prenom, email, password, userId], (err, userResult) => {
      if (err) {
          console.error("Error updating user:", err);
          return res.status(500).json({ error: 'Error updating user' });
      }

      console.log(`${userResult.affectedRows} record(s) updated in user table`);

      // Mettre à jour les informations spécifiques à chaque rôle
      updateRoleData();
  });

  function updateRoleData() {
      // Récupérer le rôle de l'utilisateur
      const roleSql = `
        SELECT role
        FROM user
        WHERE id = ?
      `;

      db.query(roleSql, [userId], (err, roleResult) => {
          if (err) {
              console.error("Error fetching user role:", err);
              return res.status(500).json({ error: 'Error fetching user role' });
          }

          // Vérifier le rôle de l'utilisateur
          const role = roleResult[0].role;

          // Mettre à jour les données spécifiques au rôle dans la table correspondante
          switch (role) {
              case 'admin':
                  updateAdmin();
                  break;
              case 'prof':
                  updateProf();
                  break;
              case 'student':
                  updateStudent();
                  break;
              default:
                  res.status(500).json({ error: 'Invalid user role' });
          }
      });
  }

  function updateAdmin() {
      const adminSql = `
        UPDATE admin
        SET nom = ?, prenom = ?, email = ?, password = ?
        WHERE id = ?
      `;
    
      db.query(adminSql, [nom, prenom, email, password, userId], (err, adminResult) => {
          handleResponse(err, adminResult);
      });
  }

  function updateProf() {
      const profSql = `
        UPDATE prof
        SET nom = ?, prenom = ?, email = ?, password = ?
        WHERE id = ?
      `;
    
      db.query(profSql, [nom, prenom, email, password, userId], (err, profResult) => {
          handleResponse(err, profResult);
      });
  }

  function updateStudent() {
      const studentSql = `
        UPDATE student
        SET nom = ?, prenom = ?, email = ?, password = ?
        WHERE id = ?
      `;
    
      db.query(studentSql, [nom, prenom, email, password, userId], (err, studentResult) => {
          handleResponse(err, studentResult);
      });
  }

  function handleResponse(err, result) {
      if (err) {
          console.error("Error updating user role data:", err);
          return res.status(500).json({ error: 'Error updating user role data' });
      }
      console.log(`${result.affectedRows} record(s) updated in role table`);
      res.status(200).json({ success: true, message: `${result.affectedRows} record(s) updated in role table` });
  }
});






  module.exports = router; 
