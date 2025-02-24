const express = require('express');
const { Pool } = require('pg');

// Configuración de la conexión a PostgreSQL
const pool = new Pool({
    user: 'vimaz',               // Cambia según tu usuario
    host: 'localhost',           // Cambia según la configuración de tu contenedor
    database: 'vimazdb',        // Cambia según tu base de datos
    password: '8825',           // Cambia según tu contraseña
    port: 5432,                  // Puerto de PostgreSQL
});

const app = express();
const PORT = process.env.PORT || 3000;

// Endpoint inicial para verificar la conexión
app.get('/', async (req, res) => {
    try {
        const result = await pool.query('SELECT NOW() AS current_time');
        res.status(200).json({
            message: 'Conexión exitosa a PostgreSQL',
            currentTime: result.rows[0].current_time,
        });
    } catch (err) {
        console.error('Error de conexión:', err);
        res.status(500).json({ error: 'Error de conexión a la base de datos' });
    }
});

// Iniciar el servidor
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
