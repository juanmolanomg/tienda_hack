const express = require('express');
const path = require('path');
const mysql = require('mysql2/promise');
const multer = require('multer');
const session = require('express-session');
const crypto = require('crypto');
const XLSX = require('xlsx');
const fs = require("fs");
const app = express();
const PORT = 4000;


// ----------------- carpetas ----------------- //
app.set('view engine', 'ejs');
app.use('/imgs', express.static(path.join(__dirname, 'imgs')));
app.set('views', path.join(__dirname, 'views'));

//------------------Vistas ---------------------//
app.get('/ejemplo', (req, res) => res.render('ejemplo', { title: 'es un ejemplo' }));


// ----------------- CONEXIÓN MYSQL ----------------- //
async function getConnection() {
    return await mysql.createConnection({
        host: 'localhost',
        user: 'root',
        password: 'root',
        database: 'votosrafaelpombo'
    });
}

app.listen(PORT, () => console.log(`Servidor corriendo en http://localhost:${PORT}`));
