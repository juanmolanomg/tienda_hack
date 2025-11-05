const express = require('express');
const path = require('path');
const mysql = require('mysql2/promise');

const app = express();
const PORT = 4000;

// ----------------- Configuración de motor de vistas ----------------- //
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// ----------------- Archivos estáticos ----------------- //
// Sirve todo lo que está en /css, /imgs y otras carpetas públicas
app.use(express.static(path.join(__dirname, 'public')));
app.use('/imgs', express.static(path.join(__dirname, 'imgs')));
app.use('/css', express.static(path.join(__dirname, 'css')));

// ----------------- Rutas ----------------- //

// Ejemplo de vista secundaria
app.get('/ejemplo', (req, res) => {
  res.render('ejemplo', { title: 'Vista de ejemplo de tienda' });
});
//para cada ejs o archivo crearle una ruta
// Vista principal (inicio)
app.get('/', (req, res) => {
  res.render('inicio_tienda', { title: 'Inicio de la Tienda' });
});

// ----------------- Conexión a MySQL ----------------- //
async function getConnection() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: 'root',
      database: 'votosrafaelpombo', // aquí puedes cambiar por tu BD de tienda
    });
    console.log(' Conectado a la base de datos MySQL');
    return connection;
  } catch (error) {
    console.error(' Error al conectar con MySQL:', error);
  }
}

// ----------------- Servidor ----------------- //
app.listen(PORT, () => {
  console.log(` Servidor corriendo en http://localhost:${PORT}`);
});
