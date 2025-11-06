const express = require('express');
const path = require('path');
const mysql = require('mysql2/promise');
const multer = require('multer');
const csv = require('csv-parser');
const fs = require('fs');
const { title } = require('process');
const bcrypt = require('bcrypt');
const app = express();
const PORT = 4000;

const session = require('express-session');

// Configuración de sesión
app.use(session({
  secret: 'mi_clave_secreta_123', // Cambia esto por una clave segura
  resave: false,                  // No guardar sesión si no ha cambiado
  saveUninitialized: false,       // No guardar sesiones vacías
  cookie: {
    maxAge: 1000 * 60 * 60 * 2,   // 2 horas
    secure: false                  // true si estás en HTTPS
  }
}));

// ----------------- Configuración ----------------- //
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use('/css', express.static(path.join(__dirname, 'css')));
app.use('/imgs', express.static(path.join(__dirname, 'imgs')));

// Configuración de Multer para subida de archivos CSV
const upload = multer({ dest: 'uploads/' });

async function getConnection() {
  return await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'root',
    database: 'retail_ropa'
  });
}

// ----------------- Funciones de cálculo ----------------- //
async function getVentasPorEdad(conn) {
  const [rows] = await conn.query(`
    SELECT
      CASE
        WHEN TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) < 18 THEN 'Menor 18'
        WHEN TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) BETWEEN 18 AND 25 THEN '18-25'
        WHEN TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+' END AS grupo_edad,
      SUM(v.cantidad) AS total_ventas
    FROM venta v
    JOIN cliente c ON v.id_cliente = c.id_cliente
    GROUP BY grupo_edad
  `);
  return rows;
}

async function getVentasPorGenero(conn) {
  const [rows] = await conn.query(`
    SELECT c.genero, SUM(v.cantidad) AS total_ventas
    FROM venta v
    JOIN cliente c ON v.id_cliente = c.id_cliente
    GROUP BY c.genero
  `);
  return rows;
}

async function getRotacionPorTipo(conn) {
  const [rows] = await conn.query(`
    SELECT tr.nombre AS tipo_ropa,
           COALESCE(SUM(v.cantidad)/NULLIF(SUM(p.stock), 0), 0) AS rotacion_promedio
    FROM producto p
    LEFT JOIN venta v ON p.id_producto = v.id_producto
    LEFT JOIN tipo_ropa tr ON p.id_tipo_ropa = tr.id_tipo_ropa
    GROUP BY tr.nombre
  `);
  return rows;
}

async function getRotacionMensual(conn) {
  const [rows] = await conn.query(`
    SELECT DATE_FORMAT(v.fecha, '%Y-%m') AS mes, 
           COALESCE(SUM(v.cantidad)/NULLIF(AVG(p.stock), 0), 0) AS rotacion_mensual
    FROM venta v
    JOIN producto p ON v.id_producto = p.id_producto
    GROUP BY mes
    ORDER BY mes
  `);
  return rows;
}

// Función para obtener recomendaciones automáticas
async function getRecomendaciones(conn) {
  // Productos con baja rotación (candidatos para descuento)
  const [bajaRotacion] = await conn.query(`
    SELECT p.id_producto, p.nombre, tr.nombre AS tipo_ropa, p.stock,
           COALESCE(SUM(v.cantidad), 0) AS total_ventas,
           COALESCE(SUM(v.cantidad)/NULLIF(p.stock, 0), 0) AS rotacion
    FROM producto p
    LEFT JOIN venta v ON p.id_producto = v.id_producto
    LEFT JOIN tipo_ropa tr ON p.id_tipo_ropa = tr.id_tipo_ropa
    GROUP BY p.id_producto
    HAVING rotacion < 0.3 AND p.stock > 10
    ORDER BY rotacion ASC
    LIMIT 10
  `);

  // Productos con alta rotación (necesitan reposición)
  const [altaRotacion] = await conn.query(`
    SELECT p.id_producto, p.nombre, tr.nombre AS tipo_ropa, p.stock,
           COALESCE(SUM(v.cantidad), 0) AS total_ventas,
           COALESCE(SUM(v.cantidad)/NULLIF(p.stock, 0), 0) AS rotacion
    FROM producto p
    LEFT JOIN venta v ON p.id_producto = v.id_producto
    LEFT JOIN tipo_ropa tr ON p.id_tipo_ropa = tr.id_tipo_ropa
    GROUP BY p.id_producto
    HAVING rotacion > 1.5
    ORDER BY rotacion DESC
    LIMIT 10
  `);

  // Productos con stock crítico
  const [stockCritico] = await conn.query(`
    SELECT p.id_producto, p.nombre, tr.nombre AS tipo_ropa, p.stock,
           COALESCE(SUM(v.cantidad), 0) AS total_ventas
    FROM producto p
    LEFT JOIN venta v ON p.id_producto = v.id_producto
    LEFT JOIN tipo_ropa tr ON p.id_tipo_ropa = tr.id_tipo_ropa
    WHERE p.stock <= 5
    GROUP BY p.id_producto
    ORDER BY p.stock ASC
  `);

  return { bajaRotacion, altaRotacion, stockCritico };
}

