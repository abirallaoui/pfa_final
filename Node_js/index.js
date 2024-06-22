const express = require('express');
const cors = require('cors'); // Importez le middleware CORS
const app = express();


var db = require('./db.js');

const bodyParser = require('body-parser');
// Utilisez express.json() au lieu de body-parser pour le traitement du corps de la demande
app.use(express.json());
app.use(bodyParser.urlencoded({extended:true}));

// Ajoutez le middleware CORS
app.use(cors());



/*const userRouter = require('./user');: Cette ligne importe le module user qui contient les routes pour gérer les requêtes liées aux utilisateurs. Il est supposé que dans le fichier user.js (ou .ts si vous utilisez TypeScript), vous avez défini toutes les routes liées aux utilisateurs.
app.use('/user', userRouter);: Cette ligne indique à l'application Express.js d'utiliser le routeur userRouter pour toutes les requêtes qui commencent par /user. Cela signifie que toutes les routes définies dans userRouter seront disponibles sous le préfixe /user.*/
const userRouter = require('./crud');
// const usersRouter = require('./admin.js');
const profilRouter = require('./profil.js');
const studentRouter = require('./student.js');
const moduleStudent = require('./moduleStudent.js');
const profQR = require('./profQR.js');
const studentQR = require('./studentQR.js');





app.use('/crud', userRouter);
// app.use('/admin', usersRouter);
app.use('/profil', profilRouter);
app.use('/student', studentRouter);
app.use('/moduleStudent', moduleStudent);
app.use('/profQR', profQR);
app.use('/studentQR', studentQR);








app.listen(3000, () => console.log('Your server is running on port 3000'));