// Función para obtener ventas por sucursal (simulado)
async function getVentasPorSucursal(conn) {
  // Como no tienes tabla sucursal, simularemos con datos dummy
  // En producción deberías tener una tabla sucursal relacionada
  return [
    { sucursal: 'Bogotá', total: 1250000 },
    { sucursal: 'Medellín', total: 980000 },
    { sucursal: 'Cali', total: 750000 },
    { sucursal: 'Barranquilla', total: 620000 }
  ];
}
app.get('/', async (req, res) => {
  return res.render('inicio_tienda',{title:'inicio de la tienda'})
})

// ----------------- Dashboard Principal ----------------- //
app.get('/dashboard', async (req, res) => {
  try {
    const conn = await getConnection();

    // Top productos con ventas y stock
    const [topProductos] = await conn.query(`
      SELECT p.id_producto, p.nombre, tr.nombre AS tipo_ropa, t.talla,
             COALESCE(SUM(v.cantidad), 0) AS totalVentas,
             p.stock,
             COALESCE(SUM(v.cantidad)/NULLIF(p.stock, 0), 0) AS rotacion
      FROM producto p
      LEFT JOIN venta v ON p.id_producto = v.id_producto
      LEFT JOIN tipo_ropa tr ON p.id_tipo_ropa = tr.id_tipo_ropa
      LEFT JOIN talla t ON p.id_talla = t.id_talla
      GROUP BY p.id_producto
      ORDER BY totalVentas DESC
      LIMIT 10
    `);

    // KPIs mejorados
    const [kpiData] = await conn.query(`
      SELECT 
        COALESCE(SUM(v.cantidad), 0) AS totalProductosVendidos,
        COALESCE(SUM(v.subtotal), 0) AS ventasTotales,
        COUNT(DISTINCT v.id_producto) AS productosActivos
      FROM venta v
    `);

    const [stockData] = await conn.query(`
      SELECT COUNT(*) AS stockCritico
      FROM producto
      WHERE stock <= 5
    `);

    const ventasTotales = kpiData[0].ventasTotales;
    const productosVendidos = kpiData[0].totalProductosVendidos;
    const rotacionPromedio = topProductos.length ? 
      topProductos.reduce((acc,p)=> acc + (p.rotacion||0),0)/topProductos.length : 0;
    const stockCritico = stockData[0].stockCritico;

    // Gráficos
    const [ventasPorCategoria] = await conn.query(`
      SELECT tr.nombre AS tipo_ropa, COALESCE(SUM(v.cantidad), 0) AS total
      FROM tipo_ropa tr
      LEFT JOIN producto p ON tr.id_tipo_ropa = p.id_tipo_ropa
      LEFT JOIN venta v ON p.id_producto = v.id_producto
      GROUP BY tr.nombre
      ORDER BY total DESC
    `);

    const [ventasPorCliente] = await conn.query(`
      SELECT ct.nombre AS cliente_tipo, COALESCE(SUM(v.cantidad), 0) AS total
      FROM cliente_tipo ct
      LEFT JOIN producto p ON ct.id_cliente_tipo = p.id_cliente_tipo
      LEFT JOIN venta v ON p.id_producto = v.id_producto
      GROUP BY ct.nombre
      ORDER BY total DESC
    `);

    const [tallasMasVendidas] = await conn.query(`
      SELECT t.talla, COALESCE(SUM(v.cantidad), 0) AS total
      FROM talla t
      LEFT JOIN producto p ON t.id_talla = p.id_talla
      LEFT JOIN venta v ON p.id_producto = v.id_producto
      GROUP BY t.talla
      ORDER BY total DESC
      LIMIT 10
    `);

    const [tendenciaMensual] = await conn.query(`
      SELECT DATE_FORMAT(fecha,'%Y-%m') AS mes, SUM(subtotal) AS total
      FROM venta
      GROUP BY mes
      ORDER BY mes
    `);

    // Datos adicionales
    const ventasPorEdad = await getVentasPorEdad(conn);
    const ventasPorGenero = await getVentasPorGenero(conn);
    const rotacionPorTipo = await getRotacionPorTipo(conn);
    const rotacionMensual = await getRotacionMensual(conn);
    const recomendaciones = await getRecomendaciones(conn);
    const ventasPorSucursal = await getVentasPorSucursal(conn);

    await conn.end();

    res.render('dashboard', {
      title: 'Dashboard Retail Moda',
      kpis: { ventasTotales, productosVendidos, rotacionPromedio, stockCritico },
      topProductos,
      ventasPorCategoria,
      ventasPorCliente,
      tallasMasVendidas,
      tendenciaMensual,
      ventasPorEdad,
      ventasPorGenero,
      rotacionPorTipo,
      rotacionMensual,
      recomendaciones,
      ventasPorSucursal
    });
  } catch (error) {
    console.error('Error en dashboard:', error);
    res.status(500).send('Error al cargar el dashboard');
  }
});

// ----------------- Cargar CSV ----------------- //
app.post('/cargar-csv', upload.single('csvfile'), async (req, res) => {
  if (!req.file) {
    return res.status(400).send('No se subió ningún archivo');
  }

  const conn = await getConnection();
  const results = [];
  let errores = 0;
  let insertados = 0;

  fs.createReadStream(req.file.path)
    .pipe(csv())
    .on('data', (data) => results.push(data))
    .on('end', async () => {
      try {
        for (const row of results) {
          // Esperamos columnas: id_producto, cantidad, subtotal, fecha (opcional)
          const { id_producto, cantidad, subtotal, fecha } = row;

          if (!id_producto || !cantidad || !subtotal) {
            errores++;
            continue;
          }

          const fechaVenta = fecha || new Date().toISOString().slice(0, 10);

          await conn.query(
            'INSERT INTO venta (id_producto, cantidad, subtotal, fecha) VALUES (?, ?, ?, ?)',
            [id_producto, cantidad, subtotal, fechaVenta]
          );
          insertados++;
        }

        await conn.end();
        fs.unlinkSync(req.file.path); // Eliminar archivo temporal

        res.send(`
          <html>
            <head><title>Carga completada</title></head>
            <body style="font-family:Arial; padding:40px; text-align:center;">
              <h2> Carga de CSV completada</h2>
              <p><strong>${insertados}</strong> registros insertados</p>
              <p><strong>${errores}</strong> errores encontrados</p>
              <a href="/" style="display:inline-block; margin-top:20px; padding:10px 20px; background:#1f6feb; color:white; text-decoration:none; border-radius:5px;">Volver al Dashboard</a>
            </body>
          </html>
        `);
      } catch (error) {
        console.error('Error procesando CSV:', error);
        res.status(500).send('Error al procesar el archivo CSV');
      }
    });
});

// ----------------- API REST para consultas dinámicas ----------------- //

// Endpoint: Productos más vendidos por mes
app.get('/api/ventas-mes/:mes', async (req, res) => {
  try {
    const conn = await getConnection();
    const { mes } = req.params; // Formato: YYYY-MM

    const [productos] = await conn.query(`
      SELECT p.nombre, tr.nombre AS categoria, SUM(v.cantidad) AS total
      FROM venta v
      JOIN producto p ON v.id_producto = p.id_producto
      JOIN tipo_ropa tr ON p.id_tipo_ropa = tr.id_tipo_ropa
      WHERE DATE_FORMAT(v.fecha, '%Y-%m') = ?
      GROUP BY p.id_producto
      ORDER BY total DESC
      LIMIT 10
    `, [mes]);

    await conn.end();
    res.json(productos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint: Stock bajo (productos críticos)
app.get('/api/stock-critico', async (req, res) => {
  try {
    const conn = await getConnection();

    const [productos] = await conn.query(`
      SELECT p.id_producto, p.nombre, tr.nombre AS categoria, p.stock, t.talla
      FROM producto p
      JOIN tipo_ropa tr ON p.id_tipo_ropa = tr.id_tipo_ropa
      JOIN talla t ON p.id_talla = t.id_talla
      WHERE p.stock <= 5
      ORDER BY p.stock ASC
    `);

    await conn.end();
    res.json(productos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Endpoint: Comparativo por género
app.get('/api/comparativo-genero', async (req, res) => {
  try {
    const conn = await getConnection();

    const [datos] = await conn.query(`
      SELECT c.genero, tr.nombre AS categoria, SUM(v.cantidad) AS total
      FROM venta v
      JOIN cliente c ON v.id_cliente = c.id_cliente
      JOIN producto p ON v.id_producto = p.id_producto
      JOIN tipo_ropa tr ON p.id_tipo_ropa = tr.id_tipo_ropa
      GROUP BY c.genero, tr.nombre
      ORDER BY total DESC
    `);

    await conn.end();
    res.json(datos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ----------------- Página de Recomendaciones ----------------- //
app.get('/recomendaciones', async (req, res) => {
  try {
    const conn = await getConnection();
    const recomendaciones = await getRecomendaciones(conn);
    await conn.end();

    res.render('recomendaciones', {
      title: 'Recomendaciones Inteligentes',
      ...recomendaciones
    });
  } catch (error) {
    console.error('Error en recomendaciones:', error);
    res.status(500).send('Error al cargar recomendaciones');
  }
});

// ----------------- Servidor ----------------- //
app.listen(PORT, () => {
  console.log(` Servidor corriendo en http://localhost:${PORT}`);
  console.log(` Dashboard: http://localhost:${PORT}/dashboard`);
  console.log(` Recomendaciones: http://localhost:${PORT}/recomendaciones`);
